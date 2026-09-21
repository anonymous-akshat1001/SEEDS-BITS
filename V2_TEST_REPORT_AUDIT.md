# SEEDS v2 Testing Report Audit

Source reviewed: `v2 - SEEDS Testing Report.pdf` (8 pages, July 2026).

Review method: full text extraction plus visual inspection of every rendered
page. Tables, screenshots, prose observations, recommendations, and open
questions were all included. The PDF was treated as test evidence, not as a
source of implementation instructions.

## Result summary

The six new bugs in section 6.2 and the critical keypad recommendations in
section 8 are resolved in the current code. The review also found residual
accessibility/privacy issues outside the issue tables; these were addressed in
the September 2026 audit pass as described below.

Claims involving timing or physical key delivery remain subject to a fresh
BlackZone-device run. Automated widget tests cannot establish hardware keypad
reliability.

## Complete finding audit

| Report finding | Current status | Evidence or disposition |
|---|---|---|
| APK installs as `frontend` / stages as `Unknown` | Resolved in app metadata | Android label and Apple display metadata use `SEEDS`; Flutter application title is also `SEEDS`. The OS installer may still show a generic staging label before package metadata is read. |
| Download is named `app-debug.apk` | Resolved for release process | Release convention is `SEEDS-v<version>.apk`. Debug artifacts retain Flutter's normal debug name. |
| Multi-step unknown-source/virus-warning installation | External distribution issue | Android/Chrome security cannot be bypassed by app code. Distribute a signed release through Play Store, managed device deployment, or an administrator-assisted documented sideload. |
| 28-second blank white launch | Resolved visually; timing needs device measurement | Native branded launch resources and an immediate Flutter `SEEDS is loading` screen now provide visual/TTS feedback. Firebase/notification initialization is deferred. Re-measure cold-start time on BlackZone hardware. |
| Welcome TTS and `*` repeat | Preserved | Shared wrapper announces each screen and binds star to repeat. |
| Touch cannot repeat Welcome instructions | Resolved in this audit | Welcome now includes a touch-, screen-reader-, and D-pad-reachable Repeat instructions control. |
| Logo/subtitle/static feature cards are silent | Resolved | Welcome branding, subtitle, and feature cards have semantics, activation TTS, and focus targets. |
| Notification permission lacks explanation | Resolved in this audit | An accessible two-choice explanation is shown before an OS notification request. Initialization remains deferred until the app UI is usable. |
| Phone/SIM permission lacks explanation | Resolved in this audit | Login explains that SIM autofill is optional and unrelated to core login/session use before requesting phone permission. Skipping or denial leaves manual login usable. |
| Microphone permission lacks explanation | Resolved in this audit | Active session entry explains live-audio/voice-command use before the first request. A denial joins the user muted instead of blocking the whole session. |
| D-pad does not traverse Welcome/Login/Register | Resolved in code and widget tests | Ordered focus targets support Up/Down traversal; Enter activates controls or enters field editing. |
| Number `1` opens symbols/shortcuts while editing | Resolved in code and widget tests | Numeric shortcuts are suppressed whenever a registered or touch-focused editable field/search bar is active. Up/Down exits edit mode. |
| Settings inaccessible/trapped on Sync Tolerance | Resolved in code and widget tests | Welcome key 3 opens Settings. Every visible setting is in one focus order; slider Left/Right adjusts and Up/Down exits. Audio Sync Tolerance was removed. |
| Settings slider values are not announced | Resolved | Volume, speech rate, and text-size changes are announced immediately. |
| Voice-command section is vague/non-functional | Resolved in current active-session implementation | Settings lists mute, unmute, raise hand, lower hand, leave, and repeat instructions and states that they work only in active sessions. Session screens contain the command handlers. Hardware speech recognition remains a manual test. |
| Dashboard number shortcuts are intermittent | Resolved in shared input model and widget tests | Dashboard shortcuts use the same centralized key handler; refresh preserves prior focus and Join-by-ID enters field mode. Physical reliability still requires the prescribed 30-run device test. |
| Audio player was touch-only/not keypad-tested | Resolved in code | Session, upload metadata, library, class audio, and selection controls expose keypad focus targets and shortcuts. Device evidence remains required. |
| Dashboard Back logs out; no Logout button | Resolved | Back backgrounds/exits without clearing preferences. Explicit accessible Logout requires confirmation and clears auth/session values only on confirmation. |
| Registration raw password JSON | Resolved | Six-character validation runs locally and API failures pass through the safe failure mapper. |
| Invalid session ID shows raw 404 | Resolved | The user receives `Session not found. Check the session ID and try again.` visually and via TTS. |
| Other audio/session errors may expose raw details | Resolved in this audit | Remaining upload, library-load, and live-session server failures now use safe mapped text; raw detail stays in debug logs. |
| Teacher-name/helper text has low contrast | Resolved | Shared subtext token was darkened and high-contrast colors apply to major surfaces and controls. |
| No font-size adjustment / apparent lack of system scaling | Resolved in this audit | Flutter system font scaling is preserved and Settings now provides a persisted 90%-150% app text-size control with D-pad and TTS feedback. |
| High contrast previously ineffective | Preserved as fixed | Setting updates shared color tokens and persists across routes/restarts. |
| Registration returns to Login | Product decision, not a defect | Current flow intentionally requires authentication after account creation; changing this requires an explicit auto-login/security decision and a registration response that establishes a valid auth token. |
| No-SIM banner | Clarified and softened | No SIM is not a core error. Current copy describes optional autofill and tells the user to enter a number manually. Behavior with a SIM must be device-tested. |
| No session/content discovery | Substantially improved | Dashboards list active sessions with Join actions; the offline-library UI has class search and browsable content. Repository-wide discovery belongs to the planned content-repository feature. |
| Content unavailable without network | Unresolved feature gap | The screen called Offline Audio Library still depends on server data/streams. True download, cache, integrity, expiry, and storage-management behavior requires separately scoped offline-content work. |
| English-only UI | Unresolved feature gap | Regional-language localization requires translation assets, locale selection/fallback, localized TTS validation, and content-language metadata; this is not safely inferable from the bug report alone. |
| Advanced Audio / Audio Sync Precision purpose unclear | Resolved by removal | The unused Audio Sync Tolerance setting is hidden and its stale preference is removed. |
| APK remains large | Improved | The rebuilt universal release APK is 85.1 MiB versus the report's 182.55 MB debug artifact. ABI-split or Play App Bundle distribution is still recommended where supported. |

## Automated verification

- `flutter test --no-pub`: 15 tests passed.
- Coverage includes D-pad traversal, edit-mode shortcut suppression, star
  repeat, slider escape, login/registration validation, password visibility,
  safe API mapping, logout behavior, Settings persistence, high contrast,
  loading semantics, 1.3x system scale, app text-size persistence, and keypad
  operation of permission explanations.
- `flutter analyze --no-pub`: no compilation errors. The repository retains
  existing analyzer warnings/info (mostly deprecated Flutter APIs and style
  lints) that are not release blockers for this report's fixes.
- `flutter build apk --release --no-pub`: succeeded; output copied to
  `SEEDS-v1.0.0.apk` (85.1 MiB, SHA-256
  `BFBCD376131D3CC0EF96A1A16551FF5614F6F9F507BEA5839B4DE34DC161E034`).
  The Gradle project currently signs release-mode builds with the debug key;
  configure a protected release keystore before public distribution.

## Manual release gate still required

On a freshly installed release APK, run every journey without touch on the
BlackZone phone and once on a mainstream Android phone. Record device/OS,
30 consecutive successes for each shortcut/control, no-SIM and inserted-SIM
behavior, denied/granted permission paths, system font scale 1.3x, cold-launch
timing, launcher/recents/settings branding, and session-end routing for both
roles.
