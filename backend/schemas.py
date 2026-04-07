# schemas.py
from pydantic import BaseModel, Field, validator
from typing import List, Optional
from datetime import datetime


# ==================== USER SCHEMAS ====================

# Input Schema - when input is received for registration
class UserCreate(BaseModel):
    # The ... signifies that the field is required
    name: str = Field(..., min_length=1, max_length=200)
    phone_number: str = Field(..., min_length=10, max_length=20)
    password: str = Field(..., min_length=6)
    role: str  # 'teacher' or 'student'
    # validator runs automatically when input is received
    @validator('role')
    def validate_role(cls, v):
        # only roles applicable are - teacher or student
        if v.lower() not in ['teacher', 'student']:
            raise ValueError('Role must be either teacher or student')
        return v.lower()


# Output Schema
class UserOut(BaseModel):
    user_id: int
    name: str
    phone_number: str
    role: str
    created_at: datetime
    
    class Config:
        orm_mode = True


# Input for user login
class UserLogin(BaseModel):
    phone_number: str
    password: str


# ==================== AUTH SCHEMAS ====================

# This table shows what is returned when the user logs in
class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: int
    role: str


# Used internally after decoding JWT
class TokenData(BaseModel):
    user_id: Optional[int] = None
    role: Optional[str] = None


# ==================== SESSION SCHEMAS ====================

# Input schema when the teacher creates a session
class SessionCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=500)


# Table stores what is returned when session has been created succesfully
class SessionOut(BaseModel):
    session_id: int
    title: Optional[str]
    is_active: bool
    created_by: Optional[int]
    created_at: datetime
    ended_at: Optional[datetime] = None
    participant_count: Optional[int] = 0  # Added participant count
    teacher_name: Optional[str] = None    # Added teacher name
    
    class Config:
        orm_mode = True


# Represents mapping table (audio and session)
class SessionAudioOut(BaseModel):
    id: int
    session_id: int
    audio_id: int
    added_at: datetime

    class Config:
        orm_mode = True


# ==================== PARTICIPANT SCHEMAS ====================

# All info regarding user inside a session - realtime classroom state
class ParticipantOut(BaseModel):
    participant_id: int
    session_id: int
    user_id: int
    joined_at: datetime
    left_at: Optional[datetime] = None
    is_muted: bool
    is_kicked: bool
    hand_raised: bool
    
    class Config:
        orm_mode = True


# Participant with user details
class ParticipantWithUser(ParticipantOut):
    user_name: Optional[str] = None


# ==================== AUDIO FILE SCHEMAS ====================


# Stores input fields when teacher uploads audio 
class AudioFileUpload(BaseModel):
    title: str = Field(..., min_length=1, max_length=500)
    description: Optional[str] = ""
    session_ids: List[int]  # Allows teacher to upload audio to multiple sessions

    @validator("session_ids")
    def validate_sessions(cls, v):
        if not v:
            raise ValueError("At least one session must be created by teacher")
        return v


# Returned after audio upload
class AudioCreateResponse(BaseModel):
    audio_id: int
    title: str
    description: Optional[str]
    file_path: str
    mime_type: str
    uploaded_at: datetime
    
    class Config:
        orm_mode = True


# Contains full audio metadata
class AudioFileOut(BaseModel):
    audio_id: int
    title: str
    description: Optional[str]
    file_path: str
    mime_type: str
    duration: Optional[float] = None
    uploaded_by: Optional[int]
    uploaded_at: datetime
    
    class Config:
        orm_mode = True


# Lists all the audios in the session
class SessionAudioFiles(BaseModel):
    session_id: int
    session_title: Optional[str]
    audios: List[AudioFileOut]

# ==================== PLAYBACK SCHEMAS ====================

# Table created just when audio is selected to be played in a session
class PlaybackCreate(BaseModel):
    audio_file_id: int
    speed: Optional[float] = 1.0
    
    # puts a limit on the audio file being played
    @validator('speed')
    def validate_speed(cls, v):
        if v < 0.5 or v > 2.0:
            raise ValueError('Speed must be between 0.5 and 2.0')
        return v


# Helps track the audio file being played in a session
class PlaybackOut(BaseModel):
    playback_id: int
    session_id: int
    audio_file_id: Optional[int]
    started_by: Optional[int]
    started_at: datetime
    ended_at: Optional[datetime] = None
    speed: float
    
    class Config:
        orm_mode = True


# Used in websockets / sse
class AudioPlaybackControl(BaseModel):
    audio_id: Optional[int] = None
    speed: float = 1.0
    position: float = 0.0
    action: str  # 'play', 'pause', 'seek'


# Represents the current state of the audio being played
class AudioPlaybackState(BaseModel):
    audio_id: Optional[int]
    title: Optional[str]
    status: str  # 'stopped', 'playing', 'paused'
    speed: float
    position: float
    duration: Optional[float]


# After upload tells the frontend which session(s) got the file
class AudioUploadWithSessionsResponse(BaseModel):
    audio: AudioFileOut
    session_ids: List[int]



# ==================== CHAT MESSAGE SCHEMAS ====================

# Input message
class ChatMessageCreate(BaseModel):
    participant_id: int
    message: str = Field(..., min_length=1, max_length=2000)


# Ouptut message
class ChatMessageRead(BaseModel):
    message_id: int
    session_id: int
    participant_id: int
    message: str
    timestamp: datetime
    is_system_message: bool = False

    class Config:
        orm_mode = True


# Adds the sender name - which would need a union hence kept as a separate table(used only when needed)
class ChatMessageWithSender(ChatMessageRead):
    """Chat message with sender name"""
    sender_name: Optional[str] = None


# ==================== LOG SCHEMAS ====================

# Table to create the logs for each event
class LogCreate(BaseModel):
    event_type: str = Field(..., min_length=1, max_length=50)
    event_details: Optional[dict] = None


# Stores the returned logs
class LogOut(BaseModel):
    log_id: int
    session_id: Optional[int]
    user_id: Optional[int]
    event_type: str
    event_details: Optional[dict]
    created_at: datetime
    
    class Config:
        orm_mode = True


# ==================== WEBSOCKET MESSAGE SCHEMAS ====================

class WebSocketMessage(BaseModel):
    """Base WebSocket message schema"""
    type: str
    

class ParticipantAction(WebSocketMessage):
    """Actions performed by participants"""
    participant_id: Optional[int] = None
    target_participant_id: Optional[int] = None


class AudioControl(WebSocketMessage):
    """Audio playback control messages"""
    audio_id: Optional[int] = None
    speed: Optional[float] = 1.0
    position: Optional[float] = 0.0


# ==================== SESSION STATE SCHEMAS ====================

class SessionState(BaseModel):
    """Complete session state for WebSocket sync"""
    session_id: int
    is_active: bool
    participants: dict  # participant_id -> participant_info
    playback: dict  # Current playback state
    
    class Config:
        arbitrary_types_allowed = True


# ==================== ERROR SCHEMAS ====================

class ErrorResponse(BaseModel):
    """Standard error response"""
    detail: str
    error_code: Optional[str] = None


class SuccessResponse(BaseModel):
    """Standard success response"""
    ok: bool = True
    message: Optional[str] = None
    data: Optional[dict] = None


# ==================== NOTIFICATIONS SCHEMAS ====================

class FCMTokenRequest(BaseModel):
    token: str
    device_type: Optional[str] = "unknown"


class FCMTokenDeleteRequest(BaseModel):
    token: str


# ==================== SELF-LISTEN SCHEMAS ====================

# Tracks what a student listened to and when - pull model schema
class SelfListenLogOut(BaseModel):
    """One entry in a student's personal listening history."""
    log_id: int
    audio_id: Optional[int]
    audio_title: Optional[str]
    listened_at: datetime

    class Config:
        orm_mode = True