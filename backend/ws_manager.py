"""
ws_manager.py — SSE-based session manager (replaces WebSocket version)

Each connected client has an asyncio.Queue.
The SSE endpoint drains its queue and streams events to the browser/app.
Client→server actions arrive as plain HTTP POST requests.
"""

import asyncio
from typing import Dict, Any, Optional, Set

# ─────────────────────────────────────────────────────────────────
# Global in-memory session state (lives as long as the server does)
#
# Structure:
# SESSION_STATE = {
#   session_id: {
#     "connections": { participant_id: asyncio.Queue, ... },
#     "participants": {
#        participant_id: {
#           "user_id": int,
#           "name": str,
#           "is_muted": bool,
#           "raised_hand": bool,
#           "is_teacher": bool,   ← NEW: needed so Flutter renders role correctly
#        }, ...
#     },
#     "playback": {
#        "audio_id": int|None, "status": "stopped"|"playing"|"paused",
#        "speed": float, "position": float, "title": str|None
#     }
#   }
# }
# ─────────────────────────────────────────────────────────────────

SESSION_STATE: Dict[int, Dict[str, Any]] = {}
SESSION_LOCK = asyncio.Lock()


class WebSocketManager:
    """
    Name kept so existing imports in main.py don't need changing.
    Internally uses asyncio.Queue instead of WebSocket objects.
    """

    def __init__(self):
        # session_id → { participant_id → asyncio.Queue }
        self.active: Dict[int, Dict[int, asyncio.Queue]] = {}

    # ── connection lifecycle ──────────────────────────────────────────────

    async def connect(
        self,
        session_id: int,
        participant_id: int,
        user_id: int,
        name: str,
        is_teacher: bool,
    ) -> asyncio.Queue:
        """
        Register a new SSE client.
        Returns the Queue the SSE generator should read from.

        Stores is_teacher in SESSION_STATE so the initial session_state
        snapshot sent to latecomers includes accurate role info.
        """
        q: asyncio.Queue = asyncio.Queue(maxsize=256)

        async with SESSION_LOCK:
            self.active.setdefault(session_id, {})[participant_id] = q

            s = SESSION_STATE.setdefault(
                session_id,
                {
                    "connections": {},
                    "participants": {},
                    "playback": {
                        "audio_id": None,
                        "status": "stopped",
                        "speed": 1.0,
                        "position": 0.0,
                        "title": None,
                    },
                },
            )

            s["connections"][participant_id] = q

            # setdefault preserves existing metadata on reconnect;
            # we update name/is_teacher each time (they don't change).
            existing = s["participants"].get(participant_id, {})
            s["participants"][participant_id] = {
                "user_id":    user_id,
                "name":       name,
                "is_muted":   existing.get("is_muted", False),
                "raised_hand": existing.get("raised_hand", False),
                "is_teacher": is_teacher,
            }

        print(f"[SSE MGR] Connected  session={session_id} participant={participant_id} "
              f"name={name!r} teacher={is_teacher}")
        return q

    async def disconnect(self, session_id: int, participant_id: int):
        """Soft disconnect — removes queue but keeps participant metadata."""
        async with SESSION_LOCK:
            self.active.get(session_id, {}).pop(participant_id, None)
            if session_id in SESSION_STATE:
                SESSION_STATE[session_id]["connections"].pop(participant_id, None)

        print(f"[SSE MGR] Disconnected session={session_id} participant={participant_id}")

    # ── sending helpers ───────────────────────────────────────────────────

    async def send_personal(self, queue: asyncio.Queue, message: dict):
        """Push one message onto a specific client's queue."""
        try:
            queue.put_nowait(message)
        except asyncio.QueueFull:
            print("[SSE MGR] Queue full — dropping personal message")

    async def broadcast(
        self,
        session_id: int,
        message: dict,
        exclude: Optional[Set[int]] = None,
    ):
        """Push a message to every connected client in a session."""
        exclude = exclude or set()
        conns = list(self.active.get(session_id, {}).items())

        if not conns:
            print(f"[SSE MGR] No connections for session {session_id} "
                  f"(type={message.get('type')})")
            return

        print(f"[SSE MGR] Broadcast session={session_id} "
              f"type={message.get('type')} excluding={exclude}")

        for pid, q in conns:
            if pid in exclude:
                continue
            try:
                q.put_nowait(message)
            except asyncio.QueueFull:
                print(f"[SSE MGR] Queue full for participant {pid}")

    async def close_session(self, session_id: int):
        """Send session_ended to all clients, then wipe state."""
        async with SESSION_LOCK:
            conns = list(self.active.get(session_id, {}).items())

            for _, q in conns:
                try:
                    q.put_nowait({"type": "session_ended"})
                    q.put_nowait(None)   # None = sentinel → SSE generator exits
                except asyncio.QueueFull:
                    pass

            self.active.pop(session_id, None)
            SESSION_STATE.pop(session_id, None)

        print(f"[SSE MGR] Session {session_id} closed")

    # ── participant actions ───────────────────────────────────────────────

    async def mute_participant(self, session_id: int, participant_id: int, mute: bool):
        async with SESSION_LOCK:
            if session_id not in SESSION_STATE:
                return
            SESSION_STATE[session_id]["participants"] \
                .setdefault(participant_id, {})["is_muted"] = mute

        await self.broadcast(
            session_id,
            {"type": "participant_muted", "participant_id": participant_id, "is_muted": mute},
        )
        print(f"[SSE MGR] Muted participant={participant_id} mute={mute} session={session_id}")

    async def kick_participant(
        self, session_id: int, participant_id: int, reason: Optional[str] = None
    ):
        q = None
        async with SESSION_LOCK:
            q = self.active.get(session_id, {}).pop(participant_id, None)
            if session_id in SESSION_STATE:
                SESSION_STATE[session_id]["connections"].pop(participant_id, None)
                SESSION_STATE[session_id]["participants"].pop(participant_id, None)

        if q:
            try:
                q.put_nowait({"type": "kicked", "reason": reason or "Removed by teacher"})
                q.put_nowait(None)   # sentinel
            except asyncio.QueueFull:
                pass
            print(f"[SSE MGR] Kicked participant={participant_id} session={session_id}")

        await self.broadcast(
            session_id,
            {"type": "participant_kicked", "participant_id": participant_id},
        )

    async def disconnect_participant(
        self, session_id: int, participant_id: int, reason: Optional[str] = None
    ):
        """Soft kick — closes stream but keeps metadata."""
        q = None
        async with SESSION_LOCK:
            q = self.active.get(session_id, {}).pop(participant_id, None)
            if session_id in SESSION_STATE:
                SESSION_STATE[session_id]["connections"].pop(participant_id, None)

        if q:
            try:
                q.put_nowait({"type": "disconnected", "reason": reason or "Connection closed"})
                q.put_nowait(None)
            except asyncio.QueueFull:
                pass

    # ── audio playback controls ───────────────────────────────────────────

    async def audio_select(self, session_id: int, audio_id: int, title: Optional[str] = None):
        async with SESSION_LOCK:
            s = SESSION_STATE.setdefault(
                session_id,
                {"connections": {}, "participants": {}, "playback": {}},
            )
            s["playback"].update(
                {"audio_id": audio_id, "title": title, "status": "stopped", "position": 0.0}
            )

        await self.broadcast(
            session_id,
            {"type": "audio_selected", "audio_id": audio_id, "title": title},
        )

    async def audio_play(
        self, session_id: int, audio_id: int, speed: float = 1.0, position: float = 0.0
    ):
        async with SESSION_LOCK:
            if session_id not in SESSION_STATE:
                return
            SESSION_STATE[session_id]["playback"].update(
                {"status": "playing", "audio_id": audio_id, "speed": speed, "position": position}
            )

        await self.broadcast(
            session_id,
            {"type": "audio_play", "audio_id": audio_id, "speed": speed, "position": position},
        )

    async def audio_pause(self, session_id: int, position: float = 0.0):
        async with SESSION_LOCK:
            if session_id not in SESSION_STATE:
                return
            SESSION_STATE[session_id]["playback"]["status"] = "paused"
            SESSION_STATE[session_id]["playback"]["position"] = position

        await self.broadcast(session_id, {"type": "audio_pause", "position": position})


# Singleton — imported everywhere
ws_mgr = WebSocketManager()