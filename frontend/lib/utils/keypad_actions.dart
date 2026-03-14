/// Centralized key-mapping labels for every screen.
///
/// Edit this file to change which digit does what on any screen.
/// The labels are used for:
///   1. Auto-generated TTS announcements ("Press 1 for Login. Press 2 for Register.")
///   2. Button text on keypad-optimized screens ("1: Login", "2: Register")
///
/// The actual callbacks are defined in each screen widget (they need access
/// to setState, Navigator, etc.) — this file only stores human-readable labels.

// ─── Welcome Screen ─────────────────────────────────────────────────────────
const Map<int, String> welcomeKeyLabels = {
  1: 'Login',
  2: 'Register',
};

// ─── Login Screen ───────────────────────────────────────────────────────────
const Map<int, String> loginKeyLabels = {
  1: 'Login',
  2: 'Register',
};

// ─── Register Screen ────────────────────────────────────────────────────────
const Map<int, String> registerKeyLabels = {
  1: 'Register',
  2: 'Go to Login',
};

// ─── Student Dashboard ──────────────────────────────────────────────────────
const Map<int, String> studentDashboardKeyLabels = {
  1: 'Refresh Sessions',
  2: 'Join Session by ID',
};

// ─── Teacher Dashboard ──────────────────────────────────────────────────────
const Map<int, String> teacherDashboardKeyLabels = {
  1: 'Refresh Sessions',
  2: 'Create Session',
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

/// Builds a TTS-friendly instruction string from a labels map.
///
/// Example output: "Press 1 for Login. Press 2 for Register."
String buildTtsInstructions(Map<int, String> labels, {String? screenName}) {
  final sorted = labels.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final parts = sorted.map((e) => 'Press ${e.key} for ${e.value}').join('. ');

  if (screenName != null && screenName.isNotEmpty) {
    return '$screenName. $parts.';
  }
  return '$parts.';
}
