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
    await prefs.remove(signedOutByChoiceKey);
    final chosenSignedOut = prefs.getString(
      TtsService.languageChosenSignedOutKey,
    );
    final restored = await restoreAccountProfile(prefs, userId);
    final administered = await _takeAdministratorSpeech(
      prefs,
      userId,
      data['speech'],
    );
    if (chosenSignedOut != null) {
      await prefs.setString('speech_language', chosenSignedOut);
      await prefs.remove(TtsService.languageChosenSignedOutKey);
    }
    if (restored || administered || chosenSignedOut != null) {
      await _applyPreferences(prefs);
    }
  }

  static String _administeredKey(int userId) => 'administered_speech_$userId';

  /// Set when the person logged out on purpose; cleared by the next sign-in.
  static const signedOutByChoiceKey = 'signed_out_by_choice';

  /// Applies the language and speed the administrator chose for this
  /// person (`speech` from sign-in or Home), but only a value that changed
  /// since it was last applied on this phone: a change the person made in
  /// Settings is kept until the administrator changes that value again.
  /// Returns whether anything was applied.
  static Future<bool> applyAdministratorSpeech(Object? speech) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return false;
    final applied = await _takeAdministratorSpeech(prefs, userId, speech);
    if (applied) await TtsService.loadFromPreferences();
    return applied;
  }

  static Future<bool> _takeAdministratorSpeech(
    SharedPreferences prefs,
    int userId,
    Object? speech,
  ) async {
    if (speech is! Map) return false;
    final language = speech['language'];
    final rate = speech['rate'];
    Map<String, Object?> last;
    try {
      final saved = jsonDecode(
        prefs.getString(_administeredKey(userId)) ?? '{}',
      );
      last = saved is Map ? Map<String, Object?>.from(saved) : {};
    } on FormatException {
      last = {};
    }
    var applied = false;
    if (language is String && language != last['language']) {
      await prefs.setString('speech_language', language);
      applied = true;
    }
    if (rate is num && rate.toDouble() != last['rate']) {
      await TtsService.storeSpeechRate(prefs, rate.toDouble());
      applied = true;
    }
    await prefs.setString(
      _administeredKey(userId),
      jsonEncode({
        'language': language is String ? language : null,
        'rate': rate is num ? rate.toDouble() : null,
      }),
    );
    return applied;
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
    // The next sign-in on this phone may be someone else: the SIM number is
    // offered but not used to sign straight back in.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(signedOutByChoiceKey, true);
    MessageCenter.carryToNextScreen(Speech.t.authLoggedOut);
    if (!context.mounted) return true;
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (_) => false);
    return true;
  }
}
