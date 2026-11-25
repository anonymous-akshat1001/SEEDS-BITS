import asyncio
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

import pytest
import pytest_asyncio
from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import auth  # noqa: E402
import classroom  # noqa: E402
import jobs  # noqa: E402
import main  # noqa: E402
import models  # noqa: E402
import quiz_routes  # noqa: E402
import scheduling as sched  # noqa: E402
import school_admin_routes as admin_api  # noqa: E402

MONDAY = date(2026, 11, 16)


def at(clock: str, day: date = MONDAY) -> datetime:
    hours, minutes = map(int, clock.split(":"))
    return sched.local_minute_to_utc(day, hours * 60 + minutes)


class Clock:
    def __init__(self, monkeypatch):
        self.now = at("08:00")
        monkeypatch.setattr(sched, "utcnow", lambda: self.now)
        monkeypatch.setattr(jobs, "utcnow", lambda: self.now)

    def set(self, clock: str):
        self.now = at(clock)


@pytest_asyncio.fixture
async def school(monkeypatch):
    engine = create_async_engine(
        "sqlite+aiosqlite://", poolclass=StaticPool, connect_args={"check_same_thread": False},
    )
    async with engine.begin() as connection:
        await connection.run_sync(models.Base.metadata.create_all)
    factory = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    clock = Clock(monkeypatch)
    sent = []

    async def fake_alert(token, **kwargs):
        sent.append((token, kwargs))
        return True

    async def fake_notification(*args, **kwargs):
        return True

    monkeypatch.setattr(classroom.fcm_service, "send_class_alert", fake_alert)
    monkeypatch.setattr(classroom.fcm_service, "send_notification", fake_notification)
    async with factory() as db:
        class_one = models.SchoolClass(name="Class 6", sort_order=1)
        english = models.Subject(name="English")
        maths = models.Subject(name="Maths")
        admin = models.User(name="Admin", phone_number="9000000000", role="admin", password_hash="x")
        teacher = models.User(name="Mrs Rao", phone_number="9000000001", role="teacher", password_hash="x")
        other_teacher = models.User(name="Mr Das", phone_number="9000000002", role="teacher", password_hash="x")
        asha = models.User(name="Asha", phone_number="9000000003", role="student", password_hash="x")
        ravi = models.User(name="Ravi", phone_number="9000000004", role="student", password_hash="x")
        db.add_all([class_one, english, maths, admin, teacher, other_teacher, asha, ravi])
        await db.flush()
        db.add_all([
            models.ClassSubjectAssociation(class_id=class_one.class_id, subject_id=english.subject_id),
            models.ClassSubjectAssociation(class_id=class_one.class_id, subject_id=maths.subject_id),
        ])
        await db.flush()
        db.add_all([
            models.TeacherClassSubjectAssignment(
                teacher_id=teacher.user_id, class_id=class_one.class_id, subject_id=english.subject_id,
            ),
            models.TeacherClassSubjectAssignment(
                teacher_id=other_teacher.user_id, class_id=class_one.class_id, subject_id=maths.subject_id,
            ),
            models.StudentClassMembership(student_id=asha.user_id, class_id=class_one.class_id),
            models.StudentClassMembership(student_id=ravi.user_id, class_id=class_one.class_id),
            models.FCMToken(user_id=asha.user_id, token="asha-phone"),
            models.FCMToken(user_id=ravi.user_id, token="ravi-phone"),
        ])
        await db.commit()
        data = dict(
            class_one=class_one, english=english, maths=maths, admin=admin, teacher=teacher,
            other_teacher=other_teacher, asha=asha, ravi=ravi,
        )
        try:
            yield db, data, clock, factory, sent
        finally:
            for session_id in list(main.SESSION_STATE):
                main.SESSION_STATE.pop(session_id, None)
                main.ws_mgr.active.pop(session_id, None)
    await engine.dispose()


async def add_entry(db, data, start="09:00", end="09:40", teacher="teacher", subject="english"):
    entry = models.TimetableEntry(
        teacher_id=data[teacher].user_id, class_id=data["class_one"].class_id,
        subject_id=data[subject].subject_id, weekday=MONDAY.weekday(),
        start_minute=int(start[:2]) * 60 + int(start[3:]), end_minute=int(end[:2]) * 60 + int(end[3:]),
    )
    db.add(entry)
    await db.commit()
    return entry


def test_cutoff_is_earlier_of_grace_and_five_minutes_before_next_class():
    end = at("09:40")
    assert sched.base_cutoff(end, None, None) == at("10:10")
    assert sched.base_cutoff(end, at("10:00"), None) == at("09:55")
    assert sched.base_cutoff(end, at("11:00"), at("10:05")) == at("10:00")
    assert sched.extended_cutoff(at("10:10"), None) == at("10:25")
    assert sched.extended_cutoff(at("10:10"), at("10:20")) == at("10:20")
    assert sched.extended_cutoff(at("10:10"), at("10:10")) is None


@pytest.mark.asyncio
async def test_substitutes_cancellations_and_holidays_change_who_sees_the_class(school):
    db, data, clock, factory, sent = school
    entry = await add_entry(db, data)
    assert [o.teacher_id for o in await sched.occurrences_on(db, MONDAY)] == [data["teacher"].user_id]
    db.add(models.OccurrenceOverride(
        entry_id=entry.entry_id, occurrence_date=MONDAY, substitute_teacher_id=data["other_teacher"].user_id,
    ))
    await db.commit()
    assert await sched.occurrences_on(db, MONDAY, teacher_id=data["teacher"].user_id) == []
    substitute = await sched.occurrences_on(db, MONDAY, teacher_id=data["other_teacher"].user_id)
    assert substitute[0].teacher_name == "Mr Das"
    assert await sched.occurrences_on(db, MONDAY + timedelta(days=7), teacher_id=data["teacher"].user_id)
    db.add(models.SchoolHoliday(holiday_date=MONDAY + timedelta(days=7), name="Festival"))
    await db.commit()
    assert await sched.occurrences_on(db, MONDAY + timedelta(days=7)) == []


@pytest.mark.asyncio
async def test_start_is_one_action_idempotent_titled_and_alerts_the_class(school):
    db, data, clock, factory, sent = school
    entry = await add_entry(db, data)
    await add_entry(db, data, "10:00", "10:40")
    clock.set("08:45")
    home = await classroom.home(current_user=data["teacher"], db=db)
    assert home["today"][0]["status"] == "upcoming" and not home["today"][0]["can_start"]
    with pytest.raises(HTTPException) as early:
        await classroom.start_class(db, data["teacher"], classroom.StartClassRequest(entry_id=entry.entry_id))
    assert early.value.status_code == 409 and "08:50" in early.value.detail
    clock.set("08:55")
    home = await classroom.home(current_user=data["teacher"], db=db)
    assert home["today"][0]["can_start"] is True
    session, created = await classroom.start_class(
        db, data["teacher"], classroom.StartClassRequest(entry_id=entry.entry_id),
    )
    assert created and session.is_active
    assert session.title.startswith("English, Class 6")
    # Back-to-back with the teacher's next class: five minutes before it.
    assert session.cutoff_at == at("09:55")
    again, created_again = await classroom.start_class(
        db, data["teacher"], classroom.StartClassRequest(entry_id=entry.entry_id),
    )
    assert not created_again and again.session_id == session.session_id
    student_home = await classroom.home(current_user=data["asha"], db=db)
    assert student_home["live_class"]["session_id"] == session.session_id
    assert student_home["live_class"]["subject_name"] == "English"
    await jobs.run_due_jobs(factory)
    assert sorted(token for token, _ in sent) == ["asha-phone", "ravi-phone"]
    assert all(kwargs["alert_kind"] == "start" for _, kwargs in sent)
    ring = sent[0][1]["ring_until_ms"] / 1000
    assert ring - (clock.now - datetime(1970, 1, 1)).total_seconds() == 60


@pytest.mark.asyncio
async def test_one_live_class_per_teacher_and_per_enrolled_class(school):
    db, data, clock, factory, sent = school
    clock.set("09:00")
    english = classroom.StartClassRequest(class_id=data["class_one"].class_id, subject_id=data["english"].subject_id)
    maths = classroom.StartClassRequest(class_id=data["class_one"].class_id, subject_id=data["maths"].subject_id)
    session, _ = await classroom.start_class(db, data["teacher"], english)
    with pytest.raises(HTTPException) as busy_class:
        await classroom.start_class(db, data["other_teacher"], maths)
    assert busy_class.value.status_code == 409 and "another teacher" in busy_class.value.detail
    await classroom.end_class(db, session, reason="teacher", ended_by=data["teacher"].user_id)
    assert not await classroom.end_class(db, session, reason="teacher", ended_by=data["teacher"].user_id)
    second, created = await classroom.start_class(db, data["other_teacher"], maths)
    assert created and second.cutoff_at == at("10:15")


@pytest.mark.asyncio
async def test_roster_reminders_and_cooldown_follow_actual_joins(school):
    db, data, clock, factory, sent = school
    clock.set("09:00")
    session, _ = await classroom.start_class(db, data["teacher"], classroom.StartClassRequest(
        class_id=data["class_one"].class_id, subject_id=data["english"].subject_id,
    ))
    await jobs.run_due_jobs(factory)
    sent.clear()
    asha = models.Participant(session_id=session.session_id, user_id=data["asha"].user_id, first_connected_at=clock.now)
    db.add(asha)
    await db.commit()
    roster = await classroom.class_roster(db, session)
    assert roster["counts"] == {"connected": 0, "left": 1, "not_joined": 1}
    assert [entry["name"] for entry in roster["not_joined"]] == ["Ravi"]
    main.ws_mgr.active[session.session_id] = {asha.participant_id: object()}
    assert (await classroom.class_roster(db, session))["counts"]["connected"] == 1
    clock.set("09:02")
    cooling = await classroom.queue_alert(db, session, "manual_reminder", requested_by=data["teacher"].user_id)
    assert cooling == {"eligible": 1, "queued": 0, "cooldown": 1}
    clock.set("09:10")
    await jobs.run_due_jobs(factory)  # the reminder queues its delivery
    await jobs.run_due_jobs(factory)
    assert [token for token, kwargs in sent] == ["ravi-phone"]
    assert sent[0][1]["alert_kind"] == "auto_reminder"
    clock.set("09:12")
    assert (await classroom.queue_alert(db, session, "manual_reminder"))["cooldown"] == 1
    clock.set("09:16")
    assert (await classroom.queue_alert(db, session, "manual_reminder"))["queued"] == 1


@pytest.mark.asyncio
async def test_extension_is_bounded_and_auto_end_respects_the_latest_cutoff(school):
    db, data, clock, factory, sent = school
    entry = await add_entry(db, data)
    clock.set("09:00")
    session, _ = await classroom.start_class(db, data["teacher"], classroom.StartClassRequest(entry_id=entry.entry_id))
    assert session.cutoff_at == at("10:10")
    await add_entry(db, data, "10:30", "11:00", teacher="other_teacher", subject="maths")
    extended = await classroom.extend_class(db, session)
    assert extended["minutes_added"] == 15 and not extended["can_extend"]
    assert session.cutoff_at == at("10:25")
    with pytest.raises(HTTPException) as no_more:
        await classroom.extend_class(db, session)
    assert no_more.value.status_code == 409
    clock.set("10:11")
    await jobs.run_due_jobs(factory)
    await db.refresh(session)
    assert session.is_active
    clock.set("10:25")
    await jobs.run_due_jobs(factory)
    await db.refresh(session)
    assert not session.is_active and session.end_reason == "automatic"


@pytest.mark.asyncio
async def test_admin_timetable_uses_only_the_teachers_pairs_and_rejects_overlaps(school):
    db, data, clock, factory, sent = school
    with pytest.raises(HTTPException) as unassigned:
        await admin_api.create_timetable_entry(admin_api.TimetableEntryCreate(
            teacher_id=data["other_teacher"].user_id, class_id=data["class_one"].class_id,
            subject_id=data["english"].subject_id, weekday=0, start_time="09:00", end_time="09:40",
        ), admin=data["admin"], db=db)
    assert unassigned.value.status_code == 422 and "People" in unassigned.value.detail
    created = await admin_api.create_timetable_entry(admin_api.TimetableEntryCreate(
        teacher_id=data["teacher"].user_id, class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id, weekday=0, start_time="09:00", end_time="09:40",
    ), admin=data["admin"], db=db)
    assert created["start_time"] == "09:00" and len(created["entries"]) == 1
    with pytest.raises(HTTPException) as clash:
        await admin_api.create_timetable_entry(admin_api.TimetableEntryCreate(
            teacher_id=data["other_teacher"].user_id, class_id=data["class_one"].class_id,
            subject_id=data["maths"].subject_id, weekday=0, start_time="09:20", end_time="10:00",
        ), admin=data["admin"], db=db)
    assert clash.value.status_code == 409 and "Class 6" in clash.value.detail


@pytest.mark.asyncio
async def test_one_lesson_can_be_added_on_several_days_and_a_clash_adds_none(school):
    db, data, clock, factory, sent = school
    created = await admin_api.create_timetable_entry(admin_api.TimetableEntryCreate(
        teacher_id=data["teacher"].user_id, class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id, weekdays=[4, 0, 2, 0],
        start_time="09:00", end_time="09:40",
    ), admin=data["admin"], db=db)
    assert [entry["weekday"] for entry in created["entries"]] == [0, 2, 4]
    with pytest.raises(HTTPException) as clash:
        await admin_api.create_timetable_entry(admin_api.TimetableEntryCreate(
            teacher_id=data["other_teacher"].user_id, class_id=data["class_one"].class_id,
            subject_id=data["maths"].subject_id, weekdays=[1, 2],
            start_time="09:10", end_time="09:50",
        ), admin=data["admin"], db=db)
    assert clash.value.detail.startswith("On Wednesday:")
    count = (await db.execute(select(models.TimetableEntry))).scalars().all()
    assert len(count) == 3
    with pytest.raises(HTTPException) as no_day:
        admin_api.TimetableEntryCreate(
            teacher_id=1, class_id=1, subject_id=1, start_time="09:00", end_time="09:40",
        ).days()
    assert no_day.value.status_code == 422


@pytest.mark.asyncio
async def test_lesson_changes_are_announced_to_the_teacher_and_class(school):
    db, data, clock, factory, sent = school
    created = await admin_api.create_timetable_entry(admin_api.TimetableEntryCreate(
        teacher_id=data["teacher"].user_id, class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id, weekdays=[0, 2],
        start_time="09:00", end_time="09:40",
    ), admin=data["admin"], db=db)
    teacher_home = await classroom.home(data["teacher"], db)
    assert [(n["kind"], n["title"], n["action"], n["actor_role"]) for n in teacher_home["notices"]] == [
        ("lesson", "English, Class 6", "created", "admin"),
    ]
    assert teacher_home["admin_notices"] == teacher_home["notices"]
    student_home = await classroom.home(data["asha"], db)
    assert [n["action"] for n in student_home["notices"]] == ["created"]

    await admin_api.set_occurrence_override(
        created["entry_id"], MONDAY, admin_api.OccurrenceUpdate(substitute_teacher_id=data["other_teacher"].user_id),
        admin=data["admin"], db=db,
    )
    substitute = (await classroom.home(data["other_teacher"], db))["notices"]
    assert [(n["action"], n["detail"]) for n in substitute] == [("substitute", MONDAY.isoformat())]
    regular = [n["action"] for n in (await classroom.home(data["teacher"], db))["notices"]]
    assert regular == ["created", "covered"]

    await admin_api.update_timetable_entry(
        created["entry_id"], admin_api.TimetableEntryUpdate(is_active=False), admin=data["admin"], db=db,
    )
    assert [n["action"] for n in (await classroom.home(data["ravi"], db))["notices"]] == ["created", "removed"]


@pytest.mark.asyncio
async def test_new_people_need_a_class_or_a_class_and_subject(school):
    db, data, clock, factory, sent = school
    for payload in (
        admin_api.UserCreate(name="Mina", phone_number="9111111111", role="student"),
        admin_api.UserCreate(name="Mr Sen", phone_number="9111111112", role="teacher"),
    ):
        with pytest.raises(HTTPException) as missing:
            await admin_api.create_user(payload, admin=data["admin"], db=db)
        assert missing.value.status_code == 422
    created = await admin_api.create_user(admin_api.UserCreate(
        name="Mina", phone_number="9111111111", role="student", class_id=data["class_one"].class_id,
    ), admin=data["admin"], db=db)
    assert created["role"] == "student"


@pytest.mark.asyncio
async def test_prepared_lesson_is_linked_and_listed_in_order_for_the_teacher(school):
    db, data, clock, factory, sent = school
    audio = [
        models.AudioFile(
            title=title, file_path=f"{title}.mp3", uploaded_by=data["teacher"].user_id,
            class_id=data["class_one"].class_id, subject_id=data["english"].subject_id,
        )
        for title in ("Part one", "Part two")
    ]
    db.add_all(audio)
    await db.flush()
    playlist = models.TeacherPlaylist(
        owner_teacher_id=data["teacher"].user_id, class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id, title="Today's story",
    )
    db.add(playlist)
    await db.flush()
    db.add_all([
        models.TeacherPlaylistItem(playlist_id=playlist.playlist_id, audio_id=audio[1].audio_id, position=1),
        models.TeacherPlaylistItem(playlist_id=playlist.playlist_id, audio_id=audio[0].audio_id, position=0),
    ])
    entry = await add_entry(db, data)
    entry.lesson_playlist_id = playlist.playlist_id
    await db.commit()
    clock.set("09:00")
    session, _ = await classroom.start_class(db, data["teacher"], classroom.StartClassRequest(entry_id=entry.entry_id))
    summary = await classroom.session_summary(db, session, for_teacher=True)
    assert [item["title"] for item in summary["lesson_items"]] == ["Part one", "Part two"]
    linked = (await db.execute(select(models.SessionAudio.audio_id).where(
        models.SessionAudio.session_id == session.session_id,
    ))).scalars().all()
    assert sorted(linked) == sorted(item.audio_id for item in audio)
    assert "lesson_items" not in await classroom.session_summary(db, session)


def test_quiz_auto_reminder_is_one_bounded_time():
    published = datetime(2026, 11, 16, 3, 0)
    quiz = models.Quiz(opens_at=None, closes_at=published + timedelta(days=5))
    assert quiz_routes._auto_reminder_time(quiz, published) == published + timedelta(days=4)
    quiz.closes_at = published + timedelta(hours=10)
    assert quiz_routes._auto_reminder_time(quiz, published) == published + timedelta(hours=5)
    quiz.closes_at = published + timedelta(minutes=30)
    assert quiz_routes._auto_reminder_time(quiz, published) is None
    quiz.closes_at = None
    assert quiz_routes._auto_reminder_time(quiz, published) == published + timedelta(hours=48)


@pytest.mark.asyncio
async def test_teacher_starts_a_published_quiz_for_the_class_and_sees_progress(school, monkeypatch):
    db, data, clock, factory, sent = school
    clock.set("09:00")
    broadcasts = []

    async def capture(session_id, event, **kwargs):
        broadcasts.append(event)

    monkeypatch.setattr(classroom.ws_mgr, "broadcast", capture)
    session, _ = await classroom.start_class(db, data["teacher"], classroom.StartClassRequest(
        class_id=data["class_one"].class_id, subject_id=data["english"].subject_id,
    ))
    common = dict(
        owner_teacher_id=data["teacher"].user_id, class_id=data["class_one"].class_id,
    )
    plants = models.Quiz(title="Plants", subject_id=data["english"].subject_id, status="published",
                         published_at=clock.now, **common)
    draft = models.Quiz(title="Draft", subject_id=data["english"].subject_id, status="draft", **common)
    other_subject = models.Quiz(title="Sums", subject_id=data["maths"].subject_id, status="published",
                                published_at=clock.now, **common)
    db.add_all([plants, draft, other_subject])
    await db.commit()

    listed = await classroom.list_activities(session.session_id, teacher=data["teacher"], db=db)
    assert [quiz["title"] for quiz in listed["quizzes"]] == ["Plants"]
    assert listed["current"] is None
    for quiz in (draft, other_subject):
        with pytest.raises(HTTPException) as refused:
            await classroom.start_activity(
                session.session_id, classroom.ActivityStart(kind="quiz", id=quiz.quiz_id),
                teacher=data["teacher"], db=db,
            )
        assert refused.value.status_code == 404

    started = await classroom.start_activity(
        session.session_id, classroom.ActivityStart(kind="quiz", id=plants.quiz_id),
        teacher=data["teacher"], db=db,
    )
    assert started["activity"] == {"kind": "quiz", "id": plants.quiz_id, "title": "Plants"}
    assert broadcasts[-1] == {"type": "activity_started", "kind": "quiz", "id": plants.quiz_id, "title": "Plants"}

    db.add_all([
        models.QuizAttempt(quiz_id=plants.quiz_id, student_id=data["asha"].user_id, attempt_number=1,
                           status="completed", total_questions=1, question_order=[], option_order={}),
        models.QuizAttempt(quiz_id=plants.quiz_id, student_id=data["ravi"].user_id, attempt_number=1,
                           status="in_progress", total_questions=1, question_order=[], option_order={}),
    ])
    await db.commit()
    progress = (await classroom.class_roster(db, session))["activity"]
    assert (progress["title"], progress["started"], progress["finished"]) == ("Plants", 2, 1)

    # Ravi has started but not finished; only he is left. He is in class.
    ravi = models.Participant(session_id=session.session_id, user_id=data["ravi"].user_id, first_connected_at=clock.now)
    db.add(ravi)
    await db.commit()
    queue = asyncio.Queue()
    main.ws_mgr.active[session.session_id] = {ravi.participant_id: queue}
    left = await classroom.activity_left_route(session.session_id, teacher=data["teacher"], db=db)
    assert [(s["name"], s["status"], s["in_class"]) for s in left["whole_class"]] == [("Ravi", "in_progress", True)]
    assert [s["name"] for s in left["in_class"]] == ["Ravi"]
    assert (left["finished"], left["enrolled"]) == (1, 2)
    assert (left["present"], left["started"]) == (1, 2)
    reminded = await classroom.remind_activity(session.session_id, teacher=data["teacher"], db=db)
    assert reminded["reminded"] == 1
    assert queue.get_nowait()["type"] == "activity_reminder"

    await classroom.stop_activity(session.session_id, teacher=data["teacher"], db=db)
    assert broadcasts[-1] == {"type": "activity_stopped"}
    assert (await classroom.class_roster(db, session))["activity"] is None
