"""Request contracts for learning journeys (content, questions and polls in one flow)."""

from datetime import datetime
from typing import Annotated, Literal, Optional, Union

from pydantic import BaseModel, Field, field_validator, model_validator

MAX_STEPS = 60
MAX_RETRIES = 5
MAX_SYNC_RUNS = 50
MAX_RUN_ANSWERS = 600


def _clean(value: str, label: str) -> str:
    cleaned = value.strip()
    if not cleaned:
        raise ValueError(f"{label} must not be blank")
    return cleaned


def _clean_options(options: list[str]) -> list[str]:
    cleaned = [_clean(option, "Option") for option in options]
    if any(len(option) > 300 for option in cleaned):
        raise ValueError("Options must not exceed 300 characters")
    if len({option.casefold() for option in cleaned}) != len(cleaned):
        raise ValueError("Options must be different from each other")
    return cleaned


class AudioStep(BaseModel):
    kind: Literal["audio"]
    audio_id: int = Field(gt=0)
    # Filled in by the server from the recording; client values are ignored.
    title: Optional[str] = None


class NarrationStep(BaseModel):
    kind: Literal["narration"]
    text: str = Field(min_length=1, max_length=2000)

    @field_validator("text")
    @classmethod
    def clean_text(cls, value):
        return _clean(value, "Narration")


class QuestionStep(BaseModel):
    kind: Literal["question"]
    text: str = Field(min_length=1, max_length=1000)
    options: list[str] = Field(min_length=2, max_length=4)
    correct_index: int = Field(ge=0, le=3)
    explanation: Optional[str] = Field(default=None, max_length=1000)
    # Earlier content step to replay after a wrong answer; None chooses automatically.
    replay_from: Optional[int] = Field(default=None, ge=0)
    source_question_id: Optional[int] = Field(default=None, gt=0)

    @field_validator("text")
    @classmethod
    def clean_text(cls, value):
        return _clean(value, "Question")

    @field_validator("options")
    @classmethod
    def clean_options(cls, value):
        return _clean_options(value)

    @field_validator("explanation")
    @classmethod
    def clean_explanation(cls, value):
        return value.strip() or None if value is not None else None

    @model_validator(mode="after")
    def correct_in_range(self):
        if self.correct_index >= len(self.options):
            raise ValueError("The correct answer must be one of the options")
        return self


class PollStep(BaseModel):
    kind: Literal["poll"]
    text: str = Field(min_length=1, max_length=1000)
    options: list[str] = Field(min_length=2, max_length=4)

    @field_validator("text")
    @classmethod
    def clean_text(cls, value):
        return _clean(value, "Poll question")

    @field_validator("options")
    @classmethod
    def clean_options(cls, value):
        return _clean_options(value)


Step = Annotated[Union[AudioStep, NarrationStep, QuestionStep, PollStep], Field(discriminator="kind")]


class JourneyContent(BaseModel):
    title: str = Field(min_length=1, max_length=160)
    description: Optional[str] = Field(default=None, max_length=1000)
    graded: bool = False
    max_retries: int = Field(default=1, ge=0, le=MAX_RETRIES)
    steps: list[Step] = Field(default_factory=list, max_length=MAX_STEPS)

    @field_validator("title")
    @classmethod
    def clean_title(cls, value):
        return _clean(value, "Title")

    @field_validator("description")
    @classmethod
    def clean_description(cls, value):
        return value.strip() or None if value is not None else None

    @model_validator(mode="after")
    def validate_replays(self):
        for index, step in enumerate(self.steps):
            if isinstance(step, QuestionStep) and step.replay_from is not None:
                if step.replay_from >= index:
                    raise ValueError(f"Step {index + 1} can only replay an earlier step")
                if self.steps[step.replay_from].kind not in ("audio", "narration"):
                    raise ValueError(f"Step {index + 1} must replay a recording or narration step")
        return self


class JourneyCreate(BaseModel):
    class_id: int = Field(gt=0)
    subject_id: int = Field(gt=0)
    title: str = Field(min_length=1, max_length=160)

    @field_validator("title")
    @classmethod
    def clean_title(cls, value):
        return _clean(value, "Title")


class JourneyUpdate(JourneyContent):
    revision: int = Field(gt=0)


class RevisionBody(BaseModel):
    revision: int = Field(gt=0)


class SyncAnswer(BaseModel):
    step_index: int = Field(ge=0, lt=MAX_STEPS)
    attempt: int = Field(ge=0, le=MAX_RETRIES)
    selected_option: int = Field(ge=0, le=3)
    answered_at: datetime


class SyncRun(BaseModel):
    run_id: str = Field(pattern=r"^[0-9a-fA-F-]{36}$")
    journey_id: int = Field(gt=0)
    journey_revision: int = Field(gt=0)
    started_at: datetime
    completed_at: Optional[datetime] = None
    played_offline: bool = False
    answers: list[SyncAnswer] = Field(default_factory=list, max_length=MAX_RUN_ANSWERS)


class SyncBody(BaseModel):
    runs: list[SyncRun] = Field(min_length=1, max_length=MAX_SYNC_RUNS)
