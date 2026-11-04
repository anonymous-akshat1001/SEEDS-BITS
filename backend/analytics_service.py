"""Exact scoped analytics; the model has no database access."""

from datetime import datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP

from fastapi import HTTPException
from sqlalchemy import select, func, exists, and_, or_, cast, String

import models


def month_shift(value, months):
    import calendar
    month = value.year * 12 + value.month - 1 + months
    year, month = divmod(month, 12)
    month += 1
    return value.replace(year=year, month=month,
                         day=min(value.day, calendar.monthrange(year, month)[1]))


def teacher_scope(user, owner, class_id, subject_id):
    if user.role == "admin":
        return True
    if user.role != "teacher":
        raise HTTPException(403, "Analytics requires an administrator or teacher.")
    return and_(
        owner == user.user_id,
        exists(select(models.TeacherClassSubjectAssignment.assignment_id).where(
            models.TeacherClassSubjectAssignment.teacher_id == user.user_id,
            models.TeacherClassSubjectAssignment.class_id == class_id,
            models.TeacherClassSubjectAssignment.subject_id == subject_id,
            models.TeacherClassSubjectAssignment.is_active.is_(True),
            models.SchoolClass.class_id == class_id,
            models.SchoolClass.is_active.is_(True),
            models.Subject.subject_id == subject_id,
            models.Subject.is_active.is_(True),
            models.ClassSubjectAssociation.class_id == class_id,
            models.ClassSubjectAssociation.subject_id == subject_id,
            models.ClassSubjectAssociation.is_active.is_(True),
        )),
    )


def visible_history(user):
    h = models.AnalyticsSession
    return teacher_scope(user, h.owner_teacher_id, h.class_id, h.subject_id)


def visible_quiz(user):
    q = models.Quiz
    return teacher_scope(user, q.owner_teacher_id, q.class_id, q.subject_id)


async def catalog(db, user, kind, search="", page=1, selected_id=None):
    h, q, u = models.AnalyticsSession, models.Quiz, models.User
    hs, qs = visible_history(user), visible_quiz(user)
    if kind in {"teacher", "student"}:
        query = select(u.user_id.label("id"), u.name.label("label")).where(u.role == kind)
        if user.role == "teacher":
            if kind == "teacher":
                query = query.where(u.user_id == user.user_id)
            else:
                query = query.where(or_(
                    exists(select(models.QuizAttempt.attempt_id).join(q).where(
                        models.QuizAttempt.student_id == u.user_id, qs,
                    )),
                    exists(select(models.AttendanceJoin.join_id).join(models.SessionRun).join(h).where(
                        models.AttendanceJoin.student_id == u.user_id, hs,
                    )),
                ))
    elif kind in {"class", "subject"}:
        entity = models.SchoolClass if kind == "class" else models.Subject
        key = entity.class_id if kind == "class" else entity.subject_id
        query = select(key.label("id"), entity.name.label("label"))
        if user.role == "teacher":
            assignment = models.TeacherClassSubjectAssignment
            query = query.where(exists(select(assignment.assignment_id).where(
                assignment.teacher_id == user.user_id, assignment.is_active.is_(True),
                (assignment.class_id if kind == "class" else assignment.subject_id) == key,
            )))
    elif kind == "session":
        s = models.Session
        archived_label = (
            "Archived session / " + models.SchoolClass.name + " / " + models.Subject.name
            + " / " + cast(h.created_at, String)
        )
        query = select(h.session_id.label("id"), func.coalesce(s.title, archived_label).label("label")) \
            .select_from(h).outerjoin(s, s.session_id == h.session_id) \
            .join(models.SchoolClass, models.SchoolClass.class_id == h.class_id) \
            .join(models.Subject, models.Subject.subject_id == h.subject_id).where(hs)
    else:
        raise HTTPException(422, "Unknown catalog kind.")
    label = query.selected_columns.label
    if selected_id is not None:
        query = query.where(query.selected_columns.id == selected_id)
    if search:
        escaped = search.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
        query = query.where(func.lower(label).like("%" + escaped.lower() + "%", escape="\\"))
    rows = (await db.execute(query.order_by(label, query.selected_columns.id)
                             .offset((page - 1) * 100).limit(101))).mappings().all()
    items = [dict(row) for row in rows[:100]]
    if kind == "teacher" and items:
        assignment = models.TeacherClassSubjectAssignment
        contexts = (await db.execute(select(
            assignment.teacher_id, models.SchoolClass.name, models.Subject.name,
        ).join(models.SchoolClass, models.SchoolClass.class_id == assignment.class_id)
          .join(models.Subject, models.Subject.subject_id == assignment.subject_id).where(
              assignment.teacher_id.in_([item["id"] for item in items]),
              assignment.is_active.is_(True),
          ).limit(1000))).all()
        for item in items:
            item["context"] = ", ".join(f"{row[1]} / {row[2]}" for row in contexts if row[0] == item["id"])
    return {"items": items, "has_more": len(rows) > 100}


async def resolve(db, user, kind, name, selected_id=None):
    if name is None and selected_id is None:
        return None
    # Exact normalized matches only; candidate lists never leave caller scope.
    result = await catalog(db, user, kind, name or "", selected_id=selected_id)
    matches = [item for item in result["items"]
               if name is None or " ".join((item["label"] or "").split()).casefold() == name.casefold()]
    if len(matches) != 1:
        raise HTTPException(409, {
            "status": "clarification_required",
            "message": f"Select a unique permitted {kind} name.",
            "clarifications": result["items"],
        })
    return matches[0]["id"]


async def execute(db, user, intent):
    now = datetime.utcnow()
    start = intent.start or (datetime.min if intent.all_time else now - timedelta(days=30))
    end = intent.end or now
    if start >= end or end > now + timedelta(minutes=5):
        raise HTTPException(422, "Invalid reporting interval.")
    ids = {}
    for field, kind in (("teacher", "teacher"), ("student", "student"),
                        ("class_name", "class"), ("subject", "subject"), ("session", "session")):
        ids[field] = await resolve(db, user, kind, getattr(intent, field), getattr(intent, field + "_id"))
    h, run, join, quiz, attempt, log = (
        models.AnalyticsSession, models.SessionRun, models.AttendanceJoin,
        models.Quiz, models.QuizAttempt, models.Log,
    )
    filters = []
    metric = intent.metric
    if metric in {"sessions_created", "session_openings", "attendance"}:
        query = select(h.session_id).where(visible_history(user))
        filters += [h.owner_teacher_id == ids["teacher"]] if ids["teacher"] else []
        filters += [h.class_id == ids["class_name"]] if ids["class_name"] else []
        filters += [h.subject_id == ids["subject"]] if ids["subject"] else []
        filters += [h.session_id == ids["session"]] if ids["session"] else []
        live_retention = or_(run.ended_at.is_(None), run.expires_at > now)
        if metric == "sessions_created":
            source = models.Session
            known_legacy = and_(
                h.provenance == "partial",
                exists(select(source.session_id).where(
                    source.session_id == h.session_id,
                    or_(source.is_active.is_(True), source.ended_at > month_shift(now, -18)),
                )),
            )
            query = select(func.count(func.distinct(h.session_id))).where(
                visible_history(user), h.created_at >= start, h.created_at < end,
                or_(known_legacy, exists(select(run.run_id).where(run.session_id == h.session_id, live_retention))),
            )
        elif metric == "session_openings":
            query = select(func.count(run.run_id)).join(h, h.session_id == run.session_id).where(
                visible_history(user), live_retention, run.opened_at >= start, run.opened_at < end,
            )
        else:
            query = select(func.count(func.distinct(join.student_id))).select_from(join).join(run).join(h).where(
                visible_history(user), live_retention, join.joined_at >= start, join.joined_at < end,
            )
            if ids["student"]:
                filters.append(join.student_id == ids["student"])
    elif metric in {"quiz_average", "quiz_attempts"}:
        query = select(
            func.avg(attempt.percentage_score) if metric == "quiz_average" else func.count(attempt.attempt_id),
            func.count(attempt.attempt_id),
        ).select_from(attempt).join(quiz).where(
            visible_quiz(user), quiz.mode == "graded",
            attempt.status.in_(["completed", "timed_out"]),
            attempt.retention_expires_at > now,
            attempt.completed_at >= start,
            attempt.completed_at < end,
        )
        for column, key in ((quiz.owner_teacher_id, "teacher"), (quiz.class_id, "class_name"),
                            (quiz.subject_id, "subject"), (attempt.student_id, "student")):
            if ids[key]:
                filters.append(column == ids[key])
    else:
        if start < now - timedelta(days=30, seconds=1):
            raise HTTPException(422, "Activity history covers only the last 30 days.")
        query = select(log.event_type, log.source, func.count().label("count")).where(
            log.created_at >= start, log.created_at < end,
            teacher_scope(user, log.owner_teacher_id, log.class_id, log.subject_id),
        )
        for column, key in ((log.owner_teacher_id, "teacher"), (log.class_id, "class_name"),
                            (log.subject_id, "subject"), (log.user_id, "student")):
            if ids[key]:
                filters.append(column == ids[key])
        if ids["session"]:
            filters.extend([log.resource_type == "session", log.resource_id == ids["session"]])
        if intent.event_type:
            filters.append(log.event_type == intent.event_type)
        query = query.where(*filters).group_by(log.event_type, log.source).order_by(log.event_type, log.source)
        groups = query.order_by(None).subquery()
        value = await db.scalar(select(func.coalesce(func.sum(groups.c.count), 0)))
        rows = [dict(row) for row in (await db.execute(
            query.offset((intent.page - 1) * 100).limit(101),
        )).mappings()]
        count = value
    if metric != "activity_counts":
        result = (await db.execute(query.where(*filters))).one()
        value, count = result[0], result[1] if len(result) > 1 else result[0]
        if metric == "quiz_average" and value is not None:
            value = float(Decimal(str(value)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP))
        rows = []
    has_more = metric == "activity_counts" and len(rows) > 100
    rows = rows[:100]
    names = {key: getattr(intent, key) for key in ids if getattr(intent, key)}
    suffix = " " + ", ".join(f"{key}: {value}" for key, value in names.items()) if names else ""
    answer = ("No finalized graded attempts." if value is None else
              f"{metric.replace('_', ' ').capitalize()}: {value}"
              + ("%" if metric == "quiz_average" else "") + suffix + ".")
    return {
        "status": "no_data" if value is None else "answered", "answer": answer,
        "metric": metric, "value": value, "count": count, "rows": rows, "has_more": has_more,
        "filters": {**names, "start": start.isoformat() + "Z", "end": end.isoformat() + "Z"},
        "timezone": "Asia/Kolkata", "as_of": now.isoformat() + "Z",
        "coverage": "Logs: 30 days. Attendance: 18 months after a run ends; "
                    "graded attempts: 18 months after finalization. "
                    "Legacy creation timestamps are preserved where available; "
                    "pre-instrumentation attendance and opening counts are unknown. "
                    "Teacher results include only currently assigned, owned resources.",
    }
