# SEEDS: Revised Interface Design

Design document for the simplified SEEDS interface for blind teachers and
students on button (feature) phones. It records the decisions from the design
discussions and the mentor review, the rules that follow from them, how the
app behaves today, and what is still to be built and tested.

| | |
|---|---|
| Audience | Developers, testers, Vision Empower operations, reviewers |
| Status | Living document. Section 13 lists what is built and what is open. |
| Related | [README.md](README.md) (setup, API, full key reference), [FEATURE_SPEC.md](FEATURE_SPEC.md), [BACKEND_DEPLOYMENT.md](BACKEND_DEPLOYMENT.md) |

---

## 1. The problem

The first version of SEEDS asked users to do setup work that a sighted
administrator could do once: register, choose a role, create a session, type
a title, invite students, refresh lists, pick a class, mute people one by one.
For a blind user on a keypad phone every extra step costs a spoken
instruction, a key press and a chance to get lost. Reading every option on
every screen could take most of the class time.

The redesign moves that work to the backend and to Vision Empower, so the
teacher and student see only what they need at that moment.

## 2. Design principles

These rules decide every interface question. If a new feature breaks one of
them, the feature must be redesigned, not the rule.

1. **The backend already knows.** Vision Empower configures who the teacher
   is, which students are in the class, the subject and the weekly timetable.
   The phone number identifies the person. Nobody ever tells the app "I am this
   teacher, teaching this section, with four students".
2. **Assume the default.** When the teacher signs in, today's class is already
   prepared ("Wednesday 2 pm, Physics, Class 6"). The default needs one key.
   Changing it is possible but is never in the way.
3. **Minimise options.** A screen offers only what is needed at that moment.
   Rare actions go one level down, under **More**. If an option is rarely
   used, remove it rather than add a key.
4. **One key per intent.** "Start my class" is one key. "Join the class" is one
   key. There is no list of classes or sessions to pick from, because each
   person has at most one live class at a time.
5. **Protocol over controls.** Classroom etiquette (who may speak, when) is
   handled by the teacher's voice and a simple global control, not by many
   per-student buttons.
6. **Short, predictable speech.** The number of options is kept small so that
   the full list of keys is short enough to hear. Every screen reads all its
   keys whenever it is opened or returned to, so nobody has to press star
   first. Star repeats everything.
7. **Same key, same meaning.** Shared keys never move between screens (see
   section 8.1).
8. **Nothing is lost.** The backend keeps the records (attendance, class
   history, quiz results). They are not shown to the teacher on the phone
   unless they are needed in class.

## 3. Context and constraints

| Constraint | Consequence for the design |
|---|---|
| Users are blind; the app speaks through its own text-to-speech (TalkBack optional) | Every screen is usable with keys and speech alone; nothing depends on reading the screen |
| Android button phones: number keys, star, hash, D-pad, OK | Numbered keys for actions; D-pad for moving through controls; no gestures |
| Small screens (240x320), large text | One column, few controls, text that wraps |
| Classes are small, and their size is whatever Vision Empower enrols; there is no fixed limit | Join and leave news is grouped and counted ("4 of 5 here") rather than read one by one; the in-class audio mesh must be tested at the largest real class size |
| Connectivity is unreliable; the app talks to the server over HTTPS, with push notifications (FCM) and a live event stream in class | The app never relies on push alone: Home re-checks the server, and joining is always possible by opening the app |
| Vision Empower operates the service | Vision Empower staff are the administrators; a conventional (sighted) web/app dashboard is acceptable for them |

## 4. People and responsibilities

| Who | Does | Does not |
|---|---|---|
| **Vision Empower (administrator)** | Adds teachers and students by phone number; puts every student in a class and gives every teacher their class and subject pairs; enters the weekly timetable, holidays, cancellations and substitutes; attaches prepared lessons; can create and publish quizzes and journeys on a teacher's behalf; watches the issues list and class records; can extend or end a live class | Take part in classes |
| **Teacher** | Signs in with their phone number; presses one key to start today's class; teaches; calls students by name to speak; mutes everyone when needed; optionally opens a quiz or journey in class | Create sessions, type titles, invite or pick students, manage accounts or the timetable |
| **Student** | Signs in with their phone number; joins with one key (or by answering the class alert); listens; raises a hand; speaks when called; does the quiz or journey the teacher opens | Search for or choose classes |
| **Backend** | Decides everything that can be known in advance (section 5) | Ask the user anything it already knows |

## 5. Decisions owned by the backend

These questions are answered by configuration and rules on the server. The app
never asks the user about them. If someone asks "what happens if...", the answer
is in this table.

| Question | Answer (rule) |
|---|---|
| Who is this person? | The phone number they type. Teachers and students have no password. Administrators sign in separately with a password. |
| What if several people share one phone? | Vision Empower gives the phone a group entry number and each person a 1 to 4 digit profile number. Typing the shared number asks for the profile number. Each person keeps their own settings on that phone. |
| Which class does the teacher take now? | The timetable entry for today whose time window is open. It can be started from 10 minutes before the scheduled start (`CLASS_EARLY_START_MINUTES`). |
| What if the teacher has three classes today? | Home always offers only the current or next one. When one ends, the next becomes the default. The full day is available on request (Home, key 8: details). |
| Which students are in the class? | The students Vision Empower enrolled in that class. Nobody picks them. |
| How do students know the class started? | Starting the class rings every enrolled student's phone for up to 60 seconds. Students who still have not joined are rung once more 10 minutes later. Nobody is rung twice within 5 minutes. |
| How does the teacher know who came? | One minute after the class starts the teacher hears "4 of 5 students here." After that, joins and leaves are spoken by name, grouped: "Akshat and Meena joined. 4 of 5 here." The class list (key 4) has the full picture. |
| What if a student opens the app late? | Home shows "1: Join" whenever their class is live. One key joins. There is nothing to choose. |
| Can a teacher or student be in two classes at once? | No. The database allows one live class per teacher and per enrolled class (so per student). |
| What is the class called? | The system names it from the subject, class and time. There is no title to type. |
| When does the class end? | When the teacher ends it, or automatically at the earlier of: scheduled end + 30 minutes, or 5 minutes before the teacher's or the class's next lesson. Warnings are spoken 5 minutes and 1 minute before. The teacher can add 15 minutes (never past the next lesson). |
| What if the teacher must teach something other than the timetable? | Home, More: "Start a class outside the timetable" (45 minutes by default, `UNSCHEDULED_CLASS_MINUTES`). A teacher with several class and subject pairs can also change their default subject there. |
| Who substitutes, what is cancelled, what are holidays? | Vision Empower sets per-date changes in the dashboard. The substitute's Home shows the class; on holidays and cancellations nothing is offered. |
| What lesson will be played? | If Vision Empower attached a prepared lesson (playlist) to the timetable slot, its first recording is already selected when the class starts; the next part is selected automatically. |
| What times are used? | India Standard Time (`SCHOOL_TIMEZONE`, default `Asia/Kolkata`) for everything typed or shown; the server stores UTC internally. |
| What is recorded? | Who joined and when, when the class started and ended and why, quiz attempts and journey progress. Kept on the server; available to Vision Empower, not read out to the teacher. |
| Timed tasks (alerts, warnings, automatic end, reminders) | Stored in the database and run by a background worker, so a server restart does not lose them. Failures appear in the administrator's issues list. |

## 6. Main flows

### 6.1 Setup (Vision Empower, once per term and as things change)

1. Add each teacher and student: name, phone number, and a class (student) or
   class and subject pairs (teacher). A class is required for every student; at
   least one class and subject is required for every teacher.
2. Enter the weekly timetable: teacher, class, subject, days, start and end
   time, optional date range and prepared lesson. One entry can cover several
   weekdays. Only the teacher's own classes and subjects can be chosen.
   Overlaps for a teacher or a class are refused.
3. Add holidays and per-date changes (cancel, substitute, different lesson).
4. Optionally create and publish quizzes and journeys on a teacher's behalf
   (the teacher is told about it on their Home).

### 6.2 The teacher's class (the default path)

```
Open app -> Home speaks: "Home. Physics, Class 6 is ready. Press 1 to start it."
         -> press 1
Class starts -> all enrolled students' phones ring
             -> "Your class is live. You are muted. Press 1 to speak, 3 to mute all students."
After 1 minute -> teacher hears once: "4 of 5 students here."
Later arrivals -> "Akshat and Meena joined. 5 of 5 here."  (grouped, by name)
Teaching     -> teacher unmutes (1), calls a student by name, mutes all (3) when needed
Content      -> 5 Start: quiz, journey or recording; 6 hears how it is going
End          -> teacher presses 8 (confirm) or the class ends itself at the cutoff
```

Total key presses to start teaching: **one**.

### 6.3 The student, on time or late

```
Phone rings "Physics has started" -> press OK -> in class, muted
        or
Student missed it, opens the app at 2:30 -> Home: "Physics class is live. Press 1 to join." -> press 1 -> in class
```

- There is no list of sessions and no "check for live session" step. Home
  updates itself every 20 seconds and whenever the app is opened.
- Before class, a student may press 1 to be joined automatically when the
  class starts.
- The teacher is told by name when a student joins late ("Akshat joined. 5
  of 5 here."). Students are not told when others join or leave.
- If the app was closed or the network dropped during class, opening the app
  returns the student to the same class.

### 6.4 Speaking in class (protocol)

The teacher runs the room by voice:

1. Everyone joins **muted**.
2. A student who wants to speak raises a hand (key 2). The teacher hears it
   and can go through hands in order (key 2).
3. The teacher calls the student by name: "Akshat, you can speak now."
4. The student unmutes (key 1), speaks, and mutes again.
5. If the room gets noisy, the teacher presses **3: mute all students**.

There is **no per-student mute or unmute button**: it was removed because it
needs a list, a selection and a confirmation, and the protocol does the same
job by voice. The proposed tightening of this protocol is in section 14.

### 6.5 Starting something in class: quiz, journey or recording

1. Teacher presses **5: Start**. A short screen offers **1 Quiz, 2 Journey,
   3 Recording**.
2. **Quiz / Journey:** the teacher picks a published one for this class and
   subject. Every student hears "Your teacher started a quiz: Plants. Press 4
   to begin" and presses **4**. It opens straight at the first question;
   leaving returns to the class. Class sound keeps playing.
3. **Recording:** the recording player opens and first reads its keys (5
   play or pause, 4/6 back and forward, 7/9 speed, 1 choose another, 3
   status, 0 back). Only when that speech ends does the selected recording
   start for the class. If the teacher presses any key before then, they are
   in control and it does not start by itself.
4. **One thing runs at a time.** Starting a quiz or journey pauses the
   recording; starting a recording closes the open quiz or journey (it stays
   in the students' normal lists).
5. **6: Status** appears on the class screen only while something runs:
   - for a quiz or journey: "5 students in class. 3 have attempted it, 1
     finished." then: who in class has not finished, who in the whole class
     has not finished, remind those in class, start a different one, stop
     offering it;
   - for a recording: the recording player with all its controls.
6. It stays in the students' normal Quizzes or Journeys lists after class.

### 6.5a Leaving class

One confirmation ("Leave class? 1 leave, 0 stay") is enough. The app tells
the server and waits at most 3 seconds for the answer, then returns Home
whatever happens; closing the class connection also tells the server. There
is no second "leave without server confirmation?" question.

### 6.6 Outside class

- **Student Home:** continue learning (key 2 goes straight to the journey in
  progress), journeys, quizzes. Journeys download automatically on Wi-Fi;
  progress syncs by itself. One automatic reminder is sent for an unfinished
  quiz.
- **Teacher Home:** quizzes, journeys, playlists, and under More: offline
  library, change subject, a class outside the timetable, settings.

## 7. What was removed, and why

| Removed | Why | Replaced by |
|---|---|---|
| Self-registration and role choice | The person is already configured | Vision Empower adds accounts |
| Passwords for teachers and students | Extra typing on a keypad | Phone number (and a profile number on shared phones) |
| Creating a session, typing a title | The timetable already defines the class | One key: start |
| Inviting students, student lists to pick from | Enrolment already defines the class | Automatic ring to all enrolled students |
| Session lists, search, Refresh | Only one class can be live per person | Home shows the one live class and updates itself |
| Class history on the phone | Not needed in class | Kept on the server for Vision Empower |
| Per-student mute and unmute | Too many key presses; protocol does it | Mute all + speaking protocol |
| Classroom check (understood / repeat / help) | Redundant with raising a hand and with in-class quizzes | Raise hand; quiz in class |
| Many keys on the class screen (status, chat, updates, tools on their own keys) | Too long to hear, rarely used | Rare actions under **7: More** |
| Separate keys for quiz, journey and recording | Three keys for one idea ("put something in front of the class") | One **5: Start** key, then 1 / 2 / 3 |
| A second "leave without server confirmation?" question | An extra decision the student cannot judge | Leave after one confirmation |

## 8. Keypad and speech

### 8.1 Global key grammar (never changes)

| Key | Meaning |
|---|---|
| 1 to 5 | The screen's choices, most used first, numbered without gaps |
| 0 | Back, cancel or leave (leaving a class and logging out ask to confirm) |
| \* | Where am I, the current state, the last message, and every key |
| # | Stop speech (never navigates) |
| 8 | Repeat the last message (on menus: details; teacher class screen: end class) |
| 9 | Faster in audio players; otherwise unused where possible |
| Audio players | 4 back 10 s, 5 play or pause, 6 forward 10 s, 7 slower, 9 faster |
| Quiz answers | 1 to 4 choose, 5 submit, 6 repeat the question |

Things that end something use the highest numbers on their screen (the
teacher's end class is 8, then 0 leave).

### 8.2 Screens

**Sign-in:** 1 sign in, 2 use this phone's SIM number, 3 administrator sign
in, 0 back.

**Teacher Home:** 1 start (or return to, or next) class, 2 quizzes, 3
journeys, 4 playlists, 5 More, 0 log out.
More: 1 offline library, 2 change subject, 3 class outside the timetable,
4 settings.

**Student Home:** 1 join (or join automatically when it starts), 2 continue
learning, 3 journeys, 4 quizzes, 5 More, 0 log out.
More: 1 library, 2 playlists, 3 settings.

**Class screen**

| Key | Teacher | Student |
|---|---|---|
| 1 | Mute / unmute myself | Mute / unmute myself |
| 2 | Raised hands (in order) | Raise / lower hand |
| 3 | Mute all students | What is playing |
| 4 | Class list (here, left, not joined; ring those not joined) | Start the quiz or journey (only while one is open) |
| 5 | Start: 1 quiz, 2 journey, 3 recording | – |
| 6 | Status of what is running (only while something runs) | – |
| 7 | More: add 15 minutes, chat, class status | More: chat, who is in class, class status |
| 8 | End class for everyone (asks to confirm) | (repeat last message) |
| 0 | Leave (class keeps running) | Leave (one confirmation) |

### 8.3 Speech rules

- **Opening a screen:** the screen's name, its state in one sentence, then
  every key. This applies on every screen for now (including the journey
  player, the class list, journey review, and with "Essential" speech or
  TalkBack on); which screens should be shorter will be decided later. Example: "Home. Physics, Class 6 is ready. Press 1 for Start
  Physics, Class 6. Press 2 for Quizzes ... Press 0 for Log out."
- **Opening a screen with a text field already focused** (sign-in): the
  same full speech, then "You are in Phone number. While editing, keys enter
  text. Press OK to finish, or use up or down to leave the field." The
  field's own announcement no longer cuts the screen's instructions off.
- **Coming back to a screen** (from a list, chat, settings or a dialog): the
  screen's name, its state, the main keys (1 to 3 and 0), then "Press star
  for all keys." This shorter form is used **only** when coming back; every
  other arrival reads every key.
- **Pressing a key or touching the screen before the opening speech starts**
  drops that opening speech, so it never talks over what the person did.
- **Screens that are still loading** say only "Journeys. Working, please
  wait." and read their counts and keys once the data has arrived, so nothing
  is announced with wrong values (such as "0 new journeys" while loading).
- **Star** always gives the full picture.
- **In class**, status speech mentions only what is not ordinary: a raised
  hand, playing audio, an open quiz, the end time, a connection problem.
- **Who came, in class (teacher only):** nothing during the first minute,
  then one summary ("4 of 5 students here."). After that, joins and leaves
  that happen close together (within 2 seconds) are spoken as one sentence:
  "Akshat and Meena joined. Ravi left. 4 of 5 here." "Of 5" is the number of
  enrolled students. Students hear none of this.
- **Keep lists short.** Because every key is read on opening, a screen with
  more than about six options is a design problem (principle 3). Mentor
  concern: reading options must not take most of the time. See section 14,
  S4 and S5.

### 8.4 Design choices, assumptions and how they help (20 Nov 2026)

| # | Choice | Assumption | How it helps |
|---|---|---|---|
| 1 | Sign-in reads every key and how editing works, even though the cursor starts in the phone field | A first-time blind user does not know OK leaves a field or that 3 is administrator sign-in | Nothing on the screen has to be discovered; the person can type at once or choose another option |
| 2 | Screens that load data speak only "loading" until the data has arrived | Wrong numbers are worse than a short wait | No misleading speech ("0 new journeys" followed by "2") |
| 3 | Leaving class needs one confirmation and never waits more than 3 seconds for the server | The student's intent is clear once they confirm; the server also learns from the closed connection | Leave always works, including on slow networks; one decision instead of two |
| 4 | Coming back to a screen reads the main keys (1 to 3 and 0) and "Press star for all keys"; every other arrival reads all keys | After using a sub-screen the person already knows where they are; the first keys are the most used | Shorter speech for frequent back-and-forth without hiding anything (star) |
| 5 | Timetable and live classes: a class marked live from before the timetable existed stays live until ended | Vision Empower ends such classes from Class records; no automatic clean-up (decided) | Nothing is ended without a person deciding; see 12 |
| 6 | One **5: Start** key opens Quiz / Journey / Recording | Teachers think "put something in front of the class", then choose what | One key to remember; the choice screen reads its three options |
| 7 | The recording player reads its keys before the recording starts; a key press cancels the automatic start | A blind teacher cannot hear the controls once the recording plays over them | The teacher knows pause, seek and speed before audio begins |
| 8 | **6: Status** appears only while something runs; for a quiz or journey it gives "N students in class, M have attempted it, K finished", for a recording it opens the player | Status is only meaningful while something runs | No dead key on the screen; one key for "how is it going?" whatever is running |
| 9 | One thing runs at a time (quiz, journey or recording) | Students cannot listen to a recording and answer a quiz at once | Simple mental model; Status always means the one running thing |
| 10 | Teacher keys: 5 Start, 6 Status, 7 More, 8 End class, 0 Leave; students: More on 7 too | Same key, same meaning across roles; ending is highest | Less to learn; ending cannot be pressed by accident in place of a common action |
| 11 | In class, the teacher's 8 ends the class instead of repeating the last message | Repeating the last message is still available with star | The end key is the highest number on the screen, as agreed |

## 9. Class alerts and joining

- The alert is a data-only push that rings insistently for up to 60 seconds,
  with a full-screen notification where Android allows it. Pressing OK or
  opening it joins directly, even after the ringing stops, while the class
  is live.
- The ring is a convenience, not the mechanism. Joining always works by
  opening the app (section 6.3).
- The teacher's class list (key 4) shows who is here, who joined and left,
  who has not joined, and can ring those not joined once (5-minute cooldown).

## 10. Administrator dashboard (Vision Empower)

A conventional dashboard with sections for: people, classes and subjects,
timetable (arranged by day, teacher or class, with search), today's schedule,
shared phones, holidays, quizzes and journeys for a teacher, issues, and class
records (live and ended classes, add time, end). Times are typed and shown in
IST. Server rules are enforced on the server, not only in the dashboard.

## 11. Backend summary

- Timetable entries per weekday with date ranges, per-date overrides
  (cancel, substitute, lesson) and holidays.
- `POST /classes/start` is idempotent; `GET /me/home` returns everything the
  Home screen needs (live class, today, next class, notices).
- Durable jobs table and worker: alerts, reminders, end warnings, automatic
  end, quiz reminders.
- One-live-class rules enforced by unique database indexes.
- Live class events over a server-sent event stream; audio over WebRTC
  between participants.
- Identity by phone number; sessions revocable by the administrator
  ("sign out everywhere").

Details: README "Interaction-reduction model" and API table.

## 12. Risks and limits

| Risk | Mitigation / status |
|---|---|
| Anyone who knows a registered number can sign in as that person | Accepted for the pilot; documented for deployment review. Profile numbers on shared phones. |
| Android may shorten or block the 60-second ring, full-screen alert or OK key; pushes can be late | Home shows Join by itself within about 20 s; opening the app always works |
| Voice commands while others speak (echo, the teacher's own audio) | Not yet tested on devices (section 15) |
| Live presence (class list) is held in one server process | Run one backend worker until presence moves to shared storage |
| Audio quality on low-end phones with a full class (mesh audio: every phone connects to every other) | Needs device testing at the largest real class size |
| Speech length on screens with many options | Keep options few (principle 3); proposals S4 and S5 |
| Testing teacher and student in tabs of the same web browser: browsers allow about 6 open connections per server, and each open class screen holds one permanently, so actions can queue and time out (seen as "Leave not working") | Test with separate browsers or devices, or on Android; leaving no longer depends on the server's answer |
| A class started before the timetable existed (no timetable link, no end time) stays live and appears as "class is live" | Vision Empower ends it in the dashboard (Class records, End class); not ended automatically by decision |

## 13. Status against this design

**Built and tested in software (needs device testing):** sections 5, 6.1 to
6.3, 6.5, 6.6, 7, 8, 9, 10, 11.

Also built after the mentor review: join and leave news by name, grouped,
and the one-minute start summary (former gap G1, suggestions S1 and S8).

**Gaps against the mentor review:**

| ID | Gap | Today |
|---|---|---|
| G3 | Global unmute and teacher-led speaking protocol | There is "mute all" but no "unmute all"; students can unmute themselves at any time |
| G4 | Home should say who the class is with ("you have a session with these four students") | Home says the subject and class, not the students |
| G5 | Fewer controls in the lesson recording player | The player still offers seek, speed, choose and upload |
| G6 | Voice commands during class must be tested with students speaking | Untested on devices |

## 14. Suggestions (to implement next)

Ordered by value for the least effort. Each can be accepted or dropped
independently.

| ID | Suggestion | Closes |
|---|---|---|
| S1 | **Done.** Names on join and leave, grouped, with "4 of 5 here". | G1 |
| S3 | **Teacher-controlled speaking.** Replace key 3 with a toggle "mute all / unmute all". While the class is muted by the teacher, a student's key 1 does not unmute but raises their hand. The teacher calls a name and unmutes all (or, optionally, unmutes the first raised hand from the hands queue). Needs a decision: is "unmute all" safe with every student's microphone open on low-end phones? | G3 |
| S4 | **Learn once, then be brief.** Read every key the first three times a screen is opened (per person, per screen), then only the state and "star for keys". A Settings switch "Always read all keys" restores the full list. This answers the mentor's concern that reading options takes most of the time, while still teaching new users every key. | Speech time |
| S5 | **Lesson-only player.** In class, key 5 simply plays or pauses the prepared lesson for everyone; seek, speed, choosing another recording and upload move under More. | G5 |
| S6 | **Name the class companions on Home.** Teacher: "Physics, Class 6, 2 pm, with 4 students: Akshat, Meena, Ravi, Asha. Press 1 to start." Names only when 5 or fewer, otherwise the count. | G4 |
| S7 | **Join on open.** If a student's class is live when they open the app, join after a short spoken countdown ("Joining Physics in 3 seconds. Press 0 to stay on Home."), so "open the app" is the whole action. | Flow 6.3 |
| S8 | **Done.** One "4 of 5 students here" a minute after the start instead of one announcement per student. | Speech time |
| S9 | **Voice command trial plan**: test "mute all" spoken by the teacher while (a) a student is speaking, (b) a recording plays, (c) on loudspeaker vs earphones. If unreliable, keep voice commands off by default and rely on key 3. Consider push-to-talk (hold a key) for voice commands to avoid false triggers. | G6 |
| S10 | **Retire unused code paths** (old session lists, invitations, classroom check strings) from the app and translation files to reduce translation and testing effort. | Maintenance |

## 15. Test plan

Software tests run on every change (backend: pytest; app: flutter test). The
items below need **real button phones and blind users**:

1. Sign-in by phone number, shared-phone profile number.
2. Teacher: open app, start class with one key; time from opening the app
   to teaching.
3. Ring: student phone locked, screen off, app closed; ring length; OK joins.
4. Late join: open the app 15 minutes after the start; one key joins.
5. Speaking protocol with a full class: raise hand, called by name, unmute,
   mute all; audio quality and delay.
6. Late joins: the teacher hears the start summary after a minute and later
   arrivals by name; check it does not talk over the teacher's own speech.
7. Voice command "mute all" with students speaking (S9).
8. Quiz in class: start, all students answer, teacher hears who is left.
9. Automatic end and warnings; adding time.
10. Speech length: time taken to hear each main screen's opening speech
    (target: under 15 seconds for Home and the class screen).
11. Network loss in class; reopening returns to the class.

## 16. Decision log

| Date | Decision |
|---|---|
| Nov 2026 | Accounts created by the administrator; phone-number sign-in; shared phones with profile numbers |
| Nov 2026 | Timetable-driven classes; one-key start; no titles, invitations, refresh or history on the phone |
| Nov 2026 | One live class per teacher and per class; automatic cutoff and 15-minute extensions |
| Nov 2026 | Ringing class alerts, one automatic reminder, 5-minute cooldown |
| Nov 2026 | Mute all; no per-student mute; classroom check removed |
| Nov 2026 | Class screen keys fixed as in section 8.2; endings on the highest keys |
| Nov 2026 | Quiz (6) and journey (7) started in class, one open at a time, students begin with 4 |
| Nov 2026 | Every key read when a screen opens and when coming back to it; nobody has to press star to learn the keys |
| Nov 2026 | Administrator can create and publish quizzes and journeys for a teacher |
| Nov 2026 | Mentor review: backend owns all known information; minimise options; assume defaults; global mute and unmute with a speaking protocol; voice commands to be tested in real use. Class size is not fixed (the "10 students" was an example). |
| Nov 2026 | Teacher hears one "4 of 5 students here" a minute after the start, then joins and leaves by name, grouped; students are not told about others joining |
| 20 Nov 2026 | One Start key (5) for quiz, journey or recording; Status (6) only while something runs; More 7; End class 8; one thing runs at a time; recording player reads its keys before playing; leaving needs one confirmation; coming back to a screen reads the main keys and points to star; loading screens wait for their data; sign-in reads all keys with the field focused (section 8.4) |
