import asyncio
from contextlib import asynccontextmanager
import os
from typing import Annotated, List, Optional
from uuid import UUID
import uuid
import aiofiles
import json
import jwt
from datetime import datetime, timedelta

from fastapi import FastAPI, Depends, WebSocket, WebSocketDisconnect, BackgroundTasks, Query, Form, HTTPException, status, UploadFile, File, APIRouter
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import update, func

from . import models, schemas, auth, ws_manager
from .database import engine, get_db
from .notification_service import fcm_service
from .ws_manager import ws_mgr, SESSION_STATE, SESSION_LOCK
from .session_logger import SessionLogger, get_session_logs, get_session_summary


# Audio directory - store audio files locally
AUDIO_DIR = os.getenv("AUDIO_DIR", "./data/audio")
os.makedirs(AUDIO_DIR, exist_ok=True)

# Create tables on startup
@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(models.Base.metadata.create_all)
    yield


# Create FastAPI app
app = FastAPI(title="SEEDS Application", lifespan=lifespan)


# CORS (Cross-Origin Resource Sharing) controls which websites can make requests to your API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],                # allow any website to access this API
    allow_credentials=True,             # allow cookies, auth headers, etc
    allow_methods=["*"],                # allow all HTTP methods
    allow_headers=["*"],                # allow all headers
)



# NO JWT AUTH FUNCTIONS :



# Create temporary dependencies which bypass JWT Authentication : 
async def get_user_by_id(user_id: int | None = Query(None), db: AsyncSession = Depends(get_db)):
    """
    Dev-only: fetch a user by user_id=123 (or will read from header X-User-Id if provided).
    This replaces JWT-based get_current_user during development.
    """
    if user_id is None:
        raise HTTPException(status_code=400, detail="user_id query param required for dev auth (e.g. user_id=5)")

    # Used to query the database
    q = await db.execute(select(models.User).filter(models.User.user_id == user_id))
    user = q.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# The following functions ensure that the user has the correct role (teacher or student)

async def require_teacher(user: models.User = Depends(get_user_by_id)):
    if user.role.lower() != "teacher":
        raise HTTPException(status_code=403, detail="Teacher role required")
    return user


async def require_student(user: models.User = Depends(get_user_by_id)):
    if user.role.lower() != "student":
        raise HTTPException(status_code=403, detail="Student role required")
    return user



# JWT AUTH



# AUTHENTICATION using JWT and FASTAPI Defaults :

@app.post("/auth/register", response_model=schemas.UserOut)
# The parameters are : Schema to create a User , endpoint dependency
async def register(user_in: schemas.UserCreate, db: AsyncSession = Depends(get_db)):

    role = user_in.role.lower()   # normalize role to lowercase

    # Only two roles are possible
    if role not in ("teacher", "student"):
        raise HTTPException(status_code=400, detail="Invalid role")
    
    # Uses Phone Number as Unique Key
    q = await db.execute(select(models.User).filter(models.User.phone_number == user_in.phone_number))
    existing = q.scalar_one_or_none()
    if existing:
        raise HTTPException(status_code=400, detail="Phone already registered")

    user = models.User(
        name=user_in.name,
        phone_number=user_in.phone_number,
        role=user_in.role,
        password_hash=auth.get_password_hash(user_in.password)    # Hashes the password to maintain security in Database
    )

    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


# In-built FASTAPI authentication method :

@app.post("/auth/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends(),
                db: AsyncSession = Depends(get_db)):
    # Treat username as phone_number
    phone = form_data.username
    password = form_data.password

    # Check if the phone number exists
    q = await db.execute(select(models.User).filter(models.User.phone_number == phone))
    user = q.scalar_one_or_none()

    if not user or not auth.verify_password(password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    # If user is valid, create a JWT token
    token_data = {"user_id": user.user_id, "role": user.role}
    access_token = auth.create_access_token(token_data, expires_delta=timedelta(days=7))
    
    # RETURN USER NAME IN RESPONSE (CRITICAL FIX)
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": user.user_id,
        "role": user.role,
        "name": user.name  # ← ADD THIS LINE
    }



# SESSION ENDPOINTS


# SESSIONS : 

@app.post("/sessions", response_model=schemas.SessionOut)
# The payload parameter automatically receives the JSON body of the request and validates it using the schema SessionCreate
async def create_session(payload: schemas.SessionCreate, 
                         user: models.User = Depends(require_teacher), 
                         db: AsyncSession = Depends(get_db)):
    # Creates a new session object
    s = models.Session(title=payload.title, created_by=user.user_id, is_active=True)
    # stages the new session for saving
    db.add(s)
    # Actually adds to db
    await db.commit()
    # Reloads s from the database to get autogenerated fields
    await db.refresh(s)

    # Initialize in-memory runtime state
    async with SESSION_LOCK:
        SESSION_STATE.setdefault(s.session_id, {
            "connections": {},
            "participants": {},
            "playback": {"audio_id": None, "status": "stopped", "speed": 1.0, "position": 0.0}
        })
    
    # Log session creation
    await SessionLogger.log_session_created(db, s.session_id, user.user_id, payload.title)
    
    return s


# Delete a session - teacher only
@app.delete("/sessions/{session_id}")
async def delete_session(session_id: int,
                      user: models.User = Depends(require_teacher),
                      db: AsyncSession = Depends(get_db),
                      background_tasks: BackgroundTasks = None):
    # Fetches the session with the given ID from the database
    q = await db.execute(select(models.Session).filter(models.Session.session_id == session_id))
    s = q.scalar_one_or_none()

    if not s:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if not s.is_active:
        raise HTTPException(status_code=400, detail="Session already ended")
    
    if s.created_by != user.user_id:
        raise HTTPException(status_code=403, detail="Only creator can end session")
    
    s.is_active = False
    s.ended_at = datetime.utcnow()
    await db.commit()
    
    # Close all WebSocket connections for this session
    if background_tasks is not None:
        background_tasks.add_task(ws_mgr.close_session, session_id)
    else:
        asyncio.create_task(ws_mgr.close_session(session_id))
    
    return {"ok": True, "message": "Session ended successfully"}


# Get the list of active sessions : 
@app.get("/sessions/active", response_model=List[schemas.SessionOut])
async def get_active_sessions(
    user: models.User = Depends(get_user_by_id),  # dev auth
    db: AsyncSession = Depends(get_db)
):
    """
    Return all active sessions with participant count.
    - Teacher: sessions they created
    - Student: all active sessions
    """
    if user.role.lower() == "teacher":
        # Only sessions created by this teacher
        q = await db.execute(
            select(models.Session).filter(
                models.Session.created_by == user.user_id,
                models.Session.is_active == True
            )
        )
    else:
        # Student: all active sessions
        q = await db.execute(
            select(models.Session).filter(models.Session.is_active == True)
        )

    sessions = q.scalars().all()
    
    # Add participant count to each session
    result = []
    for session in sessions:
        # Count active participants (not kicked, not left)
        participant_count_q = await db.execute(
            select(func.count(models.Participant.participant_id)).filter(
                models.Participant.session_id == session.session_id,
                models.Participant.is_kicked == False,
                models.Participant.left_at.is_(None)
            )
        )
        participant_count = participant_count_q.scalar() or 0
        
        # Convert to dict and add participant count
        session_dict = {
            'session_id': session.session_id,
            'title': session.title,
            'is_active': session.is_active,
            'created_by': session.created_by,
            'created_at': session.created_at,
            'ended_at': session.ended_at,
            'participant_count': participant_count
        }
        result.append(session_dict)
    
    return result





# PARTICIPANT ENDPOINTS



# PARTICIPANTS : 

# Get all students (for inviting to session)
@app.get("/users/students", response_model=List[schemas.UserOut])
async def get_all_students(
    current_user: models.User = Depends(require_teacher),
    db: AsyncSession = Depends(get_db)
):
    """Get list of all students for teacher to invite"""
    q = await db.execute(
        select(models.User).filter(models.User.role == "student")
    )
    students = q.scalars().all()
    return students



# Invite students and also send a notification to join the session
@app.post("/sessions/{session_id}/invite")
async def invite_student_to_session(
    session_id: int,
    student_id: int = Form(...),
    db: AsyncSession = Depends(get_db),
    current_user: models.User = Depends(require_teacher),
    background_tasks: BackgroundTasks = None
):
    # Verify session exists and belongs to teacher
    q = await db.execute(select(models.Session).filter(models.Session.session_id == session_id))
    session = q.scalar_one_or_none()
    
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if session.created_by != current_user.user_id:
        raise HTTPException(status_code=403, detail="Not your session")
    
    # Get student info
    q = await db.execute(select(models.User).filter(models.User.user_id == student_id))
    student = q.scalar_one_or_none()
    
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    # Get student's FCM tokens
    q = await db.execute(
        select(models.FCMToken).filter(models.FCMToken.user_id == student_id)
    )
    fcm_tokens = q.scalars().all()
    
    # Send push notifications
    if fcm_tokens and background_tasks:
        for fcm_token in fcm_tokens:
            background_tasks.add_task(
                fcm_service.send_session_invitation,
                token=fcm_token.token,
                session_id=session_id,
                session_title=session.title,
                teacher_name=current_user.name
            )
    
    # Send invitation via WebSocket if student is online
    invitation = {
        "type": "session_invitation",
        "session_id": session_id,
        "session_title": session.title,
        "teacher_name": current_user.name,
        "teacher_id": current_user.user_id
    }
    
    # Try to send to student via any active WebSocket connections
    # (This would require tracking user connections globally, not just per-session)
    
    # Log invitation
    await SessionLogger.log_participant_invited(db, session_id, student_id, current_user.user_id)
    
    return {
        "ok": True,
        "message": f"Invitation sent to {student.name}",
        "student_id": student_id,
        "session_id": session_id,
        "notifications_sent": len(fcm_tokens)
    }


# Allows teacher to add participants - can be extended to allow students to join by themselves too
@app.post("/sessions/{session_id}/join")
async def join_or_add_participant(
    session_id: int,
    user_id: int = Form(None),    # ID of the user joining or being added
    db: AsyncSession = Depends(get_db),
    current_user: models.User = Depends(get_user_by_id) 
    ):
    
    # If user_id not provided, use current_user's ID (self-join)
    if user_id is None:
        user_id = current_user.user_id
    
    # Fetch session
    q = await db.execute(select(models.Session).filter(models.Session.session_id == session_id))
    session = q.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    if not session.is_active:
        raise HTTPException(status_code=400, detail="Session is not active")

    # Fetch the target user (the one to be added)
    q_user = await db.execute(select(models.User).filter(models.User.user_id == user_id))
    target_user = q_user.scalar_one_or_none()
    if not target_user:
        raise HTTPException(status_code=404, detail="User not found")

    # Role-based validation : 
    
    # If teacher adds someone else, ensure they are the session owner
    if current_user.user_id != user_id:
        if session.created_by != current_user.user_id:
            raise HTTPException(status_code=403, detail="Only the session creator can add other users")

        if target_user.role.lower() != "student":
            raise HTTPException(status_code=400, detail="Only students can be added as participants")

    # Check if participant already exists
    q2 = await db.execute(select(models.Participant).filter(
        models.Participant.session_id == session_id,
        models.Participant.user_id == user_id
    ))
    exist = q2.scalar_one_or_none()
    if exist:
        # Participant already exists — broadcast event and return
        await ws_mgr.broadcast(session_id, {
            "type": "participant_already_present",
            "participant_id": exist.participant_id,
            "user_id": user_id,
            "name": target_user.name
        })
        return {"ok": True, "participant_id": exist.participant_id}

    # Create participant record
    p = models.Participant(session_id=session_id, user_id=user_id, joined_at=datetime.utcnow())
    db.add(p)
    await db.commit()
    await db.refresh(p)

    # Update runtime session state
    async with SESSION_LOCK:
        s = SESSION_STATE.setdefault(session_id, {
            "connections": {},
            "participants": {},
            "playback": {"audio_id": None, "status": "stopped", "speed": 1.0, "position": 0.0},
        })
        s["participants"][p.participant_id] = {
            "user_id": user_id,
            "is_muted": False,
            "raised_hand": False,
            "name": target_user.name,
        }

    # Broadcast to active clients
    await ws_mgr.broadcast(session_id, {
        "type": "participant_added",
        "participant_id": p.participant_id,
        "user_id": user_id,
        "name": target_user.name
    })
    
    # Log participant joined
    await SessionLogger.log_participant_joined(db, session_id, user_id, p.participant_id, target_user.name)

    return {"ok": True, "participant_id": p.participant_id}


# Remove Participants - 
@app.delete("/sessions/{session_id}/participants/{participant_id}")
async def remove_participant(session_id: int, participant_id: int,
                             current_user: models.User = Depends(require_teacher),
                             db: AsyncSession = Depends(get_db),
                             background_tasks: BackgroundTasks = None):
    # Looks up the participant - student in this case by ID
    q = await db.execute(select(models.Participant).filter(
        models.Participant.participant_id == participant_id,
        models.Participant.session_id == session_id
    ))
    p = q.scalar_one_or_none()
    if not p:
        raise HTTPException(status_code=404, detail="Participant not found")
    
    p.is_kicked = True
    p.left_at = datetime.utcnow()
    await db.commit()
    
    # Kick via WebSocket manager
    if background_tasks is not None:
        background_tasks.add_task(ws_mgr.kick_participant, session_id, participant_id, "Removed by teacher")
    else:
        asyncio.create_task(ws_mgr.kick_participant(session_id, participant_id, "Removed by teacher"))
    
    # Log participant kicked
    await SessionLogger.log_participant_kicked(db, session_id, p.user_id, current_user.user_id, participant_id, "Removed by teacher")
    
    return {"ok": True}


# Mute -
@app.post("/sessions/{session_id}/participants/{participant_id}/mute")
async def mute_participant(session_id: int, participant_id: int, mute: bool = True,
                           current_user: models.User = Depends(require_teacher),
                           db: AsyncSession = Depends(get_db),
                           background_tasks: BackgroundTasks = None):
    # Find student ID who is to be muted
    q = await db.execute(select(models.Participant).filter(
        models.Participant.participant_id == participant_id,
        models.Participant.session_id == session_id
    ))
    p = q.scalar_one_or_none()
    if not p:
        raise HTTPException(status_code=404, detail="Participant not found")
    
    p.is_muted = mute
    await db.commit()
    # Inform ws clients
    if background_tasks is not None:
        background_tasks.add_task(ws_mgr.mute_participant, session_id, participant_id, mute)
    else:
        asyncio.create_task(ws_mgr.mute_participant(session_id, participant_id, mute))
    return {"ok": True, "muted": mute}




# AUDIO ENDPOINTS




# AUDIO :

# Checks file extensions
ALLOWED_EXTENSIONS = {".mp3", ".wav", ".m4a", ".ogg", ".webm"}
# Checks actual file type reported by the browser because even a text file can be saved as .mp3
ALLOWED_MIME_TYPES = {"audio/mpeg", "audio/wav", "audio/mp4", "audio/x-m4a", "audio/mp3", "audio/ogg", "audio/webm"}


# Helper function to calculate audio duration during upload
async def calculate_audio_duration(file_path: str) -> float | None:
    """Calculate audio duration in seconds (requires ffprobe or similar)"""
    try:
        import subprocess
        result = subprocess.run(
            ['ffprobe', '-v', 'error', '-show_entries', 
             'format=duration', '-of', 
             'default=noprint_wrappers=1:nokey=1', file_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        duration = float(result.stdout)
        return duration
    except Exception as e:
        print(f"[AUDIO] Could not calculate duration: {e}")
        return None



# Upload audio file - only by teachers
@app.post("/audio/upload", response_model=schemas.AudioCreateResponse)
async def upload_audio(title: str = Form(...),
                       description: str = Form(""),
                       file: UploadFile = File(...),
                       current_user: models.User = Depends(require_teacher),
                       db: AsyncSession = Depends(get_db)):

    # Validate extension
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file extension {ext}. Allowed: {', '.join(ALLOWED_EXTENSIONS)}"
        )

    # Validate MIME type
    if file.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type {file.content_type}. Allowed: {', '.join(ALLOWED_MIME_TYPES)}"
        )

    # Save file - creates a unique filename using a timestamp
    filename = f"{int(datetime.utcnow().timestamp())}_{file.filename}"
    file_path = os.path.join(AUDIO_DIR, filename)

    # aiofiles is an asynchronous file I/O library — unlike normal open(), this won't block the event loop
    async with aiofiles.open(file_path, "wb") as out_file:
        content = await file.read()
        # Writes binary data("wb") to disk
        await out_file.write(content)

    # Calculate duration
    duration = await calculate_audio_duration(file_path)

    # Save metadata in DB
    af = models.AudioFile(
        title=title,
        description=description,
        file_path=file_path,
        uploaded_by=current_user.user_id,
        mime_type=file.content_type,
        duration=duration
    )
    db.add(af)
    await db.commit()
    await db.refresh(af)
    
    # Log audio upload
    await SessionLogger.log_audio_uploaded(db, current_user.user_id, af.audio_id, title, file_path, duration)
    
    return af


# Get all audio files for a teacher
@app.get("/audio/list", response_model=List[schemas.AudioFileOut])
async def list_audio_files(
    current_user: models.User = Depends(get_user_by_id),
    db: AsyncSession = Depends(get_db)
):
    """List all audio files uploaded by the current user (teacher)"""
    q = await db.execute(
        select(models.AudioFile).filter(
            models.AudioFile.uploaded_by == current_user.user_id
        ).order_by(models.AudioFile.uploaded_at.desc())
    )
    files = q.scalars().all()
    return files


# This finds an audio file in the database and returns it as a downloadable stream
@app.get("/audio/{audio_id}/stream")
async def stream_audio(audio_id: int, db: AsyncSession = Depends(get_db)):
    # Find the audio file in the database
    q = await db.execute(select(models.AudioFile).filter(models.AudioFile.audio_id == audio_id))
    af = q.scalar_one_or_none()
    if not af:
        raise HTTPException(status_code=404, detail="Audio not found")
    return FileResponse(path=af.file_path, filename=os.path.basename(af.file_path), media_type=af.mime_type)


# Actually plays the audio stream by sending data chunks
@app.get("/audio/{audio_id}/play")
async def play_audio(audio_id: int, db: AsyncSession = Depends(get_db)):
    q = await db.execute(select(models.AudioFile).filter(models.AudioFile.audio_id == audio_id))
    af = q.scalar_one_or_none()
    if not af:
        raise HTTPException(status_code=404, detail="Audio not found")
    # Defines a generator (iterfile) that yields file bytes gradually instead of loading the entire file in memory
    def iterfile():
        with open(af.file_path, mode="rb") as file_like:
            yield from file_like

    return StreamingResponse(iterfile(), media_type=af.mime_type)



# Audio endpoints using Websocket  
# These endpoints don't directly play audio 
# They send messages to connected clients (students) through the WebSocket manager (ws_mgr)


# Endpoint for the teacher to select out of a list of audio files
@app.post("/sessions/{session_id}/audio/select")
async def rest_select_audio(session_id: int, 
                            audio_id: int = Query(...),
                            current_user: models.User = Depends(require_teacher),
                            db: AsyncSession = Depends(get_db)):
    # Verify audio exists
    q = await db.execute(select(models.AudioFile).filter(models.AudioFile.audio_id == audio_id))
    af = q.scalar_one_or_none()
    if not af:
        raise HTTPException(status_code=404, detail="Audio file not found")
    
    await ws_mgr.audio_select(session_id, audio_id, af.title)
    
    # Log audio selected
    await SessionLogger.log_audio_selected(db, session_id, current_user.user_id, audio_id, af.title)
    
    return {"ok": True, "audio_id": audio_id, "title": af.title}



# Broadcasts the message of playing the audio file for a particular session
@app.post("/sessions/{session_id}/audio/play")
async def rest_play_audio(session_id: int, 
                          audio_id: int = Form(None), 
                          speed: float = Form(1.0),
                          position: float = Form(0.0),
                          current_user: models.User = Depends(require_teacher),
                          db: AsyncSession = Depends(get_db)):
    # If audio_id not provided, use currently selected audio
    if audio_id is None:
        async with SESSION_LOCK:
            if session_id in SESSION_STATE:
                audio_id = SESSION_STATE[session_id]["playback"].get("audio_id")
        if audio_id is None:
            raise HTTPException(status_code=400, detail="No audio selected for this session")
    
    await ws_mgr.audio_play(session_id, audio_id, speed, position)
    
    # Log audio play
    await SessionLogger.log_audio_play(db, session_id, current_user.user_id, audio_id, position, speed)
    
    return {"ok": True}



# Pause the audio playback for all
@app.post("/sessions/{session_id}/audio/pause")
async def rest_pause_audio(session_id: int,
                           current_user: models.User = Depends(require_teacher)):
    await ws_mgr.audio_pause(session_id)
    return {"ok": True}



# Unified audio control endpoint supporting play, pause, seek, and speed change
@app.post("/sessions/{session_id}/audio/control")
async def control_audio_playback(
    session_id: int,
    control: schemas.AudioPlaybackControl,
    current_user: models.User = Depends(require_teacher),
    db: AsyncSession = Depends(get_db)
):
    async with SESSION_LOCK:
        if session_id not in SESSION_STATE:
            raise HTTPException(status_code=404, detail="Session not found")
        
        playback = SESSION_STATE[session_id]["playback"]
        
        # Get current audio_id if not provided
        if control.audio_id is None:
            control.audio_id = playback.get("audio_id")
        
        if control.audio_id is None:
            raise HTTPException(status_code=400, detail="No audio selected")
        
        # Verify audio exists and get duration
        q = await db.execute(
            select(models.AudioFile).filter(models.AudioFile.audio_id == control.audio_id)
        )
        audio_file = q.scalar_one_or_none()
        if not audio_file:
            raise HTTPException(status_code=404, detail="Audio file not found")
        
        # Update playback state based on action
        if control.action == 'play':
            playback.update({
                "audio_id": control.audio_id,
                "status": "playing",
                "speed": control.speed,
                "position": control.position,
                "title": audio_file.title,
                "duration": audio_file.duration
            })
        elif control.action == 'pause':
            playback.update({
                "status": "paused",
                "position": control.position
            })
        elif control.action == 'seek':
            playback.update({
                "position": control.position
            })
            # If currently playing, continue playing from new position
            if playback.get("status") == "playing":
                control.action = 'play'
        else:
            raise HTTPException(status_code=400, detail="Invalid action")
    
    # Broadcast to all participants
    await ws_mgr.broadcast(session_id, {
        "type": f"audio_{control.action}",
        "audio_id": control.audio_id,
        "speed": control.speed,
        "position": control.position,
        "title": audio_file.title,
        "duration": audio_file.duration
    })
    
    return {
        "ok": True,
        "action": control.action,
        "playback": playback
    }



# Get current audio playback state for a session
@app.get("/sessions/{session_id}/audio/state", response_model=schemas.AudioPlaybackState)
async def get_audio_playback_state(
    session_id: int,
    current_user: models.User = Depends(get_user_by_id),
    db: AsyncSession = Depends(get_db)
):
    async with SESSION_LOCK:
        if session_id not in SESSION_STATE:
            raise HTTPException(status_code=404, detail="Session not found")
        
        playback = SESSION_STATE[session_id]["playback"]
        
        return schemas.AudioPlaybackState(
            audio_id=playback.get("audio_id"),
            title=playback.get("title"),
            status=playback.get("status", "stopped"),
            speed=playback.get("speed", 1.0),
            position=playback.get("position", 0.0),
            duration=playback.get("duration")
        )





# CHAT & ACTIVITY ENDPOINTS

@app.post("/sessions/{session_id}/chat", response_model=schemas.ChatMessageRead)
async def send_chat_message(
    session_id: int,
    msg: schemas.ChatMessageCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: models.User = Depends(get_user_by_id)
):
    # Verify session exists
    session = await db.get(models.Session, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Verify participant exists
    participant = await db.get(models.Participant, msg.participant_id)
    if not participant or participant.session_id != session_id:
        raise HTTPException(status_code=400, detail="Invalid participant")

    chat_msg = models.ChatMessage(
        session_id=session_id,
        participant_id=msg.participant_id,
        message=msg.message,
    )
    db.add(chat_msg)
    await db.commit()
    await db.refresh(chat_msg)

    # Broadcast to session via WebSocket manager
    await ws_mgr.broadcast(
        session_id,
        {
            "type": "chat",
            "participant_id": msg.participant_id,
            "sender_name": current_user.name,
            "message": msg.message,
            "timestamp": chat_msg.timestamp.isoformat(),
        },
    )
    
    # Log chat message
    await SessionLogger.log_chat_message(db, session_id, current_user.user_id, msg.participant_id, msg.message)

    return chat_msg


@app.get("/sessions/{session_id}/chat", response_model=List[schemas.ChatMessageRead])
async def get_chat_history(
    session_id: int,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: models.User = Depends(get_user_by_id)
):
    """Get chat history for a session"""
    q = select(models.ChatMessage).where(
        models.ChatMessage.session_id == session_id
    ).order_by(models.ChatMessage.timestamp.asc())
    
    messages = (await db.scalars(q)).all()
    return messages



@app.get("/sessions/{session_id}/state")
async def get_session_state(session_id: int, db: Annotated[AsyncSession, Depends(get_db)]):
    session = await db.get(models.Session, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    q = select(models.Participant).where(models.Participant.session_id == session_id)
    participants = (await db.scalars(q)).all()

    q_audio = (
        select(models.Playback)
        .where(models.Playback.session_id == session_id)
        .order_by(models.Playback.started_at.desc())
    )
    playback = (await db.scalars(q_audio)).first()

    return {
        "session_id": session.session_id,
        "is_active": session.is_active,
        "participants": [
            {
                "id": p.participant_id,
                "user_id": p.user_id,
                "name": p.user.name if p.user else None,
                "muted": p.is_muted,
                "hand_raised": p.hand_raised,
            }
            for p in participants
        ],
        "active_audio": {
            "audio_id": playback.audio_file_id,
            "started_at": playback.started_at.isoformat(),
        } if playback else None,
    }


# ============ SESSION LOGS ENDPOINTS ============

@app.get("/sessions/{session_id}/logs")
async def get_session_logs_endpoint(
    session_id: int,
    event_type: Optional[str] = Query(None, description="Filter by event type"),
    user_id: Optional[int] = Query(None, description="Filter by user ID"),
    limit: int = Query(100, ge=1, le=1000),
    current_user: models.User = Depends(get_user_by_id),
    db: AsyncSession = Depends(get_db)
):
    """
    Get session activity logs.
    Teachers can view all logs for sessions they created.
    """
    # Verify session exists and user has access
    session = await db.get(models.Session, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    # Only session creator (teacher) can view logs
    if session.created_by != current_user.user_id and current_user.role.lower() != "teacher":
        raise HTTPException(status_code=403, detail="Only the session creator can view logs")
    
    logs = await get_session_logs(db, session_id, event_type, user_id, limit)
    
    return {
        "session_id": session_id,
        "total_logs": len(logs),
        "logs": [
            {
                "log_id": log.log_id,
                "event_type": log.event_type,
                "user_id": log.user_id,
                "event_details": log.event_details,
                "created_at": log.created_at.isoformat()
            }
            for log in logs
        ]
    }


@app.get("/sessions/{session_id}/logs/summary")
async def get_session_logs_summary_endpoint(
    session_id: int,
    current_user: models.User = Depends(get_user_by_id),
    db: AsyncSession = Depends(get_db)
):
    """
    Get a summary of session activity including event counts.
    """
    # Verify session exists and user has access
    session = await db.get(models.Session, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    # Only session creator (teacher) can view logs
    if session.created_by != current_user.user_id and current_user.role.lower() != "teacher":
        raise HTTPException(status_code=403, detail="Only the session creator can view logs")
    
    summary = await get_session_summary(db, session_id)
    return summary







# NOTIFICATIONS USING FIREBASE





# Add endpoint to register FCM tokens - Register or update FCM token for push notifications
@app.post("/users/fcm-token")
async def register_fcm_token(
    data: schemas.FCMTokenRequest,
    current_user: models.User = Depends(get_user_by_id),
    db: AsyncSession = Depends(get_db)
):
    try:
        result = await db.execute(
            select(models.FCMToken).filter(
                models.FCMToken.user_id == current_user.user_id,
                models.FCMToken.token == data.token,
            )
        )
        existing_token: Optional[models.FCMToken] = result.scalar_one_or_none()

        if existing_token:
            existing_token.last_used = datetime.utcnow()
            await db.commit()
            return {"ok": True, "message": "Token updated"}

        new_token = models.FCMToken(
            user_id=current_user.user_id,
            token=data.token,
            device_type=data.device_type,
            last_used=datetime.utcnow(),
        )
        db.add(new_token)
        await db.commit()
        return {"ok": True, "message": "Token registered"}

    except Exception as e:
        await db.rollback()
        print(f"[FCM] Error registering token: {e}")
        raise HTTPException(status_code=500, detail="Failed to register token")





# Add endpoint to remove FCM token (when user logs out)
@app.delete("/users/fcm-token")
async def remove_fcm_token(
    data: schemas.FCMTokenDeleteRequest,
    current_user: models.User = Depends(get_user_by_id),
    db: AsyncSession = Depends(get_db)
):
    try:
        result = await db.execute(
            select(models.FCMToken).filter(
                models.FCMToken.user_id == current_user.user_id,
                models.FCMToken.token == data.token,
            )
        )
        fcm_token = result.scalar_one_or_none()
        if not fcm_token:
            return {"ok": True, "message": "Token not found"}

        await db.delete(fcm_token)
        await db.commit()
        return {"ok": True, "message": "Token removed"}
    except Exception as e:
        await db.rollback()
        print(f"[FCM] Error removing token: {e}")
        raise HTTPException(status_code=500, detail="Failed to remove token")





# WEBSOCKETS ENDPOINTS



# Websocket endpoint for signalling and controlling events : 
# Websocket for session-level real-time events.
# Client should first send a 'join' JSON message if necessary, but this endpoint also supports creating participant on connect
@app.websocket("/ws/sessions/{session_id}")
async def session_ws(websocket: WebSocket, session_id: int, db: AsyncSession = Depends(get_db)):
    user_id = None
    participant_id = None
    
    try:
        # Read query params
        qs = websocket.scope.get("query_string", b"").decode()
        params = dict([p.split("=", 1) for p in qs.split("&") if "=" in p])

        # Support both string and numeric IDs
        user_id = params.get("user_id")
        participant_id = params.get("participant_id")

        if user_id and user_id.isdigit():
            user_id = int(user_id)
        if participant_id and participant_id.isdigit():
            participant_id = int(participant_id)

        print(f"[WS INIT] Incoming connection → Session={session_id}, User={user_id}, Participant={participant_id}")

        # Minimal check: require user_id or participant_id - hence returns error if not found
        if not user_id and not participant_id:
            await websocket.accept()
            await websocket.send_json({"type": "error", "detail": "user_id or participant_id query param required"})
            await websocket.close()
            return

        # Accept WebSocket connection FIRST
        await websocket.accept()
        
        # Send initial connected message
        await websocket.send_json({
            "type": "connected",
            "session_id": session_id,
            "user_id": user_id
        })

        # If only user_id provided, ensure we have/insert Participant record for this session+user
        if participant_id is None and user_id is not None:
            # This ensures the database has a participant row for this user in this session
            q = await db.execute(select(models.Participant).filter(
                models.Participant.session_id == session_id,
                models.Participant.user_id == user_id
            ))
            p = q.scalar_one_or_none()
            # Create participant row if not exists
            if not p:
                p = models.Participant(session_id=session_id, user_id=user_id, joined_at=datetime.utcnow())
                db.add(p)
                await db.commit()
                await db.refresh(p)
            participant_id = p.participant_id
        else:
            # If participant_id provided, fetch it to resolve user_id
            q = await db.execute(select(models.Participant).filter(models.Participant.participant_id == participant_id))
            p = q.scalar_one_or_none()
            if not p:
                await websocket.send_json({"type": "error", "detail": "Invalid participant_id"})
                await websocket.close()
                return
            user_id = p.user_id

        # Resolve user info - determine whether user is a teacher
        q = await db.execute(select(models.User).filter(models.User.user_id == user_id))
        user = q.scalar_one_or_none()
        uname = user.name if user else f"user_{user_id}"
        is_teacher = user and user.role.lower() == "teacher"

        # Store participant metadata in SESSION_STATE
        async with SESSION_LOCK:
            s = SESSION_STATE.setdefault(session_id, {
                "connections": {},
                "participants": {},
                "playback": {"audio_id": None, "status": "stopped", "speed": 1.0, "position": 0.0}
            })
            s["participants"].setdefault(participant_id, {
                "user_id": user_id, 
                "is_muted": False, 
                "raised_hand": False, 
                "name": uname
            })

        # Connect websocket via manager
        await ws_mgr.connect(session_id, participant_id, websocket)
        
        # Notify others that this participant joined
        await ws_mgr.broadcast(session_id, {
            "type": "participant_joined", 
            "participant_id": participant_id, 
            "user_id": user_id, 
            "name": uname,
            "is_teacher": is_teacher
        }, exclude={participant_id})

        # Send current session state to the newly connected client - required for rendering UI
        async with SESSION_LOCK:
            state_snapshot = {
                "type": "session_state",
                "participants": SESSION_STATE[session_id]["participants"],
                "playback": SESSION_STATE[session_id]["playback"]
            }
        await ws_mgr.send_personal(websocket, state_snapshot)

        # Main receive loop
        while True:
            msg = await websocket.receive_json()
            # Each message from the client has a type field telling what action it wants to perform
            typ = msg.get("type")

            if typ == "mute_self":
                is_muted = bool(msg.get("mute", True))
                async with SESSION_LOCK:
                    SESSION_STATE[session_id]["participants"][participant_id]["is_muted"] = is_muted
                await ws_mgr.broadcast(session_id, {
                    "type": "participant_muted", "participant_id": participant_id, "is_muted": is_muted
                })

            elif typ == "raise_hand":
                async with SESSION_LOCK:
                    SESSION_STATE[session_id]["participants"][participant_id]["raised_hand"] = True
                await ws_mgr.broadcast(session_id, {"type": "hand_raised", "participant_id": participant_id})

            elif typ == "lower_hand":
                async with SESSION_LOCK:
                    SESSION_STATE[session_id]["participants"][participant_id]["raised_hand"] = False
                await ws_mgr.broadcast(session_id, {"type": "hand_lowered", "participant_id": participant_id})

            elif typ == "mute_participant":
                if not is_teacher:
                    await ws_mgr.send_personal(websocket, {"type": "error", "detail": "teacher permission required"})
                    continue
                # Get student who is to be muted
                target = int(msg.get("target_participant_id"))
                async with SESSION_LOCK:
                    SESSION_STATE[session_id]["participants"][target]["is_muted"] = True
                await ws_mgr.broadcast(session_id, {"type": "participant_muted", "participant_id": target, "is_muted": True})

            elif typ == "unmute_participant":
                if not is_teacher:
                    await ws_mgr.send_personal(websocket, {"type": "error", "detail": "teacher permission required"})
                    continue
                # Get student who is to be unmuted
                target = int(msg.get("target_participant_id"))
                async with SESSION_LOCK:
                    SESSION_STATE[session_id]["participants"][target]["is_muted"] = False
                await ws_mgr.broadcast(session_id, {"type": "participant_muted", "participant_id": target, "is_muted": False})

            elif typ == "kick_participant":
                if not is_teacher:
                    await ws_mgr.send_personal(websocket, {"type": "error", "detail": "teacher permission required"})
                    continue
                # Get student who is to be kicked
                target = int(msg.get("target_participant_id"))
                await ws_mgr.kick_participant(session_id, target, reason="Removed by teacher")
                await ws_mgr.broadcast(session_id, {"type": "participant_kicked", "participant_id": target})

            elif typ == "end_session":
                if not is_teacher:
                    await ws_mgr.send_personal(websocket, {"type": "error", "detail": "teacher permission required"})
                    continue
                await ws_mgr.broadcast(session_id, {"type": "session_ending"})
                # End websocket connection
                await ws_mgr.close_session(session_id)
                break

            elif typ == "webrtc_signal":
                target = int(msg.get("target_participant_id"))
                payload = msg.get("payload")
                await ws_mgr.broadcast(session_id, {
                    "type": "webrtc_signal", "from": participant_id, "to": target, "payload": payload
                }, exclude={participant_id})

            elif typ == "chat":
                text = msg.get("text")
                await ws_mgr.broadcast(session_id, {
                    "type": "chat",
                    "from": participant_id,
                    "sender_name": uname,
                    "text": text
                })

            else:
                await ws_mgr.send_personal(websocket, {"type": "error", "detail": f"unknown message type {typ}"})

    except WebSocketDisconnect:
        print(f"[WS CLOSE] Disconnected: Session={session_id}, User={user_id}, Participant={participant_id}")
        if participant_id:
            await ws_mgr.disconnect(session_id, participant_id)
            await ws_mgr.broadcast(session_id, {"type": "participant_left", "participant_id": participant_id})

    except Exception as e:
        import traceback
        print(f"[WS ERROR] {e}\n{traceback.format_exc()}")
        if participant_id:
            await ws_mgr.disconnect(session_id, participant_id)
            await ws_mgr.broadcast(session_id, {"type": "participant_left", "participant_id": participant_id})
        # Try to notify client before closing
        try:
            await websocket.close(code=1011)
        except Exception:
            pass