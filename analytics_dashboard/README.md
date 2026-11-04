# SEEDS Analytics

Independent, thin Flutter dashboard for **web and Android**, using existing
administrator/teacher accounts and the campus backend. No Firebase, WebRTC,
database, LLM weights or transcription models are bundled.

From this directory:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=https://YOUR-CAMPUS-HOST/seeds
flutter build web --release --no-web-resources-cdn --dart-define=API_BASE_URL=https://YOUR-CAMPUS-HOST/seeds
flutter build apk --debug --dart-define=API_BASE_URL=https://YOUR-CAMPUS-HOST/seeds
```

Configure production signing before distributing an Android release; generated
development signing is not a production key. Host web output over HTTPS and
configure trusted backend CORS origins. Do not deploy the default localhost URL.

The layout is responsive: phones get a single column and wide screens show
results beside the question. Administrators switch between Queries and Health
with bottom navigation on phones or a side rail on wide screens.

## Queries and privacy

Ask using names, for example "How many sessions were created by Teacher X for
Subject Y and Class Z?" Structured filters work without a configured model.
Available metrics cover session creation/openings, verified unique attendance,
finalized graded attempt counts/average percentages, and activity counts.
Scoped autocomplete supplies internal selections without requiring users to
memorize database IDs; ambiguous names require selection.
Structured filters offer reporting dates in Asia/Kolkata. Follow-up questions
send only the previous typed filters, not a raw conversation history; the server
revalidates access on each query. Unsupported or unclear questions require
explicit filters rather than a guessed answer.

A reopened session is **one created session** with another opening run.
Session-wide attendance deduplicates students across runs; invitations and
teacher-added placeholders do not prove attendance.

Recording is explicit, foreground-only and limited to 60 seconds. Audio goes
only to campus transcription, not a browser/cloud recognizer. Review/edit the
transcript, then select Ask. No question is queried automatically.
Validate actual web/Android codecs and microphone interruption on target devices.

Tokens, questions, answers and transcripts stay in memory. Refresh/logout
clears sign-in/context; conversation context expires after five minutes.
No background polling; health data loads on selection or explicit refresh.
Results are bounded and activity groups are paginated.

## Production gates

Migrations/permissions and institutional notices must be approved before flags
are enabled. Select and benchmark one local runtime/model, explicitly evaluating
Foundry Local/Qwen; no Azure inference is enabled. Provision local speech and
campus SMTP separately. Verify PostgreSQL access, HTTPS, backup/erasure rules,
actual microphone/accessibility behavior and Android release signing.

Measure compressed web transfer, APK size, startup and memory against a clean
same-SDK Flutter scaffold. Flutter engine assets dominate the baseline; no
unmeasured "tiny APK" promise is made. See the root deployment runbook.

### Local release footprint

Same-SDK, ARM64 release builds compared with an untouched Flutter scaffold:

| Artifact | Dashboard | Scaffold |
|---|---:|---:|
| APK (bytes) | 16,864,219 | 14,609,479 |
| Main web JavaScript, gzip (bytes) | 760,932 | 523,354 |
| Full local web directory (bytes) | 31,423,554 | 30,578,286 |

Both web builds use `--no-web-resources-cdn`; the directory includes local
CanvasKit assets and is not a single-page transfer-size measurement. The APK
comparison uses development signing and the dashboard's localhost API default,
not a distribution-ready build. Startup, memory and actual target-device voice
behavior remain unmeasured.
