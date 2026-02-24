# SEEDS-BITS — Backend

> **Synchronized Educational Environment for Dynamic Sessions**
>
> A real-time classroom platform built with **FastAPI** + **SSE** (Server-Sent Events) + **PostgreSQL**.
> Teachers create sessions, students join, and all interactions are streamed in real-time.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Tech Stack](#tech-stack)
- [Branch Info](#branch-info)
- [Deployment Guide](#deployment-guide)
  - [Prerequisites](#prerequisites)
  - [Step-by-Step Deployment](#step-by-step-deployment)
  - [Environment Variables](#environment-variables)
  - [Database Setup](#database-setup)
  - [Running the Server](#running-the-server)
  - [Nginx / Reverse Proxy Notes](#nginx--reverse-proxy-notes)
- [API Endpoints](#api-endpoints)
- [Session Logging Feature](#session-logging-feature)
  - [What Gets Logged](#what-gets-logged)
  - [Logging Architecture](#logging-architecture)
  - [Log API Endpoints](#log-api-endpoints)
- [Testing Guide](#testing-guide)
  - [Quick Smoke Test (curl)](#quick-smoke-test-curl)
  - [Testing via Swagger UI](#testing-via-swagger-ui)
  - [Full End-to-End Test Flow](#full-end-to-end-test-flow)
  - [Verifying Logs in the Database](#verifying-logs-in-the-database)
- [File Structure](#file-structure)

---

## Architecture Overview

```
Flutter App (Client)
    │
    ├── GET  /sse/sessions/{id}?user_id=X   ← long-lived SSE stream (server → client)
    ├── POST /sessions/{id}/action           ← all user actions (client → server)
    └── REST endpoints                        ← CRUD for sessions, audio, chat, etc.
    │
FastAPI Backend (Python)
    │
    ├── ws_manager.py   → manages SSE queues + broadcasts
    ├── main.py         → all endpoints + SSE + action handler
    ├── session_logger.py → logs every event to the DB
    └── models.py       → SQLAlchemy ORM models
    │
PostgreSQL Database
    └── 11 tables (users, sessions, participants, logs, ...)
```

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend Framework | FastAPI (async) |
| Real-time Transport | SSE (Server-Sent Events) — replaces WebSockets |
| Database | PostgreSQL with asyncpg driver |
| ORM | SQLAlchemy 1.4 (async) |
| Auth | JWT (python-jose) + bcrypt |
| Push Notifications | Firebase Cloud Messaging |
| Audio Streaming | aiofiles + FileResponse |

---

## Branch Info

| Branch | Purpose |
|--------|---------|
| `main` | Latest SSE-based code (no logging) |
| `kshitij` | **main + session logging** — use this for deployment |

Always deploy from the **`kshitij`** branch. It has everything from `main` plus the complete logging system.

---

## Deployment Guide

### Prerequisites

- **Python 3.10+**
- **PostgreSQL 12+** (running and accessible)
- **pip** for installing Python dependencies
- (Optional) **Nginx** or another reverse proxy for production

### Step-by-Step Deployment

```bash
# 1. Clone the repo
git clone https://github.com/anonymous-akshat1001/SEEDS-BITS.git
cd SEEDS-BITS

# 2. Switch to the kshitij branch (has logging)
git checkout kshitij
git pull origin kshitij

# 3. Install Python dependencies
cd backend
pip install -r requirements.txt

# 4. Set up the .env file (see Environment Variables section below)
cp ../.env.example ../.env   # or create manually
# Edit ../.env with your database credentials

# 5. Create the PostgreSQL database
sudo -u postgres createdb seeds_db
# OR connect to psql and run: CREATE DATABASE seeds_db;

# 6. Start the server
uvicorn main:app --host 0.0.0.0 --port 8000
# Server will auto-create tables on first startup
```

### Environment Variables

Create a `.env` file in the **project root** (parent of `backend/`):

```env
# Database connection (REQUIRED)
DATABASE_URL="postgresql+asyncpg://YOUR_USER:YOUR_PASSWORD@localhost:5432/seeds_db"

# JWT secret for authentication (REQUIRED)
JWT_SECRET="YOUR_SECURE_SECRET_KEY_HERE"

# Audio storage directory
AUDIO_DIR="./data/audio"

# Backend URL (used by frontend)
BACKEND_URL=http://your-server-ip:8000
API_BASE_URL=http://your-server-ip:8000

# Firebase (optional, for push notifications)
FIREBASE_SERVICE_ACCOUNT_KEY=""
```

> **Important**: The `DATABASE_URL` must use the `postgresql+asyncpg://` scheme (not `postgres://`).

### Database Setup

The server auto-creates all tables on startup via `Base.metadata.create_all()`. If you need to create them manually:

```sql
-- Connect to your database
psql -U your_user -d seeds_db

-- The following tables are created automatically:
-- users, sessions, participants, audio_files, playback,
-- questions, logs, jwt_tokens, chat_messages, audio_messages, fcm_tokens

-- To verify tables exist:
\dt
```

The **`logs`** table (used by session logging) has this schema:

```sql
CREATE TABLE logs (
    log_id      SERIAL PRIMARY KEY,
    session_id  INTEGER REFERENCES sessions(session_id) ON DELETE CASCADE,
    user_id     INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    event_type  VARCHAR(50) NOT NULL,
    event_details JSON,
    created_at  TIMESTAMP DEFAULT NOW()
);
```

### Running the Server

```bash
# Development (with auto-reload)
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# Production
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1
```

> **Note**: Use `--workers 1` in production because the in-memory session state (`SESSION_STATE`) is not shared across workers. For multi-worker setups, you'd need Redis or similar.

### Nginx / Reverse Proxy Notes

The SSE endpoint requires that your proxy **does not buffer** the response. The server already sends `X-Accel-Buffering: no` in the SSE response headers, which disables buffering in Nginx automatically.

If issues persist, add this to your Nginx config:

```nginx
location /sse/ {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header Connection '';
    proxy_http_version 1.1;
    proxy_buffering off;
    proxy_cache off;
    chunked_transfer_encoding off;
}
```

---

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register a new user (teacher/student) |
| POST | `/auth/login` | Login and receive JWT token |

### Sessions
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/sessions` | Create a new session (teacher only) |
| DELETE | `/sessions/{session_id}` | Delete a session (teacher only) |
| GET | `/sessions/active` | List all active sessions |
| GET | `/sessions/{session_id}/state` | Get full session state |

### Participants
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users/students` | List all students (for inviting) |
| POST | `/sessions/{session_id}/invite` | Invite a student |
| POST | `/sessions/{session_id}/join` | Join a session |
| DELETE | `/sessions/{session_id}/participants/{pid}` | Remove a participant |
| POST | `/sessions/{session_id}/participants/{pid}/mute` | Mute/unmute participant |

### Audio
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/audio/upload` | Upload an audio file |
| GET | `/audio/list` | List uploaded audio files |
| GET | `/audio/{audio_id}/stream` | Stream audio file |
| GET | `/audio/{audio_id}/play` | Play audio file |
| POST | `/sessions/{session_id}/audio/select` | Select audio for session |
| POST | `/sessions/{session_id}/audio/play` | Play audio in session |
| POST | `/sessions/{session_id}/audio/pause` | Pause audio in session |
| POST | `/sessions/{session_id}/audio/control` | Unified audio control (play/pause/seek/speed) |
| GET | `/sessions/{session_id}/audio/state` | Get current playback state |

### Chat
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/sessions/{session_id}/chat` | Send a chat message |
| GET | `/sessions/{session_id}/chat` | Get chat history |

### Real-Time (SSE)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/sse/sessions/{session_id}?user_id=X` | SSE stream (server → client) |
| POST | `/sessions/{session_id}/action` | All user actions (client → server) |

### Session Logs
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/sessions/{session_id}/logs` | Get session activity logs |
| GET | `/sessions/{session_id}/logs/summary` | Get session event summary |

### Notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/users/fcm-token` | Register FCM push token |
| DELETE | `/users/fcm-token` | Remove FCM token |

---

## Session Logging Feature

### What Gets Logged

Every significant action in a session is automatically recorded with a timestamp and JSONB details:

| Event Type | Trigger | Example Details |
|-----------|---------|-----------------|
| `session_created` | Teacher creates a session | `{"title": "Physics 101"}` |
| `session_ended` | Teacher ends a session | `{"ended_at": "2026-02-24T..."}` |
| `participant_joined` | User joins via REST or SSE | `{"user_name": "John", "participant_id": 4}` |
| `participant_left` | SSE stream disconnects | `{"participant_id": 4}` |
| `participant_kicked` | Teacher kicks a participant | `{"kicked_user_id": 3, "reason": "Removed by teacher"}` |
| `participant_invited` | Teacher invites a student | `{"invited_user_id": 5}` |
| `participant_muted` | Self-mute or teacher mute | `{"target_user_id": 3, "is_self_mute": false}` |
| `participant_unmuted` | Self-unmute or teacher unmute | `{"target_user_id": 3, "is_self_unmute": true}` |
| `hand_raised` | Student raises hand | `{"participant_id": 4}` |
| `hand_lowered` | Student lowers hand | `{"participant_id": 4}` |
| `chat_message` | User sends a chat message | `{"message": "Hello!", "message_length": 6}` |
| `audio_uploaded` | Teacher uploads audio | `{"title": "Lecture 1", "duration": 3600}` |
| `audio_selected` | Teacher selects audio for session | `{"audio_id": 1, "audio_title": "Lecture 1"}` |
| `audio_play` | Audio playback starts | `{"audio_id": 1, "position": 0.0, "speed": 1.0}` |
| `audio_pause` | Audio playback paused | `{"position": 42.5}` |
| `audio_seek` | Audio position changed | `{"audio_id": 1, "position": 120.0}` |

### Logging Architecture

```
main.py (endpoint handlers)
    │
    │  await SessionLogger.log_xxx(db, ...)
    ▼
session_logger.py
    │
    │  INSERT INTO logs (session_id, user_id, event_type, event_details, created_at)
    ▼
PostgreSQL → logs table (JSONB event_details)
```

- **`session_logger.py`** — Contains the `SessionLogger` class with 15+ static methods, one per event type
- **`models.py`** — Contains the `Log` model (maps to the `logs` table)
- **`main.py`** — Calls `SessionLogger.log_xxx()` in 26 places across REST, SSE, and action endpoints

### Log API Endpoints

#### `GET /sessions/{session_id}/logs`

Returns detailed log entries for a session. **Teacher-only access.**

**Query parameters:**
- `user_id` (required) — your user ID (for auth)
- `event_type` (optional) — filter by event type (e.g., `participant_joined`)
- `limit` (optional, default 100) — max number of logs to return

**Example response:**
```json
{
  "session_id": 8,
  "total_logs": 3,
  "logs": [
    {
      "log_id": 19,
      "event_type": "participant_muted",
      "user_id": 1,
      "event_details": {
        "participant_id": 4,
        "target_user_id": 3,
        "is_self_mute": false
      },
      "created_at": "2026-02-24T16:24:20.666428"
    },
    {
      "log_id": 18,
      "event_type": "participant_joined",
      "user_id": 3,
      "event_details": {
        "participant_id": 4,
        "user_name": "Test Student",
        "joined_at": "2026-02-24T16:24:04.954850"
      },
      "created_at": "2026-02-24T16:24:04.954861"
    }
  ]
}
```

#### `GET /sessions/{session_id}/logs/summary`

Returns aggregated event counts for a session. **Teacher-only access.**

**Example response:**
```json
{
  "session_id": 8,
  "total_events": 3,
  "event_counts": {
    "participant_muted": 1,
    "participant_joined": 1,
    "session_created": 1
  },
  "unique_participants_joined": 1,
  "participants_left": 0,
  "first_event": "2026-02-24T16:23:54.274799",
  "last_event": "2026-02-24T16:24:20.666428"
}
```

---

## Testing Guide

### Quick Smoke Test (curl)

Run these commands after the server is up. Replace `localhost:8000` with your production URL.

```bash
# 1. Register a teacher
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Teacher","phone_number":"9999999999","password":"pass123","role":"teacher"}'
# → Note the user_id (e.g., 1)

# 2. Register a student
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Student","phone_number":"8888888888","password":"pass123","role":"student"}'
# → Note the user_id (e.g., 2)

# 3. Create a session as teacher
curl -X POST "http://localhost:8000/sessions?user_id=1" \
  -H "Content-Type: application/json" \
  -d '{"title":"My Test Session"}'
# → Note the session_id (e.g., 1)

# 4. Join session as student
curl -X POST "http://localhost:8000/sessions/1/join?user_id=2" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "user_id=2"
# → Note the participant_id (e.g., 1)

# 5. Mute the student (as teacher)
curl -X POST "http://localhost:8000/sessions/1/participants/1/mute?user_id=1&mute=true"

# 6. Check the logs — should show 3 events
curl -s "http://localhost:8000/sessions/1/logs?user_id=1" | python3 -m json.tool

# 7. Check the summary
curl -s "http://localhost:8000/sessions/1/logs/summary?user_id=1" | python3 -m json.tool
```

**Expected output from step 6:**
- `session_created` with the session title
- `participant_joined` with the student's name
- `participant_muted` with `is_self_mute: false`

### Testing via Swagger UI

1. Open **`http://your-server/docs`** in a browser
2. All endpoints are listed with "Try it out" buttons
3. For the logging endpoints, scroll to:
   - **`GET /sessions/{session_id}/logs`**
   - **`GET /sessions/{session_id}/logs/summary`**
4. Click **Try it out** → enter a `session_id` and `user_id` → click **Execute**

### Full End-to-End Test Flow

For a complete test that covers SSE and the action endpoint (which is what the Flutter app uses):

```bash
# Terminal 1: Start SSE stream as student (long-lived connection)
curl -N "http://localhost:8000/sse/sessions/1?user_id=2"
# This will print SSE events as they happen

# Terminal 2: Perform actions as teacher
# Mute via action endpoint
curl -X POST "http://localhost:8000/sessions/1/action?user_id=1" \
  -H "Content-Type: application/json" \
  -d '{"type":"mute_participant","target_participant_id":1,"mute":true}'

# Send chat message
curl -X POST "http://localhost:8000/sessions/1/action?user_id=1" \
  -H "Content-Type: application/json" \
  -d '{"type":"chat","text":"Hello everyone!"}'

# End session
curl -X POST "http://localhost:8000/sessions/1/action?user_id=1" \
  -H "Content-Type: application/json" \
  -d '{"type":"end_session"}'

# Terminal 3: Check all the logged events
curl -s "http://localhost:8000/sessions/1/logs?user_id=1" | python3 -m json.tool
```

### Verifying Logs in the Database

Connect to the database directly to verify logs are being written:

```bash
psql -U your_user -d seeds_db

-- View all logs for a session
SELECT log_id, event_type, user_id, event_details, created_at
FROM logs
WHERE session_id = 1
ORDER BY created_at;

-- Count events by type
SELECT event_type, COUNT(*) as count
FROM logs
WHERE session_id = 1
GROUP BY event_type;

-- Check recent activity
SELECT * FROM logs ORDER BY created_at DESC LIMIT 10;
```

---

## File Structure

```
SEEDS-BITS/
├── .env                        # Environment variables (DB URL, JWT secret, etc.)
├── README.md                   # ← This file
├── backend/
│   ├── main.py                 # All API endpoints + SSE + action handler (1700+ lines)
│   ├── session_logger.py       # Session logging module (SessionLogger class)
│   ├── models.py               # SQLAlchemy ORM models (11 tables)
│   ├── schemas.py              # Pydantic request/response schemas
│   ├── database.py             # Async DB engine + session factory
│   ├── auth.py                 # JWT token creation + verification
│   ├── ws_manager.py           # SSE queue manager + broadcast logic
│   ├── notification_service.py # Firebase push notification service
│   ├── requirements.txt        # Python dependencies
│   └── __init__.py             # Package init
└── frontend/                   # Flutter mobile app
```

---

## Production URL

If deployed at BITS Hyderabad:
- **Swagger Docs**: `http://responsible-tech.bits-hyderabad.ac.in/seeds/docs`
- **API Base**: `http://responsible-tech.bits-hyderabad.ac.in/seeds`
