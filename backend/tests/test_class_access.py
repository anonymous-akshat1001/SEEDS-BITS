import sys
from pathlib import Path

import pytest
import pytest_asyncio
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import access_control as access  # noqa: E402
import models  # noqa: E402
import playlist_routes  # noqa: E402


@pytest_asyncio.fixture
async def seeded_db():
    engine = create_async_engine(
        "sqlite+aiosqlite://",
        poolclass=StaticPool,
        connect_args={"check_same_thread": False},
    )
    async with engine.begin() as connection:
        await connection.run_sync(models.Base.metadata.create_all)

    factory = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with factory() as db:
        class_one = models.SchoolClass(name="Class 1", sort_order=1)
        class_two = models.SchoolClass(name="Class 2", sort_order=2)
        english = models.Subject(name="English")
        maths = models.Subject(name="Maths")
        teacher = models.User(
            name="Teacher One",
            phone_number="9000000001",
            role="teacher",
            password_hash="test",
        )
        student = models.User(
            name="Student One",
            phone_number="9000000002",
            role="student",
            password_hash="test",
        )
        other_student = models.User(
            name="Student Two",
            phone_number="9000000003",
            role="student",
            password_hash="test",
        )
        db.add_all([class_one, class_two, english, maths, teacher, student, other_student])
        await db.flush()
        db.add_all(
            [
                models.TeacherClassSubjectAssignment(
                    teacher_id=teacher.user_id,
                    class_id=class_one.class_id,
                    subject_id=english.subject_id,
                ),
                models.StudentClassMembership(
                    student_id=student.user_id,
                    class_id=class_one.class_id,
                ),
                models.StudentClassMembership(
                    student_id=other_student.user_id,
                    class_id=class_two.class_id,
                ),
            ]
        )
        await db.commit()
        yield db, {
            "class_one": class_one,
            "class_two": class_two,
            "english": english,
            "maths": maths,
            "teacher": teacher,
            "student": student,
            "other_student": other_student,
        }
    await engine.dispose()


@pytest.mark.asyncio
async def test_teacher_assignment_rejects_unassigned_pair(seeded_db):
    db, data = seeded_db
    await access.require_teacher_assignment(
        db,
        data["teacher"].user_id,
        data["class_one"].class_id,
        data["english"].subject_id,
    )
    with pytest.raises(HTTPException) as denied:
        await access.require_teacher_assignment(
            db,
            data["teacher"].user_id,
            data["class_two"].class_id,
            data["english"].subject_id,
        )
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_archived_teacher_assignment_is_denied(seeded_db):
    db, data = seeded_db
    result = await db.execute(
        models.TeacherClassSubjectAssignment.__table__.select().where(
            models.TeacherClassSubjectAssignment.teacher_id
            == data["teacher"].user_id
        )
    )
    assignment_id = result.first().assignment_id
    assignment = await db.get(models.TeacherClassSubjectAssignment, assignment_id)
    assignment.is_active = False
    await db.commit()

    with pytest.raises(HTTPException) as denied:
        await access.require_teacher_assignment(
            db,
            data["teacher"].user_id,
            data["class_one"].class_id,
            data["english"].subject_id,
        )
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_student_cannot_access_other_class_session(seeded_db):
    db, data = seeded_db
    session = models.Session(
        title="Other class",
        created_by=data["teacher"].user_id,
        class_id=data["class_two"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(session)
    await db.commit()
    with pytest.raises(HTTPException) as denied:
        await access.require_session_access(db, data["student"], session)
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_teacher_cannot_access_another_teachers_session(seeded_db):
    db, data = seeded_db
    other_teacher = models.User(
        name="Teacher Two",
        phone_number="9000000004",
        role="teacher",
        password_hash="test",
    )
    db.add(other_teacher)
    await db.flush()
    db.add(
        models.TeacherClassSubjectAssignment(
            teacher_id=other_teacher.user_id,
            class_id=data["class_one"].class_id,
            subject_id=data["english"].subject_id,
        )
    )
    session = models.Session(
        title="Teacher one's room",
        created_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(session)
    await db.commit()

    with pytest.raises(HTTPException) as denied:
        await access.require_session_access(db, other_teacher, session)
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_student_cannot_stream_other_class_audio(seeded_db):
    db, data = seeded_db
    audio = models.AudioFile(
        title="Class 2 audio",
        file_path="unused.mp3",
        uploaded_by=data["teacher"].user_id,
        class_id=data["class_two"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(audio)
    await db.commit()
    with pytest.raises(HTTPException) as denied:
        await access.require_audio_access(db, data["student"], audio)
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_teacher_cannot_access_another_teachers_audio(seeded_db):
    db, data = seeded_db
    other_teacher = models.User(
        name="Teacher Two",
        phone_number="9000000005",
        role="teacher",
        password_hash="test",
    )
    db.add(other_teacher)
    await db.flush()
    db.add(
        models.TeacherClassSubjectAssignment(
            teacher_id=other_teacher.user_id,
            class_id=data["class_one"].class_id,
            subject_id=data["english"].subject_id,
        )
    )
    audio = models.AudioFile(
        title="Teacher one's audio",
        file_path="unused.mp3",
        uploaded_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(audio)
    await db.commit()

    with pytest.raises(HTTPException) as denied:
        await access.require_audio_access(db, other_teacher, audio)
    assert denied.value.status_code == 403


@pytest.mark.asyncio
async def test_class_transfer_hides_old_class_audio(seeded_db):
    db, data = seeded_db
    old_audio = models.AudioFile(
        title="Old class audio",
        file_path="unused.mp3",
        uploaded_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
    )
    db.add(old_audio)
    current = await access.get_active_student_membership(db, data["student"].user_id)
    current.is_active = False
    db.add(
        models.StudentClassMembership(
            student_id=data["student"].user_id,
            class_id=data["class_two"].class_id,
        )
    )
    await db.commit()
    with pytest.raises(HTTPException):
        await access.require_audio_access(db, data["student"], old_audio)


@pytest.mark.asyncio
async def test_teacher_playlist_visible_only_to_published_class(seeded_db):
    db, data = seeded_db
    playlist = models.TeacherPlaylist(
        owner_teacher_id=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
        title="Reading",
        is_published=True,
        is_archived=False,
    )
    db.add(playlist)
    await db.commit()
    await access.require_teacher_playlist_access(db, data["student"], playlist)
    with pytest.raises(HTTPException):
        await access.require_teacher_playlist_access(
            db, data["other_student"], playlist,
        )
    playlist.is_archived = True
    await db.commit()
    with pytest.raises(HTTPException):
        await access.require_teacher_playlist_access(db, data["student"], playlist)


@pytest.mark.asyncio
async def test_unpublished_teacher_playlist_is_hidden_from_student(seeded_db):
    db, data = seeded_db
    playlist = models.TeacherPlaylist(
        owner_teacher_id=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
        title="Draft reading",
        is_published=False,
        is_archived=False,
    )
    db.add(playlist)
    await db.commit()

    with pytest.raises(HTTPException) as denied:
        await access.require_teacher_playlist_access(db, data["student"], playlist)
    assert denied.value.status_code == 403


def test_student_playlist_is_private_to_owner():
    owner = models.User(user_id=1, name="Owner", phone_number="1", role="student", password_hash="x")
    other = models.User(user_id=2, name="Other", phone_number="2", role="student", password_hash="x")
    playlist = models.StudentPlaylist(
        playlist_id=1,
        owner_student_id=owner.user_id,
        title="Private",
    )
    access.require_student_playlist_owner(owner, playlist)
    with pytest.raises(HTTPException) as denied:
        access.require_student_playlist_owner(other, playlist)
    assert denied.value.status_code == 404


@pytest.mark.asyncio
async def test_private_playlist_marks_old_class_item_unavailable(seeded_db):
    db, data = seeded_db
    audio = models.AudioFile(
        title="Old class story",
        file_path="unused.mp3",
        uploaded_by=data["teacher"].user_id,
        class_id=data["class_one"].class_id,
        subject_id=data["english"].subject_id,
    )
    playlist = models.StudentPlaylist(
        owner_student_id=data["student"].user_id,
        title="Saved stories",
    )
    db.add_all([audio, playlist])
    await db.flush()
    db.add(
        models.StudentPlaylistItem(
            playlist_id=playlist.playlist_id,
            audio_id=audio.audio_id,
            position=0,
        )
    )
    await db.commit()

    loaded = await playlist_routes._student_playlist(db, playlist.playlist_id)
    payload = playlist_routes._student_payload(
        loaded,
        active_class_id=data["class_two"].class_id,
    )
    assert payload["items"][0]["available"] is False
    assert payload["items"][0]["stream_path"] is None
