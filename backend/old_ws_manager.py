# Code for WebSocketManager and session runtime state implementation. 
# It keeps per-session connections, participant metadata (mute state, raised hand), and broadcasts events.

# A WebSocket is a long-lived, bi-directional connection between client (browser/mobile app) and server that 
# lets both sides send messages at any time (unlike HTTP where the client requests and the server responds).

import asyncio
from typing import Dict, Any, Set

from fastapi import WebSocket, logger

# Runtime in-memory state for active sessions (kept while server runs and will be lost if the server restarts)
# Structure:
# SESSION_STATE = {
#   session_id: {
#       "connections": { participant_id: websocket, ... },
#       "participants": { participant_id: {"user_id":..., "is_muted": False, "raised_hand": False, "name": "..."} },
#       "playback": {"audio_id": None, "status": "stopped"|"playing"|"paused", "speed": 1.0, "position": 0.0}
#   }
# }

SESSION_STATE: Dict[int, Dict[str, Any]] = {}
SESSION_LOCK = asyncio.Lock()

# Simple object to manage currently active WebSocket connections at runtime
class WebSocketManager:

    def __init__(self):
        # map session_id -> {participant_id -> websocket}
        # Similar to SESSION_STATE["connections"] but is local to the manager instance
        self.active: Dict[int, Dict[int, WebSocket]] = {}

    
    # Connects to the websocket
    async def connect(self, session_id: int, participant_id: int, websocket: WebSocket):
        # Note: websocket.accept() should be called BEFORE this method
        # Acquire global lock
        async with SESSION_LOCK:
            # Local Structure
            self.active.setdefault(session_id, {})                # Ensure self.active has a dict for this session_id
            self.active[session_id][participant_id] = websocket   # Store the WebSocket object for this participant
            # Ensure SESSION_STATE exists(global entry)
            s = SESSION_STATE.setdefault(
                session_id, 
                {
                    "connections": {},
                    "participants": {},
                    "playback": {"audio_id": None, "status": "stopped", "speed": 1.0, "position": 0.0}
                }
            )
            s["connections"][participant_id] = websocket
            s["participants"].setdefault(participant_id, {"is_muted": False, "raised_hand": False})
        
        print(f"[WS MGR] Connected: Session={session_id}, Participant={participant_id}")

    
    # Disconnects from the websocket - can join later on hence metadata preserved
    async def disconnect(self, session_id: int, participant_id: int):
        async with SESSION_LOCK:
            # Remove from local instance
            self.active.get(session_id, {}).pop(participant_id, None)
            # Keep participant metadata but mark connection removed
            if session_id in SESSION_STATE:
                SESSION_STATE[session_id]["connections"].pop(participant_id, None)
        
        print(f"[WS MGR] Disconnected: Session={session_id}, Participant={participant_id}")

    
    # Sends a JSON message to a single participant via their WebSocket object using send_json()
    async def send_personal(self, websocket: WebSocket, message: dict):
        try:
            await websocket.send_json(message)
        except Exception as e:
            print(f"[WS MGR] Error sending personal message: {e}")
    
    
    # Broadcasts (sends) the same message to all connected participants in a session
    async def broadcast(self, session_id: int, message: dict, exclude: Set[int] | None = None):
        # exclude allows skipping some participant IDs(for eg : the sender)
        exclude = exclude or set()
        # Takes a snapshot list of (pid, ws) pairs. Converts to a list so that while iterating we have a stable set
        conns = list(self.active.get(session_id, {}).items())
        
        if not conns:
            print(f"[WS MGR] No active connections for session {session_id}")
            return
        
        print(f"[WS MGR] Broadcasting to session {session_id}: {message.get('type', 'unknown')} (excluding {exclude})")
        
        for pid, ws in conns:
            if pid in exclude:
                continue
            try:
                await ws.send_json(message)
            except Exception as e:
                print(f"[WS MGR] Error broadcasting to participant {pid}: {e}")
                # Consider cleaning stale connections
                pass

    
    # Close all connections in case the session is ended
    async def close_session(self, session_id: int):
        async with SESSION_LOCK:
            conns = list(self.active.get(session_id, {}).items())
            if not conns:
                print(f"[WS MGR] No connections to close for session {session_id}")
                return
            
            print(f"[WS MGR] Closing session {session_id} with {len(conns)} connections")
            
            for pid, ws in conns:
                try:
                    await ws.send_json({"type": "session_ended"})
                    await ws.close()
                except Exception as e:
                    print(f"[WS MGR] Error closing connection for participant {pid}: {e}")
            
            # Cleanup
            self.active.pop(session_id, None)
            SESSION_STATE.pop(session_id, None)
            
            print(f"[WS MGR] Session {session_id} closed successfully")



# -------------------- Participant Actions --------------------
    
    # Toggle mute for participant and broadcast
    async def mute_participant(self, session_id: int, participant_id: int, mute: bool):
        async with SESSION_LOCK:
            # If session does not exist, return
            if session_id not in SESSION_STATE:
                print(f"[WS MGR] Cannot mute - session {session_id} not found")
                return
            # Creates an entry if the participant metadata doesn't exist yet
            p = SESSION_STATE[session_id]["participants"].setdefault(participant_id, {})
            p["is_muted"] = mute
        
        await self.broadcast(
            session_id,
            {"type": "participant_muted", "participant_id": participant_id, "is_muted": mute},
        )
        print(f"[WS MGR] Participant {participant_id} muted={mute} in session {session_id}")


    # Kick a participant and close their WebSocket
    async def kick_participant(self, session_id: int, participant_id: int, reason: str | None = None):
        ws = None
        async with SESSION_LOCK:
            # Removes and returns the WebSocket object (if any) for that participant from the manager's active map
            ws = self.active.get(session_id, {}).pop(participant_id, None)
            # Remove participant metadata as well as connections
            if session_id in SESSION_STATE:
                SESSION_STATE[session_id]["connections"].pop(participant_id, None)
                SESSION_STATE[session_id]["participants"].pop(participant_id, None)
        
        if ws:
            try:
                await ws.send_json({"type": "kicked", "reason": reason or "Removed by teacher"})
                await ws.close()
                print(f"[WS MGR] Kicked participant {participant_id} from session {session_id}")
            except Exception as e:
                print(f"[WS MGR] Error kicking participant {participant_id}: {e}")
        
        await self.broadcast(session_id, {"type": "participant_kicked", "participant_id": participant_id})


    # Disconnect a specific participant
    async def disconnect_participant(self, session_id: int, participant_id: int, reason: str | None = None):
        """Disconnect a participant without removing their metadata (softer than kick)"""
        ws = None
        async with SESSION_LOCK:
            ws = self.active.get(session_id, {}).pop(participant_id, None)
            if session_id in SESSION_STATE:
                SESSION_STATE[session_id]["connections"].pop(participant_id, None)
        
        if ws:
            try:
                await ws.send_json({"type": "disconnected", "reason": reason or "Connection closed"})
                await ws.close()
                print(f"[WS MGR] Disconnected participant {participant_id} from session {session_id}")
            except Exception as e:
                print(f"[WS MGR] Error disconnecting participant {participant_id}: {e}")


# kick_participant completely removes participant metadata (so there's no trace), 
# while disconnect only removes the connection but leaves metadata intact. 
# Both are valid behaviors depending on whether you want to preserve metadata for later rejoin or to remove user entirely.

# -------------------- Audio Playback Controls --------------------

    # Set the selected audio track
    async def audio_select(self, session_id: int, audio_id: int, title: str = None):
        async with SESSION_LOCK:
            s = SESSION_STATE.setdefault(
                session_id,
                {"connections": {}, "participants": {}, "playback": {}}
            )
            # Update playback metadata
            s["playback"].update(
                {"audio_id": audio_id, "title": title, "status": "stopped", "position": 0.0}
            )
        
        await self.broadcast(session_id, {
            "type": "audio_selected", 
            "audio_id": audio_id,
            "title": title
        })
        print(f"[WS MGR] Audio {audio_id} selected for session {session_id}")


    # Start audio playback
    async def audio_play(self, session_id: int, audio_id: int, speed: float = 1.0, position: float = 0.0):
        async with SESSION_LOCK:
            if session_id not in SESSION_STATE:
                print(f"[WS MGR] Cannot play - session {session_id} not found")
                return
            SESSION_STATE[session_id]["playback"].update(
                {"status": "playing", "audio_id": audio_id, "speed": speed, "position": position}
            )
        
        await self.broadcast(
            session_id,
            {"type": "audio_play", "audio_id": audio_id, "speed": speed, "position": position},
        )
        print(f"[WS MGR] Audio {audio_id} playing in session {session_id} at speed {speed} from position {position}s")


    # Pause playback
    async def audio_pause(self, session_id: int, position: float = 0.0):
        async with SESSION_LOCK:
            if session_id not in SESSION_STATE:
                print(f"[WS MGR] Cannot pause - session {session_id} not found")
                return
            SESSION_STATE[session_id]["playback"]["status"] = "paused"
            SESSION_STATE[session_id]["playback"]["position"] = position
        
        await self.broadcast(session_id, {"type": "audio_pause", "position": position})
        print(f"[WS MGR] Audio paused in session {session_id} at position {position}s")




# A single global instance of the manager is created for other modules to import and use (singleton pattern)
ws_mgr = WebSocketManager()