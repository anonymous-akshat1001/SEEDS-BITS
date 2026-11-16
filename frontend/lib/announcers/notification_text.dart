import '../l10n/speech.dart';

/// Spoken text for push notifications.
abstract final class NotificationText {
  static String title(String type) => switch (type) {
    'session_invitation' => Speech.t.notificationTitleSessionInvitation,
    'journey_published' => Speech.t.notificationTitleJourneyPublished,
    'quiz_published' => Speech.t.notificationTitleQuizPublished,
    'quiz_reminder' => Speech.t.notificationTitleQuizReminder,
    _ => Speech.t.notificationTitleDefault,
  };

  /// What arrived and which key opens it.
  static String arrived(String type) => switch (type) {
    'session_invitation' => Speech.t.notificationArrivedSessionInvitation,
    'journey_published' => Speech.t.notificationArrivedJourneyPublished,
    'quiz_published' => Speech.t.notificationArrivedQuizPublished,
    'quiz_reminder' => Speech.t.notificationArrivedQuizReminder,
    _ => Speech.t.notificationArrivedDefault,
  };

  /// Spoken while the app is open, when a notification arrives.
  static String foreground(String type) => switch (type) {
    'session_invitation' => Speech.t.notificationForegroundSessionInvitation,
    'journey_published' => Speech.t.notificationForegroundJourneyPublished,
    'quiz_published' => Speech.t.notificationForegroundQuizPublished,
    'quiz_reminder' => Speech.t.notificationForegroundQuizReminder,
    _ => Speech.t.notificationForegroundDefault,
  };

  static String openLabel(String type) => switch (type) {
    'session_invitation' => Speech.t.notificationOpenJoinClass,
    'journey_published' => Speech.t.notificationOpenJourney,
    'quiz_published' || 'quiz_reminder' => Speech.t.notificationOpenQuizzes,
    _ => Speech.t.notificationOpenBack,
  };

  static String get cannotOpen => Speech.t.notificationCannotOpen;
}