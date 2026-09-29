"""Class, subject, enrollment, assignment, and accessible roster APIs."""

from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

import access_control as access
import auth
import models
import schemas
from database import get_db


router = APIRouter(tags=["Class and subject access"])


@router.get("/catalog/classes", response_model=list[schemas.ClassOut])
async def list_classes(
    include_archived: bool = False,
    current_user: models.User = Depends(auth.get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = select(models.SchoolClass)
    if not (include_archived and current_user.role == "admin"):
        query = query.filter(models.SchoolClass.is_active.is_(True))
    result = await db.execute(query.order_by(models.SchoolClass.sort_order))
    return result.scalars().all()


@router.get("/catalog/subjects", response_model=list[schemas.SubjectOut])
async def list_subjects(
    include_archived: bool = False,
    current_user: models.User = Depends(auth.get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = select(models.Subject)
    if not (include_archived and current_user.role == "admin"):
        query = query.filter(models.Subject.is_active.is_(True))
    result = await db.execute(query.order_by(models.Subject.name))
    return result.scalars().all()


@router.get("/me/access-context")
async def access_context(
    current_user: models.User = Depends(auth.get_current_user),
    db: AsyncSession = Depends(get_db),
):
    response: dict = {
        "user_id": current_user.user_id,
        "name": current_user.name,
        "role": current_user.role,
        "student_class": None,
        "teacher_workspaces": [],
    }
    if current_user.role == "student":
        try:
            membership = await access.get_active_student_membership(db, current_user.user_id)
        except HTTPException:
            return response
        school_class = await db.get(models.SchoolClass, membership.class_id)
        response["student_class"] = {
            "class_id": membership.class_id,
            "class_name": school_class.name if school_class else "Class",
        }
    elif current_user.role == "teacher":
        result = await db.execute(
            select(models.TeacherClassSubjectAssignment)
            .options(
                selectinload(models.TeacherClassSubjectAssignment.school_class),
                selectinload(models.TeacherClassSubjectAssignment.subject),
            )
            .filter(
                models.TeacherClassSubjectAssignment.teacher_id == current_user.user_id,
                models.TeacherClassSubjectAssignment.is_active.is_(True),
            )
        )
        response["teacher_workspaces"] = [
            {
                "assignment_id": assignment.assignment_id,
                "class_id": assignment.class_id,
                "class_name": assignment.school_class.name,
                "subject_id": assignment.subject_id,
                "subject_name": assignment.subject.name,
            }
            for assignment in result.scalars().all()
            if assignment.school_class.is_active and assignment.subject.is_active
        ]
    return response


@router.get("/admin/users", response_model=list[schemas.AdminUserOut])
async def admin_list_users(
    search: str = "",
    unassigned_only: bool = False,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    query = select(models.User).filter(models.User.role.in_(["student", "teacher"]))
    if search.strip():
        pattern = f"%{search.strip().lower()}%"
        query = query.filter(
            func.lower(models.User.name).like(pattern)
            | func.lower(models.User.phone_number).like(pattern)
        )
    users = (await db.execute(query.order_by(models.User.name))).scalars().all()
    output = []
    for user in users:
        class_id = None
        class_name = None
        assignment_count = 0
        if user.role == "student":
            membership_result = await db.execute(
                select(models.StudentClassMembership).filter(
                    models.StudentClassMembership.student_id == user.user_id,
                    models.StudentClassMembership.is_active.is_(True),
                )
            )
            membership = membership_result.scalar_one_or_none()
            if membership:
                school_class = await db.get(models.SchoolClass, membership.class_id)
                class_id = membership.class_id
                class_name = school_class.name if school_class else None
        else:
            count_result = await db.execute(
                select(func.count(models.TeacherClassSubjectAssignment.assignment_id)).filter(
                    models.TeacherClassSubjectAssignment.teacher_id == user.user_id,
                    models.TeacherClassSubjectAssignment.is_active.is_(True),
                )
            )
            assignment_count = count_result.scalar() or 0
        if unassigned_only and (class_id is not None or assignment_count > 0):
            continue
        output.append(
            {
                "user_id": user.user_id,
                "name": user.name,
                "phone_number": user.phone_number,
                "role": user.role,
                "class_id": class_id,
                "class_name": class_name,
                "assignment_count": assignment_count,
            }
        )
    return output


@router.post("/admin/classes", response_model=schemas.ClassOut)
async def create_class(
    payload: schemas.ClassCreate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    name = payload.name.strip()
    if not name:
        raise HTTPException(status_code=422, detail="Class name is required")
    existing = await db.execute(
        select(models.SchoolClass).filter(
            (func.lower(models.SchoolClass.name) == name.lower())
            | (models.SchoolClass.sort_order == payload.sort_order)
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Class name or order already exists")
    school_class = models.SchoolClass(
        name=name, sort_order=payload.sort_order,
    )
    db.add(school_class)
    await db.commit()
    await db.refresh(school_class)
    return school_class


@router.post("/admin/classes/{class_id}/archive", response_model=schemas.ClassOut)
async def archive_class(
    class_id: int,
    archived: bool = True,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    school_class = await db.get(models.SchoolClass, class_id)
    if school_class is None:
        raise HTTPException(status_code=404, detail="Class not found")
    school_class.is_active = not archived
    await db.commit()
    await db.refresh(school_class)
    return school_class


@router.post("/admin/subjects", response_model=schemas.SubjectOut)
async def create_subject(
    payload: schemas.SubjectCreate,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    name = payload.name.strip()
    if not name:
        raise HTTPException(status_code=422, detail="Subject name is required")
    result = await db.execute(
        select(models.Subject).filter(func.lower(models.Subject.name) == name.lower())
    )
    existing = result.scalar_one_or_none()
    if existing:
        if existing.is_active:
            raise HTTPException(status_code=409, detail="Subject already exists")
        existing.is_active = True
        existing.archived_at = None
        await db.commit()
        await db.refresh(existing)
        return existing
    subject = models.Subject(name=name)
    db.add(subject)
    await db.commit()
    await db.refresh(subject)
    return subject


@router.post("/admin/subjects/{subject_id}/archive", response_model=schemas.SubjectOut)
async def archive_subject(
    subject_id: int,
    archived: bool = True,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    subject = await db.get(models.Subject, subject_id)
    if subject is None:
        raise HTTPException(status_code=404, detail="Subject not found")
    subject.is_active = not archived
    subject.archived_at = datetime.utcnow() if archived else None
    await db.commit()
    await db.refresh(subject)
    return subject


@router.post("/admin/students/{student_id}/class", response_model=schemas.StudentMembershipOut)
async def enroll_or_transfer_student(
    student_id: int,
    payload: schemas.StudentEnrollmentRequest,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    student = await db.get(models.User, student_id)
    if student is None or student.role != "student":
        raise HTTPException(status_code=404, detail="Student not found")
    school_class = await db.get(models.SchoolClass, payload.class_id)
    if school_class is None or not school_class.is_active:
        raise HTTPException(status_code=404, detail="Active class not found")
    active_result = await db.execute(
        select(models.StudentClassMembership).filter(
            models.StudentClassMembership.student_id == student_id,
            models.StudentClassMembership.is_active.is_(True),
        )
    )
    current = active_result.scalar_one_or_none()
    if current and current.class_id == payload.class_id:
        membership = current
    else:
        if current:
            current.is_active = False
            current.ended_at = datetime.utcnow()
            await db.flush()
        membership = models.StudentClassMembership(
            student_id=student_id,
            class_id=payload.class_id,
            assigned_by=admin.user_id,
        )
        db.add(membership)
        await db.commit()
        await db.refresh(membership)
    return {
        "membership_id": membership.membership_id,
        "student_id": student_id,
        "student_name": student.name,
        "class_id": school_class.class_id,
        "class_name": school_class.name,
        "is_active": membership.is_active,
        "assigned_at": membership.assigned_at,
    }


@router.get("/admin/teachers/{teacher_id}/assignments", response_model=list[schemas.TeacherAssignmentOut])
async def list_teacher_assignments(
    teacher_id: int,
    include_archived: bool = False,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    query = select(models.TeacherClassSubjectAssignment).options(
        selectinload(models.TeacherClassSubjectAssignment.teacher),
        selectinload(models.TeacherClassSubjectAssignment.school_class),
        selectinload(models.TeacherClassSubjectAssignment.subject),
    ).filter(models.TeacherClassSubjectAssignment.teacher_id == teacher_id)
    if not include_archived:
        query = query.filter(models.TeacherClassSubjectAssignment.is_active.is_(True))
    assignments = (await db.execute(query)).scalars().all()
    return [_assignment_payload(assignment) for assignment in assignments]


@router.post("/admin/teachers/{teacher_id}/assignments", response_model=schemas.TeacherAssignmentOut)
async def assign_teacher(
    teacher_id: int,
    payload: schemas.TeacherAssignmentRequest,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    teacher = await db.get(models.User, teacher_id)
    if teacher is None or teacher.role != "teacher":
        raise HTTPException(status_code=404, detail="Teacher not found")
    school_class, subject = await access.require_active_class_subject(
        db, payload.class_id, payload.subject_id,
    )
    result = await db.execute(
        select(models.TeacherClassSubjectAssignment).filter(
            models.TeacherClassSubjectAssignment.teacher_id == teacher_id,
            models.TeacherClassSubjectAssignment.class_id == payload.class_id,
            models.TeacherClassSubjectAssignment.subject_id == payload.subject_id,
        )
    )
    assignment = result.scalar_one_or_none()
    if assignment:
        assignment.is_active = True
        assignment.archived_at = None
        assignment.assigned_by = admin.user_id
    else:
        assignment = models.TeacherClassSubjectAssignment(
            teacher_id=teacher_id,
            class_id=payload.class_id,
            subject_id=payload.subject_id,
            assigned_by=admin.user_id,
        )
        db.add(assignment)
    await db.commit()
    await db.refresh(assignment)
    return {
        "assignment_id": assignment.assignment_id,
        "teacher_id": teacher.user_id,
        "teacher_name": teacher.name,
        "class_id": school_class.class_id,
        "class_name": school_class.name,
        "subject_id": subject.subject_id,
        "subject_name": subject.name,
        "is_active": assignment.is_active,
    }


@router.delete("/admin/teachers/{teacher_id}/assignments/{assignment_id}")
async def archive_teacher_assignment(
    teacher_id: int,
    assignment_id: int,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    del admin
    assignment = await db.get(models.TeacherClassSubjectAssignment, assignment_id)
    if assignment is None or assignment.teacher_id != teacher_id:
        raise HTTPException(status_code=404, detail="Assignment not found")
    assignment.is_active = False
    assignment.archived_at = datetime.utcnow()
    await db.commit()
    return {"ok": True}


@router.get("/teacher/classes/{class_id}/subjects/{subject_id}/students", response_model=list[schemas.UserOut])
async def teacher_roster(
    class_id: int,
    subject_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    await access.require_teacher_assignment(db, teacher.user_id, class_id, subject_id)
    result = await db.execute(
        select(models.User)
        .join(
            models.StudentClassMembership,
            models.StudentClassMembership.student_id == models.User.user_id,
        )
        .filter(
            models.StudentClassMembership.class_id == class_id,
            models.StudentClassMembership.is_active.is_(True),
            models.User.role == "student",
        )
        .order_by(models.User.name)
    )
    return result.scalars().all()


def _assignment_payload(assignment: models.TeacherClassSubjectAssignment) -> dict:
    return {
        "assignment_id": assignment.assignment_id,
        "teacher_id": assignment.teacher_id,
        "teacher_name": assignment.teacher.name,
        "class_id": assignment.class_id,
        "class_name": assignment.school_class.name,
        "subject_id": assignment.subject_id,
        "subject_name": assignment.subject.name,
        "is_active": assignment.is_active,
    }
