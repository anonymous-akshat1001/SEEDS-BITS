"""Temporary, private, ungraded classroom checks in the existing live process."""

from uuid import uuid4

from fastapi import HTTPException

from ws_manager import SESSION_LOCK, SESSION_STATE, ws_mgr


CHOICES = {"understood", "repeat", "help"}


def snapshot(state: dict, user_id: int, teacher_id: int) -> dict:
    check = state.get("classroom_check")
    if check is None:
        return {"type": "classroom_check", "check_id": None, "revision": 0, "open": False, "responses": []}
    responses = [
        dict(response) for response in check["responses"].values()
        if user_id == teacher_id or response["user_id"] == user_id
    ]
    return {
        "type": "classroom_check", "check_id": check["check_id"],
        "revision": check["revision"], "open": check["open"],
        "responses": responses,
    }


async def act(
    session_id: int, *, kind: str, user_id: int, name: str,
    teacher_id: int, check_id: str | None, choice: str | None,
) -> dict:
    async with SESSION_LOCK:
        state = SESSION_STATE.get(session_id)
        if state is None:
            raise HTTPException(status_code=409, detail="Connect to the live classroom before using a check.")
        check = state.get("classroom_check")
        if kind == "open_check":
            if user_id != teacher_id:
                raise HTTPException(status_code=403, detail="Only the session teacher can open a check.")
            # A retry may not replace a newer check or erase its responses.
            if check_id != (check["check_id"] if check else None):
                raise HTTPException(status_code=409, detail="The classroom check changed. Refresh before opening another.")
            check = {
                "check_id": str(uuid4()), "revision": (check["revision"] if check else 0) + 1,
                "open": True, "responses": {},
            }
            state["classroom_check"] = check
        elif kind in {"close_check", "check_response"}:
            if check is None or check_id != check["check_id"]:
                raise HTTPException(status_code=409, detail="This check is no longer current. Refresh before responding.")
            if kind == "close_check":
                if user_id != teacher_id:
                    raise HTTPException(status_code=403, detail="Only the session teacher can close a check.")
                check["open"] = False
            else:
                if user_id == teacher_id:
                    raise HTTPException(status_code=403, detail="The teacher reads the check rather than submitting a student response.")
                if not check["open"]:
                    raise HTTPException(status_code=409, detail="This check is closed. Your response was not changed.")
                if choice not in CHOICES:
                    raise HTTPException(status_code=400, detail="Choose understood, repeat, or help.")
                check["responses"][user_id] = {"user_id": user_id, "name": name, "choice": choice}
            check["revision"] += 1
        elif kind != "read_check":
            raise HTTPException(status_code=400, detail="Unknown classroom check action.")

        own = snapshot(state, user_id, teacher_id)
        if kind != "read_check":
            for pid, queue in state.get("connections", {}).items():
                recipient = state.get("participants", {}).get(pid, {}).get("user_id")
                if recipient is not None:
                    await ws_mgr.send_personal(queue, snapshot(state, recipient, teacher_id))
        return own
