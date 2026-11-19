/// Centralized key-mapping labels for every screen.
///
/// Edit this file to change which digit does what on any screen. The wording
/// of each label lives in `lib/l10n/app_<language>.arb`. The labels are used for:
///   1. Auto-generated TTS announcements ("Press 1 for Login. Press 2 for Register.")
///   2. Button text on keypad-optimized screens ("1: Login", "2: Register")
///
/// The actual callbacks are defined in each screen widget (they need access
/// to setState, Navigator, etc.) — this file only stores human-readable labels.
///
/// App-wide key grammar (blind users learn keys by touch, so these never move):
///   0  Back, cancel or leave. Leaving a class or logging out always asks to
///      confirm first. Screens that do not map 0 still go back.
///   *  Help: repeat where you are and what the keys do.
///   #  Stop app speech. Never navigates.
///   Audio players are built around the raised dot on 5:
///   4  Back 10 seconds   5  Play or pause   6  Forward 10 seconds
///   7  Slower            9  Faster
///   Turning app speech off is only offered in Settings, never as a shortcut.
library;

import '../l10n/speech.dart';

// ─── Player keys shared by every audio screen ───────────────────────────────
const int playerRewindKey = 4;
const int playerPlayPauseKey = 5;
const int playerForwardKey = 6;
const int playerSlowerKey = 7;
const int playerFasterKey = 9;

Map<int, String> get playerTransportKeyLabels => {
  playerRewindKey: Speech.t.keyBack10Seconds,
  playerPlayPauseKey: Speech.t.keyPlayOrPause,
  playerForwardKey: Speech.t.keyForward10Seconds,
};

Map<int, String> get playerSpeedKeyLabels => {
  playerSlowerKey: Speech.t.keySlower,
  playerFasterKey: Speech.t.keyFaster,
};

/// Spoken names for player keys a screen maps without labelling, so help
/// never leaves out a key that does something.
Map<int, String> get playerFallbackKeyLabels => {
  playerRewindKey: Speech.t.keyBack10Seconds,
  playerPlayPauseKey: Speech.t.keyPlayOrPause,
  playerForwardKey: Speech.t.keyForward10Seconds,
  playerSlowerKey: Speech.t.keySlowerPlaybackSpeed,
  playerFasterKey: Speech.t.keyFasterPlaybackSpeed,
};

// ─── Welcome Screen ──────────────────────────────────────────────────────────
// Accounts are created by the school administrator; there is no registration.
Map<int, String> get welcomeKeyLabels => {
    1: Speech.t.keyLogin,
  2: Speech.t.keySettings,
};

// ─── Login Screen ────────────────────────────────────────────────────────────
// Keys are defined on the sign-in screen itself (1 sign in, 2 SIM, 3 admin).

// ─── Settings Screen ─────────────────────────────────────────────────────────
Map<int, String> get settingsKeyLabels => {
  0: Speech.t.keyGoBack,
  1: Speech.t.keyToggleTTS,
  2: Speech.t.keyToggleVoiceCommands,
  3: Speech.t.keyShowOrHideShortcuts,
  4: Speech.t.keyToggleHighContrast,
  5: Speech.t.keyTestTTS,
  6: Speech.t.keySaveSettings,
  7: Speech.t.keyCheckVoice,
  8: Speech.t.keySoundCuesOnOrOff,
  9: Speech.t.keyVibrationOnOrOff,
};

// ─── Student Dashboard ───────────────────────────────────────────────────────
Map<int, String> get studentDashboardKeyLabels => {
  0: Speech.t.keyLogOutAsksToConfirm,
  1: Speech.t.keyRefreshSessions,
  2: Speech.t.keySearchSessionsByNameOrID,
  3: Speech.t.keyRecordedAudioLibrary,
  4: Speech.t.keyMyPrivatePlaylists,
  5: Speech.t.keyQuizzes,
  6: Speech.t.keyLearningJourneys,
};

// ─── Teacher Dashboard ───────────────────────────────────────────────────────
Map<int, String> get teacherDashboardKeyLabels => {
  0: Speech.t.keyLogOutAsksToConfirm,
  1: Speech.t.keyRefreshSessions,
  2: Speech.t.keyCreateSession,
  3: Speech.t.keyRecordedAudioLibrary,
  4: Speech.t.keySearchSessionsByNameOrID,
  5: Speech.t.keyClassPlaylists,
  6: Speech.t.keyQuizzes,
  7: Speech.t.keyChooseClassAndSubjectWorkspace,
  8: Speech.t.keyLearningJourneys,
};

Map<int, String> get adminDashboardKeyLabels => {
  0: Speech.t.keyLogOutAsksToConfirm,
  1: Speech.t.keyRefresh,
  2: Speech.t.keySearchUsers,
  3: Speech.t.keyChangeAccountTypeFilter,
  4: Speech.t.keyChangeAssignmentFilter,
  5: Speech.t.keyCreateSubject,
  6: Speech.t.keyCreateClass,
  7: Speech.t.keyChooseAccountsClassesOrSubjectsSection,
};

Map<int, String> get teacherQuizKeyLabels => {
  0: Speech.t.keyGoBackAlt,
  1: Speech.t.keyRefresh,
  2: Speech.t.keyCreateBankQuestion,
  3: Speech.t.keyCreateQuizDraft,
  4: Speech.t.keyCreateUntimedUngradedPractice,
};

Map<int, String> get studentQuizKeyLabels => {
  0: Speech.t.keyGoBackAlt,
  1: Speech.t.keyRefreshQuizzes,
};

/// Same answer keys as learning-journey questions. "Next" is automatic after
/// the answer is announced; finishing early is a confirmed D-pad option.
Map<int, String> get quizAttemptKeyLabels => {
  1: Speech.t.keyChooseOption1,
  2: Speech.t.keyChooseOption2,
  3: Speech.t.keyChooseOption3,
  4: Speech.t.keyChooseOption4,
  5: Speech.t.keySubmitSelectedAnswer,
  6: Speech.t.keyRepeatQuestionAndOptions,
  playerSlowerKey: Speech.t.keySlowerQuizSpeech,
  8: Speech.t.keyWhereAmIIncludingTimeLeft,
  playerFasterKey: Speech.t.keyFasterQuizSpeech,
};

// ─── Live session (both roles) ───────────────────────────────────────────────
// Both screens: 1 microphone, 2 hand, 8 More, 0 leave; ending is highest
// (teacher 9 ends the class). Teachers: 3 mute all, 4 class list, 5 lesson
// recording, 6 quiz, 7 journey. Students: 3 what is playing, 4 start the
// open quiz or journey (shown only while one is open).
Map<int, String> sessionStudentKeyLabels({bool activityOpen = false}) => {
  1: Speech.t.keyMuteOrUnmute,
  2: Speech.t.keyRaiseOrLowerHand,
  3: Speech.t.sessionKeyWhatIsPlaying,
  if (activityOpen) 4: Speech.t.sessionKeyStartActivity,
  8: Speech.t.sessionKeyMore,
  0: Speech.t.sessionKeyLeave,
};

Map<int, String> get sessionTeacherKeyLabels => {
  1: Speech.t.keyMuteOrUnmute,
  2: Speech.t.sessionKeyRaisedHands,
  3: Speech.t.keyMuteAllStudents,
  4: Speech.t.sessionKeyClassList,
  5: Speech.t.sessionKeyLessonRecording,
  6: Speech.t.sessionKeyQuiz,
  7: Speech.t.sessionKeyJourney,
  8: Speech.t.sessionKeyMore,
  9: Speech.t.sessionKeyEndClass,
  0: Speech.t.sessionKeyLeave,
};

// ─── Simple Session Screen ───────────────────────────────────────────────────
Map<int, String> get simpleSessionKeyLabels => {
  1: Speech.t.keyMuteOrUnmute,
  2: Speech.t.keyRaiseOrLowerHand,
  ...playerSpeedKeyLabels,
  0: Speech.t.keyLeaveSessionAsksToConfirm,
};

// ─── Offline Audio Library (both roles) ──────────────────────────────────────
Map<int, String> get offlineAudioLibraryKeyLabels => {
  1: Speech.t.keyRefreshClasses,
  2: Speech.t.keySearchClassByName,
  3: Speech.t.keyAllAudioFiles,
  5: Speech.t.keyFocusFirstActiveClassUseDPadToBrowseClasses,
  0: Speech.t.keyGoBack,
};

// ─── Class Audio Screen (Student) ────────────────────────────────────────────
Map<int, String> get classAudioStudentKeyLabels => {
  1: Speech.t.keyRefreshFiles,
  2: Speech.t.keyNextSubjectFilter,
  ...playerTransportKeyLabels,
  ...playerSpeedKeyLabels,
  8: Speech.t.keyStopPlayback,
  0: Speech.t.keyGoBackAlt,
};

// ─── Class Audio Screen (Teacher) ────────────────────────────────────────────
Map<int, String> get classAudioTeacherKeyLabels => {
  1: Speech.t.keyRefreshFiles,
  2: Speech.t.keyNextSubjectFilter,
  3: Speech.t.keyAddAudioFile,
  ...playerTransportKeyLabels,
  ...playerSpeedKeyLabels,
  8: Speech.t.keyStopPlayback,
  0: Speech.t.keyGoBackAlt,
};

// ─── Add Audio Options Screen (Teacher) ──────────────────────────────────────
Map<int, String> get addAudioOptionsKeyLabels => {
  1: Speech.t.keyUploadNewFile,
  2: Speech.t.keySelectFromExistingLibrary,
  0: Speech.t.keyGoBack,
};

// ─── Select Existing Audio Screen (Teacher) ──────────────────────────────────
Map<int, String> get selectExistingAudioKeyLabels => {
  1: Speech.t.keyRefreshList,
  0: Speech.t.keyGoBack,
};

/// Builds a TTS-friendly instruction string from a labels map.
///
/// Example output: "Press 1 for Login. Press 2 for Register."
String buildTtsInstructions(
  Map<int, String> labels, {
  String? screenName,
  bool includeRepeatHint = true,
}) {
  final t = Speech.t;
  final sorted = labels.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final parts = sorted
      .map((e) => t.keypadPressFor('${e.key}', e.value))
      .join(t.keypadListSeparator);

  final repeatHint = includeRepeatHint ? ' ${t.keypadRepeatInstructions}' : '';

  if (screenName != null && screenName.isNotEmpty) {
    return '$screenName. $parts.$repeatHint';
  }
  return '$parts.$repeatHint';
}
