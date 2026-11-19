import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import '../main.dart' show navigatorKey;
import '../screens/session_screen.dart';
import 'api_service.dart';
import 'class_alerts.dart';
import 'message_center.dart';
import 'tts_service.dart';

/// The only way into a live class (S11, S14, S17, S18). Every caller —
/// the home screen, a notification, consented waiting-room entry, or
/// recovery after an interruption — goes through the same checks: the class
/// must be live for this account right now, and the microphone starts muted.
abstract final class ClassEntry {
  static const activeSessionKey = 'active_session_id';
  static bool _opening = false;

  /// Opens [sessionId] if it is this account's live class. [liveClass] is the
  /// `/me/home` summary when the caller already has it.
  static Future<bool> open(
    int sessionId, {
    Map<String, dynamic>? liveClass,
    String? arrival,
  }) async {
    if (_opening) return false;
    _opening = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final userName = prefs.getString('user_name') ?? prefs.getString('name');
      final role = prefs.getString('role');
      if (userId == null || userName == null || role == null) {
        MessageCenter.error(Speech.t.commonSignInFirst);
        return false;
      }
      var summary = liveClass;
      if (summary == null || summary['session_id'] != sessionId) {
        final home = await ApiService.home();
        final live = home.isSuccess && home.data is Map
            ? (home.data as Map)['live_class']
            : null;
        summary = live is Map && live['session_id'] == sessionId
            ? Map<String, dynamic>.from(live)
            : null;
        if (!home.isSuccess) {
          MessageCenter.error(home.failure!.message);
          return false;
        }
      }
      await ClassAlerts.instance.cancelFor(sessionId);
      if (summary == null) {
        MessageCenter.error(Speech.t.classNoLongerLive);
        return false;
      }
      final navigator = navigatorKey.currentState;
      if (navigator == null) return false;
      await prefs.setInt(activeSessionKey, sessionId);
      if (arrival != null) MessageCenter.carryToNextScreen(arrival);
      final subject = summary['subject_name']?.toString();
      final className = summary['class_name']?.toString();
      final title = subject ?? Speech.t.sessionDefaultTitle;
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => role == 'teacher'
                ? TeacherSessionScreen(
                    sessionId: sessionId,
                    userId: userId,
                    userName: userName,
                    sessionTitle: title,
                    className: className,
                    subjectName: subject,
                    liveClass: summary,
                  )
                : StudentSessionScreen(
                    sessionId: sessionId,
                    userId: userId,
                    userName: userName,
                    sessionTitle: title,
                    className: className,
                    subjectName: subject,
                    liveClass: summary,
                  ),
          ),
        ),
      );
      return true;
    } finally {
      _opening = false;
    }
  }

  /// Called when someone leaves on purpose or the class ends, so the app
  /// does not try to bring them back.
  static Future<void> forget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(activeSessionKey);
  }

  /// The class this phone was in when the app was interrupted, if any.
  static Future<int?> interrupted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(activeSessionKey);
  }

  /// Speaks why nothing opened when there is no live class.
  static void notLive() =>
      unawaited(TtsService.speak(Speech.t.classNoLongerLive));
}
