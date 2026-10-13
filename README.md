# SEEDS-BITS

> **Synchronized Educational Environment for Dynamic Sessions**

SEEDS is a real-time classroom platform for teachers, students, and
administrators. The repository contains:

- a **Flutter client** for Android, web, and desktop;
- a **FastAPI backend** for authentication, classes, sessions, audio, chat,
  playlists, and administration;
- a **PostgreSQL database** accessed asynchronously through SQLAlchemy; and
- optional **Firebase Cloud Messaging** support for session notifications.

Teachers can create classes and live sessions, invite students, share and
control audio, manage participants, and review session activity. Students can
join sessions, receive synchronized updates, communicate, and use the
accessibility-focused keypad and text-to-speech interface.

## Contents

- [Architecture](#architecture)
- [Technology stack](#technology-stack)
- [Repository structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [Backend setup](#backend-setup)
- [Frontend setup](#frontend-setup)
- [Firebase setup](#firebase-setup)
- [Running the application](#running-the-application)
- [Testing and validation](#testing-and-validation)
- [Building the Android app](#building-the-android-app)
- [API overview](#api-overview)
- [Session logging](#session-logging)
- [Production notes](#production-notes)
- [Troubleshooting](#troubleshooting)

## Architecture

```mermaid
flowchart LR
    U[Teacher / Student / Admin] --> F[Flutter application]

    F -->|REST and JWT| A[FastAPI application]
    F -->|Server-Sent Events| R[Real-time session manager]
    F -->|WebRTC where required| W[RTC services]

    A --> R
    A --> W
    A -->|Async SQLAlchemy| P[(PostgreSQL)]
    A -->|Audio files| S[Local audio storage]
    A -->|Optional push notifications| C[Firebase Cloud Messaging]
    C --> F
```

### Request and event flow

1. The Flutter client authenticates against the backend and stores the JWT
   locally.
2. Normal operations use REST endpoints for users, classes, sessions, audio,
   playlists, chat, and administration.
3. During a live session, the client opens an SSE connection. The backend
   maintains an in-memory queue for each connected participant.
4. Client actions are submitted to the backend, persisted when necessary, and
   broadcast to connected session members.
5. Session events are written to PostgreSQL so teachers can retrieve detailed
   logs and summaries.
6. If Firebase credentials are configured, invitations and other notifications
   can also be delivered through FCM.

### Backend components

| Component | Responsibility |
|-----------|----------------|
| `main.py` | FastAPI app, lifecycle, REST endpoints, SSE, and session actions |
| `admin_routes.py` | Administrator APIs |
| `playlist_routes.py` | Playlist APIs |
| `auth.py` | Password hashing, JWT handling, and role dependencies |
| `database.py` | Async SQLAlchemy engine and session factory |
| `models.py` | SQLAlchemy database models |
| `schemas.py` | Pydantic request and response models |
| `ws_manager.py` | Live connection queues, state, and broadcasts |
| `session_logger.py` | Persistent session event logging and summaries |
| `notification_service.py` | Optional Firebase push delivery |

### Class and subject access model

`SchoolClass` remains the backend model for the user-facing **Class** entity.
Classes and subjects have an explicit, persistent many-to-many association:

- a student has zero or one active class membership and can use every active
  subject associated with that class;
- a teacher can have multiple class-subject assignments, but an assignment is
  valid only while its class-subject association is active;
- sessions, audio, and teacher playlists retain both `class_id` and
  `subject_id`; the backend validates that pair for list, resource, media, and
  live-event access; and
- archiving catalog entries or an association prevents new work in that
  workspace without deleting historical sessions, audio, logs, or assignments.

These rules are enforced by the backend. Client filtering is only a usability
aid and is not an authorization boundary.

### Frontend layers

| Layer | Location | Responsibility |
|-------|----------|----------------|
| App bootstrap and navigation | `frontend/lib/main.dart` | Environment loading, startup, routes, and deferred notifications |
| Screens | `frontend/lib/screens/` | Login, dashboards, sessions, settings, audio, playlists, and administration |
| Services | `frontend/lib/services/` | REST, authentication state, SSE, WebSocket/RTC, notifications, and TTS |
| Shared UI | `frontend/lib/widgets/` | Reusable participant, chat, keypad, and dialog widgets |
| Utilities | `frontend/lib/utils/` | Access control, search, keypad behavior, and UI preferences |

## Technology stack

| Area | Technology |
|------|------------|
| Client | Flutter 3.35.6 / Dart 3.9.2 |
| State and local storage | Provider and SharedPreferences |
| Backend | Python 3.10+ and FastAPI |
| Database | PostgreSQL 12+ |
| ORM and driver | SQLAlchemy 1.4 async and asyncpg |
| Authentication | JWT, python-jose, and bcrypt |
| Real-time transport | Server-Sent Events, plus WebRTC where required |
| Push notifications | Firebase Cloud Messaging |
| Audio | Flutter audio packages and FastAPI file streaming |
| Tests | pytest and flutter_test |

## Repository structure

```text
SEEDS-BITS/
|-- .env.example                 Backend environment template
|-- README.md                    Project documentation
|-- backend/
|   |-- main.py                  FastAPI entry point
|   |-- admin_routes.py          Administrator routes
|   |-- playlist_routes.py       Playlist routes
|   |-- auth.py                  Authentication and authorization
|   |-- database.py              Database engine and sessions
|   |-- models.py                SQLAlchemy models
|   |-- schemas.py               Pydantic schemas
|   |-- ws_manager.py            Real-time session manager
|   |-- session_logger.py        Session event logging
|   |-- notification_service.py  Firebase server integration
|   |-- reset_db.py              Database reset/bootstrap utility
|   |-- requirements.txt         Runtime dependencies
|   |-- requirements-dev.txt     Runtime and test dependencies
|   `-- tests/                   Backend tests
`-- frontend/
    |-- lib/
    |   |-- main.dart            Flutter entry point
    |   |-- screens/             Application screens
    |   |-- services/            API and device services
    |   |-- utils/               Shared application utilities
    |   `-- widgets/             Reusable widgets
    |-- test/                    Flutter tests
    |-- android/                 Android host project
    |-- web/                     Web host project
    |-- windows/                 Windows host project
    |-- pubspec.yaml             Flutter dependencies and assets
    `-- FCM_SETUP.md             Detailed Firebase/FCM guide
```

## Prerequisites

### Required for backend development

- Git
- Python 3.10 or newer
- PostgreSQL 12 or newer

### Required for frontend development

- Flutter **3.35.6** (the revision recorded in `frontend/.metadata`)
- Dart **3.9.2** (included with Flutter 3.35.6)
- Git
- Windows Developer Mode when developing on Windows

### Required for Android development

- Android Studio
- Android SDK and command-line tools
- JDK 17
- An Android emulator or a physical device with USB debugging enabled

### Optional

- Node.js and Firebase CLI for regenerating Firebase client configuration
- A Firebase service-account JSON file for backend push notifications
- Nginx or another reverse proxy for production deployment

## Quick start

The following is the shortest local setup after the prerequisites are
installed.

```powershell
git clone https://github.com/anonymous-akshat1001/SEEDS-BITS.git
cd SEEDS-BITS

# Backend environment
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r backend\requirements-dev.txt

# Create and edit the backend configuration
Copy-Item .env.example .env

# Frontend dependencies
cd frontend
flutter pub get
```

Create the PostgreSQL database and complete the environment files described
below before starting the applications.

> On macOS or Linux, activate the Python environment with
> `source .venv/bin/activate` and use `/` instead of `\` in commands.

## Backend setup

### 1. Create the Python environment

From the repository root:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r backend\requirements-dev.txt
```

Use `requirements.txt` instead if test dependencies are not needed:

```powershell
python -m pip install -r backend\requirements.txt
```

Use `python -m pip`, not `pip install requirements.txt`. The `-r` flag tells
pip to install the packages listed in the file.

### 2. Create the PostgreSQL database

Using `createdb`:

```powershell
$env:PGPASSWORD = "your_postgres_password"
createdb -U postgres -h localhost seeds_db
Remove-Item Env:PGPASSWORD
```

Or from `psql`:

```sql
CREATE DATABASE seeds_db;
```

Clean databases receive the current tables during application startup. Existing
installations must run the Alembic migration before starting the updated
backend.

### 3. Configure the backend environment

Copy the template:

```powershell
Copy-Item .env.example .env
```

The `.env` file belongs in the repository root, not inside `backend/`.

```env
DATABASE_URL=postgresql+asyncpg://postgres:your_password@localhost:5432/seeds_db
JWT_SECRET=replace-with-a-long-random-secret
ALLOW_DEV_USER_IMPERSONATION=false

BOOTSTRAP_ADMIN_NAME=SEEDS Administrator
BOOTSTRAP_ADMIN_PHONE=9999999999
BOOTSTRAP_ADMIN_PASSWORD=replace-with-a-strong-password

AUDIO_DIR=./data/audio
BACKEND_URL=http://127.0.0.1:8000
API_BASE_URL=http://127.0.0.1:8000
WS_BASE_URL=ws://127.0.0.1:8000

FIREBASE_SERVICE_ACCOUNT_KEY=
```

Important:

- `DATABASE_URL` must use the `postgresql+asyncpg://` scheme.
- All three `BOOTSTRAP_ADMIN_*` values are required. The backend creates that
  administrator idempotently on startup, keyed by phone number, and never
  overwrites an existing administrator password.
- Public registration accepts only `teacher` and `student`; administrators
  sign in through the normal login endpoint but cannot register publicly.
- Never commit `.env`, Firebase credentials, private keys, or production
  passwords.
- Keep `ALLOW_DEV_USER_IMPERSONATION=false` except in a controlled development
  environment.
- `FIREBASE_SERVICE_ACCOUNT_KEY` is optional. Leave it empty if push
  notifications are not being tested.

### 4. Upgrade or initialize the database

For an existing database, run the data-preserving migration from the repository
root:

```powershell
.\.venv\Scripts\Activate.ps1
alembic upgrade head
```

The migration creates the class-subject association table and backfills pairs
observed in existing sessions, audio, and teacher assignments. It stops with an
actionable error if legacy rows refer to missing classes or subjects; repair
those references and rerun it.

For a disposable clean development database, the destructive reset command
creates the current schema, associates the seeded subjects with all seeded
classes, and creates the configured bootstrap administrator:

```powershell
python -m backend.reset_db --confirm-reset
```

### 5. Start the backend

```powershell
.\.venv\Scripts\Activate.ps1
cd backend
python -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

Available local URLs:

- API: `http://127.0.0.1:8000`
- Swagger UI: `http://127.0.0.1:8000/docs`
- OpenAPI JSON: `http://127.0.0.1:8000/openapi.json`

## Frontend setup

### 1. Verify Flutter

```powershell
flutter --version
flutter doctor -v
```

This project was created with Flutter 3.35.6 and Dart 3.9.2. Other compatible
Flutter versions may work, but changing SDK versions can update
`pubspec.lock` or generated platform files.

### 2. Restore Flutter packages

```powershell
cd frontend
flutter pub get --enforce-lockfile
```

If dependencies were intentionally changed in `pubspec.yaml`, run
`flutter pub get` without `--enforce-lockfile` and review the lockfile update.

### 3. Configure frontend URLs

Create both files below because the app first loads `assets/.env` and then
falls back to `.env`.

`frontend/.env`:

```env
API_BASE_URL=http://127.0.0.1:8000
WS_BASE_URL=ws://127.0.0.1:8000
WEB_VAPID_KEY=
```

`frontend/assets/.env`:

```env
API_BASE_URL=http://127.0.0.1:8000
WS_BASE_URL=ws://127.0.0.1:8000
WEB_VAPID_KEY=
```

For a physical Android device, `127.0.0.1` refers to the phone itself. Replace
it with the development computer's LAN IP address, for example:

```env
API_BASE_URL=http://192.168.1.50:8000
WS_BASE_URL=ws://192.168.1.50:8000
```

Then run the backend with `--host 0.0.0.0` and allow the port through the local
firewall.

### 4. Windows and Android setup

On Windows:

1. Enable **Developer Mode** in Windows Settings so Flutter can create
   symlinks for plugins.
2. Install Android Studio and its Android SDK.
3. Install Android SDK command-line tools and accept the licenses:

   ```powershell
   flutter doctor --android-licenses
   ```

4. Use JDK 17 for this project's Gradle version:

   ```powershell
   flutter config --jdk-dir="C:\path\to\jdk-17"
   ```

5. Confirm the Android toolchain is healthy:

   ```powershell
   flutter doctor -v
   ```

## Firebase setup

The Flutter source imports the generated
`frontend/lib/firebase_options.dart`. This file and native Firebase
configuration files are intentionally excluded from Git.

To generate the client configuration for the existing `seeds-bits` Firebase
project:

```powershell
npm install --global firebase-tools
firebase login
dart pub global activate flutterfire_cli

cd frontend
flutterfire configure --project=seeds-bits --platforms=android,web
flutter pub get --enforce-lockfile
```

Do not create a second Firebase project if `seeds-bits` is missing from the
project list. Ask a project owner to grant your Google account access.

Backend push delivery additionally requires a Firebase service-account key:

1. Generate it from **Firebase Console > Project settings > Service
   accounts**.
2. Store the JSON file outside this repository.
3. Set `FIREBASE_SERVICE_ACCOUNT_KEY` in the root `.env` to its absolute path.

Push notifications are optional for normal backend startup. See
`frontend/FCM_SETUP.md` for device registration and end-to-end notification
testing.

## Running the application

### Terminal 1: backend

```powershell
cd SEEDS-BITS
.\.venv\Scripts\Activate.ps1
cd backend
python -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

### Terminal 2: frontend

```powershell
cd SEEDS-BITS\frontend
flutter devices
flutter run
```

Run a specific target:

```powershell
# Microsoft Edge
flutter run -d edge

# A connected Android device or emulator
flutter run -d <device-id>
```

## Testing and validation

### Backend

From the repository root with the virtual environment active:

```powershell
python -m pytest backend\tests -q
```

### Frontend

```powershell
cd frontend
flutter test
flutter analyze
```

`flutter analyze` currently reports existing info-level style and deprecation
notices. Compilation errors should still be treated as failures.

### Backend smoke test

With the backend running:

```powershell
Invoke-WebRequest http://127.0.0.1:8000/openapi.json
```

You can also use Swagger UI at `http://127.0.0.1:8000/docs` to register users,
log in, create a session, and exercise the APIs.

## Building the Android app

### Debug APK

```powershell
cd frontend
flutter build apk --debug
```

Output:

```text
frontend/build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK

```powershell
flutter build apk --release
```

Release artifacts distributed by this project should be renamed to:

```text
SEEDS-v<version>.apk
```

For example, version `1.0.0` should be distributed as
`SEEDS-v1.0.0.apk`. Production releases also require an Android signing
configuration; never commit signing keys or passwords.

## API overview

The complete and current API schema is available from Swagger UI while the
backend is running. Major endpoint groups include:

| Area | Example endpoints |
|------|-------------------|
| Authentication | `POST /auth/register`, `POST /auth/login` |
| Classes and subjects | Administrator, teacher, and membership routes |
| Sessions | Create, list, join, invite, end, and delete |
| Live events | `GET /sse/sessions/{session_id}`, session action routes |
| Participants | Join, remove, mute, hand raise, and access control |
| Audio | Upload, list, stream, select, play, pause, seek, and speed |
| Playlists | Create, update, order, and assign audio |
| Chat | Send messages and retrieve session history |
| Notifications | Register and remove FCM device tokens |
| Logs | Retrieve session events and aggregated summaries |

Authentication uses JWTs. Query-parameter user impersonation is available only
when `ALLOW_DEV_USER_IMPERSONATION` is explicitly enabled.

The administrator dashboard provides separate student and teacher searches by
normalized name or phone substring. Students can be filtered by All, Enrolled,
or Unassigned and can be assigned, transferred, or removed from a class.
Teachers can be filtered by All, Assigned, or Unassigned and can hold multiple
class-subject assignments. Administrators also manage the active subjects for
each class.

Dashboard operations support pointer/touch, normal keyboard traversal,
D-pad/remote navigation, and the existing numeric-keypad shortcuts. Dialogs
provide equivalent non-pointer actions, visible focus, semantic selected or
toggled state, and spoken status/error feedback through the configured TTS
service. Class, subject, and workspace selectors support left/right D-pad
cycling with spoken selection feedback rather than requiring a dropdown menu.
Existing high-contrast and text-scale preferences remain in effect.

Ending a live session closes it for all connected participants and marks it
ended; it does not delete the session. Teachers continue to see active and
ended sessions in dashboard history, while students see only active sessions.
An ended session can be reactivated and opened again. It can also be
permanently deleted after a separate destructive confirmation; active sessions
must be ended before permanent deletion is allowed.

## Session logging

Significant session actions are stored with a timestamp and JSON event details.
Examples include:

- session creation and completion;
- participant joins, leaves, invitations, removals, and mute changes;
- raised or lowered hands;
- chat messages;
- audio upload, selection, playback, pause, seek, and speed changes; and
- accessibility/self-listen events.

Teachers can retrieve detailed session logs and aggregated summaries through
the logging endpoints. The data flow is:

```text
FastAPI endpoint
    -> SessionLogger
    -> SQLAlchemy async session
    -> PostgreSQL logs table
```

To inspect recent logs directly:

```sql
SELECT log_id, session_id, user_id, event_type, event_details, created_at
FROM logs
ORDER BY created_at DESC
LIMIT 20;
```

## Production notes

### Process model

Run the backend with **one worker** because live session queues and
`SESSION_STATE` are currently stored in process memory:

```powershell
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1
```

Multiple workers require moving shared session state to Redis or another
external store.

### Reverse proxy and SSE

An SSE proxy must not buffer responses. For Nginx:

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

### Security checklist

- Use a long, randomly generated JWT secret.
- Use HTTPS in production.
- Restrict CORS to trusted origins before public deployment.
- Store database and Firebase credentials in a secret manager.
- Keep development impersonation disabled.
- Back up PostgreSQL and uploaded audio.
- Use a proper Android release signing key.

## Troubleshooting

### `pip` is not recognized

Install Python, reopen the terminal, and use:

```powershell
python -m pip install -r backend\requirements-dev.txt
```

### Flutter reports that symlink support is required

Enable Windows Developer Mode and restart the terminal or editor.

### `firebase_options.dart` is missing

Run the FlutterFire configuration steps in [Firebase setup](#firebase-setup).

### Gradle uses an invalid or unsupported Java version

Install JDK 17 and configure Flutter:

```powershell
flutter config --jdk-dir="C:\path\to\jdk-17"
```

Do not commit a developer-specific `org.gradle.java.home` path to
`android/gradle.properties`.

### Android cannot reach the local backend

- Replace `127.0.0.1` in the frontend environment files with the computer's
  LAN IP.
- Start Uvicorn with `--host 0.0.0.0`.
- Confirm the phone and computer are on the same network.
- Allow TCP port 8000 through the local firewall.

### PostgreSQL connection fails

- Confirm the PostgreSQL service is running.
- Verify the username, password, host, port, and database in `DATABASE_URL`.
- Confirm `seeds_db` exists.
- Use `postgresql+asyncpg://`, not `postgres://`.

## Additional documentation

- `frontend/FCM_SETUP.md` - Firebase Cloud Messaging setup and testing
- Swagger UI - `http://127.0.0.1:8000/docs` while the backend is running
