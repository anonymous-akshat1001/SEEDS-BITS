"""Server-side class, subject, ownership, and playlist authorization helpers."""

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

import models


async def get_active_student_membership(
    db: AsyncSession, student_id: int,
) -> models.StudentClassMembership:
    result = await db.execute(
        select(models.StudentClassMembership).filter(
            models.StudentClassMembership.student_id == student_id,
            models.StudentClassMembership.is_active.is_(True),
        )
    )
    membership = result.scalar_one_or_none()
    if membership is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Student has not been assigned to a class.",
        )
    return membership


async def require_teacher_assignment(
    db: AsyncSession, teacher_id: int, class_id: int, subject_id: int,
) -> models.TeacherClassSubjectAssignment:
    result = await db.execute(
        select(models.TeacherClassSubjectAssignment).filter(
            models.TeacherClassSubjectAssignment.teacher_id == teacher_id,
            models.TeacherClassSubjectAssignment.class_id == class_id,
            models.TeacherClassSubjectAssignment.subject_id == subject_id,
            models.TeacherClassSubjectAssignment.is_active.is_(True),
        )
    )
    assignment = result.scalar_one_or_none()
    if assignment is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Teacher is not assigned to this class and subject.",
        )
    return assignment


async def require_active_class_subject(
    db: AsyncSession, class_id: int, subject_id: int,
) -> tuple[models.SchoolClass, models.Subject]:
    class_result = await db.execute(
        select(models.SchoolClass).filter(
            models.SchoolClass.class_id == class_id,
            models.SchoolClass.is_active.is_(True),
        )
    )
    school_class = class_result.scalar_one_or_none()
    subject_result = await db.execute(
        select(models.Subject).filter(
            models.Subject.subject_id == subject_id,
            models.Subject.is_active.is_(True),
        )
    )
    subject = subject_result.scalar_one_or_none()
    if school_class is None:
        raise HTTPException(status_code=404, detail="Class not found or inactive.")
    if subject is None:
        raise HTTPException(status_code=404, detail="Subject not found or archived.")
    return school_class, subject


async def require_class_access(
    db: AsyncSession,
    user: models.User,
    class_id: int,
    subject_id: int | None = None,
) -> None:
    if user.role == "student":
        membership = await get_active_student_membership(db, user.user_id)
        if membership.class_id != class_id:
            raise HTTPException(status_code=403, detail="This content belongs to another class.")
        return
    if user.role == "teacher" and subject_id is not None:
        await require_teacher_assignment(db, user.user_id, class_id, subject_id)
        return
    raise HTTPException(status_code=403, detail="This account cannot access the requested content.")


async def require_session_access(
    db: AsyncSession,
    user: models.User,
    session: models.Session,
    *,
    manage: bool = False,
) -> None:
    await require_class_access(db, user, session.class_id, session.subject_id)
    # A class-subject assignment authorizes a teacher to create work in that
    # workspace; it does not expose another teacher's live room, participants,
    # chat, state, or logs.  Students are class-scoped, while every teacher
    # session operation is additionally owner-scoped.
    if user.role == "teacher" and session.created_by != user.user_id:
        raise HTTPException(status_code=403, detail="This session belongs to another teacher.")
    if manage and user.role != "teacher":
        raise HTTPException(status_code=403, detail="Only the session owner can manage this session.")


async def require_audio_access(
    db: AsyncSession,
    user: models.User,
    audio: models.AudioFile,
    *,
    manage: bool = False,
) -> None:
    await require_class_access(db, user, audio.class_id, audio.subject_id)
    if user.role == "teacher" and audio.uploaded_by != user.user_id:
        raise HTTPException(status_code=403, detail="Teachers can access only their own uploaded audio.")
    if manage and (user.role != "teacher" or audio.uploaded_by != user.user_id):
        raise HTTPException(status_code=403, detail="Only the audio owner can manage this audio.")


async def require_teacher_playlist_access(
    db: AsyncSession,
    user: models.User,
    playlist: models.TeacherPlaylist,
    *,
    manage: bool = False,
) -> None:
    if user.role == "teacher":
        if playlist.owner_teacher_id != user.user_id:
            raise HTTPException(status_code=403, detail="This playlist belongs to another teacher.")
        await require_teacher_assignment(
            db, user.user_id, playlist.class_id, playlist.subject_id,
        )
        return
    if not manage and user.role == "student":
        membership = await get_active_student_membership(db, user.user_id)
        if (
            membership.class_id == playlist.class_id
            and playlist.is_published
            and not playlist.is_archived
        ):
            return
    raise HTTPException(status_code=403, detail="This playlist is not available to this account.")


def require_student_playlist_owner(
    user: models.User, playlist: models.StudentPlaylist,
) -> None:
    if user.role != "student" or playlist.owner_student_id != user.user_id:
        raise HTTPException(status_code=404, detail="Private playlist not found.")
