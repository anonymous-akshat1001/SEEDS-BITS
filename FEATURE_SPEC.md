# SEEDS Feature Specification

## Document status

**Status:** Draft — Bug Fixes scope defined  
**Scope in this revision:** Section 1 only. The Agentic AI and content-repository sections will be added after their source material and requirements are provided.  
**Primary evidence:** `v1 - SEEDS APK Testing Report .pdf` and `v2 - SEEDS Testing Report.pdf` (July 2026), reconciled against the current source tree.

## Product context

SEEDS is a Flutter client with a FastAPI/PostgreSQL backend for accessible learning sessions, audio content, TTS, voice commands, and physical-keypad use on low-spec Android button phones. The v2 test target is a BlackZone Android button phone with both keypad and touchscreen.

The product requirement for this workstream is that all core student and teacher journeys must be operable through the physical keypad without requiring touch: onboarding, registration, login, settings, dashboard actions, session joining, and safe exit/logout.

## 0. Existing SEEDS product vs. target application

This specification applies to the **target application in this codebase**, which is being expanded into a dashboard-based accessible learning platform. It is distinct from the already existing SEEDS application described below.

| Capability | Existing SEEDS application | Target application in this codebase |
|---|---|---|
| Student interaction | No student dashboard; an IVR system rings the student’s phone, through which the student listens to audio or plays quizzes. | Student dashboard in the Flutter app, with accessible navigation, content access, quizzes, and personalized learning features. |
| Content access | Relies on the integrated content repository; the existing product is expected to have this integration by mid-September. | Keeps manual teacher upload and adds an IIIT Bangalore repository browser/assignment flow for Subodha/Antara content. |
| Quiz capability | Already includes a quiz section through its existing interaction model. | Adds topic-wise dashboard quizzes from teacher-authored and authorized repository questions, with accessible attempt and progress flows. |
| Agentic AI | Not present. | Adds API-only integration with the IIIT Bangalore Agentic AI for course planning, personalized learning, and privacy-preserving progress summaries. |
| Teacher audio upload | A teacher cannot independently upload audio; content is repository-dependent. | A teacher can continue to upload/manage their own content and can additionally assign approved repository content. |

The two applications should not be assumed to share implementation, authentication, content-entitlement, or IVR behavior. Any future interoperability requirement (for example, shared repository content, quiz outcomes, or student identity) must be specified and approved as a separate integration contract.

## 1. Bug Fixes

### 1.1 Goals

- Restore a reliable keypad-only path through all core flows.
- Remove raw technical errors from user-facing UI and TTS.
- Make launch and exit states understandable on low-spec devices.
- Correct app branding in the installed Android app.
- Preserve the fixes verified in v2: role routing, high contrast mode, password visibility, back-button TTS behavior, and `*` to repeat instructions.

### 1.2 In scope

| ID | Priority | Requirement |
|---|---|---|
| BF-01 | P0 | Reliable global keypad-event handling and explicit focus traversal |
| BF-02 | P0 | Keypad-only registration and login |
| BF-03 | P0 | Keypad-only Settings access and operation, including no focus trap on sliders |
| BF-04 | P0 | Reliable student and teacher dashboard shortcuts |
| BF-05 | P1 | Accessible TTS coverage for static/home and settings content |
| BF-06 | P1 | Plain-language validation and session-join errors |
| BF-07 | P1 | Visible, accessible startup/loading state and reduced perceived launch delay |
| BF-08 | P1 | Explicit logout with confirmation; no accidental logout on dashboard back navigation |
| BF-09 | P2 | Android application branding: `SEEDS`, not `frontend` |
| BF-10 | P2 | Accessibility contrast and settings-feedback improvements |

### 1.3 Explicitly excluded from this bug-fix scope

- Offline content availability after initial load. This is a product/content-delivery capability, to be specified with content repositories.
- Regional-language support. This is a future accessibility/localization workstream.
- APK distribution friction caused by Android/Google Drive unknown-source protections. The app can improve its own name and release package, but cannot bypass device security policy.
- SIM-card detection behavior. The v2 test had no SIM; the report identifies its warning as expected behavior. Product owners must decide whether SIM detection is needed for any core flow.
- New Agentic AI capabilities.

### 1.4 Requirements

#### BF-01 — Establish reliable keypad events and focus traversal

**Problem.** D-pad focus movement does not work across home, login, and registration. On dashboards, digit shortcuts work intermittently. The shared `KeypadInstructionWrapper` currently ignores every key whenever a text field has focus; the device can therefore consume a shortcut as T9/punctuation input. This directly explains the `1`-key registration conflict and dashboard unreliability.

**Required behavior.**

- The app must define and use a single keypad-input policy across all screens.
- D-pad Up/Down/Left/Right moves focus only among visible, enabled controls in a predictable reading order; Enter/Select activates the focused control.
- Focus must be visually apparent and announced by TTS for low-vision and non-visual use.
- Screen-level numeric shortcuts must be handled before they can be interpreted as T9 text input, except when the field explicitly needs that digit as entered text.
- Each input flow must provide an unambiguous mode/gesture for switching between entering field content and invoking screen shortcuts. The chosen interaction model must be documented in in-app instructions and must not rely on timing-sensitive long presses.
- `*` repeats the current screen’s instructions. `#` remains the documented leave/back action only on screens that explicitly support it.
- No widget, including `Slider`, may permanently capture D-pad focus; focus must always be able to move away.
- Enable the existing keypad debug overlay for device QA builds, but exclude it from release builds.

**Likely implementation area.** `frontend/lib/widgets/key_instruction_wrapper.dart`, `frontend/lib/utils/keypad_config.dart`, individual screen FocusNodes/actions, and reusable focus/semantics helpers.

**Acceptance criteria.**

- On the BlackZone phone, every tested physical key is handled deterministically in 30 consecutive attempts per screen.
- No announced shortcut opens a T9 symbol picker or adds unwanted text.
- A tester can move through every interactive element on welcome, login, registration, settings, student dashboard, and teacher dashboard without touching the screen.

#### BF-02 — Make registration and login keypad-only workflows complete

**Problem.** Registration and login fields require touch to change focus; registration’s announced `1: Register` action can open the phone’s punctuation picker.

**Required behavior.**

- Registration: user can enter name, phone, and password, toggle teacher/student, submit, receive validation errors, and reach login using keypad only.
- Login: user can move between phone/password/role controls, show or hide password, submit, receive credential errors, and return to registration using keypad only.
- Form validation occurs locally where possible (required fields, phone format, password minimum length) before an API call.
- Submission controls use a semantic button/Enter activation path as the primary completion mechanism; numeric shortcuts must follow the global policy in BF-01.

**Likely implementation area.** `frontend/lib/screens/register_screen.dart`, `frontend/lib/screens/login_screen.dart`, and `key_instruction_wrapper.dart`.

**Acceptance criteria.**

- A new student and a new teacher can independently register and then log in with keypad only.
- Wrong role selection, invalid credentials, and invalid fields are stated clearly through both visible text and TTS.
- The password never arrives prefilled and can be revealed/hidden by an accessible control. (Regression check: already fixed.)

#### BF-03 — Make Settings fully reachable and prevent slider traps

**Problem.** Settings is not reachable from the welcome screen via keypad. Within Settings, D-pad navigation scrolls but does not traverse controls and becomes trapped at Audio Sync Tolerance.

**Required behavior.**

- Add a keypad-reachable Settings action from the welcome screen and announce it in that screen’s instruction list.
- Settings controls participate in a defined D-pad focus order.
- TTS toggle, voice-command toggle, high-contrast toggle, volume, speech rate, sync tolerance, reset, save, and back are all reachable and operable without touch.
- On each slider adjustment, TTS announces the setting name and current value. For example: “Speech rate, 0.5” and “Volume, 80 percent.”
- Audio Sync Tolerance has clear plain-language helper text explaining what it changes, or is hidden until the associated advanced-audio feature is available.
- Voice-command settings describe the supported commands and whether the feature is available on the device.

**Likely implementation area.** `frontend/lib/main.dart`, `frontend/lib/screens/settings_screen.dart`, `frontend/lib/utils/keypad_actions.dart`, focus helpers.

**Acceptance criteria.**

- A user enters Settings, changes each control, saves, returns home, reopens Settings, and verifies persistence with keypad only.
- D-pad navigation can always leave every slider in either direction.
- Changes in volume/speech rate are announced at the time they are made, not only after Test TTS.

#### BF-04 — Stabilize student and teacher dashboard shortcuts

**Problem.** Dashboard keys `1`, `2`, and `3` respond inconsistently. This blocks the core student flow on button phones.

**Required behavior.**

- Student dashboard shortcuts: Refresh Sessions, focus/enter Join Session by ID, and Offline Audio Library must always work.
- Teacher dashboard shortcuts: Refresh Sessions, Create Session, and Offline Audio Library must always work.
- Shortcuts must still work after returning from a pushed page, after loading finishes, and after a text field loses focus.
- When Join Session is selected, focus moves to its input field and there is an announced, keypad-only way to submit the entered ID.
- Session cards and their Join actions must be reachable in focus order.

**Likely implementation area.** `frontend/lib/screens/student_dashboard.dart`, `frontend/lib/screens/teacher_dashboard.dart`, `key_instruction_wrapper.dart`.

**Acceptance criteria.**

- Each dashboard shortcut succeeds in 30 consecutive presses on the target device.
- A student joins a known active session entirely through the keypad.
- Refresh provides visible/TTS loading and result feedback without losing focus.

#### BF-05 — Complete TTS coverage and clarify controls

**Problem.** TTS does not read static home content when tapped; settings helper text and available voice commands are not sufficiently discoverable.

**Required behavior.**

- The SEEDS logo, “Connecting everyone, everywhere” subtitle, and feature cards on the welcome screen expose meaningful semantic labels and speak their associated text when focused/activated.
- All non-decorative icons have accurate semantic labels. In particular, the audio-player sound/TTS icon must not be confused with a mute control.
- Voice-command help lists the exact supported commands per relevant screen and is read by TTS.
- Secondary text must meet contrast and readable-size requirements in both normal and high-contrast modes.

**Likely implementation area.** `frontend/lib/main.dart`, `frontend/lib/screens/settings_screen.dart`, `frontend/lib/screens/session_screen.dart`, `frontend/lib/utils/ui_utils.dart`.

**Acceptance criteria.**

- Tapping or focusing every informational home element yields a useful TTS announcement.
- A tester can identify the purpose of every visible icon using semantics/TTS.
- Dashboard teacher names and settings helper text pass the agreed contrast target (WCAG AA: 4.5:1 for normal text).

#### BF-06 — Replace raw API/HTTP errors with user-facing messages

**Problem.** Password validation displays FastAPI’s raw JSON/Pydantic error. Invalid session IDs display “Failed to join session: 404.”

**Required behavior.**

- Add a centralized API-error mapper that converts known HTTP responses and FastAPI validation details into concise UI/TTS messages.
- Registration password errors must say “Password must be at least 6 characters.”
- Invalid/nonexistent session IDs must say “Session not found. Check the session ID and try again.”
- Unknown/network errors must use a safe generic message, such as “We could not complete that request. Check your connection and try again.”
- Raw JSON, stack traces, endpoints, and status codes must be logged only in debug logs—not shown or spoken to end users.

**Likely implementation area.** `frontend/lib/services/api_service.dart`, `frontend/lib/screens/register_screen.dart`, `frontend/lib/screens/student_dashboard.dart`, and other callers that show server `detail` directly.

**Acceptance criteria.**

- A password under six characters never displays serialized JSON.
- A dummy session ID produces the specified friendly error, in both Snackbar and TTS.
- Simulated 400, 401, 404, 422, 500, and network-failure responses have reviewed user-facing messages.

#### BF-07 — Provide an accessible launch state

**Problem.** On the test phone, the app shows a blank white screen for approximately 28 seconds before Flutter draws the welcome screen.

**Required behavior.**

- Android launch UI must display SEEDS branding and a clear loading indicator/message from process launch until the first Flutter frame.
- The first Flutter screen must provide an accessible loading state while Firebase, notifications, environment configuration, and preferences initialize.
- Startup work must be profiled on the BlackZone device. Non-critical work (for example, notification registration) must not delay the first usable welcome screen.
- The solution must be compatible with a slow/no-network first launch and not leave a blank, silent state.

**Likely implementation area.** `frontend/lib/main.dart`, `frontend/android/app/src/main/res/drawable/launch_background.xml`, Android launch theme/resources, notification initialization flow.

**Acceptance criteria.**

- There is no blank unbranded screen during a cold launch.
- A visible indicator is present immediately, and an accessible “SEEDS is loading” announcement occurs once TTS is available.
- Record cold-launch time on the target device before and after; target a first usable screen within 8 seconds where network/device conditions allow. If this cannot be achieved, retain feedback continuously and document the measured bottleneck.

#### BF-08 — Add intentional logout and safe back behavior

**Problem.** Pressing Android Back from either dashboard immediately logs the user out, with no visible Logout control or confirmation.

**Required behavior.**

- Add an accessible Logout control on student and teacher dashboards.
- Invoking Logout requires confirmation: “Log out of SEEDS?” with Cancel and Log out actions, available via touch and keypad.
- Android Back from a dashboard must not silently erase login state. It should either exit/minimize the app while preserving the session or show the same confirmation; the selected policy must be consistent across both dashboards.
- On confirmed logout, clear auth/session preferences, stop any sensitive background session state, navigate to welcome/login, and announce completion.

**Likely implementation area.** `frontend/lib/screens/student_dashboard.dart`, `frontend/lib/screens/teacher_dashboard.dart`, authentication/session-preference helpers.

**Acceptance criteria.**

- Back cannot log a user out without an explicit confirmation.
- Cancel preserves login state and returns focus to the originating dashboard control.
- Confirmed logout prevents access to authenticated screens through back-stack navigation.

#### BF-09 — Correct app branding

**Problem.** The installed app and Android app drawer show `frontend` rather than `SEEDS`.

**Required behavior.**

- Android application label is `SEEDS` in install confirmation, launcher/app drawer, recents, and system settings.
- Update equivalent iOS/macOS metadata for consistent cross-platform branding where applicable.
- A release build must have a versioned, distributable file name (for example, `SEEDS-v0.3.0.apk`) in the release process.

**Likely implementation area.** `frontend/android/app/src/main/AndroidManifest.xml`, platform metadata, release pipeline.

**Acceptance criteria.**

- Fresh installation and app drawer both display `SEEDS`.

#### BF-10 — Accessibility polish and regression protection

**Problem.** Secondary text uses low-contrast grey; the v2 report identifies several prior fixes that must not regress.

**Required behavior.**

- Increase contrast/size of teacher names on active sessions and all helper/subtitle text used for instructions.
- Honour Android system font scaling where practical; layouts must remain usable at the agreed enlarged font scale.
- Retain verified behavior: high contrast visibly changes all major surfaces, `*` repeats screen instructions, password fields are blank by default, eye icons work, and back transitions do not cut off TTS.

**Likely implementation area.** `frontend/lib/utils/ui_utils.dart`, dashboard/settings widgets, Android accessibility test configuration.

**Acceptance criteria.**

- Visual review on BlackZone and at Android font scale 1.3x finds no clipped core label or inaccessible low-contrast instructional text.
- Regression suite passes the v2 “fixed” issues.

### 1.5 Delivery order

1. **Foundation:** BF-01. Decide and document the keypad interaction model; instrument QA logging.
2. **Core journeys:** BF-02, BF-03, BF-04. Validate full keypad-only student and teacher journeys on the physical device.
3. **User feedback and safety:** BF-06, BF-07, BF-08.
4. **Accessibility and packaging:** BF-05, BF-09, BF-10.

No feature work that introduces a new primary navigation path should be merged before BF-01 through BF-04 are complete, because all later work must use the same accessible keypad/focus foundation.

### 1.6 Test plan and release gate

#### Required test environments

- BlackZone button phone: physical keypad and touchscreen.
- One mainstream Android touchscreen device.
- Flutter widget tests for error mapping, focus traversal where feasible, and logout confirmation.
- Manual cold-launch timing on a clean/restarted BlackZone device.

#### Release-critical end-to-end scenarios

1. Cold launch: branded loading feedback → welcome instructions → `*` repeats.
2. Keypad-only student registration → login → dashboard → join known session → leave → safe dashboard exit/logout.
3. Keypad-only teacher registration → login → create session → open audio library → safe dashboard exit/logout.
4. Keypad-only Settings: reach every control, change/save/persist each value, and escape every slider.
5. Error paths: short password, wrong password, missing session, bad network.
6. Accessibility regression: high contrast, TTS labels, font scale, password visibility, and back-navigation speech.

#### Exit criteria

- All P0 requirements pass on the physical BlackZone device with no touch input.
- No raw technical server error is visible or spoken in the tested flows.
- No blank silent launch state; launch timing and startup bottleneck are documented.
- Android launcher name is SEEDS.
- Product owner signs off on the logout/back policy and the final keypad interaction policy.

### 1.7 Decisions needed from product owners

1. What exact keypad model should be used while a text field is active: dedicated “input mode,” a modifier key, or focus/Enter-based submission? This must avoid conflicts with T9 digit entry.
2. On dashboard Back, should the app minimize while preserving login, or show the logout confirmation? This specification supports either but prohibits silent logout.
3. Should Audio Sync Tolerance remain user-configurable? If yes, provide the intended plain-language explanation and safe range.
4. Which voice commands are officially supported today, and on which screens/devices?
5. What Android versions and device classes are official support targets, beyond the tested BlackZone phone?

## 2. Agentic AI Integration

### 2.1 Purpose and scope

SEEDS will integrate the Agentic AI developed by the MSR and A4I teams at IIIT Bangalore. The Agentic AI is an external learning service; SEEDS must remain a lightweight client. It will call the service’s APIs and render the resulting learning, planning, and progress experiences. SEEDS will not host, fine-tune, or execute an AI model locally.

The integration supports two distinct roles:

- **Teachers** plan coursework, provide its structure/materials, and receive curated ways to explain concepts accessibly and engagingly.
- **Students** learn concepts through interactive, personalized guidance that adapts to their current understanding.

Teacher visibility into student learning must be privacy-preserving. Teachers may see progress and a derived summary of learning conversations, but never the students’ raw chat messages or transcripts.

### 2.2 Threshold learning

**Threshold learning** is an instructional approach that identifies the concepts a learner must understand before they can make meaningful progress in a subject. These “threshold concepts” are often difficult, transformative, and foundational: once understood, they change how a learner understands related material; when not understood, they can block progress across many later topics.

For SEEDS, threshold learning means the agent should:

1. map a course into prerequisite concepts and threshold concepts;
2. assess a learner’s current understanding through interaction and learning signals;
3. identify likely conceptual barriers rather than merely scoring answers;
4. provide explanations, examples, questions, and alternative representations appropriate to the learner’s needs; and
5. record concept-level progress so that the learner and teacher can see what is understood, in progress, or needs support.

This is helpful because it lets students address the specific conceptual gap preventing progress, while teachers can adapt teaching plans around common barriers without needing access to private student conversations. It also aligns with SEEDS’ accessibility goal: an explanation can be presented in different forms and at different paces rather than assuming one format works for every learner.

### 2.3 Product principles

- **External-service first:** All agent inference, orchestration, coursework curation, and chat processing occur in the IIIT Bangalore service.
- **Lightweight SEEDS integration:** Flutter presents the experience; the SEEDS backend handles identity, authorization, request mediation, and minimal application data only.
- **Privacy by design:** Do not store, expose, or log raw student-agent chats in SEEDS. Teacher-facing data is limited to approved, de-identified/aggregated progress and summary fields from the external service.
- **Accessible interaction:** The AI experience must support TTS, high contrast, focus/D-pad navigation, keypad instructions, and clear error states. It must not weaken the P0 keypad foundation defined in Section 1.
- **Teacher retains control:** Agent-curated material is suggested content. A teacher can review, edit, approve, publish, revise, or withdraw it before students receive it.
- **Transparent limitations:** The UI states that the assistant is an AI learning aid, may be inaccurate, and should be used alongside teacher/course materials. It must provide an accessible route to report a problematic response.

### 2.4 User journeys

#### Teacher: course planning and curation

1. A teacher opens **AI Course Planning** from the teacher dashboard.
2. The teacher creates or selects a course/session context and provides the subject, class/level, learning outcomes, syllabus/course structure, and optional source materials or repository references.
3. SEEDS submits the authorized coursework request to the Agentic AI API.
4. The agent returns a proposed concept map, prerequisite/threshold concepts, suggested sequence, explanations, activities/questions, and accessible presentation suggestions.
5. The teacher reviews and edits the proposal, then explicitly publishes selected material to the relevant student cohort/session.
6. Students receive only teacher-published learning paths/materials, plus their own personalized agent interactions.

#### Student: personalized concept learning

1. A student opens **AI Learning Assistant** from the student dashboard.
2. The student selects an available course/topic or resumes their personal learning path.
3. The agent begins or resumes an interactive concept-focused learning session.
4. It assesses understanding conversationally, identifies a likely threshold/concept gap, and adapts explanations, examples, pacing, prompts, and practice.
5. The student can ask for repetition, a simpler explanation, an example, a quiz/check-for-understanding, or a different representation.
6. The agent records approved concept-level progress through its API. SEEDS renders the student’s own progress and suggested next step.
7. The student can exit at any time; raw chat remains private from the teacher.

#### Teacher: privacy-preserving progress view

1. A teacher opens **Student Progress** for a course/cohort.
2. SEEDS requests the agent service’s authorized progress summary for that teacher’s students.
3. The teacher sees concept-level status, trend, last activity (where approved), recommended support, and an AI-generated summary of learning themes/barriers.
4. The teacher does **not** see any raw student prompts, assistant responses, full transcript, or direct quote that could reconstruct private chat content.
5. The teacher uses the progress view to plan revision, individual support, or improved course material.

### 2.5 Functional requirements

| ID | Priority | Requirement |
|---|---|---|
| AI-01 | P0 | Integrate with the IIIT Bangalore Agentic AI only through documented external APIs; no model runtime in SEEDS. |
| AI-02 | P0 | Add teacher course-planning, review, edit, and publish workflow. |
| AI-03 | P0 | Add student interactive personalized learning workflow, scoped to available course/topic context. |
| AI-04 | P0 | Add teacher progress dashboard containing only approved summary/progress fields, never raw chats. |
| AI-05 | P0 | Enforce role-, course-, and student-level authorization on every AI request. |
| AI-06 | P1 | Provide accessible AI UI and a keypad-compatible pathway. |
| AI-07 | P1 | Support teacher review/versioning/publish state for agent-curated coursework. |
| AI-08 | P1 | Provide resilient loading, retry, timeout, unavailable-service, and safety-reporting behavior. |
| AI-09 | P1 | Record minimal auditable integration events without storing raw chat content. |
| AI-10 | P2 | Support future content repositories as optional coursework/source references, after Section 3 is specified. |

#### AI-01 — External API integration

**Required behavior.**

- Flutter must not call the IIIT Bangalore service directly with long-lived service credentials.
- Flutter calls a SEEDS backend endpoint; the backend authenticates the current user, authorizes their role/course/student scope, and invokes the external API using server-held credentials.
- The backend returns only the minimum response required by the client.
- External API base URL, client credentials, timeouts, and feature flag are environment configuration; none are committed to source control or embedded in the APK.
- All requests must include an integration/correlation ID for troubleshooting without copying private chat content into logs.

**Proposed SEEDS integration boundary.**

```text
Flutter dashboard / AI screens
  → authenticated SEEDS FastAPI endpoints
  → IIIT Bangalore Agentic AI API
  → minimal curated/progress response
  → Flutter accessible UI
```

**Likely implementation area.** New FastAPI router/service module under `backend/`; backend configuration; new Flutter AI screens, API-service methods, routes, and dashboard entry points.

#### AI-02 — Teacher coursework planning and publishing

**Required behavior.**

- A teacher can create/select a course context and submit a structured brief: title, subject, level, outcomes, topics/order, and optional material references.
- The teacher can attach/upload material only if the external API supports it; otherwise SEEDS submits references/metadata in the documented API format.
- The returned plan clearly labels threshold concepts, prerequisites, outcomes, suggested sequence, and recommended activities/explanations.
- Content stays in **Draft** until the teacher explicitly approves/publishes it for one or more sessions/cohorts.
- The teacher can edit, republish a new version, unpublish, and view which version is active.
- The agent must not autonomously publish or overwrite teacher-authored course content.

**Data to persist in SEEDS (minimal).** Course/session linkage, external resource/plan ID, teacher ownership, lifecycle state (`draft`, `published`, `archived`), version, timestamps, and non-sensitive display metadata. Authoritative generated content should remain in the external service unless the API contract requires otherwise.

#### AI-03 — Student learning assistant

**Required behavior.**

- The student sees only courses/topics they are authorized to access and that are published/available to them.
- The assistant receives the minimum necessary identity/context, preferably opaque SEEDS/external learner IDs rather than phone numbers or unnecessary profile data.
- The UI supports a student message/input, a streamed or paged agent response as supported by the external API, and explicit actions: Repeat, Simpler explanation, Example, Check understanding, Next step, and End session.
- The UI represents threshold-progress feedback in clear, non-stigmatizing language, such as “Building understanding,” “Ready to practise,” and “Needs more support.”
- Student chat is private. It is not included in SEEDS application logs, session logs, analytics payloads, or teacher APIs/views.

#### AI-04 — Teacher progress and chat-summary access

**Required behavior.**

- Teachers can view progress only for students in their authorized course/session/cohort.
- Progress is concept-level and may include: concept name, threshold status, progress state, confidence/mastery band supplied by the service, last learning activity, and recommended teacher action.
- A teacher-facing summary can describe learning themes and barriers, but must be generated/sanitized by the external service according to the agreed privacy policy.
- The summary must exclude raw messages, direct quotations, sensitive personal information, and details that could reconstruct a student’s private chat.
- The UI must disclose that it is a privacy-preserving summary rather than a transcript.
- If no summary can meet this constraint, display progress only; do not attempt local summarization from chat data.

#### AI-05 — Authorization, privacy, and data governance

**Required behavior.**

- Reuse SEEDS authenticated identity, but do not trust a client-provided `user_id`/role alone for AI authorization.
- Backend enforcement verifies teacher ownership of a course/session and student membership/access before making external calls.
- Define data minimization for every outbound request. Prohibited fields unless explicitly approved: phone number, password, FCM token, device ID, and any raw chat content sent to a teacher-facing endpoint.
- Establish retention/deletion rules with IIIT Bangalore before release: raw-chat retention, summary retention, course-material retention, export, and deletion on student/course removal.
- Obtain the required institutional consent/notice before enabling the feature for students. The notice must explain what data goes to the external service, what the teacher can view, and that raw chats are private from teachers.
- Implement an access/audit record containing actor, action, target resource ID, time, response status, and correlation ID—but never message content.

#### AI-06 — Accessible experience

**Required behavior.**

- New dashboard entries, planning forms, responses, progress cards, and controls use semantic labels, high-contrast-aware colors, scalable text, and TTS announcements.
- The AI feature must use the common keypad/focus policy from BF-01. It cannot introduce touch-only controls.
- While the student is composing text, the keypad input-mode policy must be explicit and not conflict with global shortcuts.
- Long AI responses must be chunked/navigable, not automatically read in full without an interruption/repeat control. The student must be able to pause/resume or request a concise version.
- Error/retry states are readable and announced by TTS.

#### AI-07 — Resilience and service behavior

**Required behavior.**

- Use documented timeout, retry, rate-limit, and asynchronous-job patterns from the external service; do not block the Flutter UI indefinitely.
- Show an accessible loading/progress state for AI generation and a clear retry action for transient failure.
- If the service is unavailable, preserve ordinary SEEDS dashboard/session/audio functionality and say that the AI assistant is temporarily unavailable.
- Protect the backend from duplicate submissions and repeated retry taps with idempotency/correlation keys where the external API supports them.
- Gate rollout using a server-controlled feature flag so the integration can be enabled per environment/cohort and disabled without shipping a new APK.

### 2.6 Proposed integration API surface (subject to IIIT Bangalore documentation)

The following are SEEDS-facing endpoint responsibilities, not a claim about the external API’s names or payloads. Final request/response schemas must be derived from the procured IIIT Bangalore documentation.

| SEEDS endpoint responsibility | Caller | Minimum response required |
|---|---|---|
| Create/update a course-planning brief | Teacher | External course/plan ID, status |
| Request a curated plan | Teacher | Draft plan with threshold concepts and activities |
| Review/publish/unpublish plan version | Teacher | Updated lifecycle/version status |
| List available student learning paths/topics | Student | Authorized topic list and progress state |
| Start/resume/send/close learning interaction | Student | Response content, session/reference ID, next suggested action |
| Retrieve personal progress | Student | Concept progress and next steps |
| Retrieve cohort/student progress summary | Teacher | Authorized concept-level progress and privacy-preserving summary |
| Report unsafe/incorrect response | Student/Teacher | Acknowledgement/correlation ID |

### 2.7 External documentation and decisions required before implementation

Procure the Agentic AI documentation from MSR/A4I, IIIT Bangalore. Before implementation begins, it must answer:

1. Authentication method, credential ownership, token expiry/refresh, and tenant/course isolation model.
2. Complete API schemas and API versioning policy for coursework, interactive learning, progress, summaries, uploads, and error responses.
3. Whether responses stream, poll asynchronous jobs, or return synchronously; applicable timeouts/rate limits/idempotency support.
4. Supported material formats, size limits, malware/content-validation responsibilities, and whether inputs are copied or referenced.
5. The service’s exact definition and schema for threshold concepts, student progress, and teacher-visible chat summaries.
6. Whether student/teacher identities can be opaque/pseudonymous; required fields; hosting region; encryption; retention; deletion/export; and data-processing agreement.
7. Guarantees that teacher-summary endpoints never return raw chat, quotes, or sensitive inferred attributes.
8. Moderation/safety behavior, escalation path, reporting API, availability SLA, support contact, and sandbox/test environment.
9. Licensing/cost/rate limits and whether the service is suitable for the intended student population and institutional deployment.

Until these are confirmed, do not hard-code API routes or persist external response formats as SEEDS domain models.

### 2.8 Delivery phases

1. **Discovery and agreement:** Procure API/security/privacy documentation; approve consent, retention, teacher-summary boundary, and API contract.
2. **Backend adapter:** Add feature flag, external client, credential/configuration handling, authorization middleware, minimal audit events, and sandbox contract tests.
3. **Teacher pilot:** Implement planning → review → explicit publish for a limited teacher/cohort; validate generated content review and privacy controls.
4. **Student pilot:** Implement private personalized learning interaction and personal progress view for the same cohort.
5. **Teacher progress:** Add authorized progress summaries after verifying that returned data cannot disclose raw student chat.
6. **Accessibility/release:** Complete keypad/TTS/high-contrast QA, safety/error behavior, load testing, and monitored cohort rollout.

### 2.9 Acceptance criteria and release gate

- The app contains no model weights, local inference runtime, or external service credentials in the APK.
- A teacher can create a plan, review/edit it, and explicitly publish a selected version for an authorized course.
- An authorized student can complete an interactive learning flow and view only their own progress.
- A teacher can view an authorized student’s concept-level progress and summary, while every attempt to access raw chat is unavailable at UI, SEEDS API, logs, and external-contract levels.
- Cross-course/cross-role requests are denied by the backend even if a client alters an ID in a request.
- All AI flows are usable with touch, TTS, high contrast, and the approved physical-keypad interaction model.
- Service timeout/unavailability does not block normal SEEDS functionality and produces an understandable retryable state.
- Pilot sign-off includes privacy/security review, accessibility validation on the BlackZone device, and confirmation from IIIT Bangalore that the implemented API contract is supported.

## 3. Content Repository Integration

### 3.1 Purpose and scope

SEEDS will extend its existing teacher-uploaded audio/content library with selected accessible content from the IIIT Bangalore content repository. The repository aggregates content sourced from **Subodha** and **Antara**, including accessible NCERT chapters, stories, songs, and other learning material for blind children.

The teacher remains the curator. Repository material is not automatically pushed to students: a teacher discovers content, reviews it, selects it for a course/session, and makes it available to the intended students. Manual teacher upload remains a supported and independent path.

The supplied “SEEDS 2.0 × Content Aggregators — Integration Technical Specification” describes a generic external-content API, client-credential authorization, tenant isolation, asynchronous content processing, language metadata, and accessibility-oriented content types. Its server-side implementation details (for example, MongoDB/Agenda.js) belong to the content-platform owner unless IIIT Bangalore explicitly assigns them to this codebase. The current SEEDS FastAPI backend should act as a secure consumer/adapter of the published repository API, not duplicate the entire external platform.

### 3.2 Product outcomes

- Teachers can add high-quality accessible material from Subodha/Antara alongside their own uploads.
- Students can discover and play only the content explicitly made available to them, using the same accessible audio/content experience as teacher uploads.
- Content is discoverable by curriculum, subject, class/level, language, type, title, and source.
- Provenance is transparent: users can identify whether material is teacher-uploaded, Subodha, Antara, or another approved repository source.
- The integration preserves tenant/course/session access boundaries and does not expose repository credentials in the app.

### 3.3 User journeys

#### Teacher: discover and assign repository content

1. A teacher opens **Content Library** from the teacher dashboard or a session’s audio/content panel.
2. The teacher chooses **Repository Content** in addition to the existing **Upload Content** option.
3. The teacher searches or filters the catalog by class/level, subject, language, content type (for example chapter, story, song, quiz, Braille-ready file), source, and keyword.
4. The teacher opens an accessible metadata/preview view: title, source, description, curriculum tags, language, duration/format, accessibility attributes, and rights/attribution where supplied.
5. The teacher selects one or more items and assigns them to a course, session, or intended cohort. The assignment state is explicit: draft, available/published, or removed.
6. If the repository processes an item asynchronously, the teacher sees a clear status (processing, ready, failed) and can retry/reconcile without losing their ordinary upload workflow.

#### Student: access assigned repository content

1. A student opens the existing offline/content library or session content view.
2. The app shows teacher-assigned repository and manual content in one coherent list, with source attribution and filters.
3. The student opens an item and plays/reads it through the accessible player. TTS, high contrast, screen semantics, keypad navigation, and playback controls remain available.
4. If content is unavailable or still processing, the student sees and hears an understandable status; no raw repository error is shown.

#### Teacher: monitor assignment and repository status

1. A teacher views content assigned to their course/session, including the source, availability state, and last update.
2. The teacher can remove an assignment without deleting the canonical item from the external repository.
3. Where the repository supports it, the teacher can view content-processing status and authorized quiz/activity results. This data must follow the same student privacy rules as Section 2.

### 3.4 Functional requirements

| ID | Priority | Requirement |
|---|---|---|
| CR-01 | P0 | Add a repository-content catalog as a peer to manual teacher upload. |
| CR-02 | P0 | Allow teachers to search, filter, preview, select, assign, and unassign repository items. |
| CR-03 | P0 | Show students only the items assigned to their authorized course/session/cohort. |
| CR-04 | P0 | Keep repository client credentials and service calls server-side. |
| CR-05 | P1 | Normalize source, curriculum, language, format, accessibility, and lifecycle metadata. |
| CR-06 | P1 | Support accessible playback/read access for audio and Braille-ready content where the repository provides them. |
| CR-07 | P1 | Handle pagination, processing status, retries, and unavailable repositories without blocking manual uploads. |
| CR-08 | P1 | Display provenance, licensing/attribution, and content availability clearly. |
| CR-09 | P2 | Integrate repository quiz/activity results into authorized teacher progress views. |
| CR-10 | P2 | Make assigned repository material usable as an approved source/reference for the Agentic AI course-planning flow. |

#### CR-01 — Unified content library, distinct source paths

**Required behavior.**

- The teacher content UI exposes two clear actions: **Upload my content** and **Browse repository content**.
- Existing manual uploads continue to work even when the external repository is unavailable.
- Repository items are referenced/assigned by stable external content ID; SEEDS must not silently duplicate files into its existing `audio_files` storage unless the licensing/API agreement explicitly requires a managed copy.
- The unified list identifies each item’s source: `Teacher upload`, `Subodha`, `Antara`, or a future approved repository.
- Source catalog browsing is read-only for normal teachers. Canonical repository updates/deletes are performed only through the repository owner’s authorized API/workflow.

**Likely implementation area.** `frontend/lib/screens/audio_library_screen.dart`, `frontend/lib/services/api_service.dart`, new backend repository-adapter/router modules, and schema/models for assignment/reference metadata.

#### CR-02 — Teacher discovery, metadata, preview, and assignment

**Required behavior.**

- Repository search supports server-side filters specified by the content service where available: keyword/title, class/level, subject, language, content type, source, and curriculum theme/topic.
- Results use cursor-based pagination or the repository’s documented continuation mechanism; never download the full catalog to a low-spec device.
- The result card/detail page must include: title, source, type, language, class/level, subject, theme/topic, description, duration if applicable, accessible formats, and attribution/license information when supplied.
- A teacher may assign an item to an existing session/course/cohort, remove that assignment later, and see the selected content in the current session/audio library.
- Assignment is idempotent: selecting the same external item for the same target twice does not create duplicate student-visible entries.
- The app must not present an item as ready until the repository indicates that its required media/accessibility processing is complete.

**Data to persist in SEEDS.** An assignment/reference record containing SEEDS target (`session_id` and future course/cohort identifier), external content ID, source, title/display metadata snapshot, lifecycle/availability state, assigned by, timestamps, and repository version/updated timestamp if supplied. Store a content URL only when it is short-lived or safely obtained at playback time; do not persist public or raw storage paths.

#### CR-03 — Student entitlement and playback

**Required behavior.**

- A student’s content list is filtered on the backend to their authorized sessions/courses/cohorts. The client must not be able to access another teacher’s or tenant’s repository ID by changing a URL/request parameter.
- Assigned content appears alongside manual content with source attribution, but a student does not see teacher-only draft/processing/admin metadata.
- The existing audio player must support repository audio through a secure playback URL/proxy mechanism defined by the repository contract.
- For Braille Ready Format (`.brf`) items, provide an accessible download/open/export pathway only after confirming target-device Braille display/application support. Do not label BRF as playable audio.
- Content type drives the interaction: audio uses playback controls; text/structured content uses an accessible reader; quizzes use the repository/SEEDS approved assessment view; BRF uses the supported Braille pathway.
- When an item is no longer assigned, students must lose access promptly while the canonical repository item remains unchanged.

#### CR-04 — Secure repository adapter and authorization boundary

**Required behavior.**

- Flutter calls authenticated SEEDS backend endpoints only. It never receives content-repository `client_secret`, refresh token, integration access token, or webhook secret.
- SEEDS backend authenticates teachers/students under its own auth model, authorizes the requested course/session scope, then calls the external repository API with server-held integration credentials.
- The external technical specification’s client-credentials model is the baseline when confirmed by IIIT Bangalore: short-lived access tokens, scoped privileges, HTTPS, secret hashing/storage by the service owner, and refresh/revocation handling.
- Request scope must be least-privilege. This app normally requires repository read/catalog/playback access; canonical create/update/delete privileges must not be granted merely because a teacher can upload their own SEEDS content.
- If the repository uses tenants (including the `x-tenant-ids` model described in the supplied document), SEEDS maps each school/course context to exactly the authorized tenant and rejects mismatches server-side.
- All service configuration, credentials, base URL, token lifecycle settings, and feature flags reside in backend environment configuration. Sensitive values are never logged or committed.

#### CR-05 — Content metadata and language model

**Required behavior.**

- Use a normalized SEEDS-facing content reference model that supports at least: external ID, source, title, description, type, language, class/level, subject, theme/topic, duration, creation/update time, content version, availability, accessible formats, attribution/license, and preview/playback capability.
- Preserve the repository’s language codes rather than guessing/rewriting them. The supplied specification uses ISO 639-1 codes and ISO 639-3 when no ISO 639-1 code exists; validate against the repository language registry once its final contract is confirmed.
- Support accessible content types at minimum: audio, structured text/content, quiz, and `brf`. Preserve `brailleGrade` (1 or 2) for BRF items when supplied.
- Source tags are mandatory. A source must be distinguishable in API responses and UI even if title/subject metadata is identical.
- Curriculum tags are optional for imported items only if the source does not provide them. Teachers may add local assignment labels without overwriting canonical repository metadata.

#### CR-06 — Accessibility requirements

**Required behavior.**

- Repository browsing, filtering, result cards, previews, selection, assignment, and playback are all usable through TTS, high contrast, physical keypad, D-pad focus traversal, and touch.
- New controls must conform to the keypad/focus foundation defined in BF-01 through BF-04; browsing repository content must not be touch-only.
- Search/filter controls explain current selection, result count, loading state, and focus position through TTS.
- Audio items have clear title/source/duration/play controls. Non-audio items have accurate labels and do not expose audio-only controls.
- Long lists must paginate/incrementally load with explicit “load more” feedback rather than cause a silent full-catalog load.

#### CR-07 — Asynchronous processing, status, and resilience

**Required behavior.**

- Treat repository processing and availability as asynchronous. A catalog/assignment request must not block the teacher app waiting for downstream content generation or storage.
- Map repository statuses to a small user-facing set: `Ready`, `Processing`, `Unavailable`, `Failed`, and `Removed`.
- Prefer documented signed webhooks for status updates if IIIT Bangalore exposes them; verify signature before processing. Use bounded polling/job-status lookup only as a fallback.
- Handle timeout, rate limiting, expired signed URL, missing item, unauthorized tenant, and unavailable repository with a friendly, actionable status and retry where safe.
- Repository outage must not affect manual upload, ordinary session audio, or core student/teacher dashboard use.
- Cache non-sensitive catalog metadata briefly on the backend where permitted to improve low-bandwidth usability; do not claim offline access until a separate offline-content design is approved.

#### CR-08 — Provenance, rights, and lifecycle

**Required behavior.**

- Every student/teacher-visible repository item shows its source and any required attribution, use restriction, or license supplied by the repository.
- The integration must preserve source attribution through assignment, playback, and any Agentic AI reference use.
- SEEDS must respect canonical deletion/withdrawal/version events. A removed or rights-restricted item is no longer playable even if a local assignment exists.
- Teachers can remove an assignment from their course/session without deleting the original item from Subodha, Antara, or the IIIT Bangalore repository.
- Before launch, agree the license/permission terms for streaming, downloading, caching, derivative use, and AI-assisted curation of Subodha and Antara material.

#### CR-09 — Optional quiz/activity outcomes

**Required behavior.**

- If the repository exposes quiz/activity results, ingest or request only the minimum authorized student result data needed for teacher progress.
- Results are idempotent if pushed from the repository; the external specification proposes a stable combination of external quiz ID, external student ID, and attempt time.
- Teacher views are restricted to their authorized course/tenant and must follow the Section 2 rule that raw student-agent chat remains private.
- Quiz results must be labelled as repository activity data, separate from AI-derived concept progress.

### 3.5 Proposed SEEDS-facing API responsibilities

These are integration responsibilities for the current FastAPI backend. The exact external routes, fields, authentication, content URL behavior, and webhook model must be validated with IIIT Bangalore before implementation.

| SEEDS backend responsibility | Caller | Minimum outcome |
|---|---|---|
| List repository sources/filters/languages | Teacher/Student UI | Allowed metadata/options |
| Search/list repository catalog | Teacher UI | Paginated, tenant-authorized result summaries |
| Get repository item metadata/preview | Teacher UI | Detail metadata and safe preview capability |
| Assign/unassign repository item | Teacher UI | Idempotent assignment lifecycle state |
| List assigned content | Teacher/Student UI | Entitlement-filtered unified manual/repository content list |
| Obtain secure item playback/read access | Authorized teacher/student UI | Short-lived stream/read reference or backend-proxied content |
| Receive/query processing status | Backend | Normalized availability status |
| Receive/query repository quiz outcomes | Backend/teacher UI | Authorized, idempotent outcome records |

### 3.6 Data model additions

The current codebase uses `AudioFile` and `SessionAudio` for locally uploaded audio. Repository integration needs separate references rather than overloading local file-path storage.

| Entity | Purpose | Key fields |
|---|---|---|
| `ContentSource` | Approved external source registry | source ID, display name, type, status, configuration reference |
| `RepositoryContentReference` | Cached/minimal external item metadata | source, external content ID, type, title, language, curriculum tags, accessibility metadata, version, availability, rights metadata |
| `ContentAssignment` | Teacher selection of an item for a SEEDS target | target session/course/cohort, reference ID, assigned by, state, assigned/removed times |
| `RepositorySyncStatus` | Optional status/reconciliation record | source/reference ID, external job/event ID, normalized state, last checked, error code (no secrets) |
| `RepositoryQuizResult` | Optional approved assessment outcome | source, external quiz/student IDs, tenant/course scope, attempt time, result summary, idempotency key |

The final model must be aligned with the repository’s identifiers and lifecycle guarantees. Do not store bearer credentials, raw external storage locations, or unbounded content copies in these entities.

### 3.7 External dependencies and decisions required

Before implementation, obtain and approve the following from IIIT Bangalore/content owners:

1. The production and sandbox API contract for catalog search, item detail, filtering, playback/download, source attribution, lifecycle, and status notifications.
2. Confirmation that the supplied Content Aggregator API is the interface SEEDS should consume, including base URL, API version, tenant mapping, scopes, client-registration process, and credential ownership.
3. Source inventory and canonical identifiers for Subodha and Antara, including supported content types, languages, curriculum metadata quality, BRF availability/grade, and preview/playback formats.
4. Rights, attribution, student-access, caching/download, deletion/withdrawal, and derivative/AI-use permissions for every source.
5. The expected repository availability, rate limits, response paging limits, signed URL lifetime, webhook event types/signature details, and support/escalation process.
6. Student identity mapping and quiz-result schema, plus consent/retention rules if activity data is returned.
7. Whether courses/cohorts/tenants already exist in the repository, or how the SEEDS session-centric model maps to them.
8. Target device support for BRF reading/export and any required Braille display/application integration.

### 3.8 Delivery phases

1. **Contract and rights discovery:** Confirm external API ownership, sandbox, credentials, tenant mapping, source license/attribution, content types, and BRF/device support.
2. **Backend adapter and models:** Add server-side external client, configuration/feature flag, read-only catalog adapter, entitlement checks, normalized reference/assignment model, and contract tests against sandbox.
3. **Teacher catalog pilot:** Add repository browse/search/filter/detail/assignment, initially for a small approved source/course set.
4. **Student access pilot:** Add unified assigned-content list and secure playback/read flow; validate on BlackZone with TTS/keypad/high contrast.
5. **Lifecycle and operational hardening:** Add status updates/webhook verification or bounded polling, withdrawal/version handling, observability, and source outage behavior.
6. **Optional outcomes and AI linkage:** Add quiz outcomes and approved Agentic AI source references only after privacy, rights, and course-linkage reviews pass.

### 3.9 Acceptance criteria and release gate

- A teacher can browse Subodha/Antara repository content, filter it, inspect provenance/metadata, and assign an item without manually uploading it.
- An authorized student can discover and use the assigned item through an accessible, keypad-compatible flow; an unauthorized student cannot retrieve its metadata or media reference.
- Manual upload remains fully functional when the repository is slow or unavailable.
- No external credentials or raw storage URLs are included in the APK, logs, or persistent client storage.
- Content attribution/source and rights information are visible wherever required.
- External content status changes (ready, withdrawn, failed) result in an understandable SEEDS state and do not leave broken “play” affordances.
- The initial source cohort passes device QA on the BlackZone phone for catalog browsing, playback/read action, TTS, high contrast, focus/D-pad traversal, and keypad shortcuts.
- IIIT Bangalore and the relevant Subodha/Antara rights owners approve the production API contract and permitted use before student rollout.

## 4. Topic-wise Quiz Integration

### 4.1 Purpose and scope

SEEDS will add a quiz area to the student dashboard so students can practise topic-wise concepts and teachers can monitor learning progress. Questions may come from either:

1. an approved external content repository (for example, Subodha/Antara material exposed through the IIIT Bangalore repository); or
2. a teacher who creates/uploads questions, answer options, and the correct answer in SEEDS.

Quizzes are learning and formative-assessment tools. They should help a student understand a topic and identify concepts needing support, rather than merely produce a score. Results may inform the privacy-preserving progress view in Sections 2 and 3, but quiz attempts are not student-agent chat and must be clearly labelled as assessment data.

### 4.2 Product principles

- **Topic first:** Students find quizzes by subject/course and topic, with optional subtopic, class/level, and language filtering.
- **Teacher control:** Teacher-created questions and repository questions are reviewed/selected, assigned, published, versioned, and withdrawn by authorized teachers. Repository questions must not be auto-assigned merely because they exist in the catalog.
- **Accessible by default:** The complete quiz lifecycle works with TTS, high contrast, focus/D-pad navigation, physical keypad, touch, scalable text, and clear non-visual feedback.
- **Formative and non-stigmatizing:** Results state what was understood and what to practise next. Do not expose ranking/leaderboards by default.
- **Integrity and transparency:** Show the source, teacher/course, topic, question count, estimated time, attempt policy, and feedback policy before starting.
- **Data minimization:** Store only the result data needed for progress and teacher support. Do not mix quiz responses with private Agentic AI chat records.

### 4.3 User journeys

#### Teacher: create and publish a topic quiz

1. A teacher opens **Quizzes** from the teacher dashboard or a course/session content view.
2. The teacher creates a quiz with title, course/session/cohort, topic, optional subtopic, class/level, language, instructions, attempt policy, feedback policy, and availability window.
3. The teacher adds questions manually or chooses approved repository questions.
4. For a manual multiple-choice question, the teacher enters a question prompt, two or more options, exactly one correct option, an optional explanation/hint, and optional accessibility metadata/media.
5. The teacher reviews the quiz preview, saves a draft, and explicitly publishes it to the intended students.
6. The teacher can edit a draft; after publication, changes create a new version or are restricted according to the attempt/version policy. The teacher can unpublish/archive a quiz without erasing historical attempt records.

#### Student: take a topic-wise quiz

1. A student opens **Quizzes** from the student dashboard.
2. The dashboard lists only available quizzes for the student’s authorized courses/sessions, grouped or filterable by subject and topic. It displays progress state: Not started, In progress, Submitted, or Available to retry.
3. The student opens a quiz overview and hears/sees the topic, question count, instructions, attempt count remaining, and feedback timing.
4. The student starts/resumes the attempt. Each question is announced with its topic, position, prompt, and answer choices; the student selects an option through touch or the approved keypad/focus model.
5. The student can review unanswered/flagged questions, change an answer before submission, and submit with an accessible confirmation.
6. After submission, the student receives the configured feedback: immediate explanation, score only, delayed feedback, or teacher-reviewed feedback. The result offers a clear next step, such as retry, revisit assigned content, or use the AI Learning Assistant for that topic.

#### Teacher: view quiz progress

1. A teacher opens a quiz or topic progress view for an authorized course/cohort.
2. The teacher sees topic/quiz-level completion, attempt count, score/accuracy bands, common incorrect options/concepts where appropriate, and students who may need support.
3. The teacher can see an individual student’s assessment result and question-level response only when that is part of the approved assessment policy; the UI must distinguish this from private AI chat, which remains unavailable.
4. The teacher uses results to improve instruction, assign content, or suggest an Agentic AI learning path; no automatic high-stakes decision is made from quiz results.

### 4.4 Functional requirements

| ID | Priority | Requirement |
|---|---|---|
| QZ-01 | P0 | Add a topic-wise quiz entry and list to the student dashboard. |
| QZ-02 | P0 | Support teacher-authored multiple-choice quizzes with validated questions, options, answer, and explanation. |
| QZ-03 | P0 | Support teacher selection/assignment of repository-sourced questions where permitted. |
| QZ-04 | P0 | Deliver quizzes and record attempts only for authorized students/courses/sessions. |
| QZ-05 | P0 | Provide accessible keypad, D-pad, TTS, touch, and high-contrast quiz interactions. |
| QZ-06 | P1 | Provide student feedback, topic progress, retry/resume, and recommended next steps. |
| QZ-07 | P1 | Provide authorized teacher progress and analytics views. |
| QZ-08 | P1 | Support draft/publish/version/archive lifecycle, attempt policy, and result/feedback policy. |
| QZ-09 | P1 | Integrate repository quiz outcomes idempotently where the external repository provides them. |
| QZ-10 | P2 | Link topic results to assigned repository content and the Agentic AI learning path. |

#### QZ-01 — Student dashboard quiz discovery

**Required behavior.**

- Add an accessible **Quizzes** action to the student dashboard and announce it in that screen’s keypad/TTS instructions.
- The quiz list is scoped server-side to the logged-in student’s active/available course, session, cohort, and availability window.
- Students can browse/filter by course/subject, topic, subtopic, class/level, language, source, and status when metadata exists.
- Each quiz card includes title, topic, source/teacher, question count, expected duration if supplied, status, attempts remaining, and feedback policy.
- Empty states are useful and specific, for example: “No quizzes are available for this topic yet.”
- A student can resume an allowed in-progress attempt and sees any saved responses, without accessing another student’s attempt.

**Likely implementation area.** `frontend/lib/screens/student_dashboard.dart`, new Flutter quiz-list/attempt/result screens, `frontend/lib/services/api_service.dart`, `frontend/lib/utils/keypad_actions.dart`.

#### QZ-02 — Teacher-authored question bank and quizzes

**Required behavior.**

- The initial supported question type is single-answer multiple choice. It requires a prompt, at least two non-empty options, exactly one correct option, topic, and language. Explanation/hint, subtopic, difficulty, class/level, and accessible media are optional.
- Validate question data in both UI and backend. A teacher cannot publish a quiz with an incomplete question, duplicate/blank option, no correct answer, or no topic.
- The UI must support keyboard/keypad-safe text entry in accordance with BF-01/BF-02; authoring can be desktop/touch-optimized only if the product explicitly documents that teacher authoring is not a button-phone workflow. Student delivery must never be touch-only.
- Teachers can save questions to a reusable private question bank, organize them by topic, and add selected questions to multiple quizzes without exposing their answers to students before submission.
- Correct answers, explanations, and teacher-only notes are never included in the student start/list response. They are released only according to feedback policy after server-side submission evaluation.

**Likely implementation area.** New teacher quiz/question-bank Flutter screens; new FastAPI models, schemas, endpoints, and database migration strategy.

#### QZ-03 — Repository-sourced questions

**Required behavior.**

- The teacher can search/filter eligible repository questions by source, topic, class/level, language, question type, and associated content item.
- Repository question metadata retains its immutable external source ID, source attribution, version, rights/usage status, and canonical topic tags.
- A teacher selects and assigns repository questions to a SEEDS quiz; the canonical repository record is not modified by SEEDS.
- Only questions approved by the repository’s rights and API contract may be copied, displayed, cached, or used in a SEEDS assessment.
- If a repository question is revised, withdrawn, or rights-restricted, new attempts use the permitted current version or the quiz is marked unavailable. Existing attempt history retains a safe question/version reference for auditability without re-exposing withdrawn content.
- If the repository publishes quiz outcomes directly, use the idempotent integration pattern in CR-09 rather than creating duplicate attempts.

#### QZ-04 — Attempt, submission, and authorization rules

**Required behavior.**

- The backend creates an attempt only after verifying that the student is eligible for the quiz and it is published/available.
- Each attempt is bound to a student, quiz version, course/session/cohort context, start time, attempt number, and state (`in_progress`, `submitted`, `expired`, `abandoned`, or `invalidated`).
- Save answers incrementally or on explicit navigation so a network interruption does not unnecessarily lose an in-progress quiz. Server-side updates must be idempotent and scoped to the attempt owner.
- Evaluate answers server-side. The client must never receive the answer key before submission or be treated as the authoritative scorer.
- Enforce configured time limit, attempt limit, and availability window on the backend; the client displays a readable countdown/status but cannot bypass it.
- Submission is idempotent: repeated taps/retries cannot create duplicate results or change a completed score.
- When a quiz becomes unavailable mid-attempt, preserve an auditable state and show a clear resolution policy; do not silently discard student work.
- API authorization must prevent a student from listing, starting, answering, submitting, or reading results for another student’s quiz/attempt, even if IDs are manipulated in the client.

#### QZ-05 — Accessible question-taking experience

**Required behavior.**

- The attempt screen clearly presents: question number/total, topic, prompt, each option and selection state, navigation, flag/review state, submit action, and current saved status.
- TTS reads the prompt and options on focus; students can repeat the prompt/options, pause speech, and request a concise re-read.
- Each answer option has a stable focus order and a semantic label including option letter/number, text, and selected/not selected state.
- The approved keypad model supports moving between question controls, selecting an answer, next/previous question, flag/review, repeat instructions, and submit. Numeric answer shortcuts may be offered only when they do not conflict with T9 text entry and are announced on the screen.
- Use high-contrast-aware selected/focused states; do not rely only on colour to communicate selected/correct/incorrect status.
- Feedback must communicate correctness and explanation through both text and TTS. It must not automatically speak lengthy explanations without an interrupt/repeat control.
- The UI remains usable on the BlackZone’s small screen without clipped answer options or inaccessible scrolling.

#### QZ-06 — Student feedback and learning progression

**Required behavior.**

- Each quiz defines one feedback policy before publication: `immediate_per_question`, `after_submission`, `delayed_until_teacher_release`, or `score_only`.
- Results show overall outcome and topic-level feedback in non-stigmatizing language. Where allowed, show correct answer and explanation only after the policy permits it.
- The student receives recommended next actions based on the quiz’s topic and outcome: retry if permitted, open teacher-assigned content, or open the Agentic AI Learning Assistant with the topic context.
- Progress uses transparent labels (for example, Not started, Practising, Building understanding, Ready for next topic) rather than treating a single quiz score as a permanent ability judgment.
- Students can review their own completed result/feedback within the teacher-configured retention/feedback policy.

#### QZ-07 — Teacher results and topic analytics

**Required behavior.**

- Teachers see only quizzes and students in their authorized course/session/cohort.
- Provide quiz-level metrics: assigned/started/submitted counts, completion rate, score/accuracy distribution, attempt count, and question/topic difficulty signals where data is sufficient.
- Provide student-level summary: completion status, latest/best score according to policy, attempt count, topic-level outcome, and recommended support indicator.
- Provide question-level analysis only in an aggregated/privacy-appropriate manner by default: common incorrect options, response count, and possible misconception/topic. Avoid public comparison or student ranking.
- Teacher results views distinguish **Quiz assessment data** from **Agentic AI progress summaries** and never surface raw student-agent chat content.
- Allow export only after product/privacy approval; exports must be scoped, auditable, and avoid more data than needed.

#### QZ-08 — Lifecycle, versioning, and policies

**Required behavior.**

- Quiz states: `draft`, `published`, `closed`, `archived`. Only published quizzes can be started by students.
- Quiz version increments when a published quiz’s questions, correct answers, grading, or feedback policy changes. An existing attempt stays bound to the version it began with.
- Teachers configure: target course/session/cohort, topic/subtopic, availability start/end, optional time limit, maximum attempts, feedback policy, and whether an attempt can be resumed.
- Teachers can preview the exact student-visible version before publishing.
- Archiving/unpublishing ends new access without altering completed results. Deleting a quiz is restricted when attempts exist; retain an auditable archived record instead.

#### QZ-09 — Privacy, retention, and safety

**Required behavior.**

- Treat individual answers and results as educational records. Define and obtain approval for collection purpose, teacher visibility, retention, deletion, export, and student/guardian notice before rollout.
- Do not include raw answer text, answer options, or scores in unrelated app logs, analytics, push notifications, or Agentic AI chat prompts unless explicitly required and consented to for a defined learning action.
- If a quiz score is passed to the Agentic AI, send the minimum concept-level signal needed (for example, topic and outcome band), not the full response transcript, unless the privacy agreement explicitly allows it.
- Support a report mechanism for incorrect, inappropriate, inaccessible, or potentially harmful questions; teacher/admin review must be able to withdraw the item.
- Enforce source-specific copyright/licensing rules for repository questions and teacher material.

### 4.5 Proposed data model additions

The current backend has no quiz models. Add a migration-managed quiz domain rather than storing quiz JSON in session logs.

| Entity | Purpose | Key fields |
|---|---|---|
| `QuestionBankItem` | Teacher-authored or repository-referenced reusable question | owner/source, external ID/version where applicable, topic/subtopic, prompt, type, options, correct-answer reference, explanation, language, curriculum/accessibility metadata, lifecycle |
| `Quiz` | Teacher-curated assessment container | teacher/course/session/cohort scope, title, topic metadata, state, feedback/attempt/time policies, active version |
| `QuizQuestion` | Ordered immutable snapshot/reference for a quiz version | quiz/version, question source/reference, position, points/weight, presentation snapshot/version |
| `QuizAttempt` | One student’s authorized attempt | student, quiz/version, scope, status, started/submitted/expiry times, attempt number, score/feedback release status, idempotency key |
| `QuizResponse` | Student answer for one question in one attempt | attempt/question, selected option/reference, saved time, evaluation state/score; no answer key returned to client before submission |
| `QuizResultSummary` | Fast teacher/student topic-level view | attempt/quiz/topic, outcome band, score/accuracy summary, recommended next step, released time |
| `RepositoryQuizMapping` | Optional external-repository linkage | source, external quiz/question/result IDs, external version, tenant/course mapping, synchronization status |

Answer keys and teacher-only explanations require strict backend access controls. For repository questions, preserve source/version/reference rather than assuming SEEDS owns or may permanently copy canonical question content.

### 4.6 Proposed SEEDS API responsibilities

Endpoint names are illustrative; implementation should follow the existing FastAPI conventions and the final repository API contract.

| SEEDS backend responsibility | Caller | Minimum outcome |
|---|---|---|
| Create/edit/list teacher question-bank items | Authorized teacher | Validated draft/private questions |
| Search eligible repository questions | Authorized teacher | Paginated, source-attributed question summaries |
| Create/preview/publish/archive quiz versions | Authorized teacher | Policy-validated quiz lifecycle state |
| List available quizzes and topic filters | Authorized student | Entitlement-filtered quiz cards/status |
| Start/resume/get/save response/submit attempt | Authorized student | Attempt-owned question payloads and idempotent state |
| Get student result/progress | Authorized student | Released personal feedback/next step |
| Get teacher quiz/topic results | Authorized teacher | Scope-filtered aggregate and permitted individual outcomes |
| Receive/query repository quiz outcomes | Backend | Idempotent mapped result record |
| Report/withdraw problematic question | Student/teacher/admin as permitted | Auditable review/availability action |

### 4.7 Delivery phases

1. **Policy and model design:** Approve assessment purpose, teacher/student visibility, retention, feedback policy defaults, course/session mapping, question rights, and repository contract.
2. **Core teacher-authored quiz backend:** Build migrations/models, teacher question bank, quiz draft/preview/publish lifecycle, server-side validation/scoring, and authorization tests.
3. **Student quiz MVP:** Add dashboard entry, topic-wise list, accessible attempt/resume/submit/result flow, and BlackZone device QA.
4. **Teacher progress MVP:** Add course-scoped results/progress view and topic-level intervention signals.
5. **Repository questions/results:** Implement repository search/select/reference, version/rights behavior, and idempotent external outcomes after CR-01 through CR-09 are available.
6. **AI learning linkage:** Offer student next-step links and teacher insight only after privacy review verifies that quiz signals and private chat remain appropriately separated.

### 4.8 Acceptance criteria and release gate

- A teacher can create a valid topic-wise MCQ quiz, preview it, publish it to an authorized class/session, and archive it.
- A teacher can select an approved repository question for a topic quiz while preserving source attribution and rights metadata.
- An authorized student can find a topic quiz from the dashboard, complete it with physical keypad or touch, resume after an interruption, submit once, and receive the configured feedback.
- No answer key is available in the student pre-submission API payload, client storage, or UI.
- A student cannot access another student’s attempt or a quiz outside their authorization scope; a teacher cannot access another teacher’s course results.
- A teacher can view authorized topic/quiz progress without seeing private Agentic AI chat.
- Quiz flows pass TTS, high contrast, D-pad focus, keypad, and small-screen QA on the BlackZone device.
- Repository outage leaves teacher-authored quizzes and existing authorized manual content functional.
- Privacy/retention policy, teacher visibility rules, and source licensing are approved before any student production rollout.

## 5. Future Device Integrations: Hexis and Iris

### 5.1 Scope and status

Hexis and Iris integration is a future exploration workstream. It is not a dependency for the Bug Fixes, Agentic AI, Content Repository, or Quiz releases specified above. No device-specific integration should be implemented until device SDKs/protocols, identity/security model, supported formats, synchronization behavior, and a pilot use case are confirmed with the respective device teams.

The target architecture should nevertheless preserve a clean path for these devices to consume authorized SEEDS content through a device adapter or documented integration API, rather than coupling device logic into the Flutter mobile client.

### 5.2 Hexis: Braille reading and folder navigation

**Device capability.** Hexis enables students to navigate folders with four physical buttons, select a story/text item, and read its text on a Braille strip.

**Potential SEEDS use case.** A student accesses teacher-assigned or repository-sourced text/stories from a SEEDS content hierarchy and reads the selected item on the Hexis Braille display.

**Exploration requirements.**

- Define a shallow, predictable, accessible folder hierarchy: course/subject → topic → content item. Avoid deep or dynamically re-ordered menus that are difficult to traverse with four buttons.
- Expose text and Braille-ready content with stable IDs, title, language, source/attribution, topic, and ordered navigation metadata.
- Confirm the format Hexis accepts: plain text, BRF (Braille Ready Format), a device-specific format, or a secure content transfer/read API.
- Preserve language and Braille grade metadata. Repository `.brf` content should retain `brailleGrade` where provided; conversion must not be assumed until device support is confirmed.
- Define device-side content caching, entitlement refresh, removal/withdrawal handling, and behavior when connectivity is unavailable.
- Ensure a student can access only content assigned to their authorized course/session/cohort.
- Establish whether completion/reading progress is sent back to SEEDS, what minimal event data is needed, and the consent/retention rules for that data.

### 5.3 Iris: numbered audio playback

**Device capability.** Iris plays audio files and has digit buttons `0–9` plus an `OK` button. Content can be numbered so that a student can select and play it directly on the device.

**Potential SEEDS use case.** A student accesses teacher-assigned or repository-sourced audio through an Iris-friendly numbered catalog, enters the item number, and presses OK to play it.

**Exploration requirements.**

- Provide a stable, human-usable numeric catalog per student/course/topic. The numbering scheme must avoid collisions, unexpected renumbering, and ambiguous leading-zero behavior.
- Define how a student discovers the assigned number: audio announcement, printable/Braille list, teacher handout, device browse mode, or a combination.
- Determine whether the device supports streaming, download/synchronization, local storage, playlist control, pause/resume, speed adjustment, and signed/expiring playback URLs.
- Keep access authorization server-side. The device must never embed a broadly reusable repository credential or receive unbounded catalog access.
- Define how revoked, updated, expired, or unavailable content is handled without presenting a dead number as playable.
- Confirm supported audio codecs, file-size/storage limits, network requirements, and the mechanism for progress/completion reporting if needed.
- Align the numbering interaction with the keypad policy in Section 1, but treat Iris as an independent device experience rather than assuming Flutter key-event behavior applies to it.

### 5.4 Proposed integration architecture

```text
Hexis / Iris device
  → device-specific adapter or approved device API
  → SEEDS backend device-integration endpoints
  → entitlement-checked content assignment/reference service
  → teacher uploads and approved content repositories
```

The adapter boundary may be operated by the device vendor, IIIT Bangalore, or SEEDS only after ownership and security responsibilities are agreed. The Flutter app remains the teacher/student dashboard; it should not be required to be running for either device to access content.

### 5.5 Required discovery before a device pilot

1. Obtain Hexis and Iris hardware/API/SDK documentation, supported content formats, connectivity model, provisioning method, firmware constraints, and test devices.
2. Define student/device identity pairing, authentication, authorization, reassignment/revocation, and recovery if a device is lost or shared.
3. Confirm the legal and licensing terms for copying/caching/streaming Subodha, Antara, teacher-uploaded, and other repository content to each device.
4. Agree the minimum telemetry/progress events, consent notice, retention, and teacher visibility rules.
5. Prototype one narrow end-to-end flow per device: one assigned Braille story for Hexis and one assigned numbered audio item for Iris.
6. Conduct usability testing with blind students and teachers before scaling the catalog hierarchy or device fleet.

## Conclusion

This specification defines the path from the current SEEDS codebase to an accessible, dashboard-led learning platform. The first delivery priority is a reliable button-phone experience: keypad focus, form navigation, dashboard actions, settings access, clear errors, and safe launch/logout behavior. Those foundations apply to every later feature.

On that foundation, SEEDS can add teacher-curated content from Subodha, Antara, and other approved repositories while retaining manual uploads; topic-wise accessible quizzes from teacher and repository questions; and API-only Agentic AI support for threshold learning, course planning, personalized student guidance, and privacy-preserving teacher progress insight.

External contracts are critical dependencies. Before production implementation, IIIT Bangalore must confirm the Agentic AI and repository APIs, tenant/identity mapping, security model, data processing/retention, source rights, and sandbox environments. Hexis and Iris should proceed as separately scoped future pilots once their technical and accessibility requirements are known.

Successful rollout requires staged delivery, physical-device accessibility validation—especially on the BlackZone button phone—and approval of privacy, security, content-rights, and teacher/student data-visibility policies at each integration boundary.
