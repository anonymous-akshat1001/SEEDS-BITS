from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field, root_validator, validator


MAX_ATTEMPTS = 20
MAX_TIME_LIMIT_MINUTES = 1440


def _clean_text(value: str, field_name: str) -> str:
    cleaned = value.strip()
    if not cleaned:
        raise ValueError(f"{field_name} must not be blank")
    return cleaned


class QuestionContent(BaseModel):
    question_text: str = Field(..., max_length=5000)
    options: List[str]
    correct_option_index: int = Field(..., ge=0, le=3)
    explanation: Optional[str] = Field(None, max_length=5000)

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


class BankQuestionOptionOut(BaseModel):
    option_id: int
    option_text: str
    position: int
    is_correct: bool


class BankQuestionOut(BaseModel):
    question_id: int
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
    attempt_limit: int = Field(1, ge=1, le=MAX_ATTEMPTS)
    opens_at: Optional[datetime] = None
    closes_at: Optional[datetime] = None
    time_limit_minutes: Optional[int] = Field(
        None, ge=1, le=MAX_TIME_LIMIT_MINUTES,
    )
    shuffle_questions: bool = False
    shuffle_options: bool = False

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
        return values


class QuizUpdate(QuizCreate):
    pass


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


class QuizQuestionAuthorOut(BaseModel):
    quiz_question_id: int
    source_question_id: Optional[int] = None
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
    position: int


class SafeQuizQuestion(BaseModel):
    quiz_question_id: int
    question_text: str
    position: int
    options: List[SafeQuizOption]


class StudentQuizOut(BaseModel):
    quiz_id: int
    title: str
    description: Optional[str] = None
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
    attempts_remaining: int
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
    correct_count: int
    total_questions: int
    percentage_score: float
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
    correct_option_id: int
    correct_option_text: str
    is_correct: bool
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
    selected_option_id: Optional[int] = None
    selected_option_text: Optional[str] = None
    correct_option_id: int
    correct_option_text: str
    is_correct: bool
    explanation: Optional[str] = None


class AttemptReviewOut(BaseModel):
    attempt: AttemptOut
    questions: List[ReviewQuestionOut]


class EligibleStudentOut(BaseModel):
    student_id: int
    student_name: str
    started: bool
    completed: bool
    highest_score: Optional[float] = None
    attempts: List[AttemptOut] = Field(default_factory=list)


class QuestionStatisticOut(BaseModel):
    quiz_question_id: int
    question_text: str
    response_count: int
    correct_percentage: float


class QuizSummaryOut(BaseModel):
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
