/// Centralized key-mapping labels for every screen.
///
/// Edit this file to change which digit does what on any screen.
/// The labels are used for:
///   1. Auto-generated TTS announcements ("Press 1 for Login. Press 2 for Register.")
///   2. Button text on keypad-optimized screens ("1: Login", "2: Register")
///
/// The actual callbacks are defined in each screen widget (they need access
/// to setState, Navigator, etc.) — this file only stores human-readable labels.
library;

// ─── Welcome Screen ─────────────────────────────────────────────────────────
const Map<int, String> welcomeKeyLabels = {
  1: 'Login',
  2: 'Register',
};

// ─── Login Screen ───────────────────────────────────────────────────────────
const Map<int, String> loginKeyLabels = {
  1: 'Login',
  2: 'Register',
  3: 'Toggle Teacher Account Check',
};

// ─── Register Screen ────────────────────────────────────────────────────────
const Map<int, String> registerKeyLabels = {
  1: 'Register',
  2: 'Go to Login',
  3: 'Toggle Teacher Registration',
};

// ─── Settings Screen ────────────────────────────────────────────────────────
const Map<int, String> settingsKeyLabels = {
  0: 'Go Back',
  1: 'Toggle T T S',
  2: 'Toggle Voice Commands',
  3: 'Show or Hide Shortcuts',
  4: 'Toggle High Contrast',
  5: 'Test T T S',
  6: 'Save Settings',
};

// ─── Student Dashboard ──────────────────────────────────────────────────────
const Map<int, String> studentDashboardKeyLabels = {
  1: 'Refresh Sessions',
  2: 'Join Session by ID',
  3: 'Offline Audio Library',
};

// ─── Teacher Dashboard ──────────────────────────────────────────────────────
const Map<int, String> teacherDashboardKeyLabels = {
  1: 'Refresh Sessions',
  2: 'Create Session',
  3: 'Offline Audio Library',
};

// ─── Session Screen (Student) ───────────────────────────────────────────────
const Map<int, String> sessionStudentKeyLabels = {
  1: 'Toggle Mute',
  2: 'Raise or Lower Hand',
};

// ─── Session Screen (Teacher) ───────────────────────────────────────────────
const Map<int, String> sessionTeacherKeyLabels = {
  1: 'Toggle Mute',
  2: 'Raise or Lower Hand',
  3: 'Invite Students',
  4: 'Audio Library',
};

// ─── Simple Session Screen ──────────────────────────────────────────────────
const Map<int, String> simpleSessionKeyLabels = {
  1: 'Mute or Unmute',
  2: 'Raise or Lower Hand',
  3: 'Toggle T T S',
  4: 'Leave Session',
  7: 'Slow Down Audio',
  9: 'Speed Up Audio',
};

// ─── Offline Audio Library (both roles) ─────────────────────────────────────
const Map<int, String> offlineAudioLibraryKeyLabels = {
  1: 'Refresh Classes',
  2: 'Search Class by Name',
  3: 'All Audio Files',
  0: 'Go Back',
};

// ─── Class Audio Screen (Student) ───────────────────────────────────────────
const Map<int, String> classAudioStudentKeyLabels = {
  1: 'Refresh Files',
  2: 'Play or Pause',
  3: 'Stop Playback',
  4: 'Toggle T T S',
  7: 'Slow Down Audio',
  9: 'Speed Up Audio',
  0: 'Go Back',
};

// ─── Class Audio Screen (Teacher) ───────────────────────────────────────────
const Map<int, String> classAudioTeacherKeyLabels = {
  1: 'Refresh Files',
  2: 'Add Audio File',
  3: 'Play or Pause',
  4: 'Stop Playback',
  5: 'Toggle T T S',
  7: 'Slow Down Audio',
  9: 'Speed Up Audio',
  0: 'Go Back',
};

// ─── Add Audio Options Screen (Teacher) ──────────────────────────────────
const Map<int, String> addAudioOptionsKeyLabels = {
  1: 'Upload New File',
  2: 'Select from Existing Library',
  0: 'Go Back',
};

// ─── Select Existing Audio Screen (Teacher) ──────────────────────────────
const Map<int, String> selectExistingAudioKeyLabels = {
  1: 'Refresh List',
  0: 'Go Back',
};

/// Builds a TTS-friendly instruction string from a labels map.
///
/// Example output: "Press 1 for Login. Press 2 for Register."
String buildTtsInstructions(
  Map<int, String> labels, {
  String? screenName,
  bool includeRepeatHint = true,
}) {
  final sorted = labels.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final parts = sorted.map((e) => 'Press ${e.key} for ${e.value}').join('. ');

  final repeatHint = includeRepeatHint ? ' Press star to repeat these instructions.' : '';

  if (screenName != null && screenName.isNotEmpty) {
    return '$screenName. $parts.$repeatHint';
  }
  return '$parts.$repeatHint';
}
