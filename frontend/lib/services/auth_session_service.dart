import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_services.dart';
import 'api_service.dart';
import 'tts_service.dart';
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
    ApiService.cachedToken = null;
    await TtsService.stop();
    final preferences = await SharedPreferences.getInstance();
    for (final key in _sessionKeys) {
      await preferences.remove(key);
    }
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
  }

  static Future<bool> confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const KeypadConfirmationDialog(
        title: 'Log out of SEEDS?',
        message: 'You will need to enter your phone number and password again.',
        cancelLabel: 'Cancel',
        confirmLabel: 'Log out',
      ),
    );
    return confirmed ?? false;
  }

  static Future<bool> logoutFrom(BuildContext context) async {
    if (!await confirmLogout(context)) return false;
    try {
      await NotificationService().removeToken().timeout(
        const Duration(seconds: 2),
      );
    } catch (error) {
      debugPrint('[LOGOUT] Notification token cleanup deferred: $error');
    }
    await clearLoginState();
    unawaited(TtsService.speak('Logged out'));
    if (!context.mounted) return true;
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (_) => false);
    return true;
  }
}
