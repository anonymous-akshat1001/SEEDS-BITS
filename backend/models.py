# models.py
from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Text, ForeignKey, Boolean,
    TIMESTAMP, CheckConstraint, JSON, text, Float
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from database import Base


class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    name = Column(Text, nullable=False)
    phone_number = Column(Text, unique=True, nullable=False)
    role = Column(String(20), nullable=False)
    password_hash = Column(Text, nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now())
    fcm_tokens = relationship("FCMToken", back_populates="user", cascade="all, delete-orphan")


    __table_args__ = (
        CheckConstraint("role IN ('teacher', 'student')", name="check_role"),
    )

    # Relationships
    sessions_created = relationship("Session", back_populates="creator")
    uploads = relationship("AudioFile", back_populates="uploader")
    participants = relationship("Participant", back_populates="user")


class Session(Base):
    __tablename__ = "sessions"

    session_id = Column(Integer, primary_key=True, index=True)
    title = Column(Text)
    created_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    is_active = Column(Boolean, server_default=text("true"))
    created_at = Column(TIMESTAMP, server_default=func.now())
    ended_at = Column(TIMESTAMP)

    # Relationships
    creator = relationship("User", back_populates="sessions_created")
    participants = relationship("Participant", back_populates="session", cascade="all, delete-orphan")
    playbacks = relationship("Playback", back_populates="session", cascade="all, delete-orphan")
    questions = relationship("Question", back_populates="session", cascade="all, delete-orphan")
    logs = relationship("Log", back_populates="session", cascade="all, delete-orphan")
    chat_messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")
    audio_messages = relationship("AudioMessage", back_populates="session", cascade="all, delete-orphan")


class Participant(Base):
    __tablename__ = "participants"

    participant_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    joined_at = Column(TIMESTAMP, server_default=func.now())
    left_at = Column(TIMESTAMP)
    is_muted = Column(Boolean, server_default=text("false"))  # Changed default to false for better UX
    is_kicked = Column(Boolean, server_default=text("false"))
    hand_raised = Column(Boolean, server_default=text("false"))  # Added for raise hand feature

    # Relationships
    session = relationship("Session", back_populates="participants")
    user = relationship("User", back_populates="participants")
    chat_messages = relationship("ChatMessage", back_populates="participant")
    audio_messages = relationship("AudioMessage", back_populates="participant")


class AudioFile(Base):
    __tablename__ = "audio_files"

    audio_id = Column(Integer, primary_key=True, index=True)
    title = Column(Text, nullable=False)
    description = Column(Text, server_default="")
    file_path = Column(Text, nullable=False)
    mime_type = Column(Text, server_default="audio/mpeg")
    duration = Column(Float)  # Duration in seconds (optional)
    uploaded_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    uploaded_at = Column(TIMESTAMP, server_default=func.now())
    duration = Column(Float)  # Duration in seconds (optional)

    # Relationships
    uploader = relationship("User", back_populates="uploads")
    playbacks = relationship("Playback", back_populates="audio")
    audio_messages = relationship("AudioMessage", back_populates="audio_file")


class Playback(Base):
    __tablename__ = "playback"

    playback_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False)
    audio_file_id = Column(Integer, ForeignKey("audio_files.audio_id", ondelete="SET NULL"))  # Fixed column name
    started_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    started_at = Column(TIMESTAMP, server_default=func.now())
    ended_at = Column(TIMESTAMP)
    speed = Column(Float, server_default=text("1.0"))  # Playback speed

    # Relationships
    session = relationship("Session", back_populates="playbacks")
    audio = relationship("AudioFile", back_populates="playbacks")
    starter = relationship("User")


class Question(Base):
    __tablename__ = "questions"

    question_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False)
    asked_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    content = Column(Text, nullable=False)
    asked_at = Column(TIMESTAMP, server_default=func.now())
    is_answered = Column(Boolean, server_default=text("false"))

    # Relationships
    session = relationship("Session", back_populates="questions")
    asker = relationship("User")


class Log(Base):
    __tablename__ = "logs"

    log_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sessions.session_id", ondelete="CASCADE"))
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    event_type = Column(String(50), nullable=False)
    event_details = Column(JSON)
    created_at = Column(TIMESTAMP, server_default=func.now())

    # Relationships
    session = relationship("Session", back_populates="logs")
    user = relationship("User")


class JwtToken(Base):
    __tablename__ = "jwt_tokens"

    token_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    token = Column(Text, unique=True, nullable=False)
    issued_at = Column(TIMESTAMP, server_default=func.now())
    expires_at = Column(TIMESTAMP, nullable=False)
    is_revoked = Column(Boolean, server_default=text("false"))

    # Relationships
    user = relationship("User")


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    # Changed to Integer for consistency with other tables
    message_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False)
    participant_id = Column(Integer, ForeignKey("participants.participant_id", ondelete="CASCADE"), nullable=False)
    message = Column(Text, nullable=False)
    timestamp = Column(TIMESTAMP, server_default=func.now())
    is_system_message = Column(Boolean, server_default=text("false"))  # For system notifications

    # Relationships
    session = relationship("Session", back_populates="chat_messages")
    participant = relationship("Participant", back_populates="chat_messages")


class AudioMessage(Base):
    __tablename__ = "audio_messages"

    # Changed to Integer for consistency
    audio_message_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False)
    participant_id = Column(Integer, ForeignKey("participants.participant_id", ondelete="CASCADE"), nullable=False)
    audio_file_id = Column(Integer, ForeignKey("audio_files.audio_id", ondelete="SET NULL"))
    timestamp = Column(TIMESTAMP, server_default=func.now())
    duration = Column(Float)  # Duration in seconds

    # Relationships
    session = relationship("Session", back_populates="audio_messages")
    participant = relationship("Participant", back_populates="audio_messages")
    audio_file = relationship("AudioFile", back_populates="audio_messages")


class FCMToken(Base):
    __tablename__ = "fcm_tokens"
    
    token_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    token = Column(Text, nullable=False)
    device_type = Column(String(20))  # 'android', 'ios', 'web'
    created_at = Column(TIMESTAMP, server_default=func.now())
    last_used = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())
    
    user = relationship("User")