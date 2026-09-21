import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_services.dart';
import 'tts_service.dart';

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
  };

  static Future<void> clearLoginState() async {
    final preferences = await SharedPreferences.getInstance();
    for (final key in _sessionKeys) {
      await preferences.remove(key);
    }
  }

  static Future<bool> confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out of SEEDS?'),
        content: const Text(
          'You will need to enter your phone number and password again.',
        ),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
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
