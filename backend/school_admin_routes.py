"""Administrator setup that replaces repeated teacher and student work:
accounts (S01), shared phones (S43), the timetable (S05), prepared lessons
(S21/S23), the exception queue (S41) and backend session records (S25)."""

from __future__ import annotations

import calendar
import re
from datetime import date, datetime, timedelta
from typing import Literal, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

import access_control as access
import auth
import classroom
import models
import teacher_notices
import scheduling as sched
from database import get_db
from sign_in_routes import normalize_phone
from ws_manager import ws_mgr

router = APIRouter(prefix="/admin", tags=["School administration"])


# ─── Helpers ─────────────────────────────────────────────────────────────────

_CLOCK = re.compile(r"^([01]?\d|2[0-3]):([0-5]\d)$")


def _minutes(clock: str) -> int:
    match = _CLOCK.match(clock.strip())
    if not match:
        raise HTTPException(status_code=422, detail="Use 24-hour time such as 09:30.")
    return int(match.group(1)) * 60 + int(match.group(2))


def _clock(minutes: int) -> str:
    return f"{minutes // 60:02d}:{minutes % 60:02d}"


async def _phone_available(
    db: AsyncSession, phone: str, *, ignore_user: Optional[int] = None, ignore_group: Optional[int] = None,
) -> None:
    if not phone:
        raise HTTPException(status_code=422, detail="Phone number is required.")
    user = (await db.execute(select(models.User).where(models.User.phone_number == phone))).scalar_one_or_none()
    if user is not None and user.user_id != ignore_user:
        raise HTTPException(status_code=409, detail="This phone number already belongs to another account.")
    group = (await db.execute(
        select(models.DeviceGroup).where(models.DeviceGroup.entry_phone_number == phone)
    )).scalar_one_or_none()
    if group is not None and group.group_id != ignore_group:
        raise HTTPException(status_code=409, detail="This phone number is used by a shared phone.")


# ─── Accounts (S01) ──────────────────────────────────────────────────────────


class Workspace(BaseModel):
    class_id: int
    subject_id: int


SpeechLanguage = Literal["en", "hi", "kn", "te", "bn"]


class UserCreate(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    phone_number: str = Field(min_length=1, max_length=32)
    role: Literal["student", "teacher"]
    class_id: Optional[int] = None
    assignments: list[Workspace] = Field(default_factory=list)
    speech_language: Optional[SpeechLanguage] = None
    speech_rate: Optional[float] = Field(default=None, ge=0.25, le=2.0)


class UserUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=200)
    phone_number: Optional[str] = Field(default=None, min_length=1, max_length=32)
    is_active: Optional[bool] = None
    # Sending null clears the administrator's choice.
    speech_language: Optional[SpeechLanguage] = None
    speech_rate: Optional[float] = Field(default=None, ge=0.25, le=2.0)


def _user_payload(user: models.User) -> dict:
    return {
        "user_id": user.user_id,
        "name": user.name,
        "phone_number": user.phone_number,
        "role": user.role,
        "is_active": user.is_active,
        "auth_version": user.auth_version,
        "speech_language": user.speech_language,
        "speech_rate": user.speech_rate,
    }


@router.post("/users")
async def create_user(
    payload: UserCreate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    phone = normalize_phone(payload.phone_number)
    await _phone_available(db, phone)
    if payload.role == "student" and payload.assignments:
        raise HTTPException(status_code=422, detail="Students are enrolled in a class, not assigned subjects.")
    if payload.role == "teacher" and payload.class_id is not None:
        raise HTTPException(status_code=422, detail="Assign teachers to class and subject pairs.")
    if payload.role == "student" and payload.class_id is None:
        raise HTTPException(status_code=422, detail="Choose the student's class.")
    if payload.role == "teacher" and not payload.assignments:
        raise HTTPException(status_code=422, detail="Add at least one class and subject for the teacher.")
    user = models.User(
        name=payload.name.strip(), phone_number=phone, role=payload.role,
        password_hash=auth.UNUSABLE_PASSWORD, is_active=True,
        speech_language=payload.speech_language, speech_rate=payload.speech_rate,
    )
    db.add(user)
    try:
        await db.flush()
    except IntegrityError:
        await db.rollback()
        raise HTTPException(status_code=409, detail="This phone number already belongs to another account.")
    if payload.class_id is not None:
        school_class = await db.get(models.SchoolClass, payload.class_id, populate_existing=True)
        if school_class is None or not school_class.is_active:
            await db.rollback()
            raise HTTPException(status_code=404, detail="Active class not found")
        db.add(models.StudentClassMembership(
            student_id=user.user_id, class_id=payload.class_id, assigned_by=admin.user_id,
        ))
    for workspace in {(item.class_id, item.subject_id) for item in payload.assignments}:
        try:
            await access.require_active_class_subject(db, *workspace)
        except HTTPException:
            await db.rollback()
            raise
        db.add(models.TeacherClassSubjectAssignment(
            teacher_id=user.user_id, class_id=workspace[0], subject_id=workspace[1],
            assigned_by=admin.user_id,
        ))
    await db.commit()
    await db.refresh(user)
    return _user_payload(user)


@router.patch("/users/{account_id}")
async def update_user(
    account_id: int,
    payload: UserUpdate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    user = await db.get(models.User, account_id)
    if user is None or user.role not in {"student", "teacher"}:
        raise HTTPException(status_code=404, detail="Account not found")
    revoke = False
    if payload.name is not None:
        user.name = payload.name.strip()
    sent = payload.model_fields_set
    if "speech_language" in sent:
        user.speech_language = payload.speech_language
    if "speech_rate" in sent:
        user.speech_rate = payload.speech_rate
    if payload.phone_number is not None:
        phone = normalize_phone(payload.phone_number)
        if phone != user.phone_number:
            await _phone_available(db, phone, ignore_user=user.user_id)
            user.phone_number = phone
            revoke = True
    if payload.is_active is not None and payload.is_active != user.is_active:
        if not payload.is_active and await classroom.live_session_for_teacher(db, user.user_id):
            raise HTTPException(status_code=409, detail="End this teacher's live class first.")
        user.is_active = payload.is_active
        revoke = revoke or not payload.is_active
    if revoke:
        user.auth_version += 1
        await db.execute(models.FCMToken.__table__.delete().where(models.FCMToken.user_id == user.user_id))
    await db.commit()
    if revoke:
        await ws_mgr.revoke_user(user.user_id)
    await db.refresh(user)
    return _user_payload(user)


# ─── Shared phones (S43) ─────────────────────────────────────────────────────


class DeviceGroupCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    entry_phone_number: str = Field(min_length=1, max_length=32)


class DeviceGroupUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=120)
    entry_phone_number: Optional[str] = Field(default=None, min_length=1, max_length=32)
    is_active: Optional[bool] = None


class DeviceGroupMemberCreate(BaseModel):
    user_id: int
    profile_code: str = Field(pattern=r"^\d{1,4}$")


def _group_payload(group: models.DeviceGroup) -> dict:
    return {
        "group_id": group.group_id,
        "name": group.name,
        "entry_phone_number": group.entry_phone_number,
        "is_active": group.is_active,
        "members": [
            {
                "member_id": member.member_id,
                "user_id": member.user_id,
                "name": member.user.name if member.user else None,
                "role": member.user.role if member.user else None,
                "profile_code": member.profile_code,
            }
            for member in group.members
        ],
    }


async def _load_group(db: AsyncSession, group_id: int) -> models.DeviceGroup:
    group = (await db.execute(
        select(models.DeviceGroup).options(
            selectinload(models.DeviceGroup.members).selectinload(models.DeviceGroupMember.user),
        ).where(models.DeviceGroup.group_id == group_id)
        .execution_options(populate_existing=True)
    )).scalar_one_or_none()
    if group is None:
        raise HTTPException(status_code=404, detail="Shared phone not found")
    return group


@router.get("/device-groups")
async def list_device_groups(
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    groups = (await db.execute(
        select(models.DeviceGroup).options(
            selectinload(models.DeviceGroup.members).selectinload(models.DeviceGroupMember.user),
        ).order_by(models.DeviceGroup.name)
    )).scalars().all()
    return [_group_payload(group) for group in groups]


@router.post("/device-groups")
async def create_device_group(
    payload: DeviceGroupCreate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    phone = normalize_phone(payload.entry_phone_number)
    await _phone_available(db, phone)
    group = models.DeviceGroup(name=payload.name.strip(), entry_phone_number=phone)
    db.add(group)
    await db.commit()
    return _group_payload(await _load_group(db, group.group_id))


@router.patch("/device-groups/{group_id}")
async def update_device_group(
    group_id: int,
    payload: DeviceGroupUpdate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    group = await _load_group(db, group_id)
    if payload.name is not None:
        group.name = payload.name.strip()
    if payload.entry_phone_number is not None:
        phone = normalize_phone(payload.entry_phone_number)
        await _phone_available(db, phone, ignore_group=group.group_id)
        group.entry_phone_number = phone
    if payload.is_active is not None:
        group.is_active = payload.is_active
    await db.commit()
    return _group_payload(await _load_group(db, group_id))


@router.post("/device-groups/{group_id}/members")
async def add_device_group_member(
    group_id: int,
    payload: DeviceGroupMemberCreate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    group = await _load_group(db, group_id)
    user = await db.get(models.User, payload.user_id)
    if user is None or user.role not in {"student", "teacher"}:
        raise HTTPException(status_code=404, detail="Student or teacher account not found")
    if any(member.profile_code == payload.profile_code for member in group.members):
        raise HTTPException(status_code=409, detail="This profile number is already used on this phone.")
    existing = (await db.execute(
        select(models.DeviceGroupMember).where(models.DeviceGroupMember.user_id == user.user_id)
    )).scalar_one_or_none()
    if existing is not None:
        raise HTTPException(status_code=409, detail="This person already belongs to a shared phone.")
    db.add(models.DeviceGroupMember(group_id=group.group_id, user_id=user.user_id, profile_code=payload.profile_code))
    await db.commit()
    return _group_payload(await _load_group(db, group_id))


@router.delete("/device-groups/{group_id}/members/{member_id}")
async def remove_device_group_member(
    group_id: int,
    member_id: int,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    member = await db.get(models.DeviceGroupMember, member_id)
    if member is None or member.group_id != group_id:
        raise HTTPException(status_code=404, detail="Shared phone profile not found")
    await db.delete(member)
    await db.commit()
    return _group_payload(await _load_group(db, group_id))


# ─── Timetable (S05) and prepared lessons (S21/S23) ──────────────────────────


class TimetableEntryCreate(BaseModel):
    teacher_id: int
    class_id: int
    subject_id: int
    weekday: Optional[int] = Field(default=None, ge=0, le=6)
    # Several days at once: one weekly lesson is created for each.
    weekdays: list[int] = Field(default_factory=list, max_length=7)
    start_time: str
    end_time: str
    valid_from: Optional[date] = None
    valid_until: Optional[date] = None
    lesson_playlist_id: Optional[int] = None

    def days(self) -> list[int]:
        days = sorted(set(self.weekdays) | ({self.weekday} if self.weekday is not None else set()))
        if not days or any(day < 0 or day > 6 for day in days):
            raise HTTPException(status_code=422, detail="Choose at least one day of the week.")
        return days


class TimetableEntryUpdate(BaseModel):
    teacher_id: Optional[int] = None
    weekday: Optional[int] = Field(default=None, ge=0, le=6)
    start_time: Optional[str] = None
    end_time: Optional[str] = None
    valid_from: Optional[date] = None
    valid_until: Optional[date] = None
    lesson_playlist_id: Optional[int] = None
    clear_lesson: bool = False
    clear_valid_from: bool = False
    clear_valid_until: bool = False
    is_active: Optional[bool] = None


class OccurrenceUpdate(BaseModel):
    is_cancelled: bool = False
    substitute_teacher_id: Optional[int] = None
    lesson_playlist_id: Optional[int] = None
    note: Optional[str] = Field(default=None, max_length=500)


class HolidayCreate(BaseModel):
    holiday_date: date
    name: str = Field(min_length=1, max_length=120)


def _entry_payload(entry: models.TimetableEntry) -> dict:
    return {
        "entry_id": entry.entry_id,
        "teacher_id": entry.teacher_id,
        "teacher_name": entry.teacher.name if entry.teacher else None,
        "class_id": entry.class_id,
        "class_name": entry.school_class.name if entry.school_class else None,
        "subject_id": entry.subject_id,
        "subject_name": entry.subject.name if entry.subject else None,
        "weekday": entry.weekday,
        "start_time": _clock(entry.start_minute),
        "end_time": _clock(entry.end_minute),
        "valid_from": entry.valid_from.isoformat() if entry.valid_from else None,
        "valid_until": entry.valid_until.isoformat() if entry.valid_until else None,
        "lesson_playlist_id": entry.lesson_playlist_id,
        "lesson_title": entry.lesson_playlist.title if entry.lesson_playlist else None,
        "is_active": entry.is_active,
    }


def _conflict_message(conflicts: list[models.TimetableEntry]) -> str:
    first = conflicts[0]
    return (
        "This overlaps "
        f"{first.subject.name if first.subject else 'a lesson'} for "
        f"{first.school_class.name if first.school_class else 'a class'} with "
        f"{first.teacher.name if first.teacher else 'a teacher'} "
        f"({_clock(first.start_minute)}–{_clock(first.end_minute)})."
    )


async def _require_teacher(db: AsyncSession, teacher_id: int) -> models.User:
    teacher = await db.get(models.User, teacher_id)
    if teacher is None or teacher.role != "teacher" or not teacher.is_active:
        raise HTTPException(status_code=404, detail="Active teacher not found")
    return teacher


async def _require_assignment(db: AsyncSession, teacher_id: int, class_id: int, subject_id: int) -> None:
    """Weekly lessons use only the class and subject pairs the teacher teaches."""
    await access.require_active_class_subject(db, class_id, subject_id)
    assigned = (await db.execute(
        select(models.TeacherClassSubjectAssignment.assignment_id).where(
            models.TeacherClassSubjectAssignment.teacher_id == teacher_id,
            models.TeacherClassSubjectAssignment.class_id == class_id,
            models.TeacherClassSubjectAssignment.subject_id == subject_id,
            models.TeacherClassSubjectAssignment.is_active.is_(True),
        )
    )).first()
    if assigned is None:
        raise HTTPException(
            status_code=422,
            detail="This teacher does not teach this class and subject. Add it to the teacher in People first.",
        )


async def _ensure_assignment(db: AsyncSession, teacher_id: int, class_id: int, subject_id: int, admin_id: int) -> None:
    """Scheduling a teacher for a class and subject also assigns them to it."""
    await access.require_active_class_subject(db, class_id, subject_id)
    assignment = (await db.execute(
        select(models.TeacherClassSubjectAssignment).where(
            models.TeacherClassSubjectAssignment.teacher_id == teacher_id,
            models.TeacherClassSubjectAssignment.class_id == class_id,
            models.TeacherClassSubjectAssignment.subject_id == subject_id,
        )
    )).scalar_one_or_none()
    if assignment is None:
        db.add(models.TeacherClassSubjectAssignment(
            teacher_id=teacher_id, class_id=class_id, subject_id=subject_id, assigned_by=admin_id,
        ))
    elif not assignment.is_active:
        assignment.is_active = True
        assignment.archived_at = None


async def _require_lesson(
    db: AsyncSession, playlist_id: int, teacher_id: int, class_id: int, subject_id: int,
) -> None:
    playlist = await db.get(models.TeacherPlaylist, playlist_id)
    if (
        playlist is None or playlist.is_archived
        or playlist.owner_teacher_id != teacher_id
        or playlist.class_id != class_id or playlist.subject_id != subject_id
    ):
        raise HTTPException(
            status_code=422,
            detail="Choose a lesson playlist made by this teacher for this class and subject.",
        )


async def _load_entry(db: AsyncSession, entry_id: int) -> models.TimetableEntry:
    entry = (await db.execute(
        select(models.TimetableEntry).options(
            selectinload(models.TimetableEntry.teacher),
            selectinload(models.TimetableEntry.school_class),
            selectinload(models.TimetableEntry.subject),
            selectinload(models.TimetableEntry.lesson_playlist),
        ).where(models.TimetableEntry.entry_id == entry_id)
        .execution_options(populate_existing=True)
    )).scalar_one_or_none()
    if entry is None:
        raise HTTPException(status_code=404, detail="Timetable entry not found")
    return entry


@router.get("/timetable")
async def list_timetable(
    teacher_id: Optional[int] = None,
    class_id: Optional[int] = None,
    include_inactive: bool = False,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    query = select(models.TimetableEntry).options(
        selectinload(models.TimetableEntry.teacher),
        selectinload(models.TimetableEntry.school_class),
        selectinload(models.TimetableEntry.subject),
        selectinload(models.TimetableEntry.lesson_playlist),
    )
    if teacher_id is not None:
        query = query.where(models.TimetableEntry.teacher_id == teacher_id)
    if class_id is not None:
        query = query.where(models.TimetableEntry.class_id == class_id)
    if not include_inactive:
        query = query.where(models.TimetableEntry.is_active.is_(True))
    entries = (await db.execute(query.order_by(
        models.TimetableEntry.weekday, models.TimetableEntry.start_minute,
    ))).scalars().all()
    return [_entry_payload(entry) for entry in entries]


@router.post("/timetable")
async def create_timetable_entry(
    payload: TimetableEntryCreate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    start, end = _minutes(payload.start_time), _minutes(payload.end_time)
    if start >= end:
        raise HTTPException(status_code=422, detail="The lesson must end after it starts.")
    if payload.valid_from and payload.valid_until and payload.valid_from > payload.valid_until:
        raise HTTPException(status_code=422, detail="The end date must be on or after the start date.")
    days = payload.days()
    await _require_teacher(db, payload.teacher_id)
    await _require_assignment(db, payload.teacher_id, payload.class_id, payload.subject_id)
    if payload.lesson_playlist_id is not None:
        await _require_lesson(db, payload.lesson_playlist_id, payload.teacher_id, payload.class_id, payload.subject_id)
    for day in days:
        conflicts = await sched.conflicting_entries(
            db, teacher_id=payload.teacher_id, class_id=payload.class_id, weekday=day,
            start_minute=start, end_minute=end,
            valid_from=payload.valid_from, valid_until=payload.valid_until,
        )
        if conflicts:
            message = _conflict_message(conflicts)
            if len(days) > 1:
                message = f"On {calendar.day_name[day]}: {message}"
            await db.rollback()
            raise HTTPException(status_code=409, detail=message)
    entries = [
        models.TimetableEntry(
            teacher_id=payload.teacher_id, class_id=payload.class_id, subject_id=payload.subject_id,
            weekday=day, start_minute=start, end_minute=end,
            valid_from=payload.valid_from, valid_until=payload.valid_until,
            lesson_playlist_id=payload.lesson_playlist_id,
        )
        for day in days
    ]
    db.add_all(entries)
    await db.commit()
    loaded = [await _load_entry(db, entry.entry_id) for entry in entries]
    first = loaded[0]
    title = teacher_notices.lesson_title(first)
    teacher_notices.notify(db, [first.teacher_id], admin.user_id, "lesson", first.entry_id, title, "created")
    await teacher_notices.notify_class(db, first.class_id, admin.user_id, "lesson", first.entry_id, title, "created")
    await db.commit()
    created = [_entry_payload(entry) for entry in loaded]
    # The first lesson keeps the single-entry response shape; "entries" lists every day.
    return {**created[0], "entries": created}


@router.patch("/timetable/{entry_id}")
async def update_timetable_entry(
    entry_id: int,
    payload: TimetableEntryUpdate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    entry = await _load_entry(db, entry_id)
    teacher_id = payload.teacher_id if payload.teacher_id is not None else entry.teacher_id
    weekday = payload.weekday if payload.weekday is not None else entry.weekday
    start = _minutes(payload.start_time) if payload.start_time else entry.start_minute
    end = _minutes(payload.end_time) if payload.end_time else entry.end_minute
    valid_from = None if payload.clear_valid_from else (
        payload.valid_from if payload.valid_from is not None else entry.valid_from
    )
    valid_until = None if payload.clear_valid_until else (
        payload.valid_until if payload.valid_until is not None else entry.valid_until
    )
    active = payload.is_active if payload.is_active is not None else entry.is_active
    if start >= end:
        raise HTTPException(status_code=422, detail="The lesson must end after it starts.")
    if valid_from and valid_until and valid_from > valid_until:
        raise HTTPException(status_code=422, detail="The end date must be on or after the start date.")
    if teacher_id != entry.teacher_id:
        await _require_teacher(db, teacher_id)
        await _require_assignment(db, teacher_id, entry.class_id, entry.subject_id)
    playlist_id = None if payload.clear_lesson else (
        payload.lesson_playlist_id if payload.lesson_playlist_id is not None else entry.lesson_playlist_id
    )
    if playlist_id is not None:
        await _require_lesson(db, playlist_id, teacher_id, entry.class_id, entry.subject_id)
    if active:
        conflicts = await sched.conflicting_entries(
            db, teacher_id=teacher_id, class_id=entry.class_id, weekday=weekday,
            start_minute=start, end_minute=end, valid_from=valid_from, valid_until=valid_until,
            ignore_entry_id=entry.entry_id,
        )
        if conflicts:
            message = _conflict_message(conflicts)
            await db.rollback()
            raise HTTPException(status_code=409, detail=message)
    previous_teacher, was_active = entry.teacher_id, entry.is_active
    title = teacher_notices.lesson_title(entry)
    entry.teacher_id, entry.weekday = teacher_id, weekday
    entry.start_minute, entry.end_minute = start, end
    entry.valid_from, entry.valid_until = valid_from, valid_until
    entry.lesson_playlist_id, entry.is_active = playlist_id, active
    if was_active and not active:
        teacher_notices.notify(db, [previous_teacher], admin.user_id, "lesson", entry_id, title, "removed")
        await teacher_notices.notify_class(db, entry.class_id, admin.user_id, "lesson", entry_id, title, "removed")
    elif active:
        if previous_teacher != teacher_id:
            teacher_notices.notify(db, [previous_teacher], admin.user_id, "lesson", entry_id, title, "removed")
        teacher_notices.notify(
            db, [teacher_id], admin.user_id, "lesson", entry_id, title,
            "updated" if was_active and previous_teacher == teacher_id else "created",
        )
        if not was_active:
            await teacher_notices.notify_class(db, entry.class_id, admin.user_id, "lesson", entry_id, title, "created")
    await db.commit()
    return _entry_payload(await _load_entry(db, entry_id))


@router.get("/timetable/{entry_id}/occurrences")
async def list_occurrence_overrides(
    entry_id: int,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    await _load_entry(db, entry_id)
    rows = (await db.execute(
        select(models.OccurrenceOverride).options(selectinload(models.OccurrenceOverride.substitute))
        .where(models.OccurrenceOverride.entry_id == entry_id)
        .order_by(models.OccurrenceOverride.occurrence_date)
    )).scalars().all()
    return [_override_payload(row) for row in rows]


def _override_payload(row: models.OccurrenceOverride) -> dict:
    return {
        "override_id": row.override_id,
        "entry_id": row.entry_id,
        "occurrence_date": row.occurrence_date.isoformat(),
        "is_cancelled": row.is_cancelled,
        "substitute_teacher_id": row.substitute_teacher_id,
        "substitute_name": row.substitute.name if row.substitute else None,
        "lesson_playlist_id": row.lesson_playlist_id,
        "note": row.note,
    }


@router.put("/timetable/{entry_id}/occurrences/{occurrence_date}")
async def set_occurrence_override(
    entry_id: int,
    occurrence_date: date,
    payload: OccurrenceUpdate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    entry = await _load_entry(db, entry_id)
    if not sched.entry_applies(entry, occurrence_date):
        raise HTTPException(status_code=422, detail="This lesson does not happen on that date.")
    live = (await db.execute(
        select(models.Session).where(
            models.Session.timetable_entry_id == entry_id,
            models.Session.occurrence_date == occurrence_date,
        )
    )).scalar_one_or_none()
    if live is not None:
        raise HTTPException(status_code=409, detail="This lesson has already started; end it first.")
    teacher_id = entry.teacher_id
    if payload.substitute_teacher_id is not None:
        await _require_teacher(db, payload.substitute_teacher_id)
        if await sched.substitute_conflicts(db, entry, occurrence_date, payload.substitute_teacher_id):
            raise HTTPException(status_code=409, detail="The substitute already teaches at that time.")
        await _ensure_assignment(db, payload.substitute_teacher_id, entry.class_id, entry.subject_id, admin.user_id)
        teacher_id = payload.substitute_teacher_id
    if payload.lesson_playlist_id is not None:
        await _require_lesson(db, payload.lesson_playlist_id, teacher_id, entry.class_id, entry.subject_id)
    row = (await db.execute(
        select(models.OccurrenceOverride).where(
            models.OccurrenceOverride.entry_id == entry_id,
            models.OccurrenceOverride.occurrence_date == occurrence_date,
        )
    )).scalar_one_or_none()
    if row is None:
        row = models.OccurrenceOverride(entry_id=entry_id, occurrence_date=occurrence_date)
        db.add(row)
    was_cancelled, previous_substitute = row.is_cancelled, row.substitute_teacher_id
    row.is_cancelled = payload.is_cancelled
    row.substitute_teacher_id = payload.substitute_teacher_id
    row.lesson_playlist_id = payload.lesson_playlist_id
    row.note = payload.note
    title, day = teacher_notices.lesson_title(entry), teacher_notices.day_detail(occurrence_date)
    if payload.is_cancelled and not was_cancelled:
        teacher_notices.notify(
            db, [entry.teacher_id, payload.substitute_teacher_id], admin.user_id,
            "lesson", entry_id, title, "cancelled", day,
        )
        await teacher_notices.notify_class(db, entry.class_id, admin.user_id, "lesson", entry_id, title, "cancelled", day)
    elif not payload.is_cancelled and payload.substitute_teacher_id != previous_substitute:
        if payload.substitute_teacher_id is not None:
            teacher_notices.notify(
                db, [payload.substitute_teacher_id], admin.user_id, "lesson", entry_id, title, "substitute", day,
            )
            teacher_notices.notify(db, [entry.teacher_id], admin.user_id, "lesson", entry_id, title, "covered", day)
        elif previous_substitute is not None:
            teacher_notices.notify(db, [previous_substitute], admin.user_id, "lesson", entry_id, title, "removed", day)
    await db.commit()
    row = (await db.execute(
        select(models.OccurrenceOverride).options(selectinload(models.OccurrenceOverride.substitute))
        .where(models.OccurrenceOverride.override_id == row.override_id)
    )).scalar_one()
    return _override_payload(row)


@router.delete("/timetable/{entry_id}/occurrences/{occurrence_date}")
async def clear_occurrence_override(
    entry_id: int,
    occurrence_date: date,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    row = (await db.execute(
        select(models.OccurrenceOverride).where(
            models.OccurrenceOverride.entry_id == entry_id,
            models.OccurrenceOverride.occurrence_date == occurrence_date,
        )
    )).scalar_one_or_none()
    if row is not None:
        await db.delete(row)
        await db.commit()
    return {"ok": True}


@router.get("/holidays")
async def list_holidays(
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    rows = (await db.execute(select(models.SchoolHoliday).order_by(models.SchoolHoliday.holiday_date))).scalars().all()
    return [{"holiday_id": row.holiday_id, "holiday_date": row.holiday_date.isoformat(), "name": row.name} for row in rows]


@router.post("/holidays")
async def create_holiday(
    payload: HolidayCreate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    existing = (await db.execute(
        select(models.SchoolHoliday).where(models.SchoolHoliday.holiday_date == payload.holiday_date)
    )).scalar_one_or_none()
    if existing is not None:
        raise HTTPException(status_code=409, detail="That date is already a holiday.")
    row = models.SchoolHoliday(holiday_date=payload.holiday_date, name=payload.name.strip())
    db.add(row)
    await db.commit()
    return {"holiday_id": row.holiday_id, "holiday_date": row.holiday_date.isoformat(), "name": row.name}


@router.delete("/holidays/{holiday_id}")
async def delete_holiday(
    holiday_id: int,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    row = await db.get(models.SchoolHoliday, holiday_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Holiday not found")
    await db.delete(row)
    await db.commit()
    return {"ok": True}


@router.get("/schedule")
async def schedule_for_day(
    day: Optional[date] = None,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    """Every lesson on a date with its state: upcoming, live, held or cancelled."""
    del admin
    day = day or sched.local_today()
    occurrences = await sched.occurrences_on(db, day, include_cancelled=True)
    sessions = {
        (row.timetable_entry_id, row.occurrence_date): row
        for row in (await db.execute(
            select(models.Session).where(models.Session.occurrence_date == day)
        )).scalars().all()
    }
    now = sched.utcnow()
    output = []
    for occurrence in occurrences:
        session = sessions.get(occurrence.key)
        if occurrence.cancelled:
            state = "cancelled"
        elif session is not None and session.is_active:
            state = "live"
        elif session is not None:
            state = "held"
        elif occurrence.end < now:
            state = "not_started"
        else:
            state = "upcoming"
        output.append({
            "entry_id": occurrence.entry_id,
            "occurrence_date": day.isoformat(),
            "start_time": sched.local_clock(occurrence.start),
            "end_time": sched.local_clock(occurrence.end),
            "class_name": occurrence.class_name,
            "subject_name": occurrence.subject_name,
            "teacher_name": occurrence.teacher_name,
            "substitute": occurrence.teacher_id != occurrence.regular_teacher_id,
            "has_lesson": occurrence.lesson_playlist_id is not None,
            "state": state,
            "session_id": session.session_id if session else None,
        })
    return output


@router.get("/teachers/{teacher_id}/lessons")
async def teacher_lesson_playlists(
    teacher_id: int,
    class_id: int,
    subject_id: int,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    """Playlists a teacher has made for a class and subject (lesson packages)."""
    del admin
    rows = (await db.execute(
        select(models.TeacherPlaylist).where(
            models.TeacherPlaylist.owner_teacher_id == teacher_id,
            models.TeacherPlaylist.class_id == class_id,
            models.TeacherPlaylist.subject_id == subject_id,
            models.TeacherPlaylist.is_archived.is_(False),
        ).order_by(models.TeacherPlaylist.title)
    )).scalars().all()
    return [{"playlist_id": row.playlist_id, "title": row.title} for row in rows]


# ─── Exception queue (S41) ───────────────────────────────────────────────────


@router.get("/issues")
async def list_issues(
    status: Literal["open", "resolved", "all"] = "open",
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    query = select(models.AdminIssue)
    if status != "all":
        query = query.where(models.AdminIssue.status == status)
    rows = (await db.execute(query.order_by(models.AdminIssue.last_seen_at.desc()).limit(200))).scalars().all()
    return [
        {
            "issue_id": row.issue_id,
            "kind": row.kind,
            "message": row.message,
            "details": row.details or {},
            "status": row.status,
            "occurrences": row.occurrences,
            "created_at": sched.iso_local(row.created_at),
            "last_seen_at": sched.iso_local(row.last_seen_at),
        }
        for row in rows
    ]


@router.post("/issues/{issue_id}/resolve")
async def resolve_issue(
    issue_id: int,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    row = await db.get(models.AdminIssue, issue_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Issue not found")
    row.status = "resolved"
    row.resolved_at = sched.utcnow()
    row.resolved_by = admin.user_id
    await db.commit()
    return {"ok": True}


# ─── Session records (S25) ───────────────────────────────────────────────────


@router.get("/sessions")
async def list_sessions(
    status: Literal["live", "ended", "all"] = "all",
    limit: int = Query(100, ge=1, le=500),
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    query = select(models.Session).options(
        selectinload(models.Session.school_class),
        selectinload(models.Session.subject),
        selectinload(models.Session.creator),
    )
    if status == "live":
        query = query.where(models.Session.is_active.is_(True))
    elif status == "ended":
        query = query.where(models.Session.is_active.is_(False))
    rows = (await db.execute(query.order_by(models.Session.session_id.desc()).limit(limit))).scalars().all()
    output = []
    for row in rows:
        count = (await db.execute(
            select(func.count(models.Participant.participant_id)).where(
                models.Participant.session_id == row.session_id,
                models.Participant.first_connected_at.isnot(None),
            )
        )).scalar() or 0
        output.append({
            **(await classroom.session_summary(db, row)),
            # School-local (IST) so the dashboard never depends on the admin's clock.
            "started_at": sched.iso_local(row.started_at or row.created_at),
            "ended_at": sched.iso_local(row.ended_at),
            "end_reason": row.end_reason,
            "extension_minutes": row.extension_minutes,
            "students_joined": count,
        })
    return output


async def _admin_live_session(db: AsyncSession, admin: models.User, session_id: int) -> models.Session:
    return await classroom._managed_live_session(db, admin, session_id)


@router.post("/sessions/{session_id}/end")
async def admin_end_session(
    session_id: int,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    session = await _admin_live_session(db, admin, session_id)
    await classroom.end_class(db, session, reason="admin", ended_by=admin.user_id)
    return {"ok": True}


@router.post("/sessions/{session_id}/extend")
async def admin_extend_session(
    session_id: int,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await classroom.extend_class(db, await _admin_live_session(db, admin, session_id))
