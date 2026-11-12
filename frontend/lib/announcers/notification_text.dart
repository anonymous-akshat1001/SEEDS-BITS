/// Spoken text for push notifications.
abstract final class NotificationText {
  static String title(String type) => switch (type) {
    'session_invitation' => 'Live class',
    'journey_published' => 'New learning journey',
    'quiz_published' => 'New quiz',
    'quiz_reminder' => 'Quiz reminder',
    _ => 'SEEDS update',
  };

  /// What arrived and which key opens it.
  static String arrived(String type) => switch (type) {
    'session_invitation' =>
      'Your teacher started a class. Press 1 to join, or 0 for not now.',
    'journey_published' =>
      'Your teacher shared a new learning journey. Press 1 to open it, or 0 for not now.',
    'quiz_published' =>
      'Your teacher published a new quiz. Press 1 to open your quizzes, or 0 for not now.',
    'quiz_reminder' =>
      'Reminder: you have a quiz to take. Press 1 to open your quizzes, or 0 for not now.',
    _ => 'You have a new update. Press 0 to go back.',
  };

  /// Spoken while the app is open, when a notification arrives.
  static String foreground(String type) => switch (type) {
    'session_invitation' =>
      'Your teacher started a class. Join it from Live sessions on your dashboard.',
    'journey_published' =>
      'Your teacher shared a new learning journey. Find it under Learning journeys.',
    'quiz_published' => 'Your teacher published a new quiz.',
    'quiz_reminder' => 'Reminder: you have a quiz to take.',
    _ => 'You have a new update.',
  };

  static String openLabel(String type) => switch (type) {
    'session_invitation' => 'Join class',
    'journey_published' => 'Open journey',
    'quiz_published' || 'quiz_reminder' => 'Open quizzes',
    _ => 'Back',
  };

  static const cannotOpen =
      'This could not be opened. Sign in again, then open it from your dashboard.';
}
