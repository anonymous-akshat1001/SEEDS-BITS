# SEEDS: Design Evolution and Decision Record

**From a feature-rich classroom app to a low-interaction, speech-first learning interface**

| Document control | Detail |
|---|---|
| Reviewed | 26 November 2026; source baseline `ce63008` (25 November 2026) |
| Purpose | Explain the design process: problem or feedback, decision, rationale, alternatives and remaining validation |
| Intended users | Blind teachers and students using Android button phones; Vision Empower staff administering the service |
| Readers | Project reviewers, viva examiners, developers and testers |
| Short version | [Four-page Word summary](INTERFACE_DESIGN.docx) |
| Related documents | [Project overview](README.md), [earlier testing requirements](FEATURE_SPEC.md), [deployment guide](BACKEND_DEPLOYMENT.md), [analytics design](analytics_dashboard/README.md) |

## 1. Design problem and evidence

The initial app exposed registration, role selection, session creation, titles,
invitations, session lists and individual classroom controls. On a speech-first
keypad interface, each additional control costs listening time, navigation and
memory. The redesign asks: **what does this person need to do now, and what can
the system already know?**

The resulting approach moves repeated setup to administrators, resolves the
current class on the server, and makes the common classroom action one key.
Independent learning, quizzes and authoring remain available without crowding
the live-class screen.

### How to read this record

- **Prior** identifies an earlier interaction documented in the previous design
  record or repository history.
- **Recorded** identifies an alternative explicitly discussed in the previous
  design record.
- **Reconstructed** identifies a comparison made during this code review. It is
  a technical explanation, **not evidence that the team evaluated that option
  during the project**.
- **Implemented** means represented in the reviewed source. Existing tests are
  evidence of intended behavior, not a claim that they passed in this review.
- **Proposed** means not approved or not implemented. Device usability,
  translation quality and learning outcomes must not be presented as proven.

The quoted viva feedback asks for the **design iteration** to be demonstrated,
not merely a list of features. Earlier mentor feedback recorded in this
document concerned excessive spoken instructions, too many classroom controls,
backend-owned defaults, and awareness of changes made by others. No interview
dates, participant counts or usability results have been invented.

**Scope:** this record covers consequential interface, learning, data and
architecture decisions visible in this repository. It is not a reconstruction
of every undocumented conversation. The target Flutter app is distinct from the
earlier IVR-based SEEDS product described in the feature specification.

## 2. Iteration narrative

Dates below are repository milestones, not assumed dates of mentor meetings.

| Stage / evidence | Problem or input | Design response and consequence |
|---|---|---|
| January-February 2026: initial client/server platform; `4687306`, 24 Feb | Live classroom state must reach connected users | WebSockets were replaced by SSE for the event channel. This predates the November interaction redesign; the historical reason for choosing SSE was not recorded. |
| April 2026: `d0b06f9`, `4b4e5a1` | Learning should not depend entirely on a live session | Offline audio library and pull-based content access introduced. |
| July testing requirements; fixes through October | Keypad focus failures, inconsistent shortcuts, long/unclear feedback and small-screen rendering | Shared keypad handling, explicit editing/navigation, focus feedback, readable layouts and TTS improvements. The feature specification preserves the earlier requirements, not today's key map. |
| September-October: `b2a3d1c`, `153f009`, `635a66a` | Users and content need class-level organization; teachers need assessment | Class/subject administration and quiz workflows added. |
| October-November: `3c133ce`, `c5ae1c4`, `d02a06b`, `009eff9` | Support independent learning and operational visibility | Resume/bookmarks, offline learning, separate analytics, and journeys combining content with questions. |
| 19 Nov: `25e8ac4`; mentor input recorded in the earlier design | Repeated setup burdens blind teachers; the backend already knows the class context | Administrator-managed accounts/timetable; phone sign-in; one-key start/join; automatic alerts; fewer phone-side management tasks. |
| 20 Nov: dated design entry, retained in the 23 Nov revision | Quiz, journey and recording controls compete for keys; returning screens are verbose | One Start menu, contextual Status, one activity at a time; controls spoken before playback; one leave confirmation; shorter return speech. |
| 23 Nov: `f694152` | Administrators need to prepare work on a teacher's behalf; keypad input can remain captured after sign-in | Delegated quiz/journey authoring; release stale input-method focus and retain top-screen shortcuts. |
| 24 Nov: `d719ccb` | English-only prompts exclude preferred-language use | Five-language interface text and speech, profile-specific preferences and explicit voice fallback. |
| 25 Nov: `ce63008` | Instructions still too long; class screen still overloaded; changes by others are not discoverable | One-sentence key lists; first-key-only return prompts; hands console/full-status page removed; consecutive stable keys; spoken assignments and durable notices. |
| This revision | The design history mixed old mappings, current rules and suggestions | One current key map, traceable decision register and explicit open decisions; no application behavior changed. |
| 26 Nov: interaction reduction (after `ce63008`) | Remaining avoidable interactions: Settings to choose speech, OK and 1 to sign in, typing a number the SIM knows, lowering a hand after speaking, leaving finished class work, retrying after brief network loss | D28-D34: administrator-set speech, automatic sign-in, SIM number use, automatic hand lowering, return to class, quiet retries and queued actions. |

**Central iteration:** expose available features -> reduce repeated setup ->
reduce spoken/navigation load -> announce only actionable changes. The
redesign optimizes interaction cost, not the number of available features.

## 3. Decision register

All decisions below are implemented in source unless a limitation is stated.
Evidence IDs link to the source index in section 8. Alternatives marked
Reconstructed are review-time comparisons, not historical research findings.

### A. Responsibility, identity and class entry

| ID | Decision | Why | Alternative / trade-off | Evidence |
|---|---|---|---|---|
| D01 | Vision Empower manages accounts, enrolment and timetable; can author quizzes/journeys for teachers | Do setup once instead of repeating it through speech and keypad entry | **Prior:** self-registration, role choice and teacher-managed setup. Administrative accuracy and workload become dependencies. | E1, E2 |
| D02 | Teacher/student sign-in uses a registered number; shared devices add a 1-4 digit profile number; administrators use passwords | Reduce typing; select separate accounts and preferences on shared phones | **Prior:** passwords and role selection. Number/profile entry is **not identity verification**; impersonation remains a pilot risk. | E2 |
| D03 | Home offers the current/next class; one-key start/join; generated titles; one live class per teacher and class | Remove choices the timetable and enrolment already answer | **Prior:** create/title/invite/search/refresh flows. Server constraints prevent ambiguous concurrent classes; exceptional unscheduled teaching stays under More. | E3 |
| D04 | School-local timetable, UTC storage; bounded class cutoff and extensions | Avoid timezone ambiguity and protect the following lesson without abruptly ending at the timetable time | **Reconstructed:** hard stop at scheduled end is simpler but inflexible; unlimited overrun risks the next class. Legacy undated live sessions still require administrator action. | E3 |
| D05 | Ringing alerts plus self-updating Home; students explicitly join or opt into pre-class auto-join | Push makes class entry discoverable but must not be the only route | **Prior:** manual Refresh/session selection. **Recorded proposal, not adopted:** automatic countdown join on app open; it reduces a key press but weakens user control. | E3, E4 |
| D06 | Persist notices for affected users, excluding the actor; speak them on Home and acknowledge them | People cannot visually scan for changes; server storage survives the phone being off | **Recorded:** push-only can be missed; a What's new list adds navigation; an all-day event stream adds connection overhead. Once-only narration is an intention, not a guaranteed exactly-once delivery protocol. | E4 |

### B. Keypad, speech and live-class interaction

| ID | Decision | Why | Alternative / trade-off | Evidence |
|---|---|---|---|---|
| D07 | Shared keypad policy with explicit editing/navigation, D-pad focus and native-input release | Digits must enter text while editing and reliably trigger actions otherwise, including after sign-in | **Prior:** focus/input-method capture could swallow shortcuts. **Reconstructed:** timing-sensitive long presses would add learning and motor demands. | E5 |
| D08 | Consecutive permanent keys; rare actions under More; temporary actions appended | Fewer choices to hear; activity changes must not renumber familiar actions | **Recorded:** keep old gaps to avoid relearning, remove chat/class list, or place Status before End. These respectively retain confusion, remove useful functions, or destabilize End. One-time relearning was accepted. | E5, E6 |
| D09 | First arrival reads all keys in one sentence; returning reads the first key and Back; editing instructions only in contextual help | Preserve discovery while shortening frequent repeat visits and irrelevant instructions | **Prior:** repeated "Press" per key; return prompts listed keys 1-3. **Recorded:** star-only discovery hides actions; first-three-visits adaptation remains a proposal. | E5 |
| D10 | Wait for data before speaking counts; cancel stale arrival speech; prioritize narration; support self-voicing or screen-reader mode | Avoid false empty states, speech over the user's action and competing narration | **Prior:** premature counts and delayed instructions. **Reconstructed:** narrating every update immediately would interrupt requested explanations. Live teaching audio is not automatically paused like recorded lessons. | E5, E7 |
| D11 | Everyone joins muted; students raise a hand and self-unmute when called; teacher has Mute all, not per-student controls | Classroom etiquette can replace a list/select/confirm interaction | **Prior:** individual microphone management and classroom-check controls. Current etiquette is **not enforced permission to speak**: students can still self-unmute; there is no Unmute all. | E6 |
| D12 | One teacher-only attendance summary after a minute; later changes grouped by name; hands announced without a console | Preserve awareness without speaking over every initial join or making the teacher manage a queue | **Prior:** raised-hands console and full-status page. **Recorded:** queue positions/acknowledgement controls add listening and navigation; mute/hand protocol replaces them for small classes. | E6 |
| D13 | One Start menu for quiz/journey/recording; one class activity at a time; Status only while running | One mental model for starting and monitoring work | **Prior:** separate keys and more permanent controls. Starting a quiz/journey pauses recording; recording closes the offered activity. Closing does not delete published work. | E6 |
| D14 | Announce an assignment with "Press 5 to start", including for late joiners; student chooses when to open it | A newly appearing control is otherwise invisible to a blind learner | **Recorded:** auto-open removes control; a sound alone lacks meaning; repeated automatic announcements interrupt teaching. Announce once per assignment in the current class interaction. | E6 |
| D15 | Read recording controls before automatic playback; any early key press cancels auto-start; player key 8 closes class playback | The teacher must hear the controls before competing audio begins and be able to stop sharing | **Reconstructed:** immediate playback is faster but masks instructions. Full seek/speed/select controls remain; a lesson-only player is still proposed. | E6 |
| D16 | One leave confirmation, at most three seconds waiting for the server; leaving differs from ending the class | A user should not be trapped by a poor connection or asked to judge a technical timeout | **Prior:** second "leave without confirmation?" question. Closing the connection also informs presence, but network failure can delay server reconciliation. End-for-everyone remains a separate confirmed action. | E6 |
| D17 | One text catalog per language; English, Hindi, Kannada, Telugu and Bengali; per-profile choice and explained English fallback | Keep keys stable and maintenance shared while supporting preferred-language use | **Recorded:** runtime translation needs connectivity and unpredictable wording; separate builds multiply releases; recorded prompts are costly to update. AI-draft translations still need native review; class voice commands remain English-only. | E7 |
| D18 | Single-column reflow, large-text support, deterministic focus; numbered menus/list pages limited to five choices | Fit a 240x320 display without relying on touch or hiding the next action | **Reconstructed:** dense dashboards and long lists expose more at once but increase traversal. Five-choice menus are a component limit, not a claim that every screen has only five actions. | E5 |

### C. Learning continuity, data and platform

These choices broaden the record beyond the November classroom redesign.
Where the earlier document did not record alternatives, the comparison is
explicitly reconstructed.

| ID | Decision | Why | Alternative / trade-off | Evidence |
|---|---|---|---|---|
| D19 | Continue learning, saved position/speed, bookmarks, A-B repeat and account-local private recordings | Let learners resume and revisit difficult material without restarting or sharing personal notes by default | **Reconstructed:** live-only learning or restart-from-beginning is simpler but removes learner control. Account scoping does not mean encryption or protection against device-level access. | E8 |
| D20 | Account-scoped offline lesson/journey storage with integrity checks, expiry and a shared 50,000,000-byte media allowance; Wi-Fi journey downloads | Tolerate intermittent connectivity without unbounded storage or unrestricted stale access | **Reconstructed:** stream-only fails offline; unlimited/permanent caching consumes storage and retains access indefinitely. Browser recordings stream; native-app offline capability must not be promised for web. | E8 |
| D21 | Journeys combine content/questions/polls; bounded retries replay linked content; published snapshots and idempotent run sync | Integrate explanation and practice; preserve the content version actually attempted and avoid duplicate results after reconnect | **Reconstructed:** separate audio/quiz screens fragment the flow; mutable published content or trusted client scores undermine consistency. The server recomputes correctness; first-try performance is preserved. | E9 |
| D22 | Accessible question-bank/quiz authoring, graded/practice modes, question snapshots and timed accommodations | Support both assessment and practice without later bank edits silently changing copied questions | **Reconstructed:** one quiz mode or live references are simpler but constrain teaching and stable assessment. Extra time applies to eligible timed graded quizzes, not every activity. | E9 |
| D23 | Enforce class/subject/ownership access on the backend; archive catalog entries rather than erase history | Client filtering is not authorization; past teaching and assessment records must survive catalog changes | **Reconstructed:** UI-only filters can be bypassed; deleting associated history loses evidence. A teacher sees assigned workspaces; student access follows active enrolment. | E10 |
| D24 | Retain Flutter client, FastAPI service and async SQLAlchemy/PostgreSQL persistence | Shared client components and centralized state/rules suit the implemented platform | **Reconstructed:** separate native clients duplicate interface work; client-owned class state fragments authority. This is an inherited stack, not a documented comparative technology evaluation. | E1, E10 |
| D25 | REST for actions, SSE for live events, WebRTC mesh for participant audio | Separate request/response, server updates and low-latency media responsibilities | **Prior:** WebSocket event channel, replaced in February. **Reconstructed:** polling trades latency for simplicity; an SFU may scale audio better but adds infrastructure. Mesh has no demonstrated safe class-size limit yet. | E11 |
| D26 | Durable deduplicated jobs, backend class records and an administrator issues list; no routine teacher history screen | Restarts must not lose reminders/endings; operational detail should not crowd teaching | **Prior:** teacher-side history and management. **Reconstructed:** in-memory timers lose scheduled work on restart. Durable jobs do not make in-memory live presence durable. | E3, E12 |
| D27 | Separate thin analytics app; validated local-model intents, exact scoped queries, structured filters and reviewed campus transcription | Keep heavy inference off the phone, constrain data access and make results explainable | **Reconstructed:** bundling models increases footprint; cloud transcription changes data boundaries; model-generated SQL/answers bypass deterministic metrics. Model/speech production enablement remains gated; unsupported questions require clarification, not guesses. | E13 |

### D. Interaction reduction (26 November 2026)

Chosen by the project owner from a list of suggestions for removing key
presses, decisions and listening time. Alternatives below are
**Reconstructed** unless stated.

| ID | Decision | Why | Alternative / trade-off | Evidence |
|---|---|---|---|---|
| D28 | The administrator may set each person's speech language and speed in the dashboard; the phone applies a value at sign-in and on Home updates only when the administrator's value changed since it was last applied; the person can still change it in Settings | A blind person should not have to find Settings to hear the app in their language at a comfortable speed (backend already knows, D01) | Always enforce the administrator's value (removes the person's control); apply only at account creation (later corrections never arrive); leave it to Settings (the old burden). A Settings change wins until the administrator changes that value again. A language chosen before signing in still wins over both. | E2, E4, E7 |
| D29 | Sign-in starts by itself when the number is complete: 10 digits (11 with a leading 0, 12 with +91); a shared phone's profile number continues once it reaches the length the server gives | Removes OK and 1 from the most frequent first task | Keep an explicit sign-in key (one more press and spoken step); a short pause after typing (timing-sensitive on T9 keypads). Key 1 still works. A wrong number is answered at once instead of after a confirmation step. | E2 |
| D30 | On Android, the SIM card's number is read on opening sign-in without any SEEDS question. The phone's own permission prompt appears at most once; one readable number signs in, two SIMs ask which, no SIM or a refusal means typing. After a deliberate logout the number is filled in but not used to sign in | Most people use their own phone; typing ten digits on a keypad is the largest remaining effort | **Prior:** never automatic, consent dialog first (key 2, still available). Reading only when asked protects privacy but costs every user every time; auto sign-in after logout would put the next person into the previous account. | E2 |
| D31 | When a student with a raised hand unmutes, the server lowers the hand in the same request | Being called and speaking means the request is answered; one fewer key and an accurate hands state for the teacher | Lower hands when the teacher speaks a name (not detectable reliably); leave it to the student (forgotten hands mislead the teacher). A student who unmutes without being called also loses the raised hand. | E6 |
| D32 | A quiz or journey opened from a live class returns to the class by itself after its finishing sentence; opened from Home, the result screen stays | The student's next task is the class; from Home, the result is the destination | Always return (from Home the result would be lost); never return (an extra 0 and a "back in class" step during teaching). The result stays available from Home. | E6, E9 |
| D33 | Connection failures are retried unheard for about ten seconds; reads, deletes and sign-in also retry timeouts, other writes do not. Connection and service errors end with "Press N to try again", where N is the key just pressed (1 on sign-in) | Brief drops on mobile networks are common; hearing an error for each is noise, and the person needs the one key that fixes it | Report immediately (frequent false alarms); retry forever (silent hangs). Retrying a write that timed out could repeat it, so only connection-refused writes are retried. Errors with no fixing key (for example an unregistered number) are unchanged. | E4, E5 |
| D34 | Raising or lowering a hand, and a quiz answer, are kept on the phone and sent again every few seconds until the connection returns; the person is told once. Pressing 2 again cancels a waiting hand; a waiting answer does not block leaving the quiz | These actions should not fail and ask to be repeated; the intent is clear | Persist queued actions across app restarts (more storage and stale actions in a later class); queue every action (stale chat or control actions could arrive late and surprise the class). The queue lasts while the screen is open. | E6, E9 |

## 4. Current interaction contract

This is the **current** reference. Earlier November key numbers are historical,
not alternative mappings to implement.

### 4.1 Common flows

```text
Administrator: accounts + enrolment + teacher assignments + weekly timetable
               (+ optional speech language and speed per person)
               -> optional prepared lesson / published quiz / journey
Sign-in:       SIM number used by itself, or type it -> signs in at the last digit
Teacher:       Home identifies today's class -> 1 Start -> teach -> 6 End (confirm)
Student:       alert + OK, or Home -> 1 Join -> listen / hand / speak when called
In class:      teacher 4 Start -> quiz / journey / recording -> contextual Status
               student 5 -> quiz / journey -> back in class by itself when finished
Independent:   student 2 Continue learning -> resume -> progress saves / later sync
```

**One-key start/join is measured from an authenticated, loaded Home screen.**
It is not a measured launch-to-teaching time and does not include sign-in,
permissions, loading, text entry or confirmations on other actions.

### 4.2 Keypad grammar

| Key / context | Current behavior |
|---|---|
| Digits | Announced screen choices; text digits remain text while editing |
| D-pad / OK | Move through controls / activate; OK enters or leaves field editing |
| 0 | Back/cancel; Home logout and class leave ask for confirmation |
| Star | Screen, state, last message and all keys; editing help only where relevant |
| Hash | Stop app speech; does not navigate |
| 8 | Usually last message; menus use Details; teacher recording player uses Close for class |
| Audio player | 4/6 seek ten seconds; 5 play/pause; 7/9 slower/faster |
| Quiz answers | 1-4 select; 5 submit; 6 repeat question |

Key meanings have **documented contextual exceptions**, not universal sameness.
Numbers for permanent actions stay stable within a screen and role.

| Key | Teacher Home | Student Home | Teacher in class | Student in class |
|---|---|---|---|---|
| 1 | Start/return/next class | Join/pre-class auto-join | My microphone | My microphone |
| 2 | Quizzes | Continue learning | Mute all students | Raise/lower hand |
| 3 | Journeys | Journeys | Class list and reminders | What is playing |
| 4 | Playlists | Quizzes | Start: quiz/journey/recording | More |
| 5 | More | More | More | Start assigned activity, only when offered |
| 6 | - | - | End for everyone, confirm | - |
| 7 | - | - | Status, only while something runs | - |
| 0 | Log out, confirm | Log out, confirm | Leave; class stays live | Leave, confirm |

- **Teacher Home More:** offline library, change subject, unscheduled class,
  settings. **Student Home More:** library, playlists, settings.
- **Teacher class More:** add 15 minutes, chat. **Student class More:** chat,
  who is here. Teacher class list includes here/left/not joined and reminders.
- **Opening:** name + known state + all available keys in one sentence + star.
  **Returning:** name + state + first key + Back + star for all keys.
- **Speaking protocol:** join muted -> student raises hand -> teacher hears
  the name and calls the student -> student self-unmutes, which lowers the
  hand -> teacher can mute all.
  No enforced floor grant, hands console or per-student microphone controls.
- **Activity status:** quiz/journey attempted/finished counts, unfinished
  learners, reminders and stop offering; recording Status opens its controls.
  Class sound continues while students open assigned work.

### 4.3 Server policy and operational defaults

| Area | Rule / default |
|---|---|
| Account setup | Student requires a class; teacher requires at least one class/subject assignment. Shared-phone profiles retain separate local settings. Optional speech language (en, hi, kn, te, bn) and speed (0.25-2.0 on the flutter_tts scale) per account (D28). |
| Sign-in | Automatic at 10 digits (11 with leading 0, 12 with +91) and at the server's profile-number length; Android SIM number used when permitted, permission asked once (D29, D30). |
| Network | Connection failures retried unheard for 10 seconds (writes only when the connection was refused); hand and quiz answers then retried every 3 seconds until sent (D33, D34). |
| Weekly schedule | Multiple weekdays may be entered together; teacher/class overlaps rejected; holidays and per-date cancellations/substitutes/lesson overrides supported. |
| Administrator filter | Selecting a teacher limits the class filter to their assignments; an incompatible selection resets to All classes. Avoids impossible empty results without hiding classes lacking timetable entries. |
| Start | Teacher action, not an automatic timetable launch; idempotent; opens 10 minutes early by default (`CLASS_EARLY_START_MINUTES`). |
| No timetable | Unscheduled class under More, 45 minutes by default (`UNSCHEDULED_CLASS_MINUTES`). |
| Concurrency | One live session per teacher and per enrolled class, enforced with database uniqueness constraints. |
| Cutoff | Earlier of scheduled end + 30 minutes or five minutes before the teacher's/class's next lesson; warnings at five and one minute. |
| Extension | Add 15 minutes, bounded by the next-lesson limit; administrator can extend/end. Legacy live sessions without an end time are not silently auto-ended. |
| Alerts | Ring up to 60 seconds where Android permits; one automatic reminder after ten minutes for never-joined students; five-minute per-student cooldown. |
| Home refresh | On arrival, foreground/resume and push; every 20 seconds while Home is current. Failures back off to two minutes, so 20 seconds is not a delivery guarantee. |
| Attendance speech | Teacher-only summary after one minute; subsequent joins/leaves grouped within two seconds. Class size is enrolment, not a fixed cap. |
| Prepared lesson | Timetable playlist preselects the first recording and advances through prepared parts; controls are spoken before class playback begins. |
| Time | `SCHOOL_TIMEZONE`, default `Asia/Kolkata`, for timetable entry/display; timestamps stored as UTC. |
| Records and failures | Attendance, session lifecycle, quiz/journey results stay on the backend; repeated job failures surface in the administrator issues list. |
| Notifications | Add/remove/cancel lesson: affected teacher/students; timetable update: teacher; reassignment/substitution: relevant teachers; published work: students and teacher when prepared by administrator. Never notify the actor about their own action. |
| Re-entry | Home resolves the existing live class after interruption; optional pre-class auto-join applies only while Home remains open. |

## 5. What feedback changed

| Feedback / observation | Before | Current response | What still needs proof |
|---|---|---|---|
| The system already knows the class | Teacher creates, names and invites | D01-D05: configured defaults and one action | Fewer errors and faster class start on actual phones |
| Instructions consume too much time | Repeated per-key phrases and long return help | D09-D10: compact discovery, brief returns, contextual help | Home/class opening speech under 15 seconds at the tested rate/language |
| Classroom has too many controls | Individual mute, hands console, full-status page | D08, D11-D13: voice protocol, named events, More, one Start | Blind teachers can manage real class turn-taking without the removed console |
| Changes by others are invisible | User must discover new/changed work | D06, D14: Home notices and actionable assignment speech | Correct recipients, late joins, delayed/offline recovery and acknowledgement behavior |
| Learners need language and continuity | English/live-session dependence | D17, D19-D22: preferred-language speech, resume, offline journeys | Native-speaker review, download reliability and classroom learning usefulness |

These are **design hypotheses with implementation evidence**, not measured
usability improvements. No before/after timing or learning-effect claim is made.

## 6. Open decisions and risks

### 6.1 Proposed, not current behavior

| ID retained from earlier design | Proposal | Reason to defer / decision needed |
|---|---|---|
| S3 / G3 | Teacher-controlled mute/unmute-all; student Unmute raises a hand while locked | Decide whether opening every microphone is safe; current students may self-unmute at any time. |
| S4 | Full prompts only on the first three visits per person/screen | Measure current speech first; counters complicate predictable behavior and shared phones. |
| S5 / G5 | Lesson-only player; advanced controls under More | Check whether simpler play/pause outweighs additional navigation for seek/speed. |
| S6 / G4 | Home names up to five classmates, otherwise speaks the count | Helps orientation but lengthens every arrival; roster names are not currently in Home speech. |
| S7 | Countdown auto-join on opening the app | Assess consent, interruptions and accidental entry; current entry is explicit or pre-selected. |
| S9 / G6 | Voice-command device trial; possibly push-to-talk | Test student speech/recording playback, loudspeaker/earphones and false activations; keypad must remain sufficient. |
| S10 | Retire unreachable legacy flows and unused translations | Confirm reachability first; old code/strings are not evidence that the old UX remains current. |
| S11 | Native-speaker review of Hindi, Kannada, Telugu and Bengali | Start with sign-in, Home and class prompts; AI-draft text is not validated localization. |

Former S1/S8 (named grouped presence and the one-minute summary) are implemented,
so are not retained as pending suggestions.

### 6.2 Deployment and evidence limits

- **Identity:** a known number/profile can impersonate a teacher or student.
  This is an explicitly unverified pilot model, not production authentication.
- **SIM number:** reading it requires Android's phone permission and the
  carrier to expose the number (many do not). Automatic sign-in from the SIM
  inherits the identity limit above; after a deliberate logout it only fills
  the number.
- **Queued actions:** a waiting hand or quiz answer lives only while its
  screen is open; closing the app drops it. A quiz answer retried after a
  timeout may already be saved, in which case the server's answer decides.
- **Android delivery:** push, full-screen alerts, locked-screen behavior,
  microphone permission and T9/IME recovery require real-device checks.
- **Scale:** SSE presence is in one backend process; use one backend worker
  until shared presence exists. WebRTC mesh must be tested at the largest real
  enrolment; no arbitrary class-size cap or scalability result is claimed.
- **Browser testing:** many same-origin SSE tabs can exhaust browser connection
  limits; use separate browsers/devices for realistic multi-user checks.
- **Offline/privacy:** storage limits and integrity checks are not encryption.
  Browser/native capabilities differ; expired/revoked access and account
  switching need explicit checks.
- **Notices:** acknowledgement and speech are not transactional. Test failures
  between fetching, marking seen and finishing speech; do not claim exactly-once
  listening across crashes/devices.
- **Analytics:** model/speech enablement, local runtime selection, permissions,
  consent/retention and production deployment gates remain separate from having
  the feature implemented.

## 7. Validation and viva demonstration

### Software evidence already present

The repository includes focused tests for class defaults/cutoffs/concurrency,
notices, admin authoring, keypad focus, compact speech, localization structure,
offline integrity/account isolation, quiz grading, journey replay/sync, and
scoped analytics. See section 8. **These suites were inspected, not rerun for
this documentation-only revision.**

### Short demonstration and remaining acceptance checks

| Demonstration / check | Observe or measure |
|---|---|
| Sign in; start a scheduled class | Keypad-only path; SIM number used without a question; typed number signs in at the last digit; exactly one Start press from authenticated, ready Home; separately time app-open to teaching |
| Alert / late join | Locked/closed app behavior and OK; missed push still permits Home -> 1 Join; refused microphone still permits listening |
| Return from a sub-screen | Only main action/Back narrated; star exposes all keys; hash only stops speech; no T9 shortcut capture |
| Teacher manages participation | One summary at one minute; grouped arrivals; named hand; student speaks when called; Mute all works with real audio |
| Start quiz/journey/recording | One offered activity; actionable assignment speech for present and late students; instructions before playback; key 8 closes class recording |
| Change/cancel lesson as administrator | Only affected others receive notice; observe normal refresh and offline/failure recovery, not just push receipt |
| Resume/offline/account switch | Saved learning resumes; downloads stay within the exact quota; corrupt/expired files fail clearly; another profile cannot inherit progress |
| Weak connection | Brief drops pass unheard; after 10 seconds the error names the key to retry; a raised hand and a quiz answer go through when the connection returns |
| Administrator sets speech | The person's phone speaks the chosen language and speed after sign-in or within one Home update; a later Settings change is kept |
| End / network loss / restart | Warn at five/one minute; bounded extension; leave returns despite server timeout; reconnect resolves class; jobs survive backend restart |
| Speech in every language | Time Home/class opening: target **under 15 seconds**; record speech rate, language and voice; check missing-voice explanation and native-language comprehension |
| Full enrolled class / voice commands | Measure audio quality, delay and false triggers at the largest intended class; test loudspeaker versus earphones |

For the viva, present one chain explicitly:

> **Feedback:** "too much to hear" -> **alternatives:** retain verbose help,
> hide help behind star, or shorten contextual prompts -> **choice:** full
> one-sentence discovery plus brief returns -> **implementation:** shared
> keypad wrapper -> **evidence still needed:** timed blind-user trials.

Record device, network, language, speech rate, task completion, errors and
participant feedback in future trials. Do not substitute a passing widget test
for target-device or blind-user evidence.

## 8. Source and traceability index

Paths identify implementation and existing tests; they are not claims of a new
test run. Historical reasoning also comes from the previous version of this
document at `ce63008`. Commit IDs in section 2 allow the iteration to be checked
with repository history.

| Evidence | Primary sources and checks |
|---|---|
| E1: context and inherited platform | [README](README.md), [earlier testing specification](FEATURE_SPEC.md), [app bootstrap](frontend/lib/main.dart), [API application](backend/main.py) |
| E2: setup, identity and delegation | [Sign-in](backend/sign_in_routes.py), [school administration](backend/school_admin_routes.py), [delegation context](backend/auth.py), [authoring tests](backend/tests/test_admin_authoring.py), [authentication tests](backend/tests/test_auth.py) |
| E3: schedule, lifecycle and invariants | [Class lifecycle](backend/classroom.py), [time rules](backend/scheduling.py), [models](backend/models.py), [classroom tests](backend/tests/test_classroom.py) |
| E4: Home and change awareness | [Home refresh/notices](frontend/lib/screens/home_updates.dart), [server notices](backend/teacher_notices.py), [student Home](frontend/lib/screens/student_dashboard.dart), [teacher Home](frontend/lib/screens/teacher_dashboard.dart) |
| E5: keypad and layout | [Shared keypad wrapper](frontend/lib/widgets/key_instruction_wrapper.dart), [key resolution](frontend/lib/utils/keypad_config.dart), [numbered menus](frontend/lib/widgets/numbered_menu.dart), [keypad tests](frontend/test/keypad_instruction_wrapper_test.dart), [navigation tests](frontend/test/numbered_navigation_test.dart), [large-text tests](frontend/test/large_text_reflow_test.dart) |
| E6: live-class interaction | [Session interface](frontend/lib/screens/session_screen.dart), [spoken class labels](frontend/lib/announcers/session_text.dart), [microphone controller](frontend/lib/services/session_microphone_controller.dart), [microphone tests](frontend/test/session_microphone_widget_test.dart) |
| E7: speech and language | [TTS service](frontend/lib/services/tts_service.dart), [language selection](frontend/lib/l10n/speech.dart), [English catalog](frontend/lib/l10n/app_en.arb), [speech tests](frontend/test/speech_accessibility_test.dart), [catalog tests](frontend/test/l10n_arb_test.dart) |
| E8: independent/offline learning | [Playback controller](frontend/lib/services/learning_playback_controller.dart), [progress store](frontend/lib/services/learning_progress_store.dart), [learning autopilot](frontend/lib/services/learning_autopilot.dart), [offline lessons](frontend/lib/services/offline_lesson_store.dart), [offline journeys](frontend/lib/services/offline_journey_store.dart), [private notes](frontend/lib/services/private_note_store.dart), [offline tests](frontend/test/offline_lesson_store_test.dart) |
| E9: journeys and assessment | [Journey engine](frontend/lib/services/journey_engine.dart), [journey API](backend/journey_routes.py), [quiz API](backend/quiz_routes.py), [journey tests](backend/tests/test_journeys.py), [quiz tests](backend/tests/test_quizzes.py), [guided quiz tests](frontend/test/guided_quiz_test.dart) |
| E10: data boundaries | [Authorization helpers](backend/access_control.py), [models](backend/models.py), [database](backend/database.py), [class-access tests](backend/tests/test_class_access.py) |
| E11: event/media transport | [SSE client](frontend/lib/services/sse_service.dart), [event manager](backend/ws_manager.py), [live audio peers](frontend/lib/screens/session/session_peers.dart), [SSE tests](frontend/test/sse_service_test.dart) |
| E12: durable operations | [Job worker](backend/jobs.py), [issues](backend/admin_issues.py), [session history](backend/session_history.py), [deployment constraints](BACKEND_DEPLOYMENT.md) |
| E13: analytics | [Dashboard design](analytics_dashboard/README.md), [local intent adapter](backend/model_client.py), [exact analytics](backend/analytics_service.py), [analytics tests](backend/tests/test_analytics.py), [model tests](backend/tests/test_model_client.py) |

**Maintenance rule:** change the current contract and decision register together;
record the trigger and trade-off when a decision changes. Keep rejected,
superseded and proposed designs labelled rather than silently presenting them
as implemented behavior.
