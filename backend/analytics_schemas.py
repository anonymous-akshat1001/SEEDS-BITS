"""Bounded contracts shared by structured queries and local intent interpretation."""

from datetime import datetime, timezone
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, model_validator, field_validator, field_serializer

Metric = Literal[
    "sessions_created", "session_openings", "attendance", "quiz_average",
    "quiz_attempts", "activity_counts",
]


class Intent(BaseModel):
    model_config = ConfigDict(extra="forbid")
    metric: Metric
    teacher: str | None = Field(default=None, max_length=160)
    student: str | None = Field(default=None, max_length=160)
    class_name: str | None = Field(default=None, max_length=100)
    subject: str | None = Field(default=None, max_length=100)
    session: str | None = Field(default=None, max_length=160)
    event_type: str | None = Field(default=None, max_length=50, pattern=r"^[a-z0-9_]+$")
    start: datetime | None = None
    end: datetime | None = None
    all_time: bool = False
    page: int = Field(default=1, ge=1, le=1000)
    teacher_id: int | None = Field(default=None, gt=0)
    student_id: int | None = Field(default=None, gt=0)
    class_name_id: int | None = Field(default=None, gt=0)
    subject_id: int | None = Field(default=None, gt=0)
    session_id: int | None = Field(default=None, gt=0)

    @field_validator("start", "end")
    @classmethod
    def utc(cls, value):
        if value is not None and value.tzinfo is not None:
            return value.astimezone(timezone.utc).replace(tzinfo=None)
        if value is not None:
            raise ValueError("Dates must include a timezone")
        return value

    @field_validator("teacher", "student", "class_name", "subject", "session")
    @classmethod
    def normalize(cls, value):
        if value is not None:
            value = " ".join(value.split())
            if not value:
                raise ValueError("Entity names cannot be empty")
        return value

    @field_serializer("start", "end")
    def serialize_utc(self, value):
        return value.isoformat() + "Z" if value is not None else None

    @model_validator(mode="after")
    def valid_interval(self):
        if self.start and self.end and self.start >= self.end:
            raise ValueError("Start must precede end")
        if self.metric in {"sessions_created", "session_openings"} and (self.student or self.student_id):
            raise ValueError("Student filtering applies to attendance, not session creation/openings")
        if self.metric in {"quiz_average", "quiz_attempts"} and (self.session or self.session_id):
            raise ValueError("Quizzes are not tied to live sessions")
        if self.metric != "activity_counts" and self.event_type:
            raise ValueError("Event type applies only to activity counts")
        return self


class QueryRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    question: str | None = Field(default=None, min_length=1, max_length=2000)
    intent: Intent | None = None
    context: Intent | None = None

    @model_validator(mode="after")
    def one_input(self):
        if (self.question is None) == (self.intent is None):
            raise ValueError("Provide either a question or structured intent")
        if self.context is not None and self.question is None:
            raise ValueError("Context applies only to natural language follow-ups")
        return self


CLIENT_EVENTS = {
    "learning_play", "learning_pause", "learning_complete", "learning_seek",
    "learning_speed", "learning_repeat", "bookmark_added", "bookmark_removed",
    "download_requested", "download_completed", "download_failed",
    "download_cancelled", "download_removed", "download_renewed",
    "settings_saved", "settings_reset", "screen_viewed", "logout_observed",
}


class ClientEvent(BaseModel):
    model_config = ConfigDict(extra="forbid")
    event_id: UUID
    event_type: str = Field(max_length=50)
    occurred_at: datetime
    resource_type: Literal["audio", "global"] | None = None
    resource_id: int | None = Field(default=None, gt=0)
    details: dict = Field(default_factory=dict)

    @field_validator("occurred_at")
    @classmethod
    def utc(cls, value):
        if value.tzinfo is None:
            raise ValueError("Occurrence time must include timezone")
        return value.astimezone(timezone.utc).replace(tzinfo=None)


class EventBatch(BaseModel):
    model_config = ConfigDict(extra="forbid")
    events: list[ClientEvent] = Field(min_length=1, max_length=100)
