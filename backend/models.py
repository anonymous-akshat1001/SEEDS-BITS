# models.py
from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Text, ForeignKey, Boolean,
    TIMESTAMP, CheckConstraint, JSON, text, Float, UniqueConstraint, Index,
    ForeignKeyConstraint, Date,
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from database import Base


class LearningJourney(Base):
    """A teacher-authored bundle of recordings, narration, questions and polls."""

    __tablename__ = "learning_journeys"

    journey_id = Column(Integer, primary_key=True)
    owner_teacher_id = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"), index=True)
    class_id = Column(Integer, ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False)
    subject_id = Column(Integer, ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False)
    title = Column(String(160), nullable=False)
    description = Column(Text)
    status = Column(String(20), nullable=False, server_default="draft")
    graded = Column(Boolean, nullable=False, server_default=text("false"))
    max_retries = Column(Integer, nullable=False, server_default=text("1"))
    # Draft content and its optimistic-lock revision.
    revision = Column(Integer, nullable=False, server_default=text("1"))
    steps = Column(JSON, nullable=False)
    # The draft revision that produced the latest published snapshot.
    published_from_revision = Column(Integer)
    published_revision = Column(Integer)
    published_at = Column(TIMESTAMP)
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())
    updated_at = Column(TIMESTAMP, nullable=False, server_default=func.now(), onupdate=func.now())

    subject = relationship("Subject")

    __table_args__ = (
        ForeignKeyConstraint(
            ["class_id", "subject_id"],
            ["class_subject_associations.class_id", "class_subject_associations.subject_id"],
            name="fk_journey_class_subject",
            ondelete="RESTRICT",
        ),
        CheckConstraint("status IN ('draft', 'published', 'archived')", name="check_journey_status"),
        CheckConstraint("max_retries >= 0 AND max_retries <= 5", name="check_journey_retries"),
        Index("ix_journey_workspace_status", "class_id", "subject_id", "status"),
    )


class JourneySnapshot(Base):
    """Immutable published content; runs are graded against their own snapshot."""

    __tablename__ = "journey_snapshots"

    journey_id = Column(Integer, ForeignKey("learning_journeys.journey_id", ondelete="CASCADE"), primary_key=True)
    revision = Column(Integer, primary_key=True)
    content = Column(JSON, nullable=False)
    published_at = Column(TIMESTAMP, nullable=False, server_default=func.now())


class JourneyRun(Base):
    __tablename__ = "journey_runs"

    run_id = Column(String(36), primary_key=True)
    journey_id = Column(Integer, ForeignKey("learning_journeys.journey_id", ondelete="RESTRICT"), nullable=False)
    journey_revision = Column(Integer, nullable=False)
    student_id = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    status = Column(String(20), nullable=False, server_default="in_progress")
    started_at = Column(TIMESTAMP, nullable=False)
    completed_at = Column(TIMESTAMP)
    synced_at = Column(TIMESTAMP, nullable=False, server_default=func.now())
    played_offline = Column(Boolean, nullable=False, server_default=text("false"))
    question_count = Column(Integer, nullable=False, server_default=text("0"))
    first_try_correct = Column(Integer, nullable=False, server_default=text("0"))
    replays = Column(Integer, nullable=False, server_default=text("0"))
    percentage_score = Column(Float)

    answers = relationship("JourneyAnswer", back_populates="run", cascade="all, delete-orphan")

    __table_args__ = (
        CheckConstraint("status IN ('in_progress', 'completed')", name="check_journey_run_status"),
        Index("ix_journey_run_student", "journey_id", "student_id", "status"),
    )


class JourneyAnswer(Base):
    __tablename__ = "journey_answers"

    answer_id = Column(Integer, primary_key=True)
    run_id = Column(String(36), ForeignKey("journey_runs.run_id", ondelete="CASCADE"), nullable=False)
    step_index = Column(Integer, nullable=False)
    attempt = Column(Integer, nullable=False)
    selected_option = Column(Integer, nullable=False)
    # Computed by the server from the snapshot; null for polls.
    is_correct = Column(Boolean)
    answered_at = Column(TIMESTAMP, nullable=False)

    run = relationship("JourneyRun", back_populates="answers")

    __table_args__ = (
        UniqueConstraint("run_id", "step_index", "attempt", name="uq_journey_answer_attempt"),
    )


# Stores all teachers + users and helps distiguinsh between them

class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    name = Column(Text, nullable=False)
    phone_number = Column(Text, unique=True, nullable=False)
    role = Column(String(20), nullable=False)
    password_hash = Column(Text, nullable=False)
    auth_version = Column(Integer, nullable=False, default=0, server_default=text("0"))
    must_change_password = Column(Boolean, nullable=False, default=False, server_default=text("false"))
    temporary_password_expires_at = Column(TIMESTAMP)
    temporary_password_failures = Column(Integer, nullable=False, default=0, server_default=text("0"))
    temporary_password_locked_until = Column(TIMESTAMP)
    password_reset_at = Column(TIMESTAMP)
    password_reset_by = Column(Integer)
    # Students and teachers sign in by phone number only; an inactive account
    # cannot sign in or receive class alerts.
    is_active = Column(Boolean, nullable=False, default=True, server_default=text("true"))
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
    archived_at = Column(TIMESTAMP)


class Subject(Base):
    __tablename__ = "subjects"

    subject_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    archived_at = Column(TIMESTAMP)


class ClassSubjectAssociation(Base):
    __tablename__ = "class_subject_associations"

    association_id = Column(Integer, primary_key=True, index=True)
    class_id = Column(
        Integer, ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False,
    )
    subject_id = Column(
        Integer, ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False,
    )
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    associated_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    archived_at = Column(TIMESTAMP)
    associated_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))

    school_class = relationship("SchoolClass")
    subject = relationship("Subject")
    associator = relationship("User")

    __table_args__ = (
        UniqueConstraint("class_id", "subject_id", name="uq_class_subject"),
    )


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
        ForeignKeyConstraint(
            ["class_id", "subject_id"],
            [
                "class_subject_associations.class_id",
                "class_subject_associations.subject_id",
            ],
            name="fk_teacher_assignment_class_subject",
            ondelete="RESTRICT",
        ),
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
    # True only while the class is live (started by its teacher and not ended).
    is_active = Column(Boolean, server_default=text("true"))
    created_at = Column(TIMESTAMP, server_default=func.now())
    ended_at = Column(TIMESTAMP)
    hand_queue_sequence = Column(Integer, nullable=False, server_default=text("0"))
    # Timetable occurrence this live class belongs to; NULL for an unscheduled class.
    timetable_entry_id = Column(
        Integer, ForeignKey("timetable_entries.entry_id", ondelete="SET NULL"),
    )
    occurrence_date = Column(Date)
    scheduled_start = Column(TIMESTAMP)
    scheduled_end = Column(TIMESTAMP)
    started_at = Column(TIMESTAMP)
    # Automatic safety end; moved later only by bounded extensions.
    cutoff_at = Column(TIMESTAMP)
    extension_minutes = Column(Integer, nullable=False, server_default=text("0"))
    lesson_playlist_id = Column(
        Integer, ForeignKey("teacher_playlists.playlist_id", ondelete="SET NULL"),
    )
    end_reason = Column(String(20))
    # The quiz or journey the teacher started for the class, if any.
    activity_kind = Column(String(10))
    activity_id = Column(Integer)
    activity_title = Column(String(300))
    activity_started_at = Column(TIMESTAMP)
    # Relationships
    creator = relationship("User", back_populates="sessions_created")
    participants = relationship("Participant", back_populates="session", cascade="all, delete-orphan")
    playbacks = relationship("Playback", back_populates="session", cascade="all, delete-orphan")
    # questions = relationship("Question", back_populates="session", cascade="all, delete-orphan")
    logs = relationship("Log", back_populates="session", passive_deletes=True)
    chat_messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")
    # audio_messages = relationship("AudioMessage", back_populates="session", cascade="all, delete-orphan")
    session_audios = relationship("SessionAudio", back_populates="session", cascade="all, delete-orphan")
    school_class = relationship("SchoolClass")
    subject = relationship("Subject")

    __table_args__ = (
        ForeignKeyConstraint(
            ["class_id", "subject_id"],
            [
                "class_subject_associations.class_id",
                "class_subject_associations.subject_id",
            ],
            name="fk_session_class_subject",
            ondelete="RESTRICT",
        ),
        UniqueConstraint("timetable_entry_id", "occurrence_date", name="uq_session_occurrence"),
        # One live class per teacher and per enrolled class (which also gives
        # each student at most one live class).
        Index(
            "uq_live_session_teacher", "created_by", unique=True,
            postgresql_where=text("is_active = true"), sqlite_where=text("is_active = 1"),
        ),
        Index(
            "uq_live_session_class", "class_id", unique=True,
            postgresql_where=text("is_active = true"), sqlite_where=text("is_active = 1"),
        ),
    )


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
    hand_queue_order = Column(Integer)
    hand_revision = Column(Integer, nullable=False, server_default=text("0"))
    # First authenticated live-class connection; "ever joined" for rosters and reminders.
    first_connected_at = Column(TIMESTAMP)

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

    __table_args__ = (
        ForeignKeyConstraint(
            ["class_id", "subject_id"],
            [
                "class_subject_associations.class_id",
                "class_subject_associations.subject_id",
            ],
            name="fk_audio_class_subject",
            ondelete="RESTRICT",
        ),
    )


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
    session_id = Column(Integer, ForeignKey("sessions.session_id", ondelete="SET NULL"))
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    event_type = Column(String(50), nullable=False)
    event_details = Column(JSON)
    created_at = Column(TIMESTAMP, server_default=func.now())

    # Relationships
    session = relationship("Session", back_populates="logs")
    user = relationship("User")
    event_id = Column(String(36), unique=True)
    schema_version = Column(Integer, nullable=False, server_default=text("1"))
    resource_type = Column(String(40))
    resource_id = Column(Integer)
    owner_teacher_id = Column(Integer, index=True)
    class_id = Column(Integer)
    subject_id = Column(Integer)
    source = Column(String(24), nullable=False, server_default="legacy")
    outcome = Column(String(24), nullable=False, server_default="observed")
    received_at = Column(TIMESTAMP, server_default=func.now())
    request_id = Column(String(36))
    __table_args__ = (
        Index("ix_logs_scope_time", "owner_teacher_id", "class_id", "subject_id", "created_at"),
        Index("ix_logs_type_time", "event_type", "created_at"),
    )


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
    __table_args__ = (UniqueConstraint("token", name="uq_fcm_token"),)
    
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


class QuestionBankQuestion(Base):
    __tablename__ = "question_bank_questions"

    question_id = Column(Integer, primary_key=True)
    owner_teacher_id = Column(
        Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False,
    )
    class_id = Column(Integer, ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False)
    subject_id = Column(Integer, ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False)
    question_text = Column(Text, nullable=False)
    explanation = Column(Text)
    revision = Column(Integer)
    topics = Column(JSON)
    notation = Column(String(20), nullable=False, server_default="plain_text")
    spoken_question_text = Column(Text)
    spoken_options = Column(JSON)
    spoken_explanation = Column(Text)
    spoken_reviewed = Column(Boolean, nullable=False, server_default=text("false"))
    is_archived = Column(Boolean, nullable=False, server_default=text("false"))
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())
    updated_at = Column(TIMESTAMP, nullable=False, server_default=func.now(), onupdate=func.now())
    archived_at = Column(TIMESTAMP)

    owner = relationship("User")
    school_class = relationship("SchoolClass")
    subject = relationship("Subject")
    options = relationship(
        "QuestionBankOption", back_populates="question",
        cascade="all, delete-orphan", order_by="QuestionBankOption.position",
    )

    __table_args__ = (
        ForeignKeyConstraint(
            ["class_id", "subject_id"],
            ["class_subject_associations.class_id", "class_subject_associations.subject_id"],
            name="fk_bank_question_class_subject",
            ondelete="RESTRICT",
        ),
        Index("ix_bank_question_owner_workspace", "owner_teacher_id", "class_id", "subject_id"),
        Index("ix_bank_question_owner_archived", "owner_teacher_id", "is_archived"),
    )


class QuestionBankRevision(Base):
    __tablename__ = "question_bank_revisions"

    question_id = Column(Integer, ForeignKey("question_bank_questions.question_id", ondelete="CASCADE"), primary_key=True)
    revision = Column(Integer, primary_key=True)
    content = Column(JSON, nullable=False)
    recorded_at = Column(TIMESTAMP, nullable=False, server_default=func.now())


class QuestionBankOption(Base):
    __tablename__ = "question_bank_options"

    option_id = Column(Integer, primary_key=True)
    question_id = Column(
        Integer, ForeignKey("question_bank_questions.question_id", ondelete="CASCADE"), nullable=False,
    )
    option_text = Column(Text, nullable=False)
    position = Column(Integer, nullable=False)
    is_correct = Column(Boolean, nullable=False, server_default=text("false"))

    question = relationship("QuestionBankQuestion", back_populates="options")

    __table_args__ = (
        UniqueConstraint("question_id", "position", name="uq_bank_option_position"),
        CheckConstraint("position >= 0 AND position < 4", name="check_bank_option_position"),
    )


class Quiz(Base):
    __tablename__ = "quizzes"

    quiz_id = Column(Integer, primary_key=True)
    owner_teacher_id = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    class_id = Column(Integer, ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False)
    subject_id = Column(Integer, ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False)
    title = Column(String(300), nullable=False)
    description = Column(Text)
    mode = Column(String(20), nullable=False, server_default="graded")
    feedback_policy = Column(String(30), nullable=False, server_default="legacy_immediate")
    feedback_release_at = Column(TIMESTAMP)
    status = Column(String(20), nullable=False, server_default="draft")
    attempt_limit = Column(Integer, nullable=False, server_default=text("1"))
    opens_at = Column(TIMESTAMP)
    closes_at = Column(TIMESTAMP)
    time_limit_minutes = Column(Integer)
    shuffle_questions = Column(Boolean, nullable=False, server_default=text("false"))
    shuffle_options = Column(Boolean, nullable=False, server_default=text("false"))
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())
    updated_at = Column(TIMESTAMP, nullable=False, server_default=func.now(), onupdate=func.now())
    published_at = Column(TIMESTAMP)
    closed_at = Column(TIMESTAMP)

    owner = relationship("User")
    school_class = relationship("SchoolClass")
    subject = relationship("Subject")
    questions = relationship(
        "QuizQuestion", back_populates="quiz",
        cascade="all, delete-orphan", order_by="QuizQuestion.position",
    )
    attempts = relationship("QuizAttempt", back_populates="quiz")

    __table_args__ = (
        ForeignKeyConstraint(
            ["class_id", "subject_id"],
            ["class_subject_associations.class_id", "class_subject_associations.subject_id"],
            name="fk_quiz_class_subject",
            ondelete="RESTRICT",
        ),
        CheckConstraint("status IN ('draft', 'published', 'closed')", name="check_quiz_status"),
        CheckConstraint("attempt_limit >= 1 AND attempt_limit <= 20", name="check_quiz_attempt_limit"),
        CheckConstraint(
            "time_limit_minutes IS NULL OR (time_limit_minutes >= 1 AND time_limit_minutes <= 1440)",
            name="check_quiz_time_limit",
        ),
        CheckConstraint(
            "opens_at IS NULL OR closes_at IS NULL OR opens_at < closes_at",
            name="check_quiz_schedule",
        ),
        Index("ix_quiz_owner_workspace_status", "owner_teacher_id", "class_id", "subject_id", "status"),
        Index("ix_quiz_student_listing", "class_id", "subject_id", "status", "opens_at", "closes_at"),
    )


class QuizQuestion(Base):
    __tablename__ = "quiz_questions"

    quiz_question_id = Column(Integer, primary_key=True)
    quiz_id = Column(Integer, ForeignKey("quizzes.quiz_id", ondelete="CASCADE"), nullable=False)
    source_question_id = Column(
        Integer, ForeignKey("question_bank_questions.question_id", ondelete="SET NULL"),
    )
    question_text = Column(Text, nullable=False)
    explanation = Column(Text)
    source_revision = Column(Integer)
    topics = Column(JSON)
    notation = Column(String(20), nullable=False, server_default="plain_text")
    spoken_question_text = Column(Text)
    spoken_options = Column(JSON)
    spoken_explanation = Column(Text)
    spoken_reviewed = Column(Boolean, nullable=False, server_default=text("false"))
    position = Column(Integer, nullable=False)

    quiz = relationship("Quiz", back_populates="questions")
    source_question = relationship("QuestionBankQuestion")
    options = relationship(
        "QuizOption", back_populates="question",
        cascade="all, delete-orphan", order_by="QuizOption.position",
    )

    __table_args__ = (
        UniqueConstraint("quiz_id", "position", name="uq_quiz_question_position"),
    )


class QuizOption(Base):
    __tablename__ = "quiz_options"

    quiz_option_id = Column(Integer, primary_key=True)
    quiz_question_id = Column(
        Integer, ForeignKey("quiz_questions.quiz_question_id", ondelete="CASCADE"), nullable=False,
    )
    option_text = Column(Text, nullable=False)
    position = Column(Integer, nullable=False)
    is_correct = Column(Boolean, nullable=False, server_default=text("false"))

    question = relationship("QuizQuestion", back_populates="options")

    __table_args__ = (
        UniqueConstraint("quiz_question_id", "position", name="uq_quiz_option_position"),
        CheckConstraint("position >= 0 AND position < 4", name="check_quiz_option_position"),
    )


class QuizAttempt(Base):
    __tablename__ = "quiz_attempts"

    attempt_id = Column(Integer, primary_key=True)
    quiz_id = Column(Integer, ForeignKey("quizzes.quiz_id", ondelete="RESTRICT"), nullable=False)
    student_id = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    attempt_number = Column(Integer, nullable=False)
    status = Column(String(20), nullable=False, server_default="in_progress")
    started_at = Column(TIMESTAMP, nullable=False, server_default=func.now())
    deadline_at = Column(TIMESTAMP)
    extra_time_minutes = Column(Integer, nullable=False, server_default=text("0"))
    completed_at = Column(TIMESTAMP)
    retention_expires_at = Column(TIMESTAMP, index=True)
    correct_count = Column(Integer, nullable=False, server_default=text("0"))
    total_questions = Column(Integer, nullable=False)
    percentage_score = Column(Float, nullable=False, server_default=text("0"))
    question_order = Column(JSON, nullable=False)
    option_order = Column(JSON, nullable=False)

    quiz = relationship("Quiz", back_populates="attempts")
    student = relationship("User")
    responses = relationship("QuizResponse", back_populates="attempt")

    __table_args__ = (
        CheckConstraint(
            "status IN ('in_progress', 'completed', 'timed_out')",
            name="check_quiz_attempt_status",
        ),
        UniqueConstraint("quiz_id", "student_id", "attempt_number", name="uq_quiz_attempt_number"),
        Index(
            "uq_active_quiz_attempt",
            "quiz_id", "student_id",
            unique=True,
            postgresql_where=text("status = 'in_progress'"),
            sqlite_where=text("status = 'in_progress'"),
        ),
        Index("ix_quiz_attempt_student_quiz", "student_id", "quiz_id", "status"),
    )


class QuizAccommodation(Base):
    __tablename__ = "quiz_accommodations"
    quiz_id = Column(Integer, ForeignKey("quizzes.quiz_id", ondelete="CASCADE"), primary_key=True)
    student_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), primary_key=True)
    extra_minutes = Column(Integer, nullable=False, server_default=text("0"))


class QuizResponse(Base):
    __tablename__ = "quiz_responses"

    response_id = Column(Integer, primary_key=True)
    attempt_id = Column(
        Integer, ForeignKey("quiz_attempts.attempt_id", ondelete="RESTRICT"), nullable=False,
    )
    quiz_question_id = Column(
        Integer, ForeignKey("quiz_questions.quiz_question_id", ondelete="RESTRICT"), nullable=False,
    )
    selected_option_id = Column(
        Integer, ForeignKey("quiz_options.quiz_option_id", ondelete="RESTRICT"), nullable=False,
    )
    is_correct = Column(Boolean, nullable=False)
    submitted_at = Column(TIMESTAMP, nullable=False, server_default=func.now())

    attempt = relationship("QuizAttempt", back_populates="responses")
    question = relationship("QuizQuestion")
    selected_option = relationship("QuizOption")

    __table_args__ = (
        UniqueConstraint("attempt_id", "quiz_question_id", name="uq_quiz_response_question"),
        Index("ix_quiz_response_question", "quiz_question_id"),
    )


class AnalyticsSession(Base):
    __tablename__ = "analytics_sessions"
    session_id = Column(Integer, primary_key=True, autoincrement=False)
    owner_teacher_id = Column(Integer, nullable=True, index=True)
    class_id = Column(Integer, nullable=False)
    subject_id = Column(Integer, nullable=False)
    created_at = Column(TIMESTAMP, nullable=False)
    provenance = Column(String(24), nullable=False, server_default="verified")
    deleted_at = Column(TIMESTAMP)


class SessionRun(Base):
    __tablename__ = "session_runs"
    run_id = Column(String(36), primary_key=True)
    session_id = Column(Integer, ForeignKey("analytics_sessions.session_id", ondelete="CASCADE"), nullable=False)
    opened_at = Column(TIMESTAMP, nullable=False)
    ended_at = Column(TIMESTAMP)
    expires_at = Column(TIMESTAMP, index=True)
    __table_args__ = (
        Index("ix_session_run_end", "ended_at"),
        Index("uq_open_session_run", "session_id", unique=True,
              postgresql_where=text("ended_at IS NULL"), sqlite_where=text("ended_at IS NULL")),
    )


class Attendance(Base):
    __tablename__ = "analytics_attendance"
    run_id = Column(String(36), ForeignKey("session_runs.run_id", ondelete="CASCADE"), primary_key=True)
    student_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), primary_key=True)
    first_joined_at = Column(TIMESTAMP, nullable=False)
    last_joined_at = Column(TIMESTAMP, nullable=False)


class AttendanceJoin(Base):
    __tablename__ = "analytics_attendance_joins"
    join_id = Column(String(36), primary_key=True)
    run_id = Column(String(36), ForeignKey("session_runs.run_id", ondelete="CASCADE"), nullable=False)
    student_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    joined_at = Column(TIMESTAMP, nullable=False, index=True)


class MaintenanceState(Base):
    __tablename__ = "analytics_maintenance"
    name = Column(String(60), primary_key=True)
    succeeded_at = Column(TIMESTAMP)
    status = Column(String(24), nullable=False)
    count = Column(Integer, nullable=False, server_default=text("0"))

# ─── Shared devices (S43) ────────────────────────────────────────────────────


class DeviceGroup(Base):
    """Accounts that share one phone. The entry number selects the group and a
    short numeric profile code selects the person; neither proves identity."""

    __tablename__ = "device_groups"

    group_id = Column(Integer, primary_key=True)
    name = Column(String(120), nullable=False)
    entry_phone_number = Column(Text, unique=True, nullable=False)
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())

    members = relationship(
        "DeviceGroupMember", back_populates="group",
        cascade="all, delete-orphan", order_by="DeviceGroupMember.profile_code",
    )


class DeviceGroupMember(Base):
    __tablename__ = "device_group_members"

    member_id = Column(Integer, primary_key=True)
    group_id = Column(Integer, ForeignKey("device_groups.group_id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    profile_code = Column(String(8), nullable=False)

    group = relationship("DeviceGroup", back_populates="members")
    user = relationship("User")

    __table_args__ = (
        UniqueConstraint("group_id", "profile_code", name="uq_device_group_profile_code"),
        UniqueConstraint("user_id", name="uq_device_group_member_user"),
    )


# ─── Timetable (S05) ─────────────────────────────────────────────────────────


class TimetableEntry(Base):
    """A weekly lesson slot in school-local time. Occurrences are derived per
    date; a live Session is created only when the teacher starts one."""

    __tablename__ = "timetable_entries"

    entry_id = Column(Integer, primary_key=True)
    teacher_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    class_id = Column(Integer, ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False)
    subject_id = Column(Integer, ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False)
    # Monday = 0 … Sunday = 6.
    weekday = Column(Integer, nullable=False)
    # Minutes after local midnight.
    start_minute = Column(Integer, nullable=False)
    end_minute = Column(Integer, nullable=False)
    valid_from = Column(Date)
    valid_until = Column(Date)
    # Prepared lesson package reused by every occurrence (S21/S23).
    lesson_playlist_id = Column(
        Integer, ForeignKey("teacher_playlists.playlist_id", ondelete="SET NULL"),
    )
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())

    teacher = relationship("User", foreign_keys=[teacher_id])
    school_class = relationship("SchoolClass")
    subject = relationship("Subject")
    lesson_playlist = relationship("TeacherPlaylist")

    __table_args__ = (
        ForeignKeyConstraint(
            ["class_id", "subject_id"],
            ["class_subject_associations.class_id", "class_subject_associations.subject_id"],
            name="fk_timetable_class_subject",
            ondelete="RESTRICT",
        ),
        CheckConstraint("weekday >= 0 AND weekday <= 6", name="check_timetable_weekday"),
        CheckConstraint(
            "start_minute >= 0 AND end_minute <= 1440 AND start_minute < end_minute",
            name="check_timetable_minutes",
        ),
        Index("ix_timetable_teacher_day", "teacher_id", "weekday"),
        Index("ix_timetable_class_day", "class_id", "weekday"),
    )


class OccurrenceOverride(Base):
    """One date of a timetable entry: cancelled, taught by a substitute, or
    using a different prepared lesson."""

    __tablename__ = "timetable_occurrence_overrides"

    override_id = Column(Integer, primary_key=True)
    entry_id = Column(Integer, ForeignKey("timetable_entries.entry_id", ondelete="CASCADE"), nullable=False)
    occurrence_date = Column(Date, nullable=False)
    is_cancelled = Column(Boolean, nullable=False, server_default=text("false"))
    substitute_teacher_id = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    lesson_playlist_id = Column(
        Integer, ForeignKey("teacher_playlists.playlist_id", ondelete="SET NULL"),
    )
    note = Column(Text)

    entry = relationship("TimetableEntry")
    substitute = relationship("User", foreign_keys=[substitute_teacher_id])

    __table_args__ = (
        UniqueConstraint("entry_id", "occurrence_date", name="uq_occurrence_override"),
    )


class SchoolHoliday(Base):
    __tablename__ = "school_holidays"

    holiday_id = Column(Integer, primary_key=True)
    holiday_date = Column(Date, unique=True, nullable=False)
    name = Column(String(120), nullable=False)


# ─── Durable background jobs (S39) ───────────────────────────────────────────


class ScheduledJob(Base):
    __tablename__ = "scheduled_jobs"

    job_id = Column(Integer, primary_key=True)
    kind = Column(String(40), nullable=False)
    dedupe_key = Column(String(200), unique=True, nullable=False)
    run_at = Column(TIMESTAMP, nullable=False)
    payload = Column(JSON, nullable=False)
    status = Column(String(20), nullable=False, server_default="pending")
    attempts = Column(Integer, nullable=False, server_default=text("0"))
    last_error = Column(Text)
    locked_until = Column(TIMESTAMP)
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())
    completed_at = Column(TIMESTAMP)

    __table_args__ = (
        CheckConstraint(
            "status IN ('pending', 'running', 'done', 'failed', 'cancelled')",
            name="check_job_status",
        ),
        Index("ix_job_due", "status", "run_at"),
    )


# ─── Class alerts (S13/S15/S40/S45) ──────────────────────────────────────────


class ClassAlert(Base):
    """One ringing alert event for a live class: the start alert, the single
    automatic ten-minute reminder, or a teacher's manual reminder."""

    __tablename__ = "class_alerts"

    alert_id = Column(String(36), primary_key=True)
    session_id = Column(Integer, ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False)
    kind = Column(String(20), nullable=False)
    requested_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    created_at = Column(TIMESTAMP, nullable=False)
    # Ringing stops at this instant even if the push arrives late.
    ring_until = Column(TIMESTAMP, nullable=False)

    recipients = relationship("ClassAlertRecipient", back_populates="alert", cascade="all, delete-orphan")

    __table_args__ = (
        CheckConstraint(
            "kind IN ('start', 'auto_reminder', 'manual_reminder')",
            name="check_class_alert_kind",
        ),
    )


class ClassAlertRecipient(Base):
    __tablename__ = "class_alert_recipients"

    recipient_id = Column(Integer, primary_key=True)
    alert_id = Column(String(36), ForeignKey("class_alerts.alert_id", ondelete="CASCADE"), nullable=False)
    session_id = Column(Integer, nullable=False)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    # queued, sent, failed, no_device, skipped_cooldown, skipped_joined, cancelled
    status = Column(String(20), nullable=False)
    created_at = Column(TIMESTAMP, nullable=False)
    sent_at = Column(TIMESTAMP)

    alert = relationship("ClassAlert", back_populates="recipients")

    __table_args__ = (
        UniqueConstraint("alert_id", "user_id", name="uq_class_alert_recipient"),
        Index("ix_class_alert_cooldown", "session_id", "user_id", "created_at"),
    )


# ─── Administrator exception queue (S41) ─────────────────────────────────────


class AdminIssue(Base):
    __tablename__ = "admin_issues"

    issue_id = Column(Integer, primary_key=True)
    kind = Column(String(40), nullable=False)
    dedupe_key = Column(String(200), unique=True, nullable=False)
    message = Column(Text, nullable=False)
    details = Column(JSON)
    status = Column(String(20), nullable=False, server_default="open")
    occurrences = Column(Integer, nullable=False, server_default=text("1"))
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())
    last_seen_at = Column(TIMESTAMP, nullable=False, server_default=func.now())
    resolved_at = Column(TIMESTAMP)
    resolved_by = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))

    __table_args__ = (
        CheckConstraint("status IN ('open', 'resolved')", name="check_admin_issue_status"),
        Index("ix_admin_issue_status", "status", "last_seen_at"),
    )


class TeacherNotice(Base):
    """Tells an account what someone else changed for it: an administrator
    acting for a teacher, a lesson scheduled or changed, or class work
    published for a student. teacher_id is the recipient (any role)."""

    __tablename__ = "teacher_notices"

    notice_id = Column(Integer, primary_key=True)
    teacher_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    actor_id = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"))
    kind = Column(String(10), nullable=False)
    item_id = Column(Integer, nullable=False)
    title = Column(String(300), nullable=False)
    action = Column(String(12), nullable=False)
    # A one-day change's ISO date; otherwise empty.
    detail = Column(String(40))
    created_at = Column(TIMESTAMP, nullable=False, default=datetime.utcnow)
    seen_at = Column(TIMESTAMP)

    __table_args__ = (
        CheckConstraint(
            "kind IN ('quiz', 'journey', 'playlist', 'lesson')",
            name="check_teacher_notice_kind",
        ),
        CheckConstraint(
            "action IN ('created', 'published', 'closed', 'archived', 'updated', "
            "'removed', 'cancelled', 'substitute', 'covered')",
            name="check_teacher_notice_action",
        ),
        Index("ix_teacher_notice_unseen", "teacher_id", "seen_at"),
    )

    actor = relationship("User", foreign_keys=[actor_id])
