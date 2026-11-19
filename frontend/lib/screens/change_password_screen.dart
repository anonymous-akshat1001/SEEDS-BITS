import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/message_center.dart';
import '../services/notification_services.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../announcers/auth_text.dart';

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
  static String get _busyMessage => Speech.t.authChangePasswordBusy;

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
      _fail(Speech.t.authChangePasswordErrorEnterTemporary, fix: _currentFocus);
      return;
    }
    if (_password.text.length < 6) {
      _fail(Speech.t.authChangePasswordErrorTooShort, fix: _passwordFocus);
      return;
    }
    if (_password.text != _repeat.text) {
      _fail(Speech.t.authChangePasswordErrorMismatch, fix: _repeatFocus);
      return;
    }
    if (_password.text == _current.text) {
      _fail(
        Speech.t.authChangePasswordErrorSameAsTemporary,
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
        _fail(Speech.t.authChangePasswordSessionInactive);
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
        _fail(Speech.t.authChangePasswordAccountChanged);
        return;
      }
      if (!result.isSuccess) {
        _fail(Speech.t.authChangePasswordNotConfirmed(result.failure!.message));
        return;
      }
      final data = result.data!;
      if (data['user_id'] != userId || data['must_change_password'] != false) {
        _fail(Speech.t.authChangePasswordResponseNotVerified);
        return;
      }
      await AuthSessionService.saveLoginState(data, expectedToken: token);
      _current.clear();
      _password.clear();
      _repeat.clear();
      unawaited(NotificationService().registerSavedToken());
      if (!mounted) return;
      MessageCenter.carryToNextScreen(AuthText.passwordChanged);
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/${data['role']}_dashboard', (_) => false);
    } on FormatException {
      _fail(Speech.t.authChangePasswordReplacementNotVerified);
    } on StateError {
      _fail(Speech.t.authChangePasswordSignInNotSaved);
    } on PlatformException {
      _fail(Speech.t.authChangePasswordSignInNotSavedOnPhone);
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
        label: Speech.t.authTemporaryCredential,
      ),
      (
        controller: _password,
        node: _passwordFocus,
        label: Speech.t.authNewPassword,
      ),
      (
        controller: _repeat,
        node: _repeatFocus,
        label: Speech.t.authRepeatNewPassword,
      ),
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
        screenName: Speech.t.authChangePasswordScreenName,
        introduction: Speech.t.authChangePasswordIntro,
        labels: {1: Speech.t.authSaveNewPassword, 0: Speech.t.authSignOut},
        navigationController: _keypadController,
        actions: {1: _save, 0: _signOut},
        focusTargets: [
          KeypadFocusTarget(
            node: _currentFocus,
            label: Speech.t.authTemporaryCredentialField,
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: _passwordFocus,
            label: Speech.t.authNewPasswordField,
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: _repeatFocus,
            label: Speech.t.authRepeatNewPasswordField,
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: _saveFocus,
            label: Speech.t.authSaveNewPasswordButton,
            onActivate: _save,
            isEnabled: () => !_busy,
          ),
          KeypadFocusTarget(
            node: _signOutFocus,
            label: Speech.t.authSignOutConfirmButton,
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
                      Speech.t.authChangePasswordTitle,
                      style: TextStyle(
                        color: UIUtils.textColor,
                        fontSize: UIUtils.fontSize(context, 22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(Speech.t.authChangePasswordInfo, style: bodyStyle),
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
                      Speech.t.authSaveNewPasswordKey1,
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
                      Speech.t.authSignOutKey,
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
