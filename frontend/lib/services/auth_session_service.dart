import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import '../utils/ui_utils.dart';
import 'class_alerts.dart';
import 'notification_services.dart';
import 'api_service.dart';
import 'activity_telemetry.dart';
import 'feedback_cues.dart';
import 'message_center.dart';
import 'tts_service.dart';
import 'undo_service.dart';
import '../widgets/keypad_confirmation_dialog.dart';

class AuthSessionService {
  AuthSessionService._();

  static const _sessionKeys = <String>{
    'token',
    'user_id',
    'user_name',
    'name',
    'role',
    'active_session_id',
    'participant_id',
    'must_change_password',
  };

  static Future<void> clearLoginState() async {
    ActivityTelemetry.accountChanged();
    ApiService.cachedToken = null;
    await TtsService.stop();
    final preferences = await SharedPreferences.getInstance();
    await rememberAccountProfile(preferences);
    // A class alert for the previous person must not keep ringing.
    unawaited(ClassAlerts.instance.cancelAll());
    for (final key in _sessionKeys) {
      await preferences.remove(key);
    }
  }

  /// Speech and display preferences kept per person, so on a shared phone
  /// each profile hears the app the way they set it (S04).
  static const profileKeys = [
    'tts_enabled',
    'tts_volume',
    'tts_speech_rate',
    'speech_mode',
    'speech_verbosity',
    'speech_language',
    'high_contrast_mode',
    'text_scale',
    'voice_commands_enabled',
    'show_keyboard_shortcuts',
    FeedbackCues.soundPreference,
    FeedbackCues.vibrationPreference,
  ];

  static String _profileKey(int userId) => 'account_profile_$userId';

  @visibleForTesting
  static Future<void> rememberAccountProfile(SharedPreferences prefs) async {
    final userId = prefs.getInt('user_id');
    if (userId == null) return;
    final profile = <String, Object>{
      for (final key in profileKeys)
        if (prefs.get(key) case final Object value) key: value,
    };
    await prefs.setString(_profileKey(userId), jsonEncode(profile));
  }

  /// Restores [userId]'s own preferences when they were saved on this phone;
  /// a first sign-in keeps the phone's current settings.
  @visibleForTesting
  static Future<bool> restoreAccountProfile(
    SharedPreferences prefs,
    int userId,
  ) async {
    final raw = prefs.getString(_profileKey(userId));
    if (raw == null) return false;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return false;
    }
    if (decoded is! Map) return false;
    for (final key in profileKeys) {
      final value = decoded[key];
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value == null) {
        await prefs.remove(key);
      }
    }
    return true;
  }

  static Future<void> _applyPreferences(SharedPreferences prefs) async {
    UIUtils.setHighContrastMode(prefs.getBool('high_contrast_mode') ?? true);
    UIUtils.setTextScale(prefs.getDouble('text_scale') ?? 1.0);
    await FeedbackCues.loadFromPreferences();
    await TtsService.loadFromPreferences();
  }

  static Future<void> saveLoginState(
    Map<String, dynamic> data, {
    String? expectedToken,
  }) async {
    final token = data['access_token'];
    final userId = data['user_id'];
    final role = data['role'];
    final name = data['name'];
    final requiredChange = data['must_change_password'];
    if (token is! String ||
        token.isEmpty ||
        userId is! int ||
        userId <= 0 ||
        role is! String ||
        !{'admin', 'teacher', 'student'}.contains(role) ||
        (name != null && name is! String) ||
        (requiredChange != null && requiredChange is! bool)) {
      throw const FormatException('Invalid sign-in response');
    }
    final prefs = await SharedPreferences.getInstance();
    if (expectedToken != null &&
        (prefs.getString('token') != expectedToken ||
            prefs.getInt('user_id') != userId)) {
      throw StateError('Account changed before sign-in was saved');
    }
    await clearLoginState();
    final saved = [
      await prefs.setInt('user_id', userId),
      await prefs.setString('role', role),
      await prefs.setBool('must_change_password', requiredChange == true),
      if (name is String) await prefs.setString('user_name', name),
      if (name is String) await prefs.setString('name', name),
    ];
    if (saved.any((ok) => !ok) || !await prefs.setString('token', token)) {
      throw StateError('Sign-in could not be saved');
    }
    if (await restoreAccountProfile(prefs, userId)) {
      await _applyPreferences(prefs);
    }
  }

  static Future<bool> confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: Speech.t.authLogoutTitle,
        message: Speech.t.authLogoutMessage,
        cancelLabel: Speech.t.authLogoutCancel,
        confirmLabel: Speech.t.authLogoutConfirm,
      ),
    );
    return confirmed ?? false;
  }

  static Future<bool> logoutFrom(BuildContext context) async {
    if (!await confirmLogout(context)) return false;
    unawaited(FeedbackCues.play(Cue.leave));
    await UndoService.commitPending();
    ActivityTelemetry.record('logout_observed');
    try {
      await NotificationService().removeToken().timeout(
        const Duration(seconds: 2),
      );
    } catch (error) {
      debugPrint('[LOGOUT] Notification token cleanup deferred: $error');
    }
    await clearLoginState();
    MessageCenter.carryToNextScreen(Speech.t.authLoggedOut);
    if (!context.mounted) return true;
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (_) => false);
    return true;
  }
}
