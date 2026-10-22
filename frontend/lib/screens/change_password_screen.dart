import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/notification_services.dart';
import '../services/tts_service.dart';
import '../widgets/key_instruction_wrapper.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  final _currentFocus = FocusNode(debugLabel: 'recovery-current');
  final _passwordFocus = FocusNode(debugLabel: 'recovery-new');
  final _repeatFocus = FocusNode(debugLabel: 'recovery-repeat');
  final _saveFocus = FocusNode(debugLabel: 'recovery-save');
  final _signOutFocus = FocusNode(debugLabel: 'recovery-sign-out');
  String? _error;
  bool _busy = false;

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _error = message);
    TtsService.speak(message);
  }

  Future<void> _save() async {
    if (_busy) return;
    if (_current.text.isEmpty || _password.text.length < 6) {
      _fail(
        'Enter your temporary credential and a new password of at least 6 characters.',
      );
      return;
    }
    if (_password.text != _repeat.text) {
      _fail('The new passwords do not match.');
      return;
    }
    if (_password.text == _current.text) {
      _fail('Choose a password different from the temporary credential.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('user_id');
      bool sameAccount() =>
          mounted &&
          prefs.getString('token') == token &&
          prefs.getInt('user_id') == userId &&
          prefs.getBool('must_change_password') == true;
      if (token == null || userId == null || !sameAccount()) {
        _fail('This recovery session is no longer active. Sign in again.');
        return;
      }
      final result = await ApiService.postAcknowledged(
        '/auth/change-password',
        {'current_password': _current.text, 'new_password': _password.text},
        context: 'password change',
        canSend: sameAccount,
      );
      if (!mounted) return;
      if (!sameAccount()) {
        _fail('Your account changed. No replacement sign-in was saved.');
        return;
      }
      if (!result.isSuccess) {
        _fail(
          '${result.failure!.message} Password change is not confirmed. If the connection failed, try signing in with your new password before requesting another reset.',
        );
        return;
      }
      final data = result.data!;
      if (data['user_id'] != userId || data['must_change_password'] != false) {
        _fail(
          'The password-change response could not be verified. Try signing in again with your new password.',
        );
        return;
      }
      await AuthSessionService.saveLoginState(data, expectedToken: token);
      _current.clear();
      _password.clear();
      _repeat.clear();
      unawaited(NotificationService().registerSavedToken());
      if (!mounted) return;
      TtsService.speak('Password changed. Signed in.');
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/${data['role']}_dashboard', (_) => false);
    } on FormatException {
      _fail(
        'The replacement sign-in could not be verified. Sign in again with your new password.',
      );
    } on StateError {
      _fail(
        'Your sign-in could not be saved. Sign in again with your new password.',
      );
    } on PlatformException {
      _fail(
        'Your sign-in could not be saved on this phone. Sign in again with your new password.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    if (_busy || !await AuthSessionService.confirmLogout(context)) return;
    await AuthSessionService.clearLoginState();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  void dispose() {
    for (final controller in [_current, _password, _repeat]) {
      controller.dispose();
    }
    for (final node in [
      _currentFocus,
      _passwordFocus,
      _repeatFocus,
      _saveFocus,
      _signOutFocus,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _signOut();
    },
    child: KeypadInstructionWrapper(
      screenName:
          'Change your temporary password. Internet is required. No dashboard is available until your new password is confirmed.',
      labels: const {4: 'Save new password', 0: 'Sign out'},
      actions: {4: _save, 0: _signOut},
      onHashKey: _signOut,
      focusTargets: [
        KeypadFocusTarget(
          node: _currentFocus,
          label: 'Temporary credential. Hidden input.',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _passwordFocus,
          label: 'New password. At least 6 characters. Hidden input.',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _repeatFocus,
          label: 'Repeat new password. Hidden input.',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _saveFocus,
          label: 'Save new password',
          onActivate: _save,
          isEnabled: () => !_busy,
        ),
        KeypadFocusTarget(
          node: _signOutFocus,
          label: 'Sign out without bypassing password change',
          onActivate: _signOut,
          isEnabled: () => !_busy,
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Change password',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text(
                  'Your school administrator issued a temporary credential. It lasts 24 hours. After 10 wrong attempts, temporary-credential sign-in pauses for 15 minutes. Choose a different password of at least 6 characters. This requires internet.',
                ),
                for (final field in [
                  (
                    controller: _current,
                    node: _currentFocus,
                    label: 'Temporary credential',
                  ),
                  (
                    controller: _password,
                    node: _passwordFocus,
                    label: 'New password',
                  ),
                  (
                    controller: _repeat,
                    node: _repeatFocus,
                    label: 'Repeat new password',
                  ),
                ])
                  TextField(
                    controller: field.controller,
                    focusNode: field.node,
                    decoration: InputDecoration(label: Text(field.label)),
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    enabled: !_busy,
                  ),
                if (_error != null)
                  Semantics(liveRegion: true, child: Text(_error!)),
                if (_busy)
                  const Text('Waiting for password-change confirmation.'),
                ElevatedButton(
                  focusNode: _saveFocus,
                  onPressed: _busy ? null : _save,
                  child: const Text('4: Save new password'),
                ),
                TextButton(
                  focusNode: _signOutFocus,
                  onPressed: _busy ? null : _signOut,
                  child: const Text('0: Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
