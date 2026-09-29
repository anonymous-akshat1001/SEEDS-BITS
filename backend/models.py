# models.py
from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Text, ForeignKey, Boolean,
    TIMESTAMP, CheckConstraint, JSON, text, Float, UniqueConstraint, Index
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from database import Base


# Stores all teachers + users and helps distiguinsh between them
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
        CheckConstraint("role IN ('admin', 'teacher', 'student')", name="check_role"),
    )

    # Relationships
    sessions_created = relationship("Session", back_populates="creator")
    uploads = relationship("AudioFile", back_populates="uploader")
    participants = relationship("Participant", back_populates="user")
    student_class_memberships = relationship(
        "StudentClassMembership", back_populates="student",
        foreign_keys="StudentClassMembership.student_id",
    )
    teacher_assignments = relationship(
        "TeacherClassSubjectAssignment", back_populates="teacher",
        foreign_keys="TeacherClassSubjectAssignment.teacher_id",
    )


class SchoolClass(Base):
    """Managed school classes. ``Class`` is avoided as a Python keyword."""

    __tablename__ = "classes"

    class_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(40), unique=True, nullable=False)
    sort_order = Column(Integer, unique=True, nullable=False)
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)


class Subject(Base):
    __tablename__ = "subjects"

    subject_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    archived_at = Column(TIMESTAMP)


class StudentClassMembership(Base):
    __tablename__ = "student_class_memberships"

    membership_id = Column(Integer, primary_key=True, index=True)
    student_id = Column(
        Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False,
    )
    class_id = Column(
        Integer, ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False,
    )
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    assigned_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    ended_at = Column(TIMESTAMP)
    assigned_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))

    student = relationship("User", back_populates="student_class_memberships", foreign_keys=[student_id])
    school_class = relationship("SchoolClass")
    assigner = relationship("User", foreign_keys=[assigned_by])

    __table_args__ = (
        Index(
            "uq_active_student_class",
            "student_id",
            unique=True,
            postgresql_where=text("is_active = true"),
            sqlite_where=text("is_active = 1"),
        ),
    )


class TeacherClassSubjectAssignment(Base):
    __tablename__ = "teacher_class_subject_assignments"

    assignment_id = Column(Integer, primary_key=True, index=True)
    teacher_id = Column(
        Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False,
    )
    class_id = Column(
        Integer, ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False,
    )
    subject_id = Column(
        Integer, ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False,
    )
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    assigned_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    archived_at = Column(TIMESTAMP)
    assigned_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))

    teacher = relationship("User", back_populates="teacher_assignments", foreign_keys=[teacher_id])
    school_class = relationship("SchoolClass")
    subject = relationship("Subject")
    assigner = relationship("User", foreign_keys=[assigned_by])

    __table_args__ = (
        UniqueConstraint(
            "teacher_id", "class_id", "subject_id",
            name="uq_teacher_class_subject",
        ),
    )


# Represents a live class created by a teacher
class Session(Base):
    __tablename__ = "sessions"

    session_id = Column(Integer, primary_key=True, index=True)
    title = Column(Text)
    created_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    class_id = Column(Integer, ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False)
    subject_id = Column(Integer, ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False)
    is_active = Column(Boolean, server_default=text("true"))
    created_at = Column(TIMESTAMP, server_default=func.now())
    ended_at = Column(TIMESTAMP)
    # Relationships
    creator = relationship("User", back_populates="sessions_created")
    participants = relationship("Participant", back_populates="session", cascade="all, delete-orphan")
    playbacks = relationship("Playback", back_populates="session", cascade="all, delete-orphan")
    # questions = relationship("Question", back_populates="session", cascade="all, delete-orphan")
    logs = relationship("Log", back_populates="session", cascade="all, delete-orphan")
    chat_messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")
    # audio_messages = relationship("AudioMessage", back_populates="session", cascade="all, delete-orphan")
    session_audios = relationship("SessionAudio", back_populates="session", cascade="all, delete-orphan")
    school_class = relationship("SchoolClass")
    subject = relationship("Subject")


# Represents a user inside a session(links User table with Session Table)
class Participant(Base):
    __tablename__ = "participants"

    participant_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    joined_at = Column(TIMESTAMP, server_default=func.now())
    left_at = Column(TIMESTAMP)
    is_muted = Column(Boolean, server_default=text("true"))  
    is_kicked = Column(Boolean, server_default=text("false"))
    hand_raised = Column(Boolean, server_default=text("false"))  # Added for raise hand feature

    # Relationships
    session = relationship("Session", back_populates="participants")
    user = relationship("User", back_populates="participants")
    chat_messages = relationship("ChatMessage", back_populates="participant")
    # audio_messages = relationship("AudioMessage", back_populates="participant")


# Represents audio file uploaded by teacher
class AudioFile(Base):
    __tablename__ = "audio_files"

    audio_id = Column(Integer, primary_key=True, index=True)
    title = Column(Text, nullable=False)
    description = Column(Text, server_default="")
    file_path = Column(Text, nullable=False)
    mime_type = Column(Text, server_default="audio/mpeg")
    duration = Column(Float)  # Duration in seconds (optional)
    uploaded_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    class_id = Column(Integer, ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False)
    subject_id = Column(Integer, ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False)
    uploaded_at = Column(TIMESTAMP, server_default=func.now())

    # Relationships
    uploader    = relationship("User",         back_populates="uploads")
    playbacks   = relationship("Playback",     back_populates="audio")
    # audio_messages = relationship("AudioMessage", back_populates="audio_file")
    session_links = relationship("SessionAudio", back_populates="audio", cascade="all, delete-orphan")
    school_class = relationship("SchoolClass")
    subject = relationship("Subject")


# Tracks when an audio file is played in a session
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


# Table which creates a link between Audio file uploaded by a teacher and all the session created by this teacher
class SessionAudio(Base):
    __tablename__ = "session_audio"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False)
    audio_id = Column(Integer, ForeignKey("audio_files.audio_id", ondelete="CASCADE"), nullable=False)
    added_at = Column(TIMESTAMP, server_default=func.now())

    # Relationships
    session = relationship("Session", back_populates="session_audios")
    audio = relationship("AudioFile", back_populates="session_links")


# Stores system events and logs them
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


# Stores authentication tokens
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


# Stores chat messages sent in a particular session
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


# Stores device tokens for push notifications
class FCMToken(Base):
    __tablename__ = "fcm_tokens"
    
    token_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    token = Column(Text, nullable=False)
    device_type = Column(String(20))  # 'android', 'ios', 'web'
    created_at = Column(TIMESTAMP, server_default=func.now())
    last_used = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())
    
    user = relationship("User", back_populates="fcm_tokens")


class TeacherPlaylist(Base):
    __tablename__ = "teacher_playlists"

    playlist_id = Column(Integer, primary_key=True, index=True)
    owner_teacher_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    class_id = Column(Integer, ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False)
    subject_id = Column(Integer, ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False)
    title = Column(String(300), nullable=False)
    description = Column(Text, server_default="")
    is_published = Column(Boolean, nullable=False, server_default=text("false"))
    is_archived = Column(Boolean, nullable=False, server_default=text("false"))
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now(), nullable=False)

    owner = relationship("User")
    school_class = relationship("SchoolClass")
    subject = relationship("Subject")
    items = relationship(
        "TeacherPlaylistItem", back_populates="playlist",
        cascade="all, delete-orphan", order_by="TeacherPlaylistItem.position",
    )


class TeacherPlaylistItem(Base):
    __tablename__ = "teacher_playlist_items"

    item_id = Column(Integer, primary_key=True, index=True)
    playlist_id = Column(Integer, ForeignKey("teacher_playlists.playlist_id", ondelete="CASCADE"), nullable=False)
    audio_id = Column(Integer, ForeignKey("audio_files.audio_id", ondelete="CASCADE"), nullable=False)
    position = Column(Integer, nullable=False)
    added_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)

    playlist = relationship("TeacherPlaylist", back_populates="items")
    audio = relationship("AudioFile")

    __table_args__ = (
        UniqueConstraint("playlist_id", "audio_id", name="uq_teacher_playlist_audio"),
        UniqueConstraint("playlist_id", "position", name="uq_teacher_playlist_position"),
    )


class StudentPlaylist(Base):
    __tablename__ = "student_playlists"

    playlist_id = Column(Integer, primary_key=True, index=True)
    owner_student_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    title = Column(String(300), nullable=False)
    description = Column(Text, server_default="")
    visibility = Column(String(20), nullable=False, server_default="private")
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now(), nullable=False)

    owner = relationship("User")
    items = relationship(
        "StudentPlaylistItem", back_populates="playlist",
        cascade="all, delete-orphan", order_by="StudentPlaylistItem.position",
    )

    __table_args__ = (
        CheckConstraint(
            "visibility = 'private'",
            name="check_student_playlist_private_visibility",
        ),
    )


class StudentPlaylistItem(Base):
    __tablename__ = "student_playlist_items"

    item_id = Column(Integer, primary_key=True, index=True)
    playlist_id = Column(Integer, ForeignKey("student_playlists.playlist_id", ondelete="CASCADE"), nullable=False)
    audio_id = Column(Integer, ForeignKey("audio_files.audio_id", ondelete="CASCADE"), nullable=False)
    position = Column(Integer, nullable=False)
    added_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)

    playlist = relationship("StudentPlaylist", back_populates="items")
    audio = relationship("AudioFile")

    __table_args__ = (
        UniqueConstraint("playlist_id", "audio_id", name="uq_student_playlist_audio"),
        UniqueConstraint("playlist_id", "position", name="uq_student_playlist_position"),
    )
