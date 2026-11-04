"""Privacy-filtered, transaction-neutral activity events."""

import os
from datetime import datetime
from uuid import uuid4

import models
from logging_config import request_id

DETAIL_FIELDS = {
    "position", "speed", "offline", "count", "reason_code", "participant_id",
    "target_user_id", "audio_id", "quiz_id", "attempt_id", "question_id",
    "revision", "is_muted", "is_self_mute", "understood", "repeat", "help",
    "success", "failure", "recipients", "step", "extra_minutes",
    "status", "duration_ms",
}


def enabled():
    return os.getenv("ACTIVITY_COLLECTION_ENABLED", "false").lower() == "true"


def record_event(
    db, event_type, *, actor_id=None, resource_type=None, resource_id=None,
    owner_teacher_id=None, class_id=None, subject_id=None, source="server",
    outcome="success", details=None, event_id=None, occurred_at=None,
):
    if not enabled():
        return None
    clean = {}
    for key, value in (details or {}).items():
        if key not in DETAIL_FIELDS:
            continue
        if isinstance(value, (bool, int, float)) and not isinstance(value, complex):
            clean[key] = value
        elif key == "reason_code" and isinstance(value, str) and value in {
            "network", "storage", "cancelled", "permission", "invalid", "unknown",
        }:
            clean[key] = value
    live_session = resource_type == "session" and event_type != "session_deleted"
    if live_session and any(
        isinstance(obj, models.Session) and obj.session_id == resource_id
        for obj in db.deleted
    ):
        live_session = False
    entry = models.Log(
        event_id=event_id or str(uuid4()), event_type=event_type[:50],
        user_id=actor_id, resource_type=resource_type, resource_id=resource_id,
        session_id=resource_id if live_session else None,
        owner_teacher_id=owner_teacher_id, class_id=class_id, subject_id=subject_id,
        source=source, outcome=outcome, event_details=clean,
        created_at=occurred_at or datetime.utcnow(), received_at=datetime.utcnow(),
        request_id=request_id.get(),
    )
    db.add(entry)
    return entry


def install_orm_audit():
    """Audit committed ORM state changes without copying model attributes into payloads."""
    from sqlalchemy import event, inspect
    from sqlalchemy.orm import Session as SyncSession
    if event.contains(SyncSession, "after_flush", _audit_flush):
        return
    event.listen(SyncSession, "after_flush", _audit_flush)
    event.listen(SyncSession, "after_rollback", _clear_audited)


def _clear_audited(session):
    session.info.pop("audit_events", None)


def _related(session, model, identity):
    key = model.__mapper__.primary_key[0].key
    for obj in list(session.new) + list(session.deleted):
        if isinstance(obj, model) and getattr(obj, key) == identity:
            return obj
    return session.get(model, identity)


def _audit_flush(session, context):
    from sqlalchemy import inspect
    if not enabled():
        return
    for obj in list(session.new) + list(session.dirty) + list(session.deleted):
        if isinstance(obj, (models.Log, models.AnalyticsSession, models.SessionRun,
                            models.Attendance, models.AttendanceJoin, models.MaintenanceState)):
            continue
        if obj in session.dirty and not session.is_modified(obj, include_collections=False):
            continue
        state = inspect(obj)
        name = obj.__tablename__
        operation = "created" if obj in session.new else "deleted" if obj in session.deleted else "updated"
        owner = getattr(obj, "owner_teacher_id", None)
        class_id, subject_id = getattr(obj, "class_id", None), getattr(obj, "subject_id", None)
        identity = state.identity or tuple(getattr(obj, key.name, None) for key in state.mapper.primary_key)
        resource_id = identity[0] if identity and isinstance(identity[0], int) else None
        actor_id = session.info.get("actor_id")
        kind = {
            "classes": "class", "quizzes": "quiz", "subjects": "subject",
            "question_bank_questions": "bank_question",
        }.get(name, name.rstrip("s"))
        event_type = f"{kind}_{operation}"
        if isinstance(obj, models.Session):
            owner, kind = obj.created_by, "session"
            active = state.attrs.is_active.history
            event_type = "session_" + (
                "created" if operation == "created" else "deleted" if operation == "deleted"
                else "reactivated" if active.has_changes() and obj.is_active
                else "ended" if active.has_changes() else "updated"
            )
        elif isinstance(obj, models.AudioFile):
            owner, kind = obj.uploaded_by, "audio"
            event_type = "audio_uploaded" if operation == "created" else f"audio_{operation}"
        elif isinstance(obj, models.Participant):
            kind = "session"
            resource_id = obj.session_id
            event_type = ("participant_added" if operation == "created"
                          else "participant_removed" if operation == "deleted"
                          else "participant_updated")
            for field, yes, no in (
                ("is_kicked", "participant_kicked", "participant_updated"),
                ("is_muted", "participant_muted", "participant_unmuted"),
                ("hand_raised", "hand_raised", "hand_lowered"),
                ("left_at", "participant_left", "participant_updated"),
            ):
                if state.attrs[field].history.has_changes() and operation == "updated":
                    event_type = yes if getattr(obj, field) else no
                    break
            room = _related(session, models.Session, obj.session_id)
            if room:
                owner, class_id, subject_id = room.created_by, room.class_id, room.subject_id
        elif isinstance(obj, models.ChatMessage):
            kind, resource_id, event_type = "session", obj.session_id, "chat_message"
            room = _related(session, models.Session, obj.session_id)
            if room:
                owner, class_id, subject_id = room.created_by, room.class_id, room.subject_id
        elif isinstance(obj, (models.QuizAttempt, models.QuizResponse)):
            attempt = obj if isinstance(obj, models.QuizAttempt) else _related(session, models.QuizAttempt, obj.attempt_id)
            quiz = _related(session, models.Quiz, attempt.quiz_id) if attempt else None
            if quiz:
                owner, class_id, subject_id = quiz.owner_teacher_id, quiz.class_id, quiz.subject_id
                kind, resource_id = "quiz", quiz.quiz_id
            if isinstance(obj, models.QuizAttempt):
                event_type = "quiz_attempt_" + (
                    "started" if operation == "created" and obj.status == "in_progress"
                    else obj.status if state.attrs.status.history.has_changes()
                    else operation
                )
        elif isinstance(obj, (models.QuizQuestion, models.QuizOption, models.QuizAccommodation)):
            question = _related(session, models.QuizQuestion, obj.quiz_question_id) if isinstance(obj, models.QuizOption) else None
            quiz_id = question.quiz_id if question else getattr(obj, "quiz_id", None)
            quiz = _related(session, models.Quiz, quiz_id) if quiz_id is not None else None
            if quiz:
                owner, class_id, subject_id = quiz.owner_teacher_id, quiz.class_id, quiz.subject_id
                kind, resource_id = "quiz", quiz.quiz_id
        elif isinstance(obj, (models.QuestionBankRevision, models.QuestionBankOption)):
            question = _related(session, models.QuestionBankQuestion, obj.question_id)
            if question:
                owner, class_id, subject_id = question.owner_teacher_id, question.class_id, question.subject_id
                kind, resource_id = "bank_question", question.question_id
        elif isinstance(obj, models.Quiz):
            if operation == "updated" and state.attrs.status.history.has_changes():
                event_type = {"published": "quiz_published", "closed": "quiz_closed"}.get(obj.status, event_type)
        elif isinstance(obj, models.TeacherPlaylistItem):
            playlist = _related(session, models.TeacherPlaylist, obj.playlist_id)
            if playlist:
                owner, class_id, subject_id = playlist.owner_teacher_id, playlist.class_id, playlist.subject_id
                kind, resource_id = "teacher_playlist", playlist.playlist_id
        elif isinstance(obj, models.User):
            kind = "user"
            event_type = "account_" + operation
            if state.attrs.password_hash.history.has_changes() and operation != "created":
                event_type = "password_changed"
        if isinstance(obj, models.StudentPlaylist) or isinstance(obj, models.StudentPlaylistItem):
            # Private collections expose only operation totals to administrators.
            actor_id, resource_id, kind = None, None, "private_playlist"
            owner, class_id, subject_id = None, None, None
            event_type = "private_playlist_" + operation
        record_event(
            session, event_type, actor_id=actor_id, resource_type=kind,
            resource_id=resource_id, owner_teacher_id=owner,
            class_id=class_id, subject_id=subject_id,
        )
        session.info.setdefault("audit_events", set()).add((event_type, resource_id))
