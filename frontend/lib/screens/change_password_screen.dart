import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/notification_services.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
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
  final _keypadController = KeypadNavigationController();
  String? _error;
  bool _busy = false;
  static const _busyMessage = 'Saving. Waiting for password-change confirmation.';

  /// Shows and speaks [message] once at critical priority; when a field
  /// needs fixing, focus moves there without a competing announcement.
  void _fail(String message, {FocusNode? fix}) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _busy = false;
    });
    if (fix != null && fix.context != null) {
      _keypadController.focusAndAnnounce(fix, ' ');
    }
    TtsService.speak(message, priority: SpeechPriority.critical);
  }

  Future<void> _save() async {
    if (_busy) return;
    if (_current.text.isEmpty) {
      _fail(
        'Enter your temporary credential. Moved to that field.',
        fix: _currentFocus,
      );
      return;
    }
    if (_password.text.length < 6) {
      _fail(
        'Enter a new password of at least 6 characters. Moved to new password.',
        fix: _passwordFocus,
      );
      return;
    }
    if (_password.text != _repeat.text) {
      _fail(
        'The new passwords do not match. Moved to repeat new password.',
        fix: _repeatFocus,
      );
      return;
    }
    if (_password.text == _current.text) {
      _fail(
        'Choose a password different from the temporary credential. Moved to new password.',
        fix: _passwordFocus,
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    // TalkBack hears the live region; self-voicing users need speech.
    if (TtsService.mode == SpeechMode.selfVoicing) {
      TtsService.speak(_busyMessage);
    }
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
  Widget build(BuildContext context) {
    final fields = [
      (
        controller: _current,
        node: _currentFocus,
        label: 'Temporary credential',
      ),
      (controller: _password, node: _passwordFocus, label: 'New password'),
      (controller: _repeat, node: _repeatFocus, label: 'Repeat new password'),
    ];
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
    final bodyStyle = TextStyle(
      color: UIUtils.textColor,
      fontSize: UIUtils.fontSize(context, 16),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _signOut();
      },
      child: KeypadInstructionWrapper(
        screenName: 'Change temporary password',
        introduction:
            'Enter the temporary credential from your administrator, then a '
            'new password of at least 6 characters, twice. Internet is '
            'required. The dashboard opens after the new password is confirmed.',
        labels: const {4: 'Save new password', 0: 'Sign out'},
        navigationController: _keypadController,
        actions: {4: _save, 0: _signOut},
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
            label: 'Save new password, button',
            onActivate: _save,
            isEnabled: () => !_busy,
          ),
          KeypadFocusTarget(
            node: _signOutFocus,
            label: 'Sign out, asks to confirm',
            onActivate: _signOut,
            isEnabled: () => !_busy,
          ),
        ],
        child: Scaffold(
          backgroundColor: UIUtils.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Change password',
                      style: TextStyle(
                        color: UIUtils.textColor,
                        fontSize: UIUtils.fontSize(context, 22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your school administrator issued a temporary credential. '
                    'It lasts 24 hours. After 10 wrong attempts, sign-in '
                    'pauses for 15 minutes. Choose a different password of at '
                    'least 6 characters. This requires internet.',
                    style: bodyStyle,
                  ),
                  for (final field in fields) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: field.controller,
                      focusNode: field.node,
                      style: bodyStyle,
                      decoration: InputDecoration(
                        label: Text(field.label),
                        labelStyle: TextStyle(
                          color: UIUtils.subtextColor,
                          fontSize: UIUtils.fontSize(context, 14),
                        ),
                        filled: true,
                        fillColor: UIUtils.cardColor,
                        border: border(UIUtils.cardBorderColor, 1.5),
                        enabledBorder: border(UIUtils.cardBorderColor, 1.5),
                        disabledBorder: border(UIUtils.subtextColor, 1),
                        focusedBorder: border(UIUtils.accentColor, 3),
                      ),
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      enabled: !_busy,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Errors are spoken once by TtsService (which also reaches
                  // TalkBack), so this text is not a live region.
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: UIUtils.errorColor, width: 2),
                      ),
                      child: Text(
                        _error!,
                        style: bodyStyle.copyWith(color: UIUtils.errorColor),
                      ),
                    ),
                  if (_busy)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _busyMessage,
                        style: bodyStyle.copyWith(color: UIUtils.subtextColor),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    focusNode: _saveFocus,
                    onPressed: _busy ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIUtils.primaryColor,
                      foregroundColor: UIUtils.onPrimaryColor,
                      disabledBackgroundColor: UIUtils.cardColor,
                      disabledForegroundColor: UIUtils.subtextColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: UIUtils.cardBorderColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      '4: Save new password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: UIUtils.fontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    focusNode: _signOutFocus,
                    onPressed: _busy ? null : _signOut,
                    child: Text(
                      '0: Sign out',
                      style: TextStyle(
                        fontSize: UIUtils.fontSize(context, 16),
                        color: _busy
                            ? UIUtils.subtextColor
                            : UIUtils.accentColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
