from datetime import datetime, timezone
from typing import List, Optional, Literal

from pydantic import BaseModel, Field, root_validator, validator


MAX_ATTEMPTS = 20
MAX_TIME_LIMIT_MINUTES = 1440


def _clean_text(value: str, field_name: str) -> str:
    cleaned = value.strip()
    if not cleaned:
        raise ValueError(f"{field_name} must not be blank")
    return cleaned


class QuestionMetadata(BaseModel):
    topics: List[str] = Field(default_factory=list, max_length=20)
    notation: Literal["plain_text", "described"] = "plain_text"
    spoken_question_text: Optional[str] = Field(None, max_length=5000)
    spoken_options: Optional[List[str]] = None
    spoken_explanation: Optional[str] = Field(None, max_length=5000)
    spoken_reviewed: bool = False


class QuestionContent(QuestionMetadata):
    question_text: str = Field(..., max_length=5000)
    options: List[str]
    correct_option_index: int = Field(..., ge=0, le=3)
    explanation: Optional[str] = Field(None, max_length=5000)

    @validator("topics")
    def clean_topics(cls, value):
        cleaned = [_clean_text(topic, "Topic") for topic in value]
        if any(len(topic) > 80 for topic in cleaned) or len({topic.casefold() for topic in cleaned}) != len(cleaned):
            raise ValueError("Use distinct topics of at most 80 characters each")
        return cleaned

    @validator("spoken_question_text", "spoken_explanation")
    def clean_spoken_text(cls, value):
        return value.strip() or None if value is not None else None

    @validator("spoken_options")
    def clean_spoken_options(cls, value):
        if value is None:
            return None
        if len(value) != 4:
            raise ValueError("Provide exactly four spoken option descriptions")
        cleaned = [_clean_text(option, "Spoken option") for option in value]
        if any(len(option) > 5000 for option in cleaned):
            raise ValueError("Spoken options must not exceed 5000 characters")
        return cleaned

    @root_validator(skip_on_failure=True)
    def require_reviewed_notation(cls, values):
        described = values.get("notation") == "described"
        has_alternatives = any(values.get(key) for key in ("spoken_question_text", "spoken_options", "spoken_explanation"))
        if (described or has_alternatives) and not values.get("spoken_reviewed"):
            raise ValueError("The teacher must review spoken alternatives before saving")
        if described and (not values.get("spoken_question_text") or not values.get("spoken_options")):
            raise ValueError("Described notation requires a spoken question and all four spoken options")
        if described and values.get("explanation") and not values.get("spoken_explanation"):
            raise ValueError("Provide a reviewed spoken explanation for described notation")
        return values

    @validator("question_text")
    def validate_question_text(cls, value):
        return _clean_text(value, "Question text")

    @validator("options")
    def validate_options(cls, value):
        if len(value) != 4:
            raise ValueError("Exactly four answer options are required")
        cleaned = [_clean_text(option, "Option text") for option in value]
        normalized = [option.casefold() for option in cleaned]
        if len(set(normalized)) != 4:
            raise ValueError("Answer options must be unique")
        return cleaned

    @validator("explanation")
    def clean_explanation(cls, value):
        return value.strip() or None if value is not None else None


class BankQuestionCreate(QuestionContent):
    class_id: int
    subject_id: int


class BankQuestionUpdate(QuestionContent):
    class_id: int
    subject_id: int
    expected_revision: Optional[int] = Field(None, ge=1)


class BankQuestionOptionOut(BaseModel):
    option_id: int
    option_text: str
    position: int
    is_correct: bool


class BankQuestionOut(QuestionMetadata):
    question_id: int
    revision: Optional[int] = None
    owner_teacher_id: int
    class_id: int
    subject_id: int
    class_name: Optional[str] = None
    subject_name: Optional[str] = None
    question_text: str
    explanation: Optional[str] = None
    is_archived: bool
    created_at: datetime
    updated_at: datetime
    archived_at: Optional[datetime] = None
    options: List[BankQuestionOptionOut]


class QuizCreate(BaseModel):
    class_id: int
    subject_id: int
    title: str = Field(..., max_length=300)
    description: Optional[str] = Field(None, max_length=5000)
    mode: Literal["graded", "practice"] = "graded"
    feedback_policy: Literal["after_completion", "scheduled", "score_only", "immediate", "legacy_immediate"] = "after_completion"
    feedback_release_at: Optional[datetime] = None
    attempt_limit: int = Field(1, ge=1, le=MAX_ATTEMPTS)
    opens_at: Optional[datetime] = None
    closes_at: Optional[datetime] = None
    time_limit_minutes: Optional[int] = Field(
        None, ge=1, le=MAX_TIME_LIMIT_MINUTES,
    )
    shuffle_questions: bool = False
    shuffle_options: bool = False

    @validator("opens_at", "closes_at", "feedback_release_at")
    def normalize_utc(cls, value):
        return value.astimezone(timezone.utc).replace(tzinfo=None) if value is not None and value.tzinfo is not None else value

    @validator("title")
    def clean_title(cls, value):
        return _clean_text(value, "Quiz title")

    @validator("description")
    def clean_description(cls, value):
        return value.strip() or None if value is not None else None

    @root_validator(skip_on_failure=True)
    def validate_schedule(cls, values):
        opens_at = values.get("opens_at")
        closes_at = values.get("closes_at")
        if opens_at is not None and closes_at is not None and opens_at >= closes_at:
            raise ValueError("Opening time must be before closing time")
        if values.get("mode") == "practice":
            if values.get("time_limit_minutes") is not None:
                raise ValueError("Practice has no per-attempt time limit")
            values["feedback_policy"] = "immediate"
            values["feedback_release_at"] = None
        elif values.get("feedback_policy") == "immediate":
            raise ValueError("Immediate answer feedback is available only for practice")
        if values.get("feedback_policy") == "scheduled" and values.get("feedback_release_at") is None:
            raise ValueError("Set a feedback release time")
        if values.get("feedback_policy") != "scheduled" and values.get("feedback_release_at") is not None:
            raise ValueError("Only scheduled feedback has a release time")
        return values


class QuizUpdate(QuizCreate):
    pass


class AccommodationUpdate(BaseModel):
    student_id: int = Field(gt=0)
    extra_minutes: int = Field(ge=0, le=2147483647)


class AddBankQuestion(BaseModel):
    question_id: int


class AddNewQuestion(QuestionContent):
    save_to_bank: bool = True


class QuizReorder(BaseModel):
    quiz_question_ids: List[int]


class QuizOptionAuthorOut(BaseModel):
    quiz_option_id: int
    option_text: str
    position: int
    is_correct: bool


class QuizQuestionAuthorOut(QuestionMetadata):
    quiz_question_id: int
    source_question_id: Optional[int] = None
    source_revision: Optional[int] = None
    question_text: str
    explanation: Optional[str] = None
    position: int
    options: List[QuizOptionAuthorOut]


class QuizOut(BaseModel):
    quiz_id: int
    owner_teacher_id: Optional[int]
    class_id: int
    class_name: Optional[str] = None
    subject_id: int
    subject_name: Optional[str] = None
    title: str
    description: Optional[str] = None
    mode: str = "graded"
    feedback_policy: str = "legacy_immediate"
    feedback_release_at: Optional[datetime] = None
    status: str
    display_status: str
    attempt_limit: int
    opens_at: Optional[datetime] = None
    closes_at: Optional[datetime] = None
    time_limit_minutes: Optional[int] = None
    shuffle_questions: bool
    shuffle_options: bool
    created_at: datetime
    updated_at: datetime
    published_at: Optional[datetime] = None
    closed_at: Optional[datetime] = None
    question_count: int
    questions: List[QuizQuestionAuthorOut] = Field(default_factory=list)
    notification_recipients: Optional[int] = None
    notifications_sent: Optional[int] = None
    notification_failures: Optional[int] = None


class PublicationReadiness(BaseModel):
    ready: bool
    errors: List[str]


class SafeQuizOption(BaseModel):
    quiz_option_id: int
    option_text: str
    spoken_option_text: Optional[str] = None
    position: int


class SafeQuizQuestion(BaseModel):
    quiz_question_id: int
    question_text: str
    spoken_question_text: Optional[str] = None
    topics: List[str] = Field(default_factory=list)
    position: int
    options: List[SafeQuizOption]


class StudentQuizOut(BaseModel):
    quiz_id: int
    title: str
    description: Optional[str] = None
    mode: str = "graded"
    feedback_policy: str = "legacy_immediate"
    feedback_release_at: Optional[datetime] = None
    class_name: str
    subject_id: int
    subject_name: str
    teacher_name: Optional[str] = None
    status: str
    display_status: str
    opens_at: Optional[datetime] = None
    closes_at: Optional[datetime] = None
    time_limit_minutes: Optional[int] = None
    attempt_limit: int
    attempts_used: int
    attempts_remaining: Optional[int]
    can_start_attempt: bool
    in_progress_attempt_id: Optional[int] = None
    highest_score: Optional[float] = None
    question_count: int
    server_time: datetime


class AttemptOut(BaseModel):
    attempt_id: int
    quiz_id: int
    attempt_number: int
    status: str
    started_at: datetime
    deadline_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    correct_count: Optional[int]
    total_questions: int
    percentage_score: Optional[float]
    is_graded: bool = True
    score_released: bool = True
    feedback_message: Optional[str] = None
    extra_time_minutes: int = 0
    answered_count: int
    server_time: datetime
    question: Optional[SafeQuizQuestion] = None


class AnswerSubmission(BaseModel):
    quiz_question_id: int
    selected_option_id: int


class AnswerFeedback(BaseModel):
    response_id: int
    quiz_question_id: int
    selected_option_id: int
    selected_option_text: str
    selected_option_spoken_text: Optional[str] = None
    correct_option_id: Optional[int] = None
    correct_option_text: Optional[str] = None
    correct_option_spoken_text: Optional[str] = None
    spoken_explanation: Optional[str] = None
    is_correct: Optional[bool] = None
    feedback_released: bool = True
    feedback_message: Optional[str] = None
    explanation: Optional[str] = None
    submitted_at: datetime
    next_question: Optional[SafeQuizQuestion] = None


class AttemptHistoryOut(BaseModel):
    quiz_id: int
    highest_score: Optional[float] = None
    attempts: List[AttemptOut]


class ReviewQuestionOut(BaseModel):
    quiz_question_id: int
    question_text: str
    spoken_question_text: Optional[str] = None
    selected_option_spoken_text: Optional[str] = None
    correct_option_spoken_text: Optional[str] = None
    spoken_explanation: Optional[str] = None
    selected_option_id: Optional[int] = None
    selected_option_text: Optional[str] = None
    correct_option_id: int
    correct_option_text: str
    is_correct: bool
    explanation: Optional[str] = None


class AttemptReviewOut(BaseModel):
    attempt: AttemptOut
    questions: List[ReviewQuestionOut]
    feedback_message: Optional[str] = None


class EligibleStudentOut(BaseModel):
    student_id: int
    student_name: str
    extra_time_minutes: int = 0
    started: bool
    completed: bool
    highest_score: Optional[float] = None
    attempts: List[AttemptOut] = Field(default_factory=list)


class QuestionStatisticOut(BaseModel):
    quiz_question_id: int
    question_text: str
    spoken_question_text: Optional[str] = None
    response_count: int
    correct_percentage: float


class QuizSummaryOut(BaseModel):
    mode: str = "graded"
    time_limit_minutes: Optional[int] = None
    eligible_students: int
    started: int
    completed: int
    not_attempted: int
    completion_percentage: float
    average_highest_score: Optional[float] = None
    highest_score: Optional[float] = None
    lowest_completed_score: Optional[float] = None
    per_question: List[QuestionStatisticOut]


class QuizNotificationOut(BaseModel):
    eligible_students: int
    students_notified: int
    device_notifications_queued: int
