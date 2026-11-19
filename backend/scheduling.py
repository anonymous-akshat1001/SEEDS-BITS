"""Timetable occurrences, class lifecycle windows, and cutoff arithmetic.

All database timestamps are naive UTC, matching the rest of the backend.
Timetable times are school-local wall-clock minutes (``SCHOOL_TIMEZONE``).
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from datetime import date, datetime, time, timedelta, timezone
from typing import Iterable, Optional
from zoneinfo import ZoneInfo

from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

import models


def _int_env(name: str, default: int) -> int:
    try:
        return int(os.getenv(name, str(default)))
    except ValueError:
        return default


SCHOOL_TZ = ZoneInfo(os.getenv("SCHOOL_TIMEZONE", "Asia/Kolkata"))
# Confirmed product policy (see the interaction-reduction plan, S06/S15/S45).
GRACE_AFTER_END = timedelta(minutes=30)
GAP_BEFORE_NEXT = timedelta(minutes=5)
EXTENSION_STEP = timedelta(minutes=15)
RING_DURATION = timedelta(seconds=60)
AUTO_REMINDER_AFTER = timedelta(minutes=10)
REMINDER_COOLDOWN = timedelta(minutes=5)
CUTOFF_WARNINGS = (timedelta(minutes=5), timedelta(minutes=1))
# Implementation-stage choices documented in BACKEND_DEPLOYMENT.md.
EARLY_START = timedelta(minutes=_int_env("CLASS_EARLY_START_MINUTES", 10))
UNSCHEDULED_LENGTH = timedelta(minutes=_int_env("UNSCHEDULED_CLASS_MINUTES", 45))
# A start is refused when less than this would remain before the cutoff.
MINIMUM_TEACHING_TIME = timedelta(minutes=5)


def utcnow() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def local_today(now: Optional[datetime] = None) -> date:
    return to_local(now or utcnow()).date()


def to_local(value: datetime) -> datetime:
    return value.replace(tzinfo=timezone.utc).astimezone(SCHOOL_TZ)


def local_minute_to_utc(day: date, minute: int) -> datetime:
    local = datetime.combine(day, time(0, 0), tzinfo=SCHOOL_TZ) + timedelta(minutes=minute)
    return local.astimezone(timezone.utc).replace(tzinfo=None)


def iso_utc(value: Optional[datetime]) -> Optional[str]:
    return None if value is None else value.replace(microsecond=0).isoformat() + "Z"


def iso_local(value: Optional[datetime]) -> Optional[str]:
    """School-local ISO time with its offset, e.g. 2026-11-17T09:00:00+05:30."""
    if value is None:
        return None
    return to_local(value).replace(microsecond=0).isoformat()


def local_clock(value: datetime) -> str:
    return to_local(value).strftime("%H:%M")


@dataclass
class Occurrence:
    entry_id: int
    occurrence_date: date
    teacher_id: int
    regular_teacher_id: int
    class_id: int
    subject_id: int
    start: datetime
    end: datetime
    lesson_playlist_id: Optional[int] = None
    cancelled: bool = False
    class_name: str = ""
    subject_name: str = ""
    teacher_name: str = ""
    extra: dict = field(default_factory=dict)

    @property
    def key(self) -> tuple[int, date]:
        return (self.entry_id, self.occurrence_date)


def entry_applies(entry: models.TimetableEntry, day: date) -> bool:
    if not entry.is_active or entry.weekday != day.weekday():
        return False
    if entry.valid_from is not None and day < entry.valid_from:
        return False
    if entry.valid_until is not None and day > entry.valid_until:
        return False
    return True


async def occurrences_on(
    db: AsyncSession,
    day: date,
    *,
    teacher_id: Optional[int] = None,
    class_id: Optional[int] = None,
    include_cancelled: bool = False,
) -> list[Occurrence]:
    """Occurrences on one local date, with substitutes and cancellations applied.

    ``teacher_id`` matches the teacher who actually teaches that date.
    """
    holiday = (await db.execute(
        select(models.SchoolHoliday.holiday_id).where(models.SchoolHoliday.holiday_date == day)
    )).scalar_one_or_none()
    if holiday is not None and not include_cancelled:
        return []
    query = select(models.TimetableEntry).options(
        selectinload(models.TimetableEntry.school_class),
        selectinload(models.TimetableEntry.subject),
        selectinload(models.TimetableEntry.teacher),
    ).where(
        models.TimetableEntry.is_active.is_(True),
        models.TimetableEntry.weekday == day.weekday(),
    )
    if class_id is not None:
        query = query.where(models.TimetableEntry.class_id == class_id)
    entries = [entry for entry in (await db.execute(query)).scalars().all() if entry_applies(entry, day)]
    if not entries:
        return []
    overrides = {
        override.entry_id: override
        for override in (await db.execute(
            select(models.OccurrenceOverride).options(
                selectinload(models.OccurrenceOverride.substitute),
            ).where(
                models.OccurrenceOverride.entry_id.in_([entry.entry_id for entry in entries]),
                models.OccurrenceOverride.occurrence_date == day,
            )
        )).scalars().all()
    }
    result = []
    for entry in entries:
        override = overrides.get(entry.entry_id)
        cancelled = holiday is not None or bool(override and override.is_cancelled)
        if cancelled and not include_cancelled:
            continue
        teacher = entry.teacher
        effective_teacher_id = entry.teacher_id
        if override is not None and override.substitute_teacher_id:
            effective_teacher_id = override.substitute_teacher_id
            teacher = override.substitute or teacher
        if teacher_id is not None and effective_teacher_id != teacher_id:
            continue
        playlist = entry.lesson_playlist_id
        if override is not None and override.lesson_playlist_id:
            playlist = override.lesson_playlist_id
        result.append(Occurrence(
            entry_id=entry.entry_id,
            occurrence_date=day,
            teacher_id=effective_teacher_id,
            regular_teacher_id=entry.teacher_id,
            class_id=entry.class_id,
            subject_id=entry.subject_id,
            start=local_minute_to_utc(day, entry.start_minute),
            end=local_minute_to_utc(day, entry.end_minute),
            lesson_playlist_id=playlist,
            cancelled=cancelled,
            class_name=entry.school_class.name if entry.school_class else "",
            subject_name=entry.subject.name if entry.subject else "",
            teacher_name=teacher.name if teacher else "",
        ))
    result.sort(key=lambda occurrence: (occurrence.start, occurrence.entry_id))
    return result


async def occurrences_between(
    db: AsyncSession,
    start: datetime,
    end: datetime,
    **filters,
) -> list[Occurrence]:
    """Occurrences starting in [start, end)."""
    found: list[Occurrence] = []
    day = to_local(start).date() - timedelta(days=1)
    last = to_local(end).date()
    while day <= last:
        for occurrence in await occurrences_on(db, day, **filters):
            if start <= occurrence.start < end:
                found.append(occurrence)
        day += timedelta(days=1)
    return sorted(found, key=lambda occurrence: (occurrence.start, occurrence.entry_id))


async def next_start_after(
    db: AsyncSession,
    after: datetime,
    *,
    teacher_id: Optional[int] = None,
    class_id: Optional[int] = None,
    exclude: Optional[tuple[int, date]] = None,
) -> Optional[datetime]:
    """Earliest occurrence start strictly after ``after`` within a day."""
    candidates = await occurrences_between(
        db, after + timedelta(seconds=1), after + timedelta(days=1),
        teacher_id=teacher_id, class_id=class_id,
    )
    for occurrence in candidates:
        if exclude is not None and occurrence.key == exclude:
            continue
        return occurrence.start
    return None


def base_cutoff(
    scheduled_end: datetime,
    next_teacher_start: Optional[datetime],
    next_class_start: Optional[datetime],
) -> datetime:
    """Earlier of scheduled end + 30 minutes and 5 minutes before the next
    class of the same teacher or of the same enrolled class."""
    cutoff = scheduled_end + GRACE_AFTER_END
    for upcoming in (next_teacher_start, next_class_start):
        if upcoming is not None:
            cutoff = min(cutoff, upcoming - GAP_BEFORE_NEXT)
    return cutoff


def extension_limit(
    next_teacher_start: Optional[datetime],
    next_class_start: Optional[datetime],
) -> Optional[datetime]:
    limits = [upcoming - GAP_BEFORE_NEXT for upcoming in (next_teacher_start, next_class_start) if upcoming]
    return min(limits) if limits else None


def extended_cutoff(current: datetime, limit: Optional[datetime]) -> Optional[datetime]:
    """Current cutoff plus 15 minutes, clamped; None when no time can be added."""
    proposed = current + EXTENSION_STEP
    if limit is not None:
        proposed = min(proposed, limit)
    return proposed if proposed > current else None


async def cutoff_context(
    db: AsyncSession,
    *,
    teacher_id: int,
    class_id: int,
    after: datetime,
    exclude: Optional[tuple[int, date]] = None,
) -> tuple[Optional[datetime], Optional[datetime]]:
    teacher_next = await next_start_after(db, after, teacher_id=teacher_id, exclude=exclude)
    class_next = await next_start_after(db, after, class_id=class_id, exclude=exclude)
    return teacher_next, class_next


def startable_window(occurrence: Occurrence, cutoff: datetime) -> tuple[datetime, datetime]:
    return occurrence.start - EARLY_START, cutoff - MINIMUM_TEACHING_TIME


def overlaps(start_a: int, end_a: int, start_b: int, end_b: int) -> bool:
    return start_a < end_b and start_b < end_a


def date_ranges_overlap(
    from_a: Optional[date], until_a: Optional[date],
    from_b: Optional[date], until_b: Optional[date],
) -> bool:
    low = max(from_a or date.min, from_b or date.min)
    high = min(until_a or date.max, until_b or date.max)
    return low <= high


async def conflicting_entries(
    db: AsyncSession,
    *,
    teacher_id: int,
    class_id: int,
    weekday: int,
    start_minute: int,
    end_minute: int,
    valid_from: Optional[date],
    valid_until: Optional[date],
    ignore_entry_id: Optional[int] = None,
) -> list[models.TimetableEntry]:
    """Active weekly entries that would overlap for the same teacher or class."""
    query = select(models.TimetableEntry).options(
        selectinload(models.TimetableEntry.school_class),
        selectinload(models.TimetableEntry.subject),
        selectinload(models.TimetableEntry.teacher),
    ).where(
        models.TimetableEntry.is_active.is_(True),
        models.TimetableEntry.weekday == weekday,
        or_(
            models.TimetableEntry.teacher_id == teacher_id,
            models.TimetableEntry.class_id == class_id,
        ),
    )
    if ignore_entry_id is not None:
        query = query.where(models.TimetableEntry.entry_id != ignore_entry_id)
    return [
        entry for entry in (await db.execute(query)).scalars().all()
        if overlaps(start_minute, end_minute, entry.start_minute, entry.end_minute)
        and date_ranges_overlap(valid_from, valid_until, entry.valid_from, entry.valid_until)
    ]


async def substitute_conflicts(
    db: AsyncSession, entry: models.TimetableEntry, day: date, substitute_id: int,
) -> list[Occurrence]:
    """Occurrences the substitute already teaches that overlap this date's slot."""
    start = local_minute_to_utc(day, entry.start_minute)
    end = local_minute_to_utc(day, entry.end_minute)
    return [
        occurrence for occurrence in await occurrences_on(db, day, teacher_id=substitute_id)
        if occurrence.entry_id != entry.entry_id and occurrence.start < end and start < occurrence.end
    ]


def session_label(subject_name: str, class_name: str, when: datetime) -> str:
    """Generated title (S09). Clients speak subject and class from fields."""
    return f"{subject_name}, {class_name}, {to_local(when).strftime('%d %b %Y')}"


def unique_sorted(values: Iterable[datetime]) -> list[datetime]:
    return sorted(set(values))
