# SEEDS-BITS

> **Synchronized Educational Environment for Dynamic Sessions**

SEEDS is a real-time classroom platform for teachers, students, and
administrators. The repository contains:

- a **Flutter client** for Android, web, and desktop;
- a **FastAPI backend** for authentication, classes, sessions, audio, chat,
  playlists, and administration;
- a **PostgreSQL database** accessed asynchronously through SQLAlchemy; and
- optional **Firebase Cloud Messaging** support for session notifications.

The school administrator creates every account, enrolls students, assigns
teachers and sets up the weekly timetable. Students and teachers sign in with
their phone number only. A teacher starts today's class with one key; every
enrolled student's phone rings and opening the alert joins the class. Teachers
share and control audio, mute all students at once, hear who has joined and
who has not, and ring those who have not joined. Students join, listen,
speak when they choose, and use the accessibility-focused keypad and
text-to-speech interface. See [Interaction-reduction model](#interaction-reduction-model).

The design principles, flows, key maps and open decisions are in
[INTERFACE_DESIGN.md](INTERFACE_DESIGN.md).

## Contents

- [Architecture](#architecture)
- [Interaction-reduction model](#interaction-reduction-model)
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
- [Keypad accessibility](#keypad-accessibility)
- [Teacher/student journeys and complete button maps](USER_JOURNEYS.md)
- [Quiz module](#quiz-module)
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
| `quiz_routes.py` | Question banks, quiz authoring, attempts, grading, and results |
| `quiz_schemas.py` | Typed quiz request and response contracts |
| `journey_routes.py` | Learning journey authoring, publication, student play, offline sync, and results |
| `journey_schemas.py` | Typed learning-journey step and sync contracts |
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

## Interaction-reduction model

SEEDS is built for blind teachers and students on Android button phones. Setup
that used to be repeated by teachers and students is done once by the
administrator or by the backend, and each screen speaks only what to do now
(**star** always reads every key). Numbers such as S05 refer to the approved
interaction-reduction plan.

### Accounts and sign-in (S01–S04, S43)

- The administrator creates accounts, enrolls students and assigns teachers.
  There is no self-registration.
- Students and teachers type their phone number and press **1**. No password,
  OTP or role choice; the server's role decides the home screen. This is an
  unverified testing-phase identity model (see Backend setup).
- **Shared phones:** the administrator creates a shared-phone group with its own
  entry number and gives each person a 1–4 digit profile number. Entering the
  shared number asks for the profile number; it selects an account and is not
  a password. Each profile keeps its own speech and display settings on the
  phone, and switching account stops any ringing class alert.
- Administrators sign in with a password on a separate screen (**3** on
  sign-in) and can never use the number-only path.

### Timetable and class lifecycle (S05–S10, S24, S25)

- The administrator enters weekly lessons (teacher, class, subject, one or
  more weekdays, start and end time, optional date range and prepared lesson
  playlist), holidays, and per-date cancellations, substitutes or lesson
  changes. Choosing several days creates one weekly lesson per day in one
  step; if any day overlaps, none is created. After choosing the teacher, only
  the classes and subjects assigned to them in **People** are offered, and the
  server rejects any other pair. Overlapping lessons for a teacher or a class
  are rejected. Times are typed and shown in the school's time zone
  (`SCHOOL_TIMEZONE`, India Standard Time by default), never UTC; class
  records and issues also show IST whatever the admin computer's clock says.
  The timetable can be arranged by day, teacher or class (each
  heading shows its lesson count) and searched by teacher, class, subject or
  lesson.
- Adding a person requires a class for a student and at least one class and
  subject for a teacher (enforced by the server too).
- A class becomes live only when its teacher presses **1: Start** on Home. It
  can start from `CLASS_EARLY_START_MINUTES` (default 10) before the scheduled
  start. Starting is idempotent; the session label is generated, so there is
  no title to type. With nothing scheduled, a teacher can still start an
  unscheduled class from **More** (`UNSCHEDULED_CLASS_MINUTES`, default 45).
- One live class at a time per teacher and per enrolled class (so per
  student), enforced by unique database indexes, not only by the app.
- The scheduled end does not end the class. It ends when the teacher ends it
  for everyone, or automatically at the **cutoff**: the earlier of scheduled
  end + 30 minutes and 5 minutes before the teacher's or the class's next
  lesson. Spoken warnings come 5 minutes and 1 minute before. **7 → 1** (More,
  Add 15 minutes) adds
  15 minutes, never past the next-lesson limit; the administrator can also
  add time or end a class in **Class records**.
- Ended classes are kept as backend records only (no teacher history).

### Alerts, joining and the live class (S11–S20, S44, S45)

- Starting a class rings every enrolled student's phone for up to 60 seconds.
  Ten minutes after the start, students who have never joined get one more
  ringing alert. The teacher's **4 → 4** (class list, remind) rings everyone
  not yet joined again.
  No student is rung twice within 5 minutes, whatever the source.
- Opening the alert, or pressing OK on it while the app is open, joins the
  class directly. After the ringing stops, a silent notification stays and
  still joins while the class is live. The student home also shows **1: Join**
  by itself within about 20 seconds, so there is no Refresh button.
- Before a class, a student can explore Home freely, or press **1** to join
  automatically when that class starts (only while Home stays open).
- Everyone joins muted. The first class asks once for the microphone;
  refusing still allows listening, later classes do not ask again, and
  pressing Unmute asks again or offers Android settings.
- After an interruption (network loss or the app closing), opening SEEDS
  returns to the same live class. Leaving on purpose, the class ending or
  signing out prevents this.
- Teachers: **3** mute all students, **4** class list (who is here, who
  joined and left, who has not joined; ring those not joined; raised hands;
  remove someone), **5** Start (**1** quiz, **2** journey, **3** recording),
  **6** status of what is running (only while something runs), **7** More
  (add time, chat, class status), **8** end the class for everyone. A
  prepared lesson is selected on entry, so **5 → 3** plays it, and the next
  part is selected when one finishes.
- Leaving needs one confirmation. The app tells the server, waits at most 3
  seconds, then returns Home whatever happens (closing the class connection
  also tells the server).
- Who came: one minute after the class starts the teacher hears "4 of 5
  students here." After that, joins and leaves are spoken by name and grouped
  when they happen together: "Akshat and Meena joined. Ravi left. 4 of 5
  here." ("of 5" is the number of enrolled students, sent by the server with
  the class state.) Students are not told when others join or leave.

### Quiz, journey or recording in class

- The teacher presses **5: Start**, then **1** quiz, **2** journey or **3**
  recording. Quizzes and journeys are the **published** ones for the class's
  subject (quizzes only while open).
- One thing runs at a time: starting a quiz or journey pauses the recording;
  starting a recording closes the open quiz or journey.
- Every student in class hears "Your teacher started a quiz: Plants. Press 4
  to begin." and gets **4: Start quiz: Plants** (or **4: Start journey: …**)
  on the class screen; students who join later see it too. That key goes
  straight into the first question or step, with no list or confirmation;
  leaving returns to the class and says "Back in class." The class sound
  keeps playing meanwhile.
- If it cannot start (closed, no attempts left), the server's reason is
  spoken. It stays in the student's normal Quizzes or Journeys list after the
  class.
- **Recording:** the player opens and reads its keys first (5 play or pause,
  4/6 back and forward 10 seconds, 7/9 speed, 1 choose, 2 upload, 3 status,
  0 back); the selected recording starts for the class when that speech
  ends. Pressing any key in the player first cancels the automatic start.
- **6: Status** appears only while something runs. For a quiz or journey it
  says "5 students in class. 3 have attempted it, 1 finished." and offers:
  **1** who in class has not finished, **2** who in the whole class has not
  finished (each name says not started or started, and in the whole list
  whether they are in class), **3** remind those in class who have not
  finished, **4** start a different one, **5** stop offering it. For a
  recording it opens the player with all its controls.
- The class list (**4**) also says "Plants: 12 started, 8 finished." Journey
  progress counts once the student's phone has sent it.

### Learning that runs itself (S26, S28–S30)

- **2: Continue learning** opens the journey in progress straight into the
  player at the saved place.
- Progress saved offline is sent automatically. New journeys are prepared for
  offline use on Wi-Fi only (Settings toggle, on by default), at most two per
  run and within the existing download allowance.
- Each published quiz gets one automatic reminder for students who have not
  attempted it (a day before it closes, halfway through a shorter window, or
  two days after publishing when it never closes).

### Backend automation and operations (S38–S41)

- `GET /me/home` tells each app what to offer now.
- Alerts, reminders, warnings and automatic ending are durable jobs in
  `scheduled_jobs`, run by the API process (`JOB_WORKER_ENABLED`, default true;
  `JOB_POLL_SECONDS`, default 2). Overdue jobs run right after a restart.
  Run one API process (or several sharing PostgreSQL; claims use
  `SKIP LOCKED`). Live presence for the class list is held in that process.
- Problems that need an administrator (student without a class, teacher
  without an assignment, student phone not registered for alerts, prepared
  lesson without playable audio, repeatedly failing background task) appear
  once each under **Issues** in the administrator dashboard.
- `SCHOOL_TIMEZONE` (default `Asia/Kolkata`) is the timezone of timetable times.

### Limits and real-phone checks (S42)

- A push is not guaranteed: notifications may be disabled, delayed, or
  blocked by battery savers, Do Not Disturb or a force-stopped app. Home still
  shows the class. Ringing uses Android's repeating notification sound and a
  full-screen request; Android decides whether the screen wakes, and the lock
  screen is never bypassed.
- Before rollout, check on each target phone with touch disabled: sign-in by
  number with no SIM over Wi-Fi; start and join in one key each; the alert
  rings no longer than 60 seconds and OK joins; the 10-minute reminder and
  5-minute pause; mute all on several phones (actual sound, not just state);
  microphone refusal and later Unmute; warnings and the exact cutoff; recovery
  after closing the app; 30 consecutive presses of each changed shortcut.

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
|   |-- journey_routes.py        Learning journey routes
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
- There is no public registration. The administrator creates student and
  teacher accounts (dashboard **Accounts → Add person**). Students and teachers
  sign in with `POST /auth/phone-login` (phone number only); administrators
  sign in with `POST /auth/login` (password). Neither path serves the other.
- **Testing-phase identity model:** a phone number is not verified, so anyone
  who knows a registered number (and, on a shared phone, its short profile
  number) can use that account. Review identity before any real deployment.
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

The current head is `20261119_14`, which adds `teacher_notices` (what an
administrator created, published, closed or archived for a teacher). Before
it, `20261119_13` adds the quiz or journey a teacher
starts in class (`sessions.activity_*`). Before it, `20261117_12` (interaction
reduction): accounts gain
`is_active`; new tables hold shared phones, the timetable, per-date overrides,
holidays, durable jobs, class alerts and administrator issues; sessions gain
their timetable occurrence, start, cutoff and end reason; participants gain
`first_connected_at`. It closes all but the newest live session per teacher
and per class so the one-live-class indexes can be built.

The migration creates the class-subject association table and backfills pairs
observed in existing sessions, audio, and teacher assignments. It stops with an
actionable error if legacy rows refer to missing classes or subjects; repair
those references and rerun it.

The current head also adds the quiz tables, classroom hand-queue columns
(`20261020_03`) and private reusable lesson sequences (`20261020_04`, removed
again by `20261109_10`).
Assessment policies and future-attempt extra time are added by `20261020_05`;
`20261020_06` adds reviewed spoken question metadata and traceable bank
revisions without reconstructing legacy history. Revision
`20261020_07` adds versioned authentication sessions and administrator-assisted
password recovery. Existing password hashes and accounts are preserved, with
no forced change until an authorized administrator explicitly resets an account.
Revision `20261020_08` makes each push token exclusive to one account.
As approved, every ambiguous legacy duplicate association is revoked, including
duplicates within one account; unambiguous links remain. Affected phones regain
notifications on their next normal signed-in registration. No accounts, lessons,
notes or assessment records are removed.
Revision `20261102_09` adds analytics history. The current head,
`20261109_10`, adds learning journeys (`learning_journeys`,
`journey_snapshots`, `journey_runs`, `journey_answers`) and **drops the former
`lesson_sequences` table and its saved teacher lesson plans**; back up first if
they are needed. Its downgrade recreates an empty `lesson_sequences` table.
Upgrade an existing database **before starting this backend
version**; `create_all` at startup does not add columns to existing tables.
The hand migration retains existing raised-hand flags and leaves their
original order unknown, rather than manufacturing timestamps. It adds a
session sequence, nullable participant queue order and participant revision;
no existing educational records are deleted. Its upgrade is tested against
an isolated legacy database, not evidence of a production migration.

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

Backend push delivery additionally requires Firebase server credentials:

1. Generate it from **Firebase Console > Project settings > Service
   accounts**.
2. Store the JSON file outside this repository.
3. Set `FIREBASE_SERVICE_ACCOUNT_KEY` in the root `.env` to its absolute path.

If that variable is empty or the file is absent, the backend tries Google
Application Default Credentials. Quiz publication reports zero successful
deliveries when neither credential source is available, rather than silently
claiming that notifications were sent. Push notifications are optional for
normal backend startup. See
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

### Keypad-first redesign foundation

The shared numbered-menu components now power administration section/class
actions and the teacher class-and-subject chooser. The complete application
journeys have not yet been migrated; other screens retain their existing key
mappings unless explicitly listed below.

- `NumberedMenu` provides up to five direct digit choices.
- `KeypadTextStep` provides a single native input field with validation and an
  OK/Done completion path. D-pad Up/Down remains the fallback for leaving
  editing; digits, star, and hash are never intercepted while editing.
- `KeypadPagedList` requests five items per page from its supplied loader,
  keeps failed-page retries non-destructive, and rejects stale account-scoped
  results. Search is delegated to the complete source, not the visible page.
  Backend paginated browsing adapters are still to be implemented.
- These components explicitly opt into `KeypadInteractionPolicy.numbered`:
  `0` is Back, `*` repeats help, and `#` stops app narration. Lists use `7/9`
  for previous/next, `8` for search, and `6` for options. Legacy wrappers keep
  their existing mappings.

### Accessibility regression fixes

- Focused text fields always retain digits, star and hash, even before an
  explicit edit-mode transition. OK finishes editing without inserting a
  newline; D-pad Up/Down remains available.
- Browser speech uses a fresh utterance for every announcement. Cancellation
  settles the outgoing request and stale browser callbacks cannot read newer
  text or complete newer speech. Android continues to use `flutter_tts`.
- Administration defaults to Accounts; key `7` chooses Accounts, Classes or
  Subjects. Filters stay mounted and retain focus while loading; the selected
  filter and current button are spoken after the response. Class management
  and class-subject selection use numbered choices.
- Teacher key `7` opens numbered class/subject assignments (five per page,
  complete-assignment search); key `8` opens lesson plans. No assignment
  dropdown is used. Registration key `3` toggles student/teacher.
- Teacher quizzes use key `4` for untimed practice. Choosing saved questions
  refreshes the workspace bank first; Step 2 also lists questions already saved
  in the draft, with OK to read their options. Save/validation errors are spoken and
  scrolled into view immediately; uncertain writes still require review rather
  than automatic retry. Quiz scoring, attempts and snapshot rules are unchanged.
- Recorded-library key `5` focuses the first active class without opening its
  recordings; D-pad browses sessions and OK opens one. An empty or unavailable
  list is announced without navigating.
- Downloads: `1` refresh, `2` find online recordings, `3` status, `4` cancel an
  active transfer, `5` download the listed pack with confirmation. File actions
  remain D-pad accessible. Existing confirmation-dialog mappings are retained.
- Screen help names the main reachable sections rather than only "controls."
- Returning from a page or dismissing a dialog automatically repeats the
  current page's help, including pages that announce their initial load
  themselves. Restored focus cannot cancel that help; active action feedback
  finishes first, and a new keypad action cancels the pending repeat.
- Administration help describes the selected Accounts, Classes or Subjects
  section. Numbered lists announce item keys, options, paging, search, back,
  D-pad traversal and OK, not just the available items.
- Lesson plans use separate numbered menus for create/choose, add a step,
  step management and plan management. Plan, step and recording pickers use
  five-item searchable lists. `0` returns one level, `8` reads status, `*`
  repeats help and `#` stops speech. Selecting never runs a step; running and
  deletion still require confirmation and retain server revision checks.
- Student quiz help explains filter controls, starting/resuming and history.
  Active attempts automatically read each question and all spoken option
  texts, with state-specific key and D-pad instructions. Focus alone never
  selects or submits; private feedback and results still require explicit
  requests. Empty classroom hand/summary actions speak their unavailable state
  rather than silently doing nothing.

Learning journeys require the current backend's `/teacher/journeys` and
`/student/journeys` routes and the `20261109_10` migration. Back up the
database, run `alembic upgrade head`, then restart the updated backend.

Run the foundation and compatibility tests from `frontend`:

```powershell
flutter test test\numbered_navigation_test.dart test\keypad_instruction_wrapper_test.dart
```

Browser speech cancellation/error ownership has a separate browser-only suite:

```powershell
flutter test --platform chrome test\browser_speech_engine_test.dart
```

These speech tests mock the browser synthesis API; they do not prove audible
voice quality or native phone compatibility.
If a Windows Flutter SDK returns 404 for its own `/canvaskit/` test assets, fix
or update that SDK's test asset server, or use a non-Windows test runner. The
browser regression run for these changes supplied the installed SDK assets
through a local test-only route; no SDK or dependency-cache files were edited.

Physical BlackZone validation is required before signing off device compatibility:
verify digits/T9, star/hash, OK/Done, D-pad editing exit, both unidentified
buttons beside OK, and held-key behavior across route transitions. Desktop
widget tests do not establish native IME or hardware compatibility.

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

The keypad regression suite covers native OK activation, navigation versus
text editing (including star/hash input), Back with focus restoration,
confirmation dialogs, numeric date validation, and audio-library traversal
beyond the initially rendered rows. Quiz tests cover spoken prompts, saved
answer progression, duplicate-action guards, HTTP failures, malformed
confirmations, completion retry, and resuming after all answers are saved.
Learning/download tests cover per-account persistence, native position/speed
restoration, bookmark removal, repeat endpoints, authenticated manifests,
byte-range recovery, SHA-256 integrity, the exact per-account 50 MB boundary,
thirty-day expiry, clock rollback, cancellation, partial playlist-pack outcomes
and confirmed unreadable-record recovery. Saved downloads remain keypad
reachable while online library requests are stalled. Voice tests cover explicit
activation, no restart, narration/lifecycle cancellation and confirmed unmute.
SIM/privacy tests cover no automatic native access, per-request consent with
pre-granted permissions, single/multiple SIM selection, invalid or unavailable
numbers, permission denial, native/plugin/format errors and late responses after
leaving login. The SIM picker is checked at 240x320 with 1.5x text. Notification
tests inspect the actual mocked FCM request and native Android display arguments
for generic previews, private visibility and removal of personal routing metadata.
Recovery tests cover administrator authorization, external-identity attestation,
stale-reset guards, exact temporary-credential expiry/attempt policy, restricted
sessions, old-token rejection, password replacement, SSE reset races and full
queue termination. Widget/native-channel tests verify private credential review,
no automatic password narration, no dashboard bypass, account-change guards,
small-screen reachability and capture muting/audio-stop requests on revocation.
Voice setup tests cover manual screen-reader mode, unavailable/failed/stalled
English voice checks, late results, the 1.5x faster default and preserved saved
rates. The optional keypad-practice screen has been removed. Reflow tests preserve nonlinear system
scaling and test 2x system times 1.5x app scaling at 240x320 across welcome,
authentication, Settings, dashboards, quiz attempts and history,
checking focus reachability and text truncation. Native lesson-player and live
teacher/student session tests additionally exercise 3x text layouts.
Push tests verify exclusive ownership under concurrent SQLite registration,
account-scoped deletion after switching, restricted-session rejection and
privacy-safe duplicate-link migration. PostgreSQL concurrency and actual push
delivery still require operational validation.
These are automated widget/service checks, not physical-phone or blind-user
validation.

Latest speech/quiz usability checkpoint: **337 full Flutter tests passed**.
The unchanged backend retains its previous **95 passing tests** checkpoint;
it was not rerun for these frontend-only revisions. Final static analysis
reports **zero errors/warnings** and **38 existing informational findings**.
The Android debug APK was rebuilt; patch whitespace checks passed. Following
the final legacy-feedback-policy and wording review, all 25 guided quiz/reflow
tests passed again and the directly affected analyzer targets were clean. This is
software evidence, not release acceptance. No configured-database migration,
deployment or commit was performed.

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
| Authentication | `POST /auth/phone-login` (students, teachers; `profile_code` on shared phones), `POST /auth/login` (administrators) |
| Home | `GET /me/home`: the live class, today's classes and, for teachers, their class-subject workspaces |
| Classes | `POST /classes/start`, `POST /sessions/{id}/extend`, `GET /sessions/{id}/roster`, `POST /sessions/{id}/remind-not-joined`, `POST /sessions/{id}/end` |
| School setup | `/admin/users`, `/admin/device-groups`, `/admin/timetable`, `/admin/timetable/{id}/occurrences/{date}`, `/admin/holidays`, `/admin/schedule`, `/admin/issues`, `/admin/sessions` |
| Classes and subjects | Administrator, teacher, and membership routes |
| Live events | `GET /sse/sessions/{session_id}`, session action routes (`mute_all_students` with a `request_id`) |
| Participants | Join, remove, mute all students, hand raise, and access control |
| Audio | Upload, list, stream, select, play, pause, seek, and speed |
| Playlists | Create, update, order, and assign audio |
| Chat | Send messages and retrieve session history |
| Notifications | Register and remove FCM device tokens |
| Logs | Retrieve session events and aggregated summaries |
| Quizzes | Question bank, authoring, publication, attempts, feedback, review, and results |
| Learning journeys | `GET/POST /teacher/journeys`, `PUT /teacher/journeys/{id}`, `.../preview`, `.../publish`, `.../archive`, `.../restore`, `.../duplicate`, `.../results`, `GET /student/journeys`, `GET /student/journeys/{id}`, `POST /student/journeys/sync` |

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

## Keypad accessibility

The current accessibility work targets Android keypad phones. Support on a
particular phone still requires checking its physical key events, Android
version, English TTS engine, audio, and available memory.

- Up/Down traverses enabled controls and wraps; each focused control is
  announced with its position ("3 of 7"), and wrapping says "End of list.
  Back to the first item." OK activates a control or enters a text field's
  edit mode.
- Up/Down exits text editing. While editing, digits, star, and hash belong to
  the field rather than triggering screen shortcuts.
- Opening any screen speaks where you are, its current state in one
  sentence, and then every key that screen offers ("Press 1 for ..., press 2
  for ..."), so nothing has to be discovered. This holds on every screen,
  including the journey player and the class list, and also with
  "Essential" speech or TalkBack. Sign-in opens in the phone field and still
  reads every key, then "You are in Phone number" and how editing works.
  Coming back to a screen from one opened on top of it (a list, chat,
  settings, a dialog) reads the screen, its state, keys 1 to 3 and 0, then
  "Press star for all keys". A screen that is still loading says only that
  it is loading and reads its counts and keys once loaded. Pressing a key
  before the opening speech starts drops that speech. The class screen reads
  all its keys when you join.
- Keys are numbered from 1 with no unused gaps, except where a key keeps the
  same meaning everywhere. Welcome: **1** sign in, **2** settings. Single-
  action forms (change password, a question, quiz settings) save with **1**.
  Quiz draft: **1** refresh, **2** write a question, **3** use a saved
  question, **4** remove one, **5** review; while reviewing, **1** refresh,
  **2** settings, **3** publish. The class audio library pauses the class
  audio with **3**.
- Outside editing, every screen uses the same keys: **0** goes back or
  cancels, **star** repeats screen help, **hash** stops app speech (it never
  navigates), **8** repeats the last message (on the teacher's class
  screen 8 ends the class; star still says the last message). Back does not log out. Logout, leaving a live session and ending
  a session require confirmation; cancelling a dialog returns focus to the
  control that opened it.
- Audio players share one layout around the raised 5 key: **4** back 10
  seconds, **5** play or pause, **6** forward 10 seconds, **7** slower,
  **9** faster. Turning app speech off is only offered in Settings.
- A live session is one short screen showing only what is needed every
  minute. Keys mean the same on both screens where they can: **1**
  microphone, **2** hand, **7** More (the less used actions), **0** leave;
  ending is highest: the teacher's **8** ends the class for everyone. Joining
  says the state ("You are in class and muted. Press 1 to speak, 2 to raise
  your hand.") and then every key; the status only mentions what is not
  ordinary (a raised hand, playing audio, an open quiz or journey, the end
  time, a connection problem). Star still reads every key.
  Students: **1** mute or unmute, **2** raise or lower hand, **3** what is
  playing (read only), **4** start the quiz or journey the teacher opened
  (shown only while one is open), **7** More (**1** chat, **2** who is in
  class, read only, **3** class status and held-back updates), **0** leave
  (one confirmation: 0 stays, 1 leaves).
  Teachers (they have no hand to raise): **1** mute or unmute, **2** raised
  hands queue, **3** mute all students (the teacher's microphone is not
  touched; students may unmute themselves afterwards), **4** class list
  (counts first; then who is here, who joined and left, who has not joined;
  ring everyone not yet joined; raised hands; remove someone), **5** Start
  (quiz, journey or recording), **6** status of what is running (only while
  something runs), **7** More (**1** add 15 minutes, **2** chat, **3** class
  status and summary), **8** end class for everyone (asks to confirm) and
  **0** leave (the class keeps running). Only the teacher's player controls
  the class recording, for everyone at once. There is no single-student mute.
- While answering or reviewing a quiz, **7** and **9** make quiz speech
  slower or faster (also the D-pad **Quiz speech speed** control: left or
  right). If options were being read, they are read again at the new speed.
  The quiz speed is remembered for the next quiz and never changes the
  Settings speed used everywhere else. Quiz answer keys match learning
  journeys: **1–4** choose, **5** submit, **6** repeat the question, **8**
  where am I (including time left). **Finish quiz now** is a D-pad item that
  asks to confirm.
- Recorded-library controls, lesson rows, private preview, and session
  broadcast controls have explicit spoken focus targets. Private preview and
  playback for everyone are described separately.
- **Recorded Audio Library** replaces the misleading user-facing "Offline"
  label. Finding online recordings and streaming require internet. Its
  **Downloaded Lessons** action opens locally saved recordings without
  waiting for an online list.

### Blind-user accessibility features

- **Sound cues and vibration.** Short distinct sounds for correct, wrong,
  saved, error, end of list, loading, unmuted (your turn to speak), muted and
  leaving. They work while speech is stopped. On Android they are paired with
  vibration: one short buzz for OK, two for an error, a long one for leaving
  or ending. Settings **8** turns sound cues on or off and **9** turns
  vibration on or off.
- **One place for spoken text.** Sentences live in `frontend/lib/announcers/`
  (dashboard, admin, settings, sign-in, library, quiz, session, journeys and
  notifications), so wording stays consistent and can be translated.
- **Messages you can hear again.** Pop-up SnackBars are replaced by a
  persistent last-message bar at the bottom of every screen. Press **8** (on
  screens where 8 has no other job) or **star** to hear it again.
- **Star always answers "where am I".** Screen name, focused item, current
  state (for example "Muted. Hand raised. 3 hands waiting. Recording
  playing."), the last message, then the keys.
- **Natural numbers and times.** Phone numbers digit by digit, session IDs as
  "session four two", times as "10:30 in the morning", durations as
  "2 minutes 10 seconds" (`frontend/lib/utils/spoken_format.dart`).
- **No touch-only controls.** Dropdowns and sliders (subject and quiz state
  pickers, admin pickers, quiz timings, Settings volume, text size and speech
  rate, lesson position) are left/right controls that announce their value.
- **Undo.** Removing a journey step, a download or a playlist item says
  "Press 1 within 10 seconds to undo". The removal is only made permanent
  after that window.
- **Fewer timers.** Nothing acts just because the user was silent; searches
  run only when asked. Where a time limit applies (quizzes), 8 says the time
  left and warnings are spoken before it runs out.
- **Notifications that open the right item.** Tapping a live-class, journey
  or quiz notification opens a spoken page, for example "Your teacher started
  a class. Press 1 to join."

### Speech and recorded audio

Self-voicing is the default. When Android TalkBack is turned on, SEEDS
switches automatically to screen-reader mode and sends its announcements
(status changes, errors, results) to TalkBack instead of speaking over it;
it switches back when TalkBack is turned off. Choosing a speech mode in
Settings overrides this automatic behaviour, and choosing **Automatic**
restores it. Essential narration shortens automatic page help and
suppresses automatic incidental updates. Standard groups incidental updates;
Detailed includes more update groups. Explicit reads and star help remain
available regardless of narration level.

### Visual design for low vision

High contrast (white and yellow on black) is on by default and can be turned
off in Settings. Text is never smaller than 14 points, cards and inputs have
visible borders, the keypad-focused control always has a thick yellow ring,
and states are written in words ("Live now", "Selected", "Muted") rather
than shown by colour alone. Layouts stack into one column on 240×320 screens.

The default speech speed is **1.75 times** the TTS engine's normal speed
(flutter_tts rate 0.875). Settings offers **0.5 to 4 times** in 0.25 steps,
spoken as "times normal speed", plus Test TTS. Phones that still had the
previous 1.5-times default saved move to the new default once; any other
saved speed is kept. Android and web now use the same scale (the web engine
previously played the default at 0.75 times).

Focus/navigation and requested speech replace stale utterances. Incidental
joins, departures and hand updates cannot interrupt requested speech. Live
classes defer those updates for **Read class updates**; incoming chat is read
only using **Read latest message**. **Stop speech** is reachable in the quiz,
class audio, session and Settings controls.

Enabling voice commands in Settings makes **Listen for command** available
in the session connection row; it does not start recognition. Each explicit
activation opens one window of up to twelve seconds, with a reachable Stop
control and no automatic restart. App narration, route changes and lifecycle
interruption cancel listening. Whole commands are required; voice-command
unmute additionally requires keypad/touch confirmation before the normal
server-acknowledged self-unmute. Direct microphone shortcuts are unchanged.

Requested narration pauses registered recorded lessons, playlists and private
previews. Only the current utterance may resume the same item, and only if
its screen is still current, the user still intends playback, and its player
has not been disposed. Stopping speech also releases that pause. Live-session
audio is not automatically paused. Playlist Play after Pause resumes the
existing position.

In self-voicing navigation mode, star restores disabled or zero-volume app
speech and repeats help. It does not change Android system volume, intercept
star while editing, or re-enable narration in screen-reader mode. Native
engine/setup operations are bounded; speech errors are logged and exposed in
Settings with English-voice recovery guidance.

### Saved learning progress

Class recordings and playlist items share per-account progress: playback
position, speed, completion, named or numbered bookmarks, and A-B repeat
points. Private teacher previews do not create learning progress.

- **Continue Learning** in the Recorded Audio Library checks the current
  authorized audio list before opening an unfinished lesson. Unavailable
  recordings do not erase saved progress. A refreshed playlist stops a lesson
  that is no longer available.
- Use **Add bookmark**, edit its name with OK, then leave editing with
  Up/Down and choose Save. The point is the position when Add bookmark was
  selected, not the later position after entering its name. **Bookmarks**
  offers jumping and confirmed removal. Jumping does not start paused audio.
- **Set A**, then **Set B** at a later point, then explicitly turn repeat on.
  Saved points do not automatically enable looping on the next visit.
  **Clear A-B** removes the repeat points, not the recording.
- Back/forward ten-second controls offer short review in either player.
  These are time-based seeks, not invented sentence or chapter boundaries;
  current recordings do not supply chapter/transcript metadata.
- Learning controls are in the D-pad focus order. The class player controls
  scroll separately from the lesson list on small screens; Up/Down leaves a
  native seek slider rather than becoming trapped in slider adjustments.
- Positions checkpoint at five-second intervals during playback and flush on
  pause, explicit seek/speed changes, stop, lifecycle interruption and screen
  disposal. Abrupt process termination can lose the most recent unsaved
  interval; successful atomic writes survive reopening.
- Saving failures are displayed and spoken, with **Retry saving**. If saved
  data cannot be read, starting from the beginning without changing it requires
  explicit confirmation. Existing unreadable data is retained, not silently
  replaced with an empty record.

Progress is stored in private application-support files, separately per
account, and retained across logout. The learning directory is excluded from
Android cloud backup and device transfer. It contains lesson metadata, not
authentication tokens or media URLs. Retained progress is not permission to
access a recording. Offline media is stored separately under the same
account-isolated learning directory, as described below.

### Downloaded lessons

Every recording currently authorized for the signed-in account is eligible
for downloading, subject to a **50,000,000-byte (50 MB) media allowance per
account**, not per phone. Several accounts can therefore consume more than
50 MB together. Existing downloads, positions and bookmarks remain on this
phone across logout; another account cannot open them through the app.

- Open **Downloaded Lessons** from the Recorded Audio Library, a class audio
  list or a playlist. Choose an individual recording, or confirm a sequential
  download of the listed recordings. Internet/data is required to download.
- Downloads are foreground, user-started operations, not an Android background
  download service. Use Cancel or confirm Back to stop; partial data remains
  for an explicit retry. Process interruption also requires an explicit retry.
- The server checks current access before issuing an account-bound manifest
  with exact size, SHA-256 and a thirty-day expiry. A complete recording must
  match its size and digest before installation and local playback. Partial
  files cannot be played. Resumed transfers validate the server's byte range.
- Partial files reserve the recording's full declared size. Storage is never
  silently freed by deleting lessons. **Remove download** asks for confirmation
  and removes only the selected recording/partial data, preserving learning
  progress and bookmarks. A failed/cancelled pack reports how many recordings
  were verified and retains them.
- Playback uses an actual local device-file source and the same position,
  speed, bookmark and repeat controls as online lessons. Online playback
  authorization is rechecked when opening a saved lesson. Only connectivity
  failure permits fallback to its existing unexpired offline access; denial,
  malformed responses, expired access and failed integrity checks do not.
  **Renew access** requires a successful online authorization.
- Access lasts thirty days from server authorization, including when offline.
  An online access denial blocks subsequent offline playback but retains the
  file. Immediate revocation without connectivity is impossible. Local clock
  rollback checks are a mitigation, not a trusted clock or tamper-proof DRM.
  Reconnecting and renewing repairs an invalid time checkpoint.
- An unreadable download record is reported, not silently overwritten. The
  manager offers confirmed removal of only that record's media/metadata.
  Progress, bookmarks and other lessons remain intact; new transfers remain
  blocked until unreadable quota records are resolved.

Media and metadata are app-private and excluded from Android backup/transfer;
tokens and token-bearing URLs are not written into download metadata.
Automated restart, account-isolation, integrity, expiry and native local-source
tests are not physical-device airplane-mode or blind-user validation.

### Optional SIM suggestions and private notifications

Accounts are created by the school administrator; there is no registration
screen. Sign-in asks only for the phone number, typed on the keypad, so it
works with no SIM card and on Wi-Fi. Login never scans SIMs automatically.
**2: Fill in my number from the SIM card** first explains the optional access, even when Android permission
was granted earlier. After permission, a keypad-accessible chooser requires an
explicit selection, including for a single SIM. Choosing fills only the phone
field; it neither verifies account ownership nor signs in. Cancel, missing SIMs,
denied permissions and native errors preserve manual entry and Wi-Fi login.
Leaving login cancels further UI work; a late permission check cannot initiate
another permission request or SIM scan.

New FCM previews and foreground local notifications use **SEEDS update** and
**Open SEEDS to review your updates.** Android requests private lock-screen
visibility. Routing retains only update type and session/quiz/class/subject IDs;
names, titles, phone numbers, grades and message text are not included. Local
notification taps also discard personal fields from legacy routing payloads.
Class alerts are data-only pushes (type, session, alert and ring-until only);
the app builds its own private notification. Opening one joins the class
directly after the backend rechecks that it is live for this account.
Actual OEM lock-screen behaviour still requires
device testing; previously displayed OS notifications are not retroactively
rewritten by this change.

**3: Administrator sign in** opens the separate password screen used only by
administrators.

Push-token registration is an atomic database upsert against a unique token.
A token has one signed-in account owner, rather than accumulating links across
shared-phone logins. Logout deletion is conditional on the requesting account,
so an old account cannot delete a token already reassigned to another account.
Sign-in, registration and native refresh share account-pinned acknowledged
registration. Neither full push tokens nor native speech-error details are
logged by these paths. Migration `20261020_08` revokes all ambiguous old duplicate
links rather than guessing an owner; the next signed-in registration restores
one owner. Already delivered notifications and in-flight provider delivery
cannot be recalled; generic previews and server destination authorization remain
necessary. This does not prove complete shared-device isolation.

### English voice setup without a practice screen

Startup goes directly to the intended welcome, dashboard or required
password-change screen. There is no keypad-practice screen or practice route.
**Settings, 7: Check English voice** directly checks Android voice setup.
Speech mode selection remains an explicit device preference and does not
enable an Android screen reader for you.

English availability checks are explicit and bounded, try en-IN then en-US,
and distinguish an available language from Android-reported installed offline
voice data. **Test TTS** requests a sample separately. Successful checks cannot
prove audibility or offline operation: install English voice data in Android's
Text-to-speech output settings and test the sample in airplane mode before relying
on it. Missing/stalled/failed checks provide visible recovery instructions.
App speech remains off in manual screen-reader mode.

### Magnified text and private assessment speech

System `TextScaler` behavior is preserved per font size, including nonlinear
scaling, and multiplied by the existing 0.9-1.5 app setting. Narrow screens no
longer cap accessibility scaling or shrink base type. Core small-screen headings
move into scrollable content, field labels wrap, registration roles use a
wrapping switch tile, and lesson sections scroll together instead of competing
for fixed vertical space. Live-chat Read/Stop/help controls remain present even
when the available pane is very short.

Answer-save announcements and completed-result introductions are generic.
Correctness, answer keys, explanations and scores require explicit private Read;
completed attempts expose **8: Read result privately**. History introductions
do not announce a grade; explicitly focused summaries/attempts remain readable.
Server-driven participant/hand/recording-selection announcements are generic.
Existing feedback-release authorization and academic policy remain unchanged.
Broader populated-route/dialog reflow, personal-speech/shared-device audit,
physical screen-reader/OEM behavior and blind-user acceptance remain open.

### Administrator recovery: sign out everywhere

Students and teachers no longer have passwords, so there is nothing to reset.
If a phone number was used on the wrong phone, an administrator opens the
account and chooses **Sign out everywhere** (`POST
/admin/users/{id}/sign-out-everywhere` with the expected authentication
version). Every app session for that account ends, push devices are removed
and live-class streams close; the person signs in again with their number.
Deactivating an account (`PATCH /admin/users/{id}` with `is_active: false`)
does the same and blocks sign-in. Changing an account's phone number also
signs it out everywhere.

The administrator's own temporary-password flow below is unchanged: it applies
only to administrator accounts.

### Admin: quizzes and journeys for a teacher

The administrator dashboard's **Quizzes and journeys** section lets an
administrator pick a teacher and one of that teacher's assigned classes and
subjects, then list that teacher's quizzes and journeys, create and edit
drafts, publish them, close a published quiz and archive a published journey.
Quiz questions are typed new (optionally saved to the teacher's bank) or
picked from that teacher's own question bank. Journeys use every step type
(recording, narration, question, bank question, poll); the recordings offered
are only audio that teacher uploaded for that class and subject.

The app calls the ordinary teacher routes (`/teacher/quizzes*`,
`/question-bank*`, `/teacher/journeys*`, `/audio/list`, `/audio/upload`) with
the administrator's token and an `X-Act-As-Teacher: <teacher user_id>` header
(or `?as_teacher=<id>`). The server resolves an active teacher and applies
exactly that teacher's rules: ownership, class-and-subject assignment,
readiness and publish checks, student notifications and the quiz auto-reminder.
A teacher's own token ignores the header. Audit events record the
administrator as the actor.

Each creation, publication, closure or archive made this way is stored in
`teacher_notices`. The teacher's `GET /me/home` includes unseen ones as
`admin_notices: [{notice_id, kind: "quiz"|"journey", title, action:
"created"|"published"|"closed"|"archived"}]` (oldest first, at most 50), and
`POST /me/notices/seen` with `{"notice_ids": [...]}` marks them seen.

### Administrator temporary-password change

An administrator can open an existing teacher/student account, choose
**Password recovery**, attest that identity was verified outside SEEDS, and
separately confirm the reset. A claimed name, phone number or SIM suggestion
alone is not verification. Existing assignment management remains available from
the same account menu. This flow cannot reset administrator accounts.

The server securely generates a **12-digit temporary credential**, including
possible leading zeros, valid for **24 hours**. After **10 failed attempts**,
temporary-credential sign-in pauses for **15 minutes**, including attempts with
the correct credential during that pause. When the pause ends, another attempt
window is available until the credential expires. An administrator can explicitly
issue a replacement after identity verification. Normal password-login rules and
the existing six-character minimum remain unchanged.

The credential is kept only in the reset response and the administrator's open
review, never stored as plaintext in the database, app preferences or logs. The
administrator must explicitly **Read and reveal credential privately**; no
automatic speech or clipboard copy occurs. Closing requires confirmation and
discards that review copy without cancelling the completed reset. An unconfirmed
or malformed response blocks another reset in that review; close and refresh
before considering a deliberate replacement. A server-side expected-version
guard rejects stale requests, including blind retries after a lost acknowledgment.

Sign-in with a temporary credential opens a required password-change screen,
not a dashboard. Its fields are hidden and never automatically narrated. Back
can only offer sign-out. Startup honors a remembered required-change state, and
notification taps cannot skip it. The server independently blocks normal
REST/media/SSE access until change, verifies the temporary credential again,
rejects reusing it as the new password, and issues a replacement session only
after saving the new password. Password text is not silently trimmed.
If change acknowledgment is lost, try signing in with the new password before
requesting another reset; the change may already have succeeded.

Reset and successful password change advance the server's authentication
version. Old REST/media tokens are rejected. Reset removes push associations,
mutes persisted participation, and ends active SSE account streams, discarding
queued events even when their queue is full. Stream authorization is rechecked
around bootstrap snapshots and subsequent events. The current app stops native
capture, requests audio/peer cleanup, clears sign-in and returns to login when
revoked; native cleanup failures have explicit guidance and bounded waits.
Push registration resumes only for a normal signed-in session.

This invalidates online authorization, not bytes already obtained. Approved
account-private downloads, private notes and learning records are retained.
Disconnected devices cannot be instantly revoked, and actual Android/OEM
microphone and lifecycle behaviour still requires physical-device validation.
The database records reset time and administrator ID, not the credential.
Existing versionless tokens remain compatible only while the account's
authentication version is still zero.

### Live connection and action recovery

The session interface exposes spoken connection status and a keypad-reachable
Retry connection control after an interruption. A successful HTTP response alone
does not establish a live connection: the server must identify the participant
on a valid event stream. Connection headers and the initial acknowledgment each
have a ten-second bound. A stream with no updates or keepalives for sixty
seconds is interrupted; the backend normally sends keepalives every twenty-five
seconds.

Transient failures reconnect with two-to-thirty-second exponential backoff,
plus up to 250 milliseconds of jitter. Sign-in failures, unavailable classes,
removal and ended sessions stop retrying. Reconnecting receives a fresh server
snapshot, not a replay of previous client actions. Old streams and timers are
cancelled when leaving or changing sessions.

Class actions and audio selection/control require a typed, valid `ok: true`
acknowledgment within ten seconds. Failed or unreadable responses are not
success. An unconfirmed action may already have reached the server: check its
state before retrying. There is no automatic replay of chat, unmute, end-class
or removal actions. Account changes invalidate pending acknowledgments and
block requests that have not yet been sent.

Chat shows **Sending**, **Sent** or **Not confirmed**. Its draft remains until
confirmation, duplicate sends are blocked while pending, and an older
acknowledgment cannot erase a newly edited draft. Reading the latest message
also reads its delivery status. Playback announcements confirm that the class
request was accepted; they do not claim that every participant heard it.
The remaining native microphone behaviour needs integration and device
validation. The approved policy is that teachers
may mute others, but only participants may unmute themselves. Both server
mutation routes reject a teacher unmuting someone else; teacher controls offer
Mute or Read microphone status instead. A brief control-connection interruption
must preserve the last local microphone state, never automatically unmuting.

Mute and hand changes are persisted in the existing participant record, so a
fresh stream can restore them. Server stream cleanup checks queue ownership:
an old stream cannot remove a replacement connection or publish a false
departure. Cancellation during the initial connection frames also releases
the stream.

Fresh class joins start muted, including re-entry after leaving. Only an
explicit, acknowledged self-unmute can enable the local audio track; an incoming
unmute flag cannot do so. A teacher mute disables the local track immediately
and takes precedence over an older pending unmute. Missing microphone access
produces permission/rejoin guidance rather than a false Unmuted announcement.
An unconfirmed mute still leaves this phone muted.

The former simplified session interface has been replaced with the standard
session, as approved. Its legacy `/simple_session` route is retained as an alias
with the same session/user/class/subject context. There is one live-voice path,
not a recording-only interface pretending to provide a working microphone.
Automated 240x320 checks cover teacher/student startup and native-channel mute
commands; they do not establish real microphone or WebRTC interoperability.

Real Android audio focus, TTS completion/cancellation, screen-reader
coexistence, headset routing, recognition, and physical keys still need
device testing. The remaining teacher, assessment, onboarding and release
validation phases are not implied by these improvements.

### Deferred integrations and release gates

No AI service, external content repository, IVR/SMS channel or offline graded
assessment is enabled by this accessibility work. Product approval and the
applicable provider/content-owner agreements must precede implementation.

| Future area | Required decisions and contracts | Required verification before enabling |
| --- | --- | --- |
| AI assistance | Product owner approves learning scope, teacher review, student-data disclosure/retention, provider terms, costs and failure behaviour; provider confirms an actual supported API. | Content quality and teacher review, minimum-data requests, consent/access isolation, unavailable/rate-limited service and safe failures. |
| External repositories | Product/content owners establish source API, licence, attribution, accessible formats, download/redistribution rights and withdrawal policy. No source is selected yet. | Real API/format compatibility, attribution, class/subject access, permitted caching and removed or inaccessible content. |
| Non-Android IVR/SMS | Product owner and telecom provider define availability, cost, consent, account identity on shared numbers, privacy, keypad/audio limits and delivery semantics. This requires a separate channel, not the Android APK. | Shared-number identity, accessible prompts, interrupted calls, undelivered/duplicate messages and truthful acknowledgments. |
| Offline graded quizzes | Education/product owners approve question protection, authoritative timing, accommodations, attempt identity, feedback release, expiry and conflict/grading rules. Backend/client owners agree a versioned synchronization and idempotency contract. | Restart/offline timing, duplicate synchronization, changed/revoked access, conflict resolution and no false completion/grading. |

Target phones/Android versions, classroom scale, performance/resource limits,
signing and distribution still require approval and measured evidence.
Physical-device tests and sessions with blind teachers/students have not been
run; automated checks do not establish accessibility certification or release
readiness. Learning journeys, checks, private notes and assessment changes have
software-level evidence below. Direct English-voice guidance, core magnified
reflow, private assessment readout and exclusive push-token ownership now have
automated evidence. Broader populated-route/dialog reflow and shared-phone speech/
identity coverage, device/operational thresholds and integrated release acceptance
remain unfinished. The user reconfirmed device models/hardware, classroom scale
and performance/distribution limits are not yet known; these gates remain blocked.

### Teacher classroom controls

In a live session teachers press **2** for the raised hands queue, **3** to
mute all students, **4** for the class list, **5** to start a quiz, journey
or recording, **6** for the status of what is running, **7** for **More**
(**1** add 15 minutes, **2** chat, **3** class status and summary) and **8**
to end the class (asks to confirm). The class
keeps running
underneath. The
class list offers who is here, who joined and left, who has not joined,
ringing everyone not yet joined, and the raised hands queue. The
raised hands queue provides:

- **Read classroom summary** on demand: the local connection state, last
  received participant/hand/microphone counts, requested class playback and
  private-preview state. Counts are not guarantees of media delivery.
  Remote reconnecting counts and active-speaker identification are explicitly
  unavailable; microphone flags are not evidence that someone is speaking.
- Server-persisted first-raised-first-served order for newly raised hands.
  Repeating Raise does not move a hand. Lowering, teacher acknowledgment,
  explicit leaving and removal clear it; raising again gets a new position.
  Brief event-stream reconnects preserve position. Existing hands whose age
  is unknown are labelled separately and displayed before known-order hands;
  their relative original order is not claimed.
- **Previous**, **Next** and **Read selected hand** without changing anyone's
  hand or microphone. A selected participant remains selected across list
  reordering. If that hand disappears, another hand must be explicitly
  selected before acknowledgment; it cannot silently become the next target.
- **Acknowledge and lower hand**, confirmed by the server, only for the
  selected current hand and owning teacher. A stale request cannot lower a
  newly raised hand. Pending duplicate actions are disabled; unreadable or
  failed acknowledgments retain the queue and expose a readable error in the
  dialog. Revision checks prevent older events/acknowledgments from replacing
  newer hand state. This action never unmutes anyone.
- **Stop speech**, **Repeat console help**, Back/hash and wrapping traversal
  in a scrollable dialog, with automated 240x320 and 1.5x text checks.

Leaving immediately mutes this phone and asks the server to clear its hand.
If that action is unconfirmed, a second dialog offers an explicit local-only
exit or staying to retry, rather than claiming that the hand was cleared.
A fresh join resets the hand and starts muted.

The queue requires the database migration described above.

### Learning journeys

A **learning journey** joins content and checking into one flow, replacing the
former teacher-only lesson plans. A teacher bundles recordings, narration read
by the phone, questions and polls in order, for example: *"Let us hear about
some food today"* (narration), a food story (recording), *"Which grain is in
the story?"* (question) and *"Have you eaten rice this week?"* (poll). A wrong
answer replays the part it came from, then asks again; after the allowed
tries the answer and explanation are read and the journey moves on. Polls have
no wrong answer. Live-session lesson plans were removed; the classroom
console and checks are unchanged. Standalone quizzes and playlists remain.

**Teachers** open **8: Learning Journeys** from the dashboard (workspace
required). Every screen is one small job with at most five numbered choices,
the same keys as everywhere else (0 back, 8 read details, star help, hash stop
speech) and a matching D-pad focus order, so blind teachers can author end to
end without touch:

- Home: 1 create, 2 drafts, 3 published, 4 archived, 5 refresh.
- A journey: 1 hear and edit steps, 2 add a step, 3 preview as a student,
  4 publish (or results when nothing is unpublished), 5 more options
  (results, rename, grading and tries, duplicate, archive/restore/delete).
- Each step: hear in full, edit, move earlier/later (spoken new position),
  remove with confirmation. Moving or removing keeps each question's replay
  point on the same content, or falls back to automatic.
- Adding a step is a guided sequence of single-field screens with a read-back
  before saving. Recordings can be picked from your library, uploaded, or
  recorded through Private notes and published to the class. Questions can be
  written (2-4 options) or taken from your question bank. A question replays
  automatically from the first recording or narration since the previous
  question, or from a step you choose.
- Publishing first reads a summary with blocking problems (for example a
  missing recording, or grading with no question) and warnings (no
  explanation, nothing to replay), then needs confirmation. Students get a
  notification. Later edits stay in the draft until published again.
- Results read a class summary, each student, each question's first-try rate
  and average tries (which content needs teaching again) and poll tallies.

**Students** open **6: Learning Journeys**: 1 continue the last journey,
2 new, 3 in progress, 4 completed, 5 downloaded (opens without internet).
A journey can be started, described, downloaded or restarted. In the player:

| Step | Keys |
|------|------|
| Recording or narration | 1 where am I, 2 next step, 3 repeat step, 4/6 back/forward 10 seconds, 5 play/pause, 7/9 slower/faster, 8 previous recording or narration |
| Question or poll | 1-4 choose (read back), 5 submit, 6 repeat question, 7/9 quiz speech speed, 8 where am I |
| Finished | 1 play again |

0 leaves with confirmation; the place is saved on the phone. A recording that
finishes moves on automatically and the next step is announced. The finished
summary reads the first-try score.

**Offline and sync.** A download saves the published version and every
recording on the phone, sharing the account's 50 MB allowance, integrity checks
and 30-day access of downloaded lessons. Removing a journey keeps recordings
still used by another downloaded journey. Progress and answers are saved per
account after each step and queued; they are sent when the journeys screen
opens or a journey ends with internet. The server recomputes correctness and
scores from the exact published version played, ignores device judgments,
accepts repeats of the same run idempotently and rejects runs from other
accounts or impossible answers.

**Grading.** Ungraded by default. A graded journey's score is the share of
questions answered correctly on the first try in the student's first finished
run; replays help learning but do not raise it. Because answers are on the
phone to allow offline replays, graded journeys suit low-stakes checks; use
the Quiz module for protected assessments.

Automated tests cover the engine (replay, retries, polls, resume), offline
queueing and downloads, keypad menus, the player key flow, confirmation on
leaving, and 240x320 at 1.5x text. Before release, check on a physical keypad
phone, with TalkBack on and off: a blind teacher authors and publishes a
five-step journey without touch; a student plays it in airplane mode after
downloading, answers wrongly to hear the replay, leaves and resumes, then
reconnects and the teacher sees the results.

### Private recorded notes and reviewed teacher publication

**Private notes** is reachable from the recorded library even while its
online request stalls. **Private study notes** in class/playlist learning
controls captures the lesson and timestamp at activation and pauses the
lesson before opening the notes screen. No microphone recording starts from
opening a screen, playing a lesson, or joining a session.

- Recording requires a name, explicit confirmation and microphone permission.
  It is foreground-only and blocked while any live-session screen is mounted.
  Explicit Stop, leaving the screen, app interruption, or app narration stops
  capture. Native Android capture also stops on pause. A recording cannot
  automatically restart after interruption.
- Each note lasts at most five minutes. Notes and unpublished teacher drafts
  share a separate **10,000,000-byte per-account** allowance, additional to the
  50 MB lesson-download allowance. Partial/orphan audio counts toward usage.
  Nothing is automatically evicted. If finalization or storage fails, the
  incomplete file is retained and cannot be played or published as a saved
  note; selected recovery/removal is available.
- Notes are stored in the account's app-private learning directory, excluded
  from backup/transfer with the existing learning-data exclusions. They are
  retained across logout and isolated from other accounts. Student notes
  stay on this phone and are never offered for upload.
- Review uses the actual local media file. Rename and selected deletion are
  keypad-accessible; deletion requires confirmation and preserves other
  notes, progress, bookmarks and downloads.
- Only teachers are offered Publish, after successful local review in the
  current visit. They must select an authorized class/subject workspace and
  explicitly confirm publication. Existing authenticated upload/access
  rules apply. The returned recording/workspace/teacher identity must match
  before success is announced. An ambiguous upload may already have reached
  the server: check the library before retrying to avoid duplicate recordings.
- Published notes inherit class authorization, download limits and thirty-day
  offline access. Disconnected copies cannot be instantly revoked. Publishing
  never silently removes the local draft; deleting that draft does not delete
  the online recording or someone else's downloaded copy.

Automated tests exercise account/quota boundaries, interruption/late-start
races, native local playback, selected deletion, publication confirmation and
240x320 layouts at 1.5x text. A debug build does not establish microphone
quality, storage reliability or accessibility on physical target phones.

## Quiz module

### Teacher workflow

Each teacher has a private question bank scoped to an active assigned
class-subject workspace. A bank question contains exactly four different,
non-empty options and one correct answer. It may include an explanation.
Teachers can search, edit, archive, and duplicate their questions. Adding a
bank question to a quiz creates a quiz-owned snapshot, so later bank edits
never rewrite published content or student records.

Questions may include up to 20 distinct teacher-entered topics/concepts (80
characters each). Teachers can declare English plain text or described
notation/diagrams. Described content requires a teacher-written spoken question,
all four spoken options, a spoken explanation when an explanation is supplied,
and explicit teacher review. Editing the content clears the review checkbox.
There is no automatic equation or diagram interpretation. The original text
remains visible; question speech, option replay, answer feedback and review
semantics use the reviewed alternatives. Shuffled options retain their own
spoken descriptions.

New bank questions start at revision 1. Each saved revision retains its content;
new clients send the expected revision to reject stale edits. Quiz creation,
bank attachment and duplication copy metadata and source revision into frozen
snapshots. **Read question revision history** is private to the owning teacher,
read-only, and navigates older/newer versions in bounded pages. Existing legacy
revision numbers and pre-tracking history are unknown, not invented.

From **Teacher Dashboard > Quizzes & Question Bank**, a teacher can:

1. name a graded quiz or choose the separate ungraded-practice entry;
2. optionally expand settings for description, attempt limits (1-20),
   scheduling, timing (1-1440 minutes), feedback release and independent shuffle;
3. continue to a guided draft, write a question or choose one from the bank;
4. add further questions or remove a mistaken addition with confirmation;
5. review the settings, complete questions, correct answers and explanations;
6. separately confirm Publish, or save for later without publishing;
7. manually close a published quiz or duplicate any quiz into a new draft; and
8. open a results dashboard with class statistics, every student's individual
   attempt scores, and the names of students who have not attempted; and
9. send one reminder notification to all students who have not attempted.

**Create untimed practice** is separate from graded creation. Practice has
unlimited retries, no per-attempt timer and immediate answer feedback. Optional
opening/closing availability still applies. Practice completion and learning
feedback are not presented as academic grades in student history or class
reports. Existing graded attempt limits and published quiz behaviour are
preserved.

Graded creation starts with one attempt, no timer and feedback after completion.
The title is the only initial field; optional settings are collapsed, not
removed. Question entry starts with the question, four options and a separate
correct-answer selector; explanation, topics and reviewed spoken notation are
available under an optional section. Existing metadata automatically expands
when editing. New quiz questions are saved atomically to the draft and reusable
private question bank. Draft cards reopen **Continue creation**, not Publish.
Unconfirmed question saves block another add until an authoritative Refresh,
avoiding accidental duplicates. Review and publication remain separate steps.

For a timed graded quiz, the owning teacher may set a student's nonnegative
whole extra minutes from results; zero removes that future allowance. Only
eligible students in the authorized workspace can be changed. The allowance
and effective deadline are frozen when a new attempt starts and capped at quiz
close. Changing it never extends or shortens an existing attempt.

Drafts are private to their owner. Publication requires an active teacher
assignment, an active class-subject association, and at least one valid
question. Publishing immediately attempts delivery to every enrolled student
with a registered device token and reports successful or failed device
deliveries to the teacher. Published or attempted academic records are
retained. Only an unattempted draft can be deleted; material revisions use
duplication.

### Student workflow and grading

Students see published quizzes only for their current active class and active
subjects. Closed quizzes remain listed only when that student previously
attempted them. Historical review intentionally follows current
class-membership rules: transferring a student prevents access to the old
class, while retained database records remain available to the owning teacher.

Starting a quiz resumes an existing in-progress attempt. Otherwise the server
enforces scheduling, closure, and the attempt limit before creating the next
one-based attempt. When the attempt limit is exhausted, the quiz card no longer
offers a start action and directs the student to attempt history instead.
Question and option order is generated once and stored.
The effective deadline is the earlier of the per-attempt limit and quiz close
time. Device clocks and client countdowns are not authoritative.

Answers require explicit submission and are final after the server accepts
them. Practice releases immediate feedback. New graded quizzes default to
feedback after final submission; teachers can instead choose scheduled release
or score-only. Scheduled scores/keys require both finalization and the server
release time. Score-only never releases answer keys or explanations to the
student. Until release, an answer is **saved and locked**, not falsely marked
incorrect. The backend enforces these rules on answer, completion, listing,
history and review responses, including spoken alternatives. The owning
teacher retains private results access. Existing quizzes retain their explicit
legacy immediate-feedback policy; duplicating one creates a new-policy draft.

Unanswered graded questions receive zero. The backend stores
the correct count, total, and percentage rounded to two decimal places using
decimal half-up rounding. A student's primary score uses their highest released
completed or timed-out graded attempt. The owning teacher's private class reports
use each student's highest final graded attempt regardless of student release
time, while retaining every attempt. Practice has no academic
percentage/highest-score aggregate.

### Quiz accessibility controls

Quiz screens reuse the application keypad wrapper, focus order, confirmation
dialogs, high-contrast palette, text scaling, semantics, and TTS service.
Touch, pointer, Tab/Shift+Tab, D-pad arrows, and OK/Enter remain available.

- Teacher dashboard: **6** opens Quizzes & Question Bank.
- Student dashboard: **5** opens Quizzes.
- Guided draft: **2** writes a question, **3** reuses a bank question,
  **4** removes a saved question with confirmation, **6** opens review and
  **0** saves for later/returns. In review, **5** changes the title or optional
  settings without publishing, and **8** requests Publish confirmation;
  Back to adding questions remains reachable by D-pad/OK or touch.
- During an attempt: **1–4** select an option, **5** explicitly submits it,
  **6** repeats the question and options, and **8** says where you are and
  the time left. Once the server confirms the answer is saved, the next
  question (or finishing) follows automatically; it cannot finish an
  unanswered question. Correct or wrong is never spoken aloud automatically,
  so classmates cannot overhear: the previous answer's feedback stays
  available privately on the next question. Choosing an option never
  automatically submits.
- **Finish quiz now** (a D-pad item) requests early final submission. The
  app first checks the server's current saved-answer count, then confirms
  unanswered questions, saved-only answers and irreversibility. An
  unavailable/unverified count blocks this action rather than guessing from
  stale local state.
- Back, hash, **0** and the app-bar Back control offer **Leave without
  submitting** for active attempts. An unsaved selection may be lost; timers
  continue, and resume remains subject to server availability and authorization.
- After completion: **0** or **6** returns to the Quizzes screen and **8**
  reads the result privately.
- Outside text editing, **star** repeats the current screen instructions
  and **hash** goes Back.
- D-pad arrows move through controls; OK/Enter activates the focused control.
- The question prompt comes before the options in spoken focus order.
  Focusable controls read all options, the selected answer and saved status,
  remaining time, or stop speech. Returning to the feedback region and
  pressing OK repeats the explanation.

Question and quiz authoring dialogs use the same interaction model. Up and
down move through every field and action, OK enters text editing, and up or
down leaves editing. Bank-question options are entered as four separate fields;
the correct answer is then chosen in a separate required selector, avoiding an
implicit default answer. Quiz opening and closing controls announce whether a
time is unset, open a keypad dialog for year, month, day, hour (24-hour clock)
and minute, restore focus after selection, and support left-arrow clearing.
The dialog validates real calendar dates and the existing allowed range;
entry is in local time and submission remains UTC. Visible **Options** buttons
replace three-dot menus for question-bank actions; their dialogs expose every
action in deterministic D-pad order. Quiz cards, the results dashboard,
student score entries, bulk reminders, result history, and answer review are
all D-pad reachable and expose complete spoken semantic labels.

Selecting or focusing an option never grades it. After confirmed submission,
focus moves to a live feedback region. Correctness is communicated with text,
an icon, semantics, and speech rather than color alone. Connectivity failures
retain the local selection and do not show success until the server confirms
the response. Failed or malformed completion responses preserve saved
feedback and expose **5: Retry completion**, rather than announcing a result.
An in-progress attempt resumed with every answer already saved also exposes
**5: View result** without requiring another answer submission.

A teacher's saved questions can be reused in any number of quizzes,
including quizzes for their other classes and subjects. **Choose a saved
question** lists this class and subject first and names the class and subject
of the others. Each quiz keeps its own copy, so editing the saved question
later never changes a quiz that already uses it.

### Quiz migration and retention

Existing installations must apply the quiz migration:

```powershell
.\.venv\Scripts\Activate.ps1
alembic upgrade head
```

Revision `20261013_02` creates normalized bank, snapshot, attempt, option, and
response tables plus workspace, status, student, and partial active-attempt
indexes. It follows `20261013_01`, supports PostgreSQL and the SQLite test
suite, and preserves class, subject, user, assignment, and prior application
data. Quiz owners and attempt students may become null when users are removed,
but attempts, responses, scores, and snapshots are restricted from cascading
deletion.

Apply through head `20261020_08` before running this version. Migration tests
verify preservation of a legacy published quiz, wording, immediate-feedback
policy, unknown revision metadata and an existing user's password hash and
baseline sign-in state. Back up the database before migration;
downgrading the new revisions drops their policy/metadata/history tables or
columns and is not a data-preserving rollback.

Do not downgrade the recovery revision while temporary credentials or restricted
sessions remain active: older code cannot enforce forced change, temporary
expiry or authentication-version revocation. Resolve those accounts and approve
a session-invalidation/rollback procedure before deploying older code. The
configured database has not been upgraded by this implementation work.
Downgrading revision `20261020_08` removes the exclusivity constraint but cannot
restore revoked ambiguous links; users must re-register their devices after
signing in. Do not use a rollback to reintroduce multi-account token associations.

Ending a live session closes it for all connected participants and marks it
ended; it does not delete the session. A class also ends automatically at its
safety cutoff (see [Interaction-reduction model](#interaction-reduction-model)).
Ended classes are backend records only: teachers have no history, reactivation
or deletion screens. Administrators read records in **Class records**
(`GET /admin/sessions`); a new lesson is always a new occurrence.

## Session logging

### Analytics dashboard and local queries

The separate [Flutter analytics dashboard](analytics_dashboard/README.md)
targets web and Android. It reuses existing admin/teacher accounts, accepts
English text and reviewed English voice transcripts, and supports ordinary
teacher/student/class/subject names rather than requiring database IDs.
Numbers come from parameterized backend queries; the model only proposes a
validated metric/filter intent. Students are denied. Teachers remain restricted
to currently assigned class-subject pairs AND their own resources.

Apply Alembic migrations before enabling the disabled-by-default flags in
[.env.example](.env.example); `create_all` does not upgrade existing tables.
See the [analytics deployment section](BACKEND_DEPLOYMENT.md#analytics-and-local-query-services).

- `POST /analytics/query`: question OR structured `intent`.
- `GET /analytics/catalog`: bounded scoped name lookup.
- `GET /analytics/health`: admin request/error charts and service state.
- `POST /analytics/transcribe`: authenticated campus English transcription.
- `POST /activity/events`: bounded, deduplicated client event ingestion.

Example (works without a model):

```json
{"intent":{"metric":"sessions_created","teacher":"Teacher X","subject":"Subject Y","class_name":"Class Z"}}
```

Default reports cover the last 30 days, displayed as Asia/Kolkata. Explicit
timestamps need an offset; educational `all_time` covers retained records only.

**Session semantics:** ending/reopening preserves the original creation
identity. `sessions_created` counts it once; `session_openings` counts each run.
Attendance records authenticated student SSE connections, not enrollment,
invitations or teacher-added rows. Reconnects do not inflate unique students.
Ambiguous old participant/log rows are not backfilled as attendance.

**Quiz semantics:** `quiz_average` averages finalized graded attempt percentages
equally, including timeouts and excluding practice/in-progress attempts.
The existing quiz `average_highest_score` is unchanged.

**Retention:** logs/activity cover 30 days. Attendance and finalized
attempts/responses expire 18 calendar months after run end/finalization.
Session deletion retains minimal title-free history; explicit administrative
erasure removes identity-linked analytics. Reopening does not extend an older
run's expiry. Self-listen log history becomes a 30-day view.

ORM mutations receive transaction-coupled, content-free events; live controls
and external effects have separate observed outcomes. Passwords, tokens, chat,
question/answer bodies, private notes and bookmark labels are excluded.
Private-playlist operations expose only global admin counts.

Build the learning app with `--dart-define=TELEMETRY_ENABLED=true` only after
the notice/server ingestion are ready. Approved bookmark, seek/speed/repeat/
completion, download and settings actions use a bounded per-account queue.
They are `client_reported`, not verified learning/attendance. Missing, expired
or revoked offline uploads are coverage gaps; notes are never instrumented.

Local adapters support Ollama and OpenAI-compatible llama.cpp/Foundry Local
endpoints. **Qwen is a model, not an alternative to Ollama.** Foundry Local
shared-server suitability and exact model quality require campus benchmarks;
no Azure deployment or automatic cloud fallback is included.

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
