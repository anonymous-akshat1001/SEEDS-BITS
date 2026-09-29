"""Teacher class playlists and student-private playlist APIs."""

import os

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

import access_control as access
import auth
import models
import schemas
from database import get_db


router = APIRouter(tags=["Playlists"])


def _teacher_options():
    return (
        selectinload(models.TeacherPlaylist.owner),
        selectinload(models.TeacherPlaylist.school_class),
        selectinload(models.TeacherPlaylist.subject),
        selectinload(models.TeacherPlaylist.items)
        .selectinload(models.TeacherPlaylistItem.audio)
        .selectinload(models.AudioFile.subject),
    )


def _student_options():
    return (
        selectinload(models.StudentPlaylist.items)
        .selectinload(models.StudentPlaylistItem.audio)
        .selectinload(models.AudioFile.subject),
    )


async def _teacher_playlist(
    db: AsyncSession, playlist_id: int,
) -> models.TeacherPlaylist:
    result = await db.execute(
        select(models.TeacherPlaylist)
        .options(*_teacher_options())
        .filter(models.TeacherPlaylist.playlist_id == playlist_id)
    )
    playlist = result.scalar_one_or_none()
    if playlist is None:
        raise HTTPException(status_code=404, detail="Teacher playlist not found")
    return playlist


async def _student_playlist(
    db: AsyncSession, playlist_id: int,
) -> models.StudentPlaylist:
    result = await db.execute(
        select(models.StudentPlaylist)
        .options(*_student_options())
        .filter(models.StudentPlaylist.playlist_id == playlist_id)
    )
    playlist = result.scalar_one_or_none()
    if playlist is None:
        raise HTTPException(status_code=404, detail="Private playlist not found")
    return playlist


def _item_payload(
    item,
    *,
    available: bool = True,
    stream_path: str | None = None,
) -> dict:
    return {
        "item_id": item.item_id,
        "audio_id": item.audio_id,
        "position": item.position,
        "title": item.audio.title if item.audio else "Unavailable audio",
        "subject_name": (
            item.audio.subject.name
            if item.audio and item.audio.subject
            else None
        ),
        "stream_path": stream_path if available else None,
        "available": available,
    }


def _teacher_payload(playlist: models.TeacherPlaylist, include_items: bool = True) -> dict:
    return {
        "playlist_id": playlist.playlist_id,
        "owner_teacher_id": playlist.owner_teacher_id,
        "owner_name": playlist.owner.name if playlist.owner else None,
        "class_id": playlist.class_id,
        "class_name": playlist.school_class.name if playlist.school_class else None,
        "subject_id": playlist.subject_id,
        "subject_name": playlist.subject.name if playlist.subject else None,
        "title": playlist.title,
        "description": playlist.description,
        "is_published": playlist.is_published,
        "is_archived": playlist.is_archived,
        "created_at": playlist.created_at,
        "updated_at": playlist.updated_at,
        "item_count": len(playlist.items),
        "items": [
            _item_payload(
                item,
                stream_path=(
                    f"/teacher-playlists/{playlist.playlist_id}"
                    f"/items/{item.item_id}/stream"
                ),
            )
            for item in playlist.items
        ] if include_items else [],
    }


def _student_payload(
    playlist: models.StudentPlaylist,
    include_items: bool = True,
    *,
    active_class_id: int | None = None,
) -> dict:
    return {
        "playlist_id": playlist.playlist_id,
        "owner_student_id": playlist.owner_student_id,
        "title": playlist.title,
        "description": playlist.description,
        "visibility": playlist.visibility or "private",
        "created_at": playlist.created_at,
        "updated_at": playlist.updated_at,
        "item_count": len(playlist.items),
        "items": [
            _item_payload(
                item,
                available=(
                    item.audio is not None
                    and (
                        active_class_id is None
                        or item.audio.class_id == active_class_id
                    )
                ),
                stream_path=(
                    f"/student-playlists/{playlist.playlist_id}"
                    f"/items/{item.item_id}/stream"
                ),
            )
            for item in playlist.items
        ] if include_items else [],
    }


@router.get("/teacher-playlists", response_model=list[schemas.TeacherPlaylistOut])
async def list_teacher_playlists(
    include_archived: bool = False,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    query = select(models.TeacherPlaylist).options(*_teacher_options()).filter(
        models.TeacherPlaylist.owner_teacher_id == teacher.user_id,
    )
    if not include_archived:
        query = query.filter(models.TeacherPlaylist.is_archived.is_(False))
    playlists = (await db.execute(query.order_by(models.TeacherPlaylist.updated_at.desc()))).scalars().all()
    output = []
    for playlist in playlists:
        try:
            await access.require_teacher_playlist_access(db, teacher, playlist, manage=True)
        except HTTPException:
            continue
        output.append(_teacher_payload(playlist, include_items=False))
    return output


@router.post("/teacher-playlists", response_model=schemas.TeacherPlaylistOut)
async def create_teacher_playlist(
    payload: schemas.TeacherPlaylistCreate,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    title = payload.title.strip()
    if not title:
        raise HTTPException(status_code=422, detail="Playlist title is required")
    await access.require_active_class_subject(db, payload.class_id, payload.subject_id)
    await access.require_teacher_assignment(
        db, teacher.user_id, payload.class_id, payload.subject_id,
    )
    playlist = models.TeacherPlaylist(
        owner_teacher_id=teacher.user_id,
        class_id=payload.class_id,
        subject_id=payload.subject_id,
        title=title,
        description=(payload.description or "").strip(),
    )
    db.add(playlist)
    await db.commit()
    return _teacher_payload(await _teacher_playlist(db, playlist.playlist_id))


@router.get("/teacher-playlists/{playlist_id}", response_model=schemas.TeacherPlaylistOut)
async def get_teacher_playlist(
    playlist_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _teacher_playlist(db, playlist_id)
    await access.require_teacher_playlist_access(db, teacher, playlist, manage=True)
    return _teacher_payload(playlist)


@router.patch("/teacher-playlists/{playlist_id}", response_model=schemas.TeacherPlaylistOut)
async def update_teacher_playlist(
    playlist_id: int,
    payload: schemas.PlaylistUpdate,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _teacher_playlist(db, playlist_id)
    await access.require_teacher_playlist_access(db, teacher, playlist, manage=True)
    if payload.title is not None:
        title = payload.title.strip()
        if not title:
            raise HTTPException(status_code=422, detail="Playlist title is required")
        playlist.title = title
    if payload.description is not None:
        playlist.description = payload.description.strip()
    await db.commit()
    return _teacher_payload(await _teacher_playlist(db, playlist_id))


@router.post("/teacher-playlists/{playlist_id}/publish", response_model=schemas.TeacherPlaylistOut)
async def publish_teacher_playlist(
    playlist_id: int,
    published: bool = True,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _teacher_playlist(db, playlist_id)
    await access.require_teacher_playlist_access(db, teacher, playlist, manage=True)
    if published and playlist.is_archived:
        raise HTTPException(status_code=400, detail="Restore the playlist before publishing it")
    playlist.is_published = published
    await db.commit()
    return _teacher_payload(await _teacher_playlist(db, playlist_id))


@router.post("/teacher-playlists/{playlist_id}/archive", response_model=schemas.TeacherPlaylistOut)
async def archive_teacher_playlist(
    playlist_id: int,
    archived: bool = True,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _teacher_playlist(db, playlist_id)
    await access.require_teacher_playlist_access(db, teacher, playlist, manage=True)
    playlist.is_archived = archived
    if archived:
        playlist.is_published = False
    await db.commit()
    return _teacher_payload(await _teacher_playlist(db, playlist_id))


@router.post("/teacher-playlists/{playlist_id}/items", response_model=schemas.TeacherPlaylistOut)
async def add_teacher_playlist_item(
    playlist_id: int,
    payload: schemas.PlaylistItemAdd,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _teacher_playlist(db, playlist_id)
    await access.require_teacher_playlist_access(db, teacher, playlist, manage=True)
    audio = await db.get(models.AudioFile, payload.audio_id)
    if audio is None:
        raise HTTPException(status_code=404, detail="Audio not found")
    await access.require_audio_access(db, teacher, audio, manage=True)
    if audio.class_id != playlist.class_id or audio.subject_id != playlist.subject_id:
        raise HTTPException(status_code=400, detail="Audio must match the playlist class and subject")
    if any(item.audio_id == audio.audio_id for item in playlist.items):
        raise HTTPException(status_code=409, detail="Audio is already in this playlist")
    db.add(
        models.TeacherPlaylistItem(
            playlist_id=playlist_id,
            audio_id=audio.audio_id,
            position=len(playlist.items),
        )
    )
    await db.commit()
    return _teacher_payload(await _teacher_playlist(db, playlist_id))


@router.delete("/teacher-playlists/{playlist_id}/items/{item_id}", response_model=schemas.TeacherPlaylistOut)
async def remove_teacher_playlist_item(
    playlist_id: int,
    item_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _teacher_playlist(db, playlist_id)
    await access.require_teacher_playlist_access(db, teacher, playlist, manage=True)
    item = next((entry for entry in playlist.items if entry.item_id == item_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Playlist item not found")
    await db.delete(item)
    await db.flush()
    await _renumber_teacher(db, playlist_id)
    await db.commit()
    return _teacher_payload(await _teacher_playlist(db, playlist_id))


@router.post("/teacher-playlists/{playlist_id}/reorder", response_model=schemas.TeacherPlaylistOut)
async def reorder_teacher_playlist(
    playlist_id: int,
    payload: schemas.PlaylistReorder,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _teacher_playlist(db, playlist_id)
    await access.require_teacher_playlist_access(db, teacher, playlist, manage=True)
    await _apply_order(db, playlist.items, payload.item_ids)
    await db.commit()
    return _teacher_payload(await _teacher_playlist(db, playlist_id))


@router.get("/student/teacher-playlists", response_model=list[schemas.TeacherPlaylistOut])
async def student_teacher_playlists(
    subject_id: int | None = None,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    membership = await access.get_active_student_membership(db, student.user_id)
    filters = [
        models.TeacherPlaylist.class_id == membership.class_id,
        models.TeacherPlaylist.is_published.is_(True),
        models.TeacherPlaylist.is_archived.is_(False),
    ]
    if subject_id is not None:
        filters.append(models.TeacherPlaylist.subject_id == subject_id)
    result = await db.execute(
        select(models.TeacherPlaylist).options(*_teacher_options()).filter(*filters)
        .order_by(models.TeacherPlaylist.updated_at.desc())
    )
    return [_teacher_payload(playlist, include_items=False) for playlist in result.scalars().all()]


@router.get("/student/teacher-playlists/{playlist_id}", response_model=schemas.TeacherPlaylistOut)
async def student_teacher_playlist_detail(
    playlist_id: int,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _teacher_playlist(db, playlist_id)
    await access.require_teacher_playlist_access(db, student, playlist)
    return _teacher_payload(playlist)


@router.get("/teacher-playlists/{playlist_id}/items/{item_id}/stream")
async def stream_teacher_playlist_item(
    playlist_id: int,
    item_id: int,
    current_user: models.User = Depends(auth.get_media_user),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _teacher_playlist(db, playlist_id)
    await access.require_teacher_playlist_access(db, current_user, playlist)
    item = next((entry for entry in playlist.items if entry.item_id == item_id), None)
    if item is None or item.audio is None:
        raise HTTPException(status_code=404, detail="Playlist item not found")
    await access.require_audio_access(db, current_user, item.audio)
    if not os.path.isfile(item.audio.file_path):
        raise HTTPException(status_code=404, detail="Audio file is unavailable")
    return FileResponse(
        item.audio.file_path,
        media_type=item.audio.mime_type,
    )


@router.get("/student-playlists", response_model=list[schemas.StudentPlaylistOut])
async def list_student_playlists(
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(models.StudentPlaylist).options(*_student_options()).filter(
            models.StudentPlaylist.owner_student_id == student.user_id,
        ).order_by(models.StudentPlaylist.updated_at.desc())
    )
    return [_student_payload(playlist, include_items=False) for playlist in result.scalars().all()]


@router.post("/student-playlists", response_model=schemas.StudentPlaylistOut)
async def create_student_playlist(
    payload: schemas.PlaylistCreate,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    await access.get_active_student_membership(db, student.user_id)
    title = payload.title.strip()
    if not title:
        raise HTTPException(status_code=422, detail="Playlist title is required")
    playlist = models.StudentPlaylist(
        owner_student_id=student.user_id,
        title=title,
        description=(payload.description or "").strip(),
    )
    db.add(playlist)
    await db.commit()
    return _student_payload(await _student_playlist(db, playlist.playlist_id))


@router.get("/student-playlists/{playlist_id}", response_model=schemas.StudentPlaylistOut)
async def get_student_playlist(
    playlist_id: int,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _student_playlist(db, playlist_id)
    access.require_student_playlist_owner(student, playlist)
    membership = await access.get_active_student_membership(db, student.user_id)
    return _student_payload(playlist, active_class_id=membership.class_id)


@router.get("/student-playlists/{playlist_id}/items/{item_id}/stream")
async def stream_student_playlist_item(
    playlist_id: int,
    item_id: int,
    student: models.User = Depends(auth.get_media_user),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _student_playlist(db, playlist_id)
    access.require_student_playlist_owner(student, playlist)
    item = next((entry for entry in playlist.items if entry.item_id == item_id), None)
    if item is None or item.audio is None:
        raise HTTPException(status_code=404, detail="Playlist item not found")
    await access.require_audio_access(db, student, item.audio)
    if not os.path.isfile(item.audio.file_path):
        raise HTTPException(status_code=404, detail="Audio file is unavailable")
    return FileResponse(
        item.audio.file_path,
        media_type=item.audio.mime_type,
    )


@router.patch("/student-playlists/{playlist_id}", response_model=schemas.StudentPlaylistOut)
async def update_student_playlist(
    playlist_id: int,
    payload: schemas.PlaylistUpdate,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _student_playlist(db, playlist_id)
    access.require_student_playlist_owner(student, playlist)
    if payload.title is not None:
        title = payload.title.strip()
        if not title:
            raise HTTPException(status_code=422, detail="Playlist title is required")
        playlist.title = title
    if payload.description is not None:
        playlist.description = payload.description.strip()
    await db.commit()
    return _student_payload(await _student_playlist(db, playlist_id))


@router.delete("/student-playlists/{playlist_id}")
async def delete_student_playlist(
    playlist_id: int,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _student_playlist(db, playlist_id)
    access.require_student_playlist_owner(student, playlist)
    await db.delete(playlist)
    await db.commit()
    return {"ok": True}


@router.post("/student-playlists/{playlist_id}/items", response_model=schemas.StudentPlaylistOut)
async def add_student_playlist_item(
    playlist_id: int,
    payload: schemas.PlaylistItemAdd,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _student_playlist(db, playlist_id)
    access.require_student_playlist_owner(student, playlist)
    audio = await db.get(models.AudioFile, payload.audio_id)
    if audio is None:
        raise HTTPException(status_code=404, detail="Audio not found")
    await access.require_audio_access(db, student, audio)
    if any(item.audio_id == audio.audio_id for item in playlist.items):
        raise HTTPException(status_code=409, detail="Audio is already in this playlist")
    db.add(
        models.StudentPlaylistItem(
            playlist_id=playlist_id,
            audio_id=audio.audio_id,
            position=len(playlist.items),
        )
    )
    await db.commit()
    return _student_payload(await _student_playlist(db, playlist_id))


@router.delete("/student-playlists/{playlist_id}/items/{item_id}", response_model=schemas.StudentPlaylistOut)
async def remove_student_playlist_item(
    playlist_id: int,
    item_id: int,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _student_playlist(db, playlist_id)
    access.require_student_playlist_owner(student, playlist)
    item = next((entry for entry in playlist.items if entry.item_id == item_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Playlist item not found")
    await db.delete(item)
    await db.flush()
    await _renumber_student(db, playlist_id)
    await db.commit()
    return _student_payload(await _student_playlist(db, playlist_id))


@router.post("/student-playlists/{playlist_id}/reorder", response_model=schemas.StudentPlaylistOut)
async def reorder_student_playlist(
    playlist_id: int,
    payload: schemas.PlaylistReorder,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    playlist = await _student_playlist(db, playlist_id)
    access.require_student_playlist_owner(student, playlist)
    await _apply_order(db, playlist.items, payload.item_ids)
    await db.commit()
    return _student_payload(await _student_playlist(db, playlist_id))


async def _apply_order(db: AsyncSession, items: list, requested_ids: list[int]) -> None:
    current_ids = [item.item_id for item in items]
    if len(requested_ids) != len(set(requested_ids)) or set(requested_ids) != set(current_ids):
        raise HTTPException(status_code=400, detail="Reorder list must contain every playlist item exactly once")
    by_id = {item.item_id: item for item in items}
    for index, item in enumerate(items):
        item.position = -(index + 1)
    await db.flush()
    for position, item_id in enumerate(requested_ids):
        by_id[item_id].position = position


async def _renumber_teacher(db: AsyncSession, playlist_id: int) -> None:
    result = await db.execute(
        select(models.TeacherPlaylistItem).filter(
            models.TeacherPlaylistItem.playlist_id == playlist_id,
        ).order_by(models.TeacherPlaylistItem.position)
    )
    await _normalize_positions(db, result.scalars().all())


async def _renumber_student(db: AsyncSession, playlist_id: int) -> None:
    result = await db.execute(
        select(models.StudentPlaylistItem).filter(
            models.StudentPlaylistItem.playlist_id == playlist_id,
        ).order_by(models.StudentPlaylistItem.position)
    )
    await _normalize_positions(db, result.scalars().all())


async def _normalize_positions(db: AsyncSession, items: list) -> None:
    for index, item in enumerate(items):
        item.position = -(index + 1)
    await db.flush()
    for index, item in enumerate(items):
        item.position = index
