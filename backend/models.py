# models.py
from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Text, ForeignKey, Boolean,
    TIMESTAMP, CheckConstraint, JSON, text, Float, UniqueConstraint, Index,
    ForeignKeyConstraint,
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
    completed_at = Column(TIMESTAMP)
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
