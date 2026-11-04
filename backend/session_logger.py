# session_logger.py
# Comprehensive session logging module for SEEDS-BITS
# This module provides centralized logging for all session activities

from datetime import datetime, timedelta
from typing import Optional, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
import models
from activity_events import record_event


# Event type constants
class EventType:
    # Session lifecycle
    SESSION_CREATED = "session_created"
    SESSION_ENDED = "session_ended"
    
    # Participant events
    PARTICIPANT_JOINED = "participant_joined"
    PARTICIPANT_LEFT = "participant_left"
    PARTICIPANT_KICKED = "participant_kicked"
    PARTICIPANT_INVITED = "participant_invited"
    
    # Participant actions
    HAND_RAISED = "hand_raised"
    HAND_LOWERED = "hand_lowered"
    PARTICIPANT_MUTED = "participant_muted"
    PARTICIPANT_UNMUTED = "participant_unmuted"
    
    # Audio events
    AUDIO_UPLOADED = "audio_uploaded"
    AUDIO_SELECTED = "audio_selected"
    AUDIO_PLAY = "audio_play"
    AUDIO_PAUSE = "audio_pause"
    AUDIO_SEEK = "audio_seek"
    
    # Chat events
    CHAT_MESSAGE = "chat_message"


class SessionLogger:
   
    
    @staticmethod
    async def log_event(
        db: AsyncSession,
        session_id: int,
        event_type: str,
        user_id: Optional[int] = None,
        details: Optional[dict] = None
    ) -> Optional[models.Log]:
       
        if (event_type, session_id) in db.info.get("audit_events", set()):
            return None
        room = await db.get(models.Session, session_id)
        log_entry = record_event(
            db, event_type, actor_id=user_id, resource_type="session",
            resource_id=session_id,
            owner_teacher_id=room.created_by if room else None,
            class_id=room.class_id if room else None,
            subject_id=room.subject_id if room else None, details=details,
        )
        await db.commit()
        return log_entry
    
    
    @staticmethod
    async def log_session_created(
        db: AsyncSession,
        session_id: int,
        creator_id: int,
        title: str
    ):
        """Log when a session is created."""
        return await SessionLogger.log_event(
            db, session_id, EventType.SESSION_CREATED,
            user_id=creator_id,
            details={"title": title}
        )
    
    @staticmethod
    async def log_session_ended(
        db: AsyncSession,
        session_id: int,
        ended_by: int
    ):
        """Log when a session ends."""
        return await SessionLogger.log_event(
            db, session_id, EventType.SESSION_ENDED,
            user_id=ended_by,
            details={"ended_at": datetime.utcnow().isoformat()}
        )
    
    # Participant Events
    
    @staticmethod
    async def log_participant_joined(
        db: AsyncSession,
        session_id: int,
        user_id: int,
        participant_id: int,
        user_name: str
    ):
        """Log when a participant joins a session."""
        return await SessionLogger.log_event(
            db, session_id, EventType.PARTICIPANT_JOINED,
            user_id=user_id,
            details={
                "participant_id": participant_id,
                "user_name": user_name,
                "joined_at": datetime.utcnow().isoformat()
            }
        )
    
    @staticmethod
    async def log_participant_left(
        db: AsyncSession,
        session_id: int,
        user_id: int,
        participant_id: int
    ):
        """Log when a participant leaves a session."""
        return await SessionLogger.log_event(
            db, session_id, EventType.PARTICIPANT_LEFT,
            user_id=user_id,
            details={
                "participant_id": participant_id,
                "left_at": datetime.utcnow().isoformat()
            }
        )
    
    @staticmethod
    async def log_participant_kicked(
        db: AsyncSession,
        session_id: int,
        kicked_user_id: int,
        kicked_by_user_id: int,
        participant_id: int,
        reason: Optional[str] = None
    ):
        """Log when a participant is kicked from a session."""
        return await SessionLogger.log_event(
            db, session_id, EventType.PARTICIPANT_KICKED,
            user_id=kicked_by_user_id,
            details={
                "participant_id": participant_id,
                "kicked_user_id": kicked_user_id,
                "reason": reason,
                "kicked_at": datetime.utcnow().isoformat()
            }
        )
    
    @staticmethod
    async def log_participant_invited(
        db: AsyncSession,
        session_id: int,
        invited_user_id: int,
        invited_by_user_id: int
    ):
        """Log when a participant is invited to a session."""
        return await SessionLogger.log_event(
            db, session_id, EventType.PARTICIPANT_INVITED,
            user_id=invited_by_user_id,
            details={
                "invited_user_id": invited_user_id,
                "invited_at": datetime.utcnow().isoformat()
            }
        )
    
    # Participant Actions
    
    @staticmethod
    async def log_hand_raised(
        db: AsyncSession,
        session_id: int,
        user_id: int,
        participant_id: int
    ):
        """Log when a participant raises their hand."""
        return await SessionLogger.log_event(
            db, session_id, EventType.HAND_RAISED,
            user_id=user_id,
            details={"participant_id": participant_id}
        )
    
    @staticmethod
    async def log_hand_lowered(
        db: AsyncSession,
        session_id: int,
        user_id: int,
        participant_id: int
    ):
        """Log when a participant lowers their hand."""
        return await SessionLogger.log_event(
            db, session_id, EventType.HAND_LOWERED,
            user_id=user_id,
            details={"participant_id": participant_id}
        )
    
    @staticmethod
    async def log_participant_muted(
        db: AsyncSession,
        session_id: int,
        target_user_id: int,
        muted_by_user_id: int,
        participant_id: int,
        is_self_mute: bool = False
    ):
        """Log when a participant is muted."""
        return await SessionLogger.log_event(
            db, session_id, EventType.PARTICIPANT_MUTED,
            user_id=muted_by_user_id,
            details={
                "participant_id": participant_id,
                "target_user_id": target_user_id,
                "is_self_mute": is_self_mute
            }
        )
    
    @staticmethod
    async def log_participant_unmuted(
        db: AsyncSession,
        session_id: int,
        target_user_id: int,
        unmuted_by_user_id: int,
        participant_id: int,
        is_self_unmute: bool = False
    ):
        """Log when a participant is unmuted."""
        return await SessionLogger.log_event(
            db, session_id, EventType.PARTICIPANT_UNMUTED,
            user_id=unmuted_by_user_id,
            details={
                "participant_id": participant_id,
                "target_user_id": target_user_id,
                "is_self_unmute": is_self_unmute
            }
        )
    
    # Audio Events
    
    @staticmethod
    async def log_audio_selected(
        db: AsyncSession,
        session_id: int,
        user_id: int,
        audio_id: int,
        audio_title: str
    ):
        """Log when an audio file is selected."""
        return await SessionLogger.log_event(
            db, session_id, EventType.AUDIO_SELECTED,
            user_id=user_id,
            details={
                "audio_id": audio_id,
                "audio_title": audio_title
            }
        )
    
    @staticmethod
    async def log_audio_play(
        db: AsyncSession,
        session_id: int,
        user_id: int,
        audio_id: int,
        position: float = 0.0,
        speed: float = 1.0
    ):
        """Log when audio playback starts."""
        return await SessionLogger.log_event(
            db, session_id, EventType.AUDIO_PLAY,
            user_id=user_id,
            details={
                "audio_id": audio_id,
                "position": position,
                "speed": speed
            }
        )
    
    @staticmethod
    async def log_audio_pause(
        db: AsyncSession,
        session_id: int,
        user_id: int,
        audio_id: Optional[int] = None,
        position: float = 0.0
    ):
        """Log when audio playback is paused."""
        return await SessionLogger.log_event(
            db, session_id, EventType.AUDIO_PAUSE,
            user_id=user_id,
            details={
                "audio_id": audio_id,
                "position": position
            }
        )
    
    @staticmethod
    async def log_audio_seek(
        db: AsyncSession,
        session_id: int,
        user_id: int,
        audio_id: int,
        position: float
    ):
        """Log when audio position is seeked."""
        return await SessionLogger.log_event(
            db, session_id, EventType.AUDIO_SEEK,
            user_id=user_id,
            details={
                "audio_id": audio_id,
                "position": position
            }
        )
    
    # Chat Events
    
    @staticmethod
    async def log_chat_message(
        db: AsyncSession,
        session_id: int,
        user_id: int,
        participant_id: int,
        message: str
    ):
        """Log when a chat message is sent."""
        return await SessionLogger.log_event(
            db, session_id, EventType.CHAT_MESSAGE,
            user_id=user_id,
            details={
                "participant_id": participant_id,
                "message": message,
                "message_length": len(message)
            }
        )
    
    # Audio Upload Event
    
    @staticmethod
    async def log_audio_uploaded(
        db: AsyncSession,
        user_id: int,
        audio_id: int,
        title: str,
        file_path: str,
        duration: Optional[float] = None
    ):
        """Log when a teacher uploads an audio file."""
        # Note: session_id is 0 for global uploads not tied to a session
        if (EventType.AUDIO_UPLOADED, audio_id) in db.info.get("audit_events", set()):
            return None
        audio = await db.get(models.AudioFile, audio_id)
        log_entry = record_event(
            db, EventType.AUDIO_UPLOADED, actor_id=user_id, resource_type="audio",
            resource_id=audio_id, owner_teacher_id=user_id,
            class_id=audio.class_id if audio else None,
            subject_id=audio.subject_id if audio else None,
        )
        await db.commit()
        return log_entry


async def get_session_logs(
    db: AsyncSession,
    session_id: int,
    event_type: Optional[str] = None,
    user_id: Optional[int] = None,
    limit: int = 100
) -> list[models.Log]:
   
    query = select(models.Log).filter(
        models.Log.session_id == session_id,
        models.Log.created_at > datetime.utcnow() - timedelta(days=30),
    )
    
    if event_type:
        query = query.filter(models.Log.event_type == event_type)
    if user_id:
        query = query.filter(models.Log.user_id == user_id)
    
    query = query.order_by(models.Log.created_at.desc()).limit(limit)
    
    result = await db.execute(query)
    return result.scalars().all()


async def get_user_session_activity(
    db: AsyncSession,
    user_id: int,
    session_id: Optional[int] = None,
    limit: int = 100
) -> list[models.Log]:
    
    query = select(models.Log).filter(
        models.Log.user_id == user_id,
        models.Log.created_at > datetime.utcnow() - timedelta(days=30),
    )
    
    if session_id:
        query = query.filter(models.Log.session_id == session_id)
    
    query = query.order_by(models.Log.created_at.desc()).limit(limit)
    
    result = await db.execute(query)
    return result.scalars().all()


async def get_session_summary(db: AsyncSession, session_id: int) -> dict:
    filters = (models.Log.session_id == session_id,
               models.Log.created_at > datetime.utcnow() - timedelta(days=30))
    event_counts = dict((await db.execute(
        select(models.Log.event_type, func.count()).where(*filters).group_by(models.Log.event_type)
    )).all())
    first, last = (await db.execute(select(
        func.min(models.Log.created_at), func.max(models.Log.created_at),
    ).where(*filters))).one()
    participants = await db.scalar(select(func.count(func.distinct(models.AttendanceJoin.student_id)))
        .join(models.SessionRun).where(
            models.SessionRun.session_id == session_id,
            (models.SessionRun.ended_at.is_(None)) | (models.SessionRun.expires_at > datetime.utcnow()),
        ))
    return {
        "session_id": session_id,
        "total_events": sum(event_counts.values()),
        "event_counts": event_counts,
        "unique_participants_joined": participants,
        "participants_left": event_counts.get(EventType.PARTICIPANT_LEFT, 0),
        "first_event": first.isoformat() if first else None,
        "last_event": last.isoformat() if last else None,
        "coverage": "Events: 30 days; verified attendance since collection was enabled.",
    }


# Convenience alias
logger = SessionLogger()
