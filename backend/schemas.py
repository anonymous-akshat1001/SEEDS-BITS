# schemas.py
from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime


# ==================== USER SCHEMAS ====================

class UserCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    phone_number: str = Field(..., min_length=10, max_length=20)
    password: str = Field(..., min_length=6)
    role: str  # 'teacher' or 'student'
    
    @validator('role')
    def validate_role(cls, v):
        if v.lower() not in ['teacher', 'student']:
            raise ValueError('Role must be either teacher or student')
        return v.lower()


class UserOut(BaseModel):
    user_id: int
    name: str
    phone_number: str
    role: str
    created_at: datetime
    
    class Config:
        orm_mode = True


class UserLogin(BaseModel):
    phone_number: str
    password: str


# ==================== AUTH SCHEMAS ====================

class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: int
    role: str


class TokenData(BaseModel):
    user_id: Optional[int] = None
    role: Optional[str] = None


# ==================== SESSION SCHEMAS ====================

class SessionCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=500)


class SessionOut(BaseModel):
    session_id: int
    title: Optional[str]
    is_active: bool
    created_by: Optional[int]
    created_at: datetime
    ended_at: Optional[datetime] = None
    participant_count: Optional[int] = 0  # Added participant count
    
    class Config:
        orm_mode = True


class SessionDetail(SessionOut):
    """Extended session info with additional metadata"""
    creator_name: Optional[str] = None


# ==================== PARTICIPANT SCHEMAS ====================

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


class ParticipantWithUser(ParticipantOut):
    """Participant with user details"""
    user_name: Optional[str] = None


# ==================== AUDIO FILE SCHEMAS ====================

class AudioFileUpload(BaseModel):
    title: str = Field(..., min_length=1, max_length=500)
    description: Optional[str] = ""


class AudioCreateResponse(BaseModel):
    audio_id: int
    title: str
    description: Optional[str]
    file_path: str
    mime_type: str
    uploaded_at: datetime
    
    class Config:
        orm_mode = True


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


# ==================== PLAYBACK SCHEMAS ====================

class PlaybackCreate(BaseModel):
    audio_file_id: int
    speed: Optional[float] = 1.0
    
    @validator('speed')
    def validate_speed(cls, v):
        if v < 0.5 or v > 2.0:
            raise ValueError('Speed must be between 0.5 and 2.0')
        return v


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


class AudioPlaybackControl(BaseModel):
    audio_id: int | None = None
    speed: float = 1.0
    position: float = 0.0
    action: str  # 'play', 'pause', 'seek'


class AudioPlaybackState(BaseModel):
    audio_id: int | None
    title: str | None
    status: str  # 'stopped', 'playing', 'paused'
    speed: float
    position: float
    duration: float | None



# ==================== CHAT MESSAGE SCHEMAS ====================

class ChatMessageCreate(BaseModel):
    participant_id: int
    message: str = Field(..., min_length=1, max_length=2000)


class ChatMessageRead(BaseModel):
    message_id: int
    session_id: int
    participant_id: int
    message: str
    timestamp: datetime
    is_system_message: bool = False

    class Config:
        orm_mode = True


class ChatMessageWithSender(ChatMessageRead):
    """Chat message with sender name"""
    sender_name: Optional[str] = None


# ==================== AUDIO MESSAGE SCHEMAS ====================

class AudioMessageCreate(BaseModel):
    participant_id: int
    audio_file_id: int
    duration: Optional[float] = None


class AudioMessageRead(BaseModel):
    audio_message_id: int
    session_id: int
    participant_id: int
    audio_file_id: Optional[int]
    timestamp: datetime
    duration: Optional[float] = None

    class Config:
        orm_mode = True


class AudioMessageWithDetails(AudioMessageRead):
    """Audio message with sender and file details"""
    sender_name: Optional[str] = None
    audio_title: Optional[str] = None


# ==================== QUESTION SCHEMAS ====================

class QuestionCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)


class QuestionOut(BaseModel):
    question_id: int
    session_id: int
    asked_by: Optional[int]
    content: str
    asked_at: datetime
    is_answered: bool
    
    class Config:
        orm_mode = True


class QuestionWithAsker(QuestionOut):
    """Question with asker name"""
    asker_name: Optional[str] = None


# ==================== LOG SCHEMAS ====================

class LogCreate(BaseModel):
    event_type: str = Field(..., min_length=1, max_length=50)
    event_details: Optional[dict] = None


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