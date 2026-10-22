import sys
import json
import hashlib
import time
import asyncio
from pathlib import Path
from unittest.mock import AsyncMock

import pytest
import pytest_asyncio
from fastapi import BackgroundTasks, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from sqlalchemy import select

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import access_control as access  # noqa: E402
import main  # noqa: E402
import models  # noqa: E402
import playlist_routes  # noqa: E402
import classroom_checks  # noqa: E402
import sequence_routes as sequences  # noqa: E402
from pydantic import ValidationError


@pytest.mark.asyncio
@pytest.mark.parametrize("bootstrap_frames", [0, 1])
async def test_sse_reset_between_authorization_and_bootstrap_sends_no_private_snapshot(live_room, bootstrap_frames):
    db, data, room, _, student, *_ = live_room
    response = await main.session_sse(room.session_id, data["student"], db)
    if bootstrap_frames:
        assert "event: connected" in await anext(response.body_iterator)
    data["student"].auth_version += 1
    data["student"].must_change_password = True
    await db.commit()
    frame = await anext(response.body_iterator)
    assert "event: authentication_revoked" in frame
    assert "session_state" not in frame
    with pytest.raises(StopAsyncIteration):
        await anext(response.body_iterator)
    assert student.participant_id not in main.ws_mgr.active.get(room.session_id, {})


@pytest.mark.asyncio
async def test_active_sse_reset_closes_after_revocation_instead_of_delivering_queued_events(live_room):
    db, data, room, _, student, *_ = live_room
    response = await main.session_sse(room.session_id, data["student"], db)
    assert "event: connected" in await anext(response.body_iterator)
    assert "event: session_state" in await anext(response.body_iterator)
    queue = main.ws_mgr.active[room.session_id][student.participant_id]
    queue.put_nowait({"type": "chat", "text": "Queued private message"})
    data["student"].auth_version += 1
    data["student"].must_change_password = True
    await db.commit()
    await main.ws_mgr.revoke_user(data["student"].user_id)
    frame = await anext(response.body_iterator)
    assert "event: authentication_revoked" in frame
    assert "Queued private" not in frame
    with pytest.raises(StopAsyncIteration):
        await anext(response.body_iterator)


@pytest_asyncio.fixture
async def sequence_plan(live_room, tmp_path):
    db, data, room, teacher, student, logs, broadcast = live_room
    path = tmp_path / "sequence.m4a"
    path.write_bytes(b"private teacher lesson")
    audio = models.AudioFile(
        title="Sequence recording", file_path=str(path), mime_type="audio/mp4",
        uploaded_by=data["teacher"].user_id, class_id=room.class_id, subject_id=room.subject_id,
    )
    db.add(audio)
    await db.commit()
    result = await sequences.create_plan(sequences.CreatePlan(
        title="Reusable lesson", class_id=room.class_id, subject_id=room.subject_id,
        steps=[sequences.Step(kind="prompt", text="Introduce the concept"),
               sequences.Step(kind="audio", text=audio.title, audio_id=audio.audio_id),
               sequences.Step(kind="check", text="Ask whether to repeat")],
    ), data["teacher"], db)
    return live_room, result["plan"], audio, path


@pytest.mark.asyncio
async def test_reusable_sequences_persist_without_classroom_side_effects(sequence_plan):
    (db, data, room, _, _, _, broadcast), plan, audio, _ = sequence_plan
    loaded = await sequences.list_plans(session_id=room.session_id, teacher=data["teacher"], db=db)
    assert loaded["plans"] == [plan]
    assert [step["kind"] for step in plan["steps"]] == ["prompt", "audio", "check"]
    for index in range(3):
        result = await sequences.prepare_step(plan["sequence_id"], index, 1, room.session_id, data["teacher"], db)
        assert result["position"] == index
        assert result["step"]["kind"] == plan["steps"][index]["kind"]
    assert main.SESSION_STATE[room.session_id]["playback"]["audio_id"] is None
    assert "classroom_check" not in main.SESSION_STATE[room.session_id]
    assert all(person["is_muted"] for person in main.SESSION_STATE[room.session_id]["participants"].values())
    broadcast.assert_not_awaited()


@pytest.mark.asyncio
async def test_sequence_revision_guards_edit_prepare_and_selected_removal(sequence_plan):
    (db, data, room, *_), plan, _, _ = sequence_plan
    changed = await sequences.update_plan(plan["sequence_id"], sequences.UpdatePlan(
        title="Changed plan", revision=1, steps=[sequences.Step(kind="prompt", text="New first step")],
    ), data["teacher"], db)
    assert changed["plan"]["revision"] == 2
    for operation in (
        sequences.update_plan(plan["sequence_id"], sequences.UpdatePlan(title="Stale", revision=1), data["teacher"], db),
        sequences.prepare_step(plan["sequence_id"], 0, 1, room.session_id, data["teacher"], db),
        sequences.delete_plan(plan["sequence_id"], 1, data["teacher"], db),
    ):
        with pytest.raises(HTTPException) as stale:
            await operation
        assert stale.value.status_code == 409
    await sequences.delete_plan(plan["sequence_id"], 2, data["teacher"], db)
    assert (await sequences.list_plans(session_id=room.session_id, teacher=data["teacher"], db=db))["plans"] == []


@pytest.mark.asyncio
async def test_sequence_owner_workspace_and_current_assignment_are_revalidated(sequence_plan):
    (db, data, room, *_), plan, _, _ = sequence_plan
    other = models.User(name="Other sequence teacher", phone_number="9000000111", role="teacher", password_hash="test")
    db.add(other)
    await db.flush()
    db.add(models.TeacherClassSubjectAssignment(teacher_id=other.user_id, class_id=room.class_id, subject_id=room.subject_id))
    await db.commit()
    with pytest.raises(HTTPException) as denied:
        await sequences.prepare_step(plan["sequence_id"], 0, 1, None, other, db)
    assert denied.value.status_code == 403
    assignment = (await db.execute(select(models.TeacherClassSubjectAssignment).where(
        models.TeacherClassSubjectAssignment.teacher_id == data["teacher"].user_id,
    ))).scalar_one()
    assignment.is_active = False
    await db.commit()
    with pytest.raises(HTTPException) as revoked:
        await sequences.prepare_step(plan["sequence_id"], 0, 1, room.session_id, data["teacher"], db)
    assert revoked.value.status_code == 403


@pytest.mark.asyncio
async def test_missing_sequence_recording_is_retained_but_not_prepared(sequence_plan):
    (db, data, room, *_), plan, _, path = sequence_plan
    path.unlink()
    with pytest.raises(HTTPException) as missing:
        await sequences.prepare_step(plan["sequence_id"], 1, 1, room.session_id, data["teacher"], db)
    assert missing.value.status_code == 409
    loaded = await sequences.list_plans(session_id=room.session_id, teacher=data["teacher"], db=db)
    assert len(loaded["plans"][0]["steps"]) == 3


@pytest.mark.parametrize("step", [
    {"kind": "quiz", "text": "Graded quizzes are not sequence steps"},
    {"kind": "audio", "text": "Missing identity"},
    {"kind": "prompt", "text": "Not audio", "audio_id": 1},
    {"kind": "check", "text": "   "},
])
def test_sequence_step_contract_excludes_graded_or_malformed_actions(step):
    with pytest.raises(ValidationError):
        sequences.Step(**step)


@pytest.mark.asyncio
async def test_offline_manifest_binds_hash_size_account_and_thirty_day_access(seeded_db, tmp_path):
    db, data = seeded_db
    path = tmp_path / "lesson.mp3"
    content = b"verified educational audio"
    path.write_bytes(content)
    audio = models.AudioFile(
        title="English recording", file_path=str(path), mime_type="audio/mpeg",
        uploaded_by=data["teacher"].user_id, class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(audio)
    await db.commit()
    before = int(time.time())
    manifest = await main.offline_audio_manifest(audio.audio_id, data["student"], db)
    assert manifest["account_id"] == data["student"].user_id
    assert manifest["audio_id"] == audio.audio_id
    assert manifest["bytes"] == len(content)
    assert manifest["sha256"] == hashlib.sha256(content).hexdigest()
    assert before <= manifest["authorized_at"] <= int(time.time())
    assert manifest["expires_at"] - manifest["authorized_at"] == 30 * 24 * 60 * 60
    assert "file_path" not in manifest


@pytest.mark.asyncio
async def test_offline_manifest_checks_access_before_reading_a_file(seeded_db):
    db, data = seeded_db
    audio = models.AudioFile(
        title="Other class", file_path="does-not-exist.mp3", mime_type="audio/mpeg",
        uploaded_by=data["teacher"].user_id, class_id=data["class_two"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(audio)
    await db.commit()
    with pytest.raises(HTTPException) as denied:
        await main.offline_audio_manifest(audio.audio_id, data["student"], db)
    assert denied.value.status_code == 403


@pytest.mark.asyncio
@pytest.mark.parametrize("size,status", [(0, 409), (50_000_001, 413), (None, 404)])
async def test_offline_manifest_reports_empty_oversized_and_missing_media(seeded_db, tmp_path, size, status):
    db, data = seeded_db
    path = tmp_path / "lesson.mp3"
    if size is not None:
        with path.open("wb") as output:
            output.truncate(size)
    audio = models.AudioFile(
        title="Unavailable recording", file_path=str(path), mime_type="audio/mpeg",
        uploaded_by=data["teacher"].user_id, class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(audio)
    await db.commit()
    with pytest.raises(HTTPException) as denied:
        await main.offline_audio_manifest(audio.audio_id, data["student"], db)
    assert denied.value.status_code == status


@pytest_asyncio.fixture
async def live_room(seeded_db, monkeypatch):
    db, data = seeded_db
    room = models.Session(
        title="Live microphone policy",
        created_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
        is_active=True,
    )
    db.add(room)
    await db.flush()
    teacher = models.Participant(
        session_id=room.session_id, user_id=data["teacher"].user_id, is_muted=True,
    )
    student = models.Participant(
        session_id=room.session_id, user_id=data["student"].user_id, is_muted=True,
    )
    db.add_all([teacher, student])
    await db.commit()
    logs = {}
    for name in (
        "log_participant_muted", "log_participant_unmuted",
        "log_participant_joined", "log_participant_left",
        "log_hand_raised", "log_hand_lowered",
    ):
        logs[name] = AsyncMock()
        monkeypatch.setattr(main.SessionLogger, name, logs[name])
    broadcast = AsyncMock(wraps=main.ws_mgr.broadcast)
    monkeypatch.setattr(main.ws_mgr, "broadcast", broadcast)
    main.SESSION_STATE[room.session_id] = {
        "connections": {},
        "participants": {
            participant.participant_id: {
                "user_id": participant.user_id,
                "name": user.name,
                "is_muted": True,
                "raised_hand": False,
                "is_teacher": user.role == "teacher",
            }
            for participant, user in (
                (teacher, data["teacher"]), (student, data["student"]),
            )
        },
        "playback": {
            "audio_id": None, "status": "stopped", "speed": 1.0, "position": 0.0,
        },
    }
    try:
        yield db, data, room, teacher, student, logs, broadcast
    finally:
        main.SESSION_STATE.pop(room.session_id, None)
        main.ws_mgr.active.pop(room.session_id, None)


@pytest.mark.asyncio
@pytest.mark.parametrize("transport", ["legacy", "action"])
async def test_teacher_cannot_remotely_unmute(live_room, transport):
    db, data, room, teacher, student, logs, broadcast = live_room
    with pytest.raises(HTTPException) as denied:
        if transport == "legacy":
            await main.mute_participant(
                room.session_id, student.participant_id, mute=False,
                current_user=data["teacher"], db=db,
                background_tasks=BackgroundTasks(),
            )
        else:
            await main.session_action(
                room.session_id,
                main.SessionAction(
                    type="unmute_participant",
                    target_participant_id=student.participant_id,
                ),
                current_user=data["teacher"], db=db,
            )
    assert denied.value.status_code == 403
    assert "Only the participant" in denied.value.detail
    await db.refresh(student)
    assert student.is_muted is True
    assert main.SESSION_STATE[room.session_id]["participants"][student.participant_id]["is_muted"] is True
    broadcast.assert_not_awaited()
    logs["log_participant_unmuted"].assert_not_awaited()


@pytest.mark.asyncio
@pytest.mark.parametrize("transport", ["legacy", "action"])
async def test_teacher_can_still_mute_and_persist_state(live_room, transport):
    db, data, room, teacher, student, logs, broadcast = live_room
    student.is_muted = False
    await db.commit()
    main.SESSION_STATE[room.session_id]["participants"][student.participant_id]["is_muted"] = False
    if transport == "legacy":
        tasks = BackgroundTasks()
        result = await main.mute_participant(
            room.session_id, student.participant_id, mute=True,
            current_user=data["teacher"], db=db, background_tasks=tasks,
        )
        await tasks()
    else:
        result = await main.session_action(
            room.session_id,
            main.SessionAction(type="mute_participant", target_participant_id=student.participant_id),
            current_user=data["teacher"], db=db,
        )
    assert result["ok"] is True
    await db.refresh(student)
    assert student.is_muted is True
    assert main.SESSION_STATE[room.session_id]["participants"][student.participant_id]["is_muted"] is True
    logs["log_participant_muted"].assert_awaited_once()
    broadcast.assert_awaited_once()


@pytest.mark.asyncio
async def test_student_can_unmute_only_their_own_microphone(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    result = await main.session_action(
        room.session_id, main.SessionAction(type="mute_self", mute=False),
        current_user=data["student"], db=db,
    )
    assert result["ok"] is True
    await db.refresh(student)
    assert student.is_muted is False
    state = main.SESSION_STATE[room.session_id]["participants"]
    assert state[student.participant_id]["is_muted"] is False
    assert state[teacher.participant_id]["is_muted"] is True
    logs["log_participant_unmuted"].assert_awaited_once()


@pytest.mark.asyncio
async def test_fresh_self_join_is_muted_even_after_a_previous_unmute(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    student.is_muted = False
    await db.commit()
    main.SESSION_STATE[room.session_id]["participants"][student.participant_id]["is_muted"] = False
    result = await main.join_or_add_participant(
        room.session_id, user_id=None, current_user=data["student"], db=db,
    )
    assert result["ok"] is True
    await db.refresh(student)
    assert student.is_muted is True
    assert main.SESSION_STATE[room.session_id]["participants"][student.participant_id]["is_muted"] is True


@pytest.mark.asyncio
async def test_teacher_adding_existing_student_does_not_change_microphone(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    student.is_muted = False
    await db.commit()
    main.SESSION_STATE[room.session_id]["participants"][student.participant_id]["is_muted"] = False
    await main.join_or_add_participant(
        room.session_id, user_id=student.user_id, current_user=data["teacher"], db=db,
    )
    await db.refresh(student)
    assert student.is_muted is False
    assert main.SESSION_STATE[room.session_id]["participants"][student.participant_id]["is_muted"] is False


@pytest.mark.asyncio
@pytest.mark.parametrize("action", ["mute_participant", "unmute_participant"])
async def test_student_cannot_control_another_microphone(live_room, action):
    db, data, room, teacher, student, logs, broadcast = live_room
    with pytest.raises(HTTPException) as denied:
        await main.session_action(
            room.session_id,
            main.SessionAction(type=action, target_participant_id=teacher.participant_id),
            current_user=data["student"], db=db,
        )
    assert denied.value.status_code == 403
    broadcast.assert_not_awaited()


@pytest.mark.asyncio
@pytest.mark.parametrize("raised", [True, False])
async def test_hand_status_is_saved_for_reconnection(live_room, raised):
    db, data, room, teacher, student, logs, broadcast = live_room
    student.hand_raised = not raised
    await db.commit()
    result = await main.session_action(
        room.session_id,
        main.SessionAction(type="raise_hand" if raised else "lower_hand"),
        current_user=data["student"], db=db,
    )
    assert result["ok"] is True
    await db.refresh(student)
    assert student.hand_raised is raised
    assert main.SESSION_STATE[room.session_id]["participants"][student.participant_id]["raised_hand"] is raised


async def _read_live_snapshot(response):
    await response.body_iterator.__anext__()
    frame = await response.body_iterator.__anext__()
    return json.loads(next(line[6:] for line in frame.splitlines() if line.startswith("data: ")))


@pytest.mark.asyncio
async def test_fifo_hand_order_is_persisted_idempotent_and_moves_only_after_lowering(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    async def action(kind, user):
        return await main.session_action(room.session_id, main.SessionAction(type=kind), current_user=user, db=db)
    first = await action("raise_hand", data["student"])
    assert first["hand_state"]["hand_queue_order"] == 1
    repeated = await action("raise_hand", data["student"])
    assert repeated["hand_state"]["hand_queue_order"] == 1
    second = await action("raise_hand", data["teacher"])
    assert second["hand_state"]["hand_queue_order"] == 2
    await action("lower_hand", data["student"])
    assert student.hand_queue_order is None
    third = await action("raise_hand", data["student"])
    assert third["hand_state"]["hand_queue_order"] == 3
    assert third["hand_state"]["hand_revision"] > first["hand_state"]["hand_revision"]
    assert student.is_muted is True


@pytest.mark.asyncio
async def test_unknown_legacy_hand_order_is_not_invented(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    student.hand_raised = True
    await db.commit()
    result = await main.session_action(room.session_id, main.SessionAction(type="raise_hand"), current_user=data["student"], db=db)
    assert result["hand_state"]["hand_queue_order"] is None
    assert room.hand_queue_sequence == 0


@pytest.mark.asyncio
async def test_teacher_acknowledges_only_selected_current_hand_without_changing_microphone(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    await main.session_action(room.session_id, main.SessionAction(type="raise_hand"), current_user=data["student"], db=db)
    student.is_muted = False
    await db.commit()
    result = await main.session_action(
        room.session_id,
        main.SessionAction(type="acknowledge_hand", target_participant_id=student.participant_id, hand_queue_order=student.hand_queue_order),
        current_user=data["teacher"], db=db,
    )
    assert result["hand_state"]["raised_hand"] is False
    assert result["hand_state"]["acknowledged_by"] == data["teacher"].user_id
    assert student.hand_raised is False and student.hand_queue_order is None
    assert student.is_muted is False
    logs["log_participant_unmuted"].assert_not_awaited()


@pytest.mark.asyncio
async def test_stale_acknowledgment_cannot_lower_a_newly_raised_hand(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    for kind in ("raise_hand", "lower_hand", "raise_hand"):
        await main.session_action(room.session_id, main.SessionAction(type=kind), current_user=data["student"], db=db)
    with pytest.raises(HTTPException) as denied:
        await main.session_action(
            room.session_id, main.SessionAction(type="acknowledge_hand", target_participant_id=student.participant_id, hand_queue_order=1),
            current_user=data["teacher"], db=db,
        )
    assert denied.value.status_code == 409
    assert student.hand_raised is True and student.hand_queue_order == 2


@pytest.mark.asyncio
async def test_student_cannot_acknowledge_or_lower_someone_elses_hand(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    await main.session_action(room.session_id, main.SessionAction(type="raise_hand"), current_user=data["teacher"], db=db)
    with pytest.raises(HTTPException) as denied:
        await main.session_action(
            room.session_id, main.SessionAction(type="acknowledge_hand", target_participant_id=teacher.participant_id, hand_queue_order=teacher.hand_queue_order),
            current_user=data["student"], db=db,
        )
    assert denied.value.status_code == 403
    assert teacher.hand_raised is True


@pytest.mark.asyncio
async def test_explicit_leave_clears_hand_and_fresh_join_requires_new_queue_position(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    await main.session_action(room.session_id, main.SessionAction(type="raise_hand"), current_user=data["student"], db=db)
    await main.session_action(room.session_id, main.SessionAction(type="leave_session"), current_user=data["student"], db=db)
    assert student.hand_raised is False and student.hand_queue_order is None
    assert student.left_at is not None and student.is_muted is True
    await main.join_or_add_participant(room.session_id, student.user_id, current_user=data["student"], db=db)
    assert student.left_at is None and student.hand_raised is False
    result = await main.session_action(room.session_id, main.SessionAction(type="raise_hand"), current_user=data["student"], db=db)
    assert result["hand_state"]["hand_queue_order"] == 2


@pytest.mark.asyncio
async def test_transient_stream_reconnect_retains_queue_position_and_sends_it_to_other_clients(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    result = await main.session_action(room.session_id, main.SessionAction(type="raise_hand"), current_user=data["student"], db=db)
    expected = result["hand_state"]
    for _ in range(2):
        response = await main.session_sse(room.session_id, current_user=data["student"], db=db)
        try:
            snapshot = await _read_live_snapshot(response)
            own = snapshot["participants"][str(student.participant_id)]
            assert own["hand_queue_order"] == expected["hand_queue_order"]
            assert own["hand_revision"] == expected["hand_revision"]
            joined = next(call.args[1] for call in reversed(broadcast.await_args_list) if call.args[1]["type"] == "participant_joined")
            assert joined["raised_hand"] is True
            assert joined["hand_queue_order"] == expected["hand_queue_order"]
        finally:
            await response.body_iterator.aclose()


@pytest.mark.asyncio
@pytest.mark.parametrize("transport", ["legacy", "action"])
async def test_removal_clears_persisted_queue_state(live_room, transport):
    db, data, room, teacher, student, logs, broadcast = live_room
    await main.session_action(room.session_id, main.SessionAction(type="raise_hand"), current_user=data["student"], db=db)
    if transport == "legacy":
        tasks = BackgroundTasks()
        await main.remove_participant(room.session_id, student.participant_id, current_user=data["teacher"], db=db, background_tasks=tasks)
        await tasks()
    else:
        await main.session_action(
            room.session_id, main.SessionAction(type="kick_participant", target_participant_id=student.participant_id),
            current_user=data["teacher"], db=db,
        )
    assert student.hand_raised is False and student.hand_queue_order is None
    assert student.is_kicked is True and student.left_at is not None


@pytest.mark.asyncio
async def test_acknowledgment_cannot_target_another_session(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    other_room = models.Session(
        title="Other room", created_by=data["teacher"].user_id,
        class_id=room.class_id, subject_id=room.subject_id, is_active=True,
    )
    db.add(other_room)
    await db.flush()
    other = models.Participant(session_id=other_room.session_id, user_id=student.user_id, hand_raised=True, hand_queue_order=1)
    db.add(other)
    await db.commit()
    with pytest.raises(HTTPException) as denied:
        await main.session_action(
            room.session_id, main.SessionAction(type="acknowledge_hand", target_participant_id=other.participant_id, hand_queue_order=1),
            current_user=data["teacher"], db=db,
        )
    assert denied.value.status_code == 404
    assert other.hand_raised is True


@pytest.mark.asyncio
async def test_classroom_checks_are_private_changeable_and_never_broadcast_named_results(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    queues = {teacher.participant_id: asyncio.Queue(), student.participant_id: asyncio.Queue(), 999: asyncio.Queue()}
    state = main.SESSION_STATE[room.session_id]
    state["connections"] = queues
    state["participants"][999] = {"user_id": data["other_student"].user_id, "name": "Other"}
    opened = await main.session_action(room.session_id, main.SessionAction(type="open_check"), current_user=data["teacher"], db=db)
    check = opened["check_state"]
    for choice in ("understood", "repeat", "help"):
        response = await main.session_action(
            room.session_id, main.SessionAction(type="check_response", check_id=check["check_id"], choice=choice),
            current_user=data["student"], db=db,
        )
        assert response["check_state"]["responses"] == [{"user_id": student.user_id, "name": data["student"].name, "choice": choice}]
    assert len(state["classroom_check"]["responses"]) == 1
    last = {}
    for pid, queue in queues.items():
        while not queue.empty():
            last[pid] = queue.get_nowait()
    assert last[teacher.participant_id]["responses"][0]["choice"] == "help"
    assert last[student.participant_id]["responses"][0]["choice"] == "help"
    assert last[999]["responses"] == []
    broadcast.assert_not_awaited()
    for logger in logs.values():
        logger.assert_not_awaited()


@pytest.mark.asyncio
async def test_classroom_checks_reject_closed_stale_invalid_and_student_management(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    with pytest.raises(HTTPException) as denied:
        await main.session_action(room.session_id, main.SessionAction(type="open_check"), current_user=data["student"], db=db)
    assert denied.value.status_code == 403
    opened = await main.session_action(room.session_id, main.SessionAction(type="open_check"), current_user=data["teacher"], db=db)
    identity = opened["check_state"]["check_id"]
    for kind, actor, id_value, choice, status in (
        ("check_response", "student", identity, "invalid", 400),
        ("check_response", "student", "stale", "help", 409),
        ("close_check", "student", identity, None, 403),
        ("open_check", "teacher", None, None, 409),
        ("check_response", "teacher", identity, "understood", 403),
    ):
        with pytest.raises(HTTPException) as denied:
            await main.session_action(
                room.session_id, main.SessionAction(type=kind, check_id=id_value, choice=choice),
                current_user=data[actor], db=db,
            )
        assert denied.value.status_code == status
    await main.session_action(room.session_id, main.SessionAction(type="close_check", check_id=identity), current_user=data["teacher"], db=db)
    with pytest.raises(HTTPException) as denied:
        await main.session_action(room.session_id, main.SessionAction(type="check_response", check_id=identity, choice="help"), current_user=data["student"], db=db)
    assert denied.value.status_code == 409


@pytest.mark.asyncio
async def test_next_check_and_server_state_reset_clear_responses_but_transient_reconnect_preserves_them(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    opened = await main.session_action(room.session_id, main.SessionAction(type="open_check"), current_user=data["teacher"], db=db)
    identity = opened["check_state"]["check_id"]
    await main.session_action(room.session_id, main.SessionAction(type="check_response", check_id=identity, choice="repeat"), current_user=data["student"], db=db)
    for user in ("student", "teacher"):
        response = await main.session_sse(room.session_id, current_user=data[user], db=db)
        try:
            snapshot = await _read_live_snapshot(response)
            assert snapshot["classroom_check"]["check_id"] == identity
            assert snapshot["classroom_check"]["responses"][0]["choice"] == "repeat"
        finally:
            await response.body_iterator.aclose()
    replacement = await main.session_action(room.session_id, main.SessionAction(type="open_check", check_id=identity), current_user=data["teacher"], db=db)
    assert replacement["check_state"]["check_id"] != identity
    assert replacement["check_state"]["responses"] == []
    main.SESSION_STATE[room.session_id].pop("classroom_check")
    refreshed = await main.session_action(room.session_id, main.SessionAction(type="read_check"), current_user=data["student"], db=db)
    assert refreshed["check_state"]["check_id"] is None
    assert refreshed["check_state"]["responses"] == []


@pytest.mark.asyncio
async def test_reconnection_restores_persisted_mute_and_hand_state(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    student.is_muted = False
    student.hand_raised = True
    await db.commit()
    main.SESSION_STATE[room.session_id]["participants"].pop(student.participant_id)
    for _ in range(2):
        response = await main.session_sse(room.session_id, current_user=data["student"], db=db)
        try:
            snapshot = await _read_live_snapshot(response)
            own = snapshot["participants"][str(student.participant_id)]
            assert own["is_muted"] is False
            assert own["raised_hand"] is True
        finally:
            await response.body_iterator.aclose()
        assert student.participant_id not in main.ws_mgr.active.get(room.session_id, {})


@pytest.mark.asyncio
async def test_old_stream_cleanup_cannot_disconnect_a_replacement(live_room):
    db, data, room, teacher, student, logs, broadcast = live_room
    first = await main.session_sse(room.session_id, current_user=data["student"], db=db)
    replacement = None
    try:
        await _read_live_snapshot(first)
        replacement = await main.session_sse(room.session_id, current_user=data["student"], db=db)
        await _read_live_snapshot(replacement)
        queue = main.ws_mgr.active[room.session_id][student.participant_id]
        broadcast.reset_mock()
        await first.body_iterator.aclose()
        assert main.ws_mgr.active[room.session_id][student.participant_id] is queue
        assert student.participant_id in main.SESSION_STATE[room.session_id]["participants"]
        broadcast.assert_not_awaited()
        logs["log_participant_left"].assert_not_awaited()
    finally:
        await first.body_iterator.aclose()
        if replacement is not None:
            await replacement.body_iterator.aclose()
    assert student.participant_id not in main.ws_mgr.active.get(room.session_id, {})
    logs["log_participant_left"].assert_awaited_once()


@pytest.mark.asyncio
@pytest.mark.parametrize("frames", [1, 2])
async def test_disconnect_during_bootstrap_releases_its_stream(live_room, frames):
    db, data, room, teacher, student, logs, broadcast = live_room
    response = await main.session_sse(room.session_id, current_user=data["student"], db=db)
    try:
        for _ in range(frames):
            await response.body_iterator.__anext__()
    finally:
        await response.body_iterator.aclose()
    assert student.participant_id not in main.ws_mgr.active.get(room.session_id, {})
    assert student.participant_id not in main.SESSION_STATE[room.session_id]["participants"]


@pytest_asyncio.fixture
async def seeded_db():
    engine = create_async_engine(
        "sqlite+aiosqlite://",
        poolclass=StaticPool,
        connect_args={"check_same_thread": False},
    )
    async with engine.begin() as connection:
        await connection.run_sync(models.Base.metadata.create_all)

    factory = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with factory() as db:
        class_one = models.SchoolClass(name="Class 1", sort_order=1)
        class_two = models.SchoolClass(name="Class 2", sort_order=2)
        english = models.Subject(name="English")
        maths = models.Subject(name="Maths")
        teacher = models.User(
            name="Teacher One",
            phone_number="9000000001",
            role="teacher",
            password_hash="test",
        )
        student = models.User(
            name="Student One",
            phone_number="9000000002",
            role="student",
            password_hash="test",
        )
        other_student = models.User(
            name="Student Two",
            phone_number="9000000003",
            role="student",
            password_hash="test",
        )
        db.add_all([class_one, class_two, english, maths, teacher, student, other_student])
        await db.flush()
        db.add_all(
            [
                models.ClassSubjectAssociation(
                    class_id=class_one.class_id,
                    subject_id=english.subject_id,
                ),
                models.ClassSubjectAssociation(
                    class_id=class_two.class_id,
                    subject_id=english.subject_id,
                ),
            ]
        )
        await db.flush()
        db.add_all(
            [
                models.TeacherClassSubjectAssignment(
                    teacher_id=teacher.user_id,
                    class_id=class_one.class_id,
                    subject_id=english.subject_id,
                ),
                models.StudentClassMembership(
                    student_id=student.user_id,
                    class_id=class_one.class_id,
                ),
                models.StudentClassMembership(
                    student_id=other_student.user_id,
                    class_id=class_two.class_id,
                ),
            ]
        )
        await db.commit()
        yield db, {
            "class_one": class_one,
            "class_two": class_two,
            "english": english,
            "maths": maths,
            "teacher": teacher,
            "student": student,
            "other_student": other_student,
        }
    await engine.dispose()


@pytest.mark.asyncio
async def test_teacher_assignment_rejects_unassigned_pair(seeded_db):
    db, data = seeded_db
    await access.require_teacher_assignment(
        db,
        data["teacher"].user_id,
        data["class_one"].class_id,
        data["english"].subject_id,
    )
    with pytest.raises(HTTPException) as denied:
        await access.require_teacher_assignment(
            db,
            data["teacher"].user_id,
            data["class_two"].class_id,
            data["english"].subject_id,
        )
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_teacher_assignment_rejects_subject_not_associated_with_class(
    seeded_db,
):
    db, data = seeded_db
    with pytest.raises(HTTPException) as denied:
        await access.require_teacher_assignment(
            db,
            data["teacher"].user_id,
            data["class_one"].class_id,
            data["maths"].subject_id,
        )
    assert denied.value.status_code == 404


@pytest.mark.asyncio
async def test_archived_teacher_assignment_is_denied(seeded_db):
    db, data = seeded_db
    result = await db.execute(
        models.TeacherClassSubjectAssignment.__table__.select().where(
            models.TeacherClassSubjectAssignment.teacher_id
            == data["teacher"].user_id
        )
    )
    assignment_id = result.first().assignment_id
    assignment = await db.get(models.TeacherClassSubjectAssignment, assignment_id)
    assignment.is_active = False
    await db.commit()

    with pytest.raises(HTTPException) as denied:
        await access.require_teacher_assignment(
            db,
            data["teacher"].user_id,
            data["class_one"].class_id,
            data["english"].subject_id,
        )
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_student_cannot_access_other_class_session(seeded_db):
    db, data = seeded_db
    session = models.Session(
        title="Other class",
        created_by=data["teacher"].user_id,
        class_id=data["class_two"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(session)
    await db.commit()
    with pytest.raises(HTTPException) as denied:
        await access.require_session_access(db, data["student"], session)
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_teacher_can_list_ended_sessions_without_exposing_them_as_active(
    seeded_db,
):
    db, data = seeded_db
    ended = models.Session(
        title="Completed lesson",
        created_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
        is_active=False,
    )
    db.add(ended)
    await db.commit()

    active_only = await main.get_active_sessions(
        include_ended=False,
        user=data["teacher"],
        db=db,
    )
    history = await main.get_active_sessions(
        include_ended=True,
        user=data["teacher"],
        db=db,
    )

    assert all(session["session_id"] != ended.session_id for session in active_only)
    ended_payload = next(
        session for session in history if session["session_id"] == ended.session_id
    )
    assert ended_payload["is_active"] is False


@pytest.mark.asyncio
async def test_teacher_can_reactivate_then_permanently_delete_ended_session(
    seeded_db,
):
    db, data = seeded_db
    session = models.Session(
        title="Reusable lesson",
        created_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
        is_active=False,
    )
    db.add(session)
    await db.commit()

    response = await main.reactivate_session(
        session_id=session.session_id,
        user=data["teacher"],
        db=db,
    )
    assert response["ok"] is True
    assert session.is_active is True
    assert session.ended_at is None

    with pytest.raises(HTTPException) as active_delete:
        await main.permanently_delete_session(
            session_id=session.session_id,
            user=data["teacher"],
            db=db,
        )
    assert active_delete.value.status_code == 409

    session.is_active = False
    await db.commit()
    response = await main.permanently_delete_session(
        session_id=session.session_id,
        user=data["teacher"],
        db=db,
    )
    assert response["ok"] is True
    assert await db.get(models.Session, session.session_id) is None


@pytest.mark.asyncio
async def test_student_accesses_all_active_subjects_associated_with_class(seeded_db):
    db, data = seeded_db
    maths_association = models.ClassSubjectAssociation(
        class_id=data["class_one"].class_id,
        subject_id=data["maths"].subject_id,
    )
    db.add(maths_association)
    await db.commit()

    await access.require_class_access(
        db,
        data["student"],
        data["class_one"].class_id,
        data["english"].subject_id,
    )
    await access.require_class_access(
        db,
        data["student"],
        data["class_one"].class_id,
        data["maths"].subject_id,
    )


@pytest.mark.asyncio
async def test_student_denied_archived_class_subject_pair(seeded_db):
    db, data = seeded_db
    result = await db.execute(
        models.ClassSubjectAssociation.__table__.select().where(
            models.ClassSubjectAssociation.class_id == data["class_one"].class_id
        )
    )
    association = await db.get(
        models.ClassSubjectAssociation,
        result.first().association_id,
    )
    association.is_active = False
    await db.commit()

    with pytest.raises(HTTPException) as denied:
        await access.require_class_access(
            db,
            data["student"],
            data["class_one"].class_id,
            data["english"].subject_id,
        )
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_teacher_cannot_access_another_teachers_session(seeded_db):
    db, data = seeded_db
    other_teacher = models.User(
        name="Teacher Two",
        phone_number="9000000004",
        role="teacher",
        password_hash="test",
    )
    db.add(other_teacher)
    await db.flush()
    db.add(
        models.TeacherClassSubjectAssignment(
            teacher_id=other_teacher.user_id,
            class_id=data["class_one"].class_id,
            subject_id=data["english"].subject_id,
        )
    )
    session = models.Session(
        title="Teacher one's room",
        created_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(session)
    await db.commit()

    with pytest.raises(HTTPException) as denied:
        await access.require_session_access(db, other_teacher, session)
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_student_cannot_stream_other_class_audio(seeded_db):
    db, data = seeded_db
    audio = models.AudioFile(
        title="Class 2 audio",
        file_path="unused.mp3",
        uploaded_by=data["teacher"].user_id,
        class_id=data["class_two"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(audio)
    await db.commit()
    with pytest.raises(HTTPException) as denied:
        await access.require_audio_access(db, data["student"], audio)
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_teacher_cannot_access_another_teachers_audio(seeded_db):
    db, data = seeded_db
    other_teacher = models.User(
        name="Teacher Two",
        phone_number="9000000005",
        role="teacher",
        password_hash="test",
    )
    db.add(other_teacher)
    await db.flush()
    db.add(
        models.TeacherClassSubjectAssignment(
            teacher_id=other_teacher.user_id,
            class_id=data["class_one"].class_id,
            subject_id=data["english"].subject_id,
        )
    )
    audio = models.AudioFile(
        title="Teacher one's audio",
        file_path="unused.mp3",
        uploaded_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(audio)
    await db.commit()

    with pytest.raises(HTTPException) as denied:
        await access.require_audio_access(db, other_teacher, audio)
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_class_transfer_hides_old_class_audio(seeded_db):
    db, data = seeded_db
    old_audio = models.AudioFile(
        title="Old class audio",
        file_path="unused.mp3",
        uploaded_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(old_audio)
    current = await access.get_active_student_membership(db, data["student"].user_id)
    current.is_active = False
    db.add(
        models.StudentClassMembership(
            student_id=data["student"].user_id,
            class_id=data["class_two"].class_id,
        )
    )
    await db.commit()
    with pytest.raises(HTTPException):
        await access.require_audio_access(db, data["student"], old_audio)


@pytest.mark.asyncio
async def test_teacher_playlist_visible_only_to_published_class(seeded_db):
    db, data = seeded_db
    playlist = models.TeacherPlaylist(
        owner_teacher_id=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
        title="Reading",
        is_published=True,
        is_archived=False,
    )
    db.add(playlist)
    await db.commit()
    await access.require_teacher_playlist_access(db, data["student"], playlist)
    with pytest.raises(HTTPException):
        await access.require_teacher_playlist_access(
            db, data["other_student"], playlist,
        )
    playlist.is_archived = True
    await db.commit()
    with pytest.raises(HTTPException):
        await access.require_teacher_playlist_access(db, data["student"], playlist)


@pytest.mark.asyncio
async def test_unpublished_teacher_playlist_is_hidden_from_student(seeded_db):
    db, data = seeded_db
    playlist = models.TeacherPlaylist(
        owner_teacher_id=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
        title="Draft reading",
        is_published=False,
        is_archived=False,
    )
    db.add(playlist)
    await db.commit()

    with pytest.raises(HTTPException) as denied:
        await access.require_teacher_playlist_access(db, data["student"], playlist)
    assert denied.value.status_code == 403


def test_student_playlist_is_private_to_owner():
    owner = models.User(user_id=1, name="Owner", phone_number="1", role="student", password_hash="x")
    other = models.User(user_id=2, name="Other", phone_number="2", role="student", password_hash="x")
    playlist = models.StudentPlaylist(
        playlist_id=1,
        owner_student_id=owner.user_id,
        title="Private",
    )
    access.require_student_playlist_owner(owner, playlist)
    with pytest.raises(HTTPException) as denied:
        access.require_student_playlist_owner(other, playlist)
    assert denied.value.status_code == 404


@pytest.mark.asyncio
async def test_private_playlist_marks_old_class_item_unavailable(seeded_db):
    db, data = seeded_db
    audio = models.AudioFile(
        title="Old class story",
        file_path="unused.mp3",
        uploaded_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
    )
    playlist = models.StudentPlaylist(
        owner_student_id=data["student"].user_id,
        title="Saved stories",
    )
    db.add_all([audio, playlist])
    await db.flush()
    db.add(
        models.StudentPlaylistItem(
            playlist_id=playlist.playlist_id,
            audio_id=audio.audio_id,
            position=0,
        )
    )
    await db.commit()

    loaded = await playlist_routes._student_playlist(db, playlist.playlist_id)
    payload = playlist_routes._student_payload(
        loaded,
        active_class_id=data["class_two"].class_id,
    )
    assert payload["items"][0]["available"] is False
    assert payload["items"][0]["stream_path"] is None
