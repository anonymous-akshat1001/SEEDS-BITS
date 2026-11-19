import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';

import '../announcers/auth_text.dart';
import '../l10n/speech.dart';
import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/notification_services.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../widgets/sim_suggestion_dialog.dart';

/// Opens the home screen for a signed-in account's role.
void openHomeForRole(BuildContext context, String role) {
  final route = switch (role) {
    'admin' => '/admin_dashboard',
    'teacher' => '/teacher_dashboard',
    _ => '/student_dashboard',
  };
  Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
}

/// Students and teachers sign in with their phone number only. The keypad
/// enters the number, so it works with no SIM card and on Wi-Fi. A shared
/// phone then asks for the person's short profile number.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  bool isLoading = false;
  bool _needsProfile = false;
  String? _errorMessage;
  final _keypadController = KeypadNavigationController();
  final _phoneFocus = FocusNode(debugLabel: 'login-phone');
  final _codeFocus = FocusNode(debugLabel: 'login-profile-code');
  final _submitFocus = FocusNode(debugLabel: 'login-submit');
  final _simFocus = FocusNode(debugLabel: 'login-sim-suggestion');
  final _adminFocus = FocusNode(debugLabel: 'login-admin');
  bool _simRequestPending = false;
  bool _simDetecting = false;
  String? _simStatusMessage;

  /// Strips the leading '91' country code from Indian phone numbers.
  String _stripCountryCode(String number) {
    var cleaned = number.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (cleaned.startsWith('91') && cleaned.length > 10) {
      cleaned = cleaned.substring(2);
    }
    return cleaned;
  }

  @override
  void dispose() {
    phoneCtrl.dispose();
    codeCtrl.dispose();
    for (final node in [
      _phoneFocus,
      _codeFocus,
      _submitFocus,
      _simFocus,
      _adminFocus,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  // ── Optional SIM suggestion: never automatic, never required ──────────

  Future<void> _initMobileNumber() async {
    if (_simRequestPending || _simDetecting || isLoading) return;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      setState(() => _simStatusMessage = Speech.t.authSimUnavailableOnDevice);
      await TtsService.speak(_simStatusMessage!);
      return;
    }
    setState(() => _simRequestPending = true);
    try {
      final continueWithSim = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => KeypadConfirmationDialog(
          title: Speech.t.authSimDialogTitle,
          message: Speech.t.authSimDialogMessage,
          confirmLabel: Speech.t.authSimDialogConfirm,
        ),
      );
      if (continueWithSim != true) {
        if (mounted) {
          setState(() => _simStatusMessage = Speech.t.authSimAutofillSkipped);
        }
        return;
      }
      if (!mounted) return;
      var status = await Permission.phone.status.timeout(
        const Duration(seconds: 10),
      );
      if (!mounted) return;
      setState(() {
        _simDetecting = true;
        _simStatusMessage = Speech.t.authSimDetecting;
      });
      if (!status.isGranted) status = await Permission.phone.request();
      if (!mounted) return;
      if (!status.isGranted) {
        setState(() => _simStatusMessage = Speech.t.authSimAutofillUnavailable);
        unawaited(TtsService.speak(Speech.t.authSimAutofillUnavailable));
        return;
      }
      var hasPhonePermission = await MobileNumber.hasPhonePermission.timeout(
        const Duration(seconds: 10),
      );
      if (!mounted) return;
      if (!hasPhonePermission) {
        await MobileNumber.requestPhonePermission;
        if (!mounted) return;
        hasPhonePermission = await MobileNumber.hasPhonePermission.timeout(
          const Duration(seconds: 10),
        );
      }
      if (!hasPhonePermission) {
        await _simUnavailable(StateError('Phone permission was not granted'));
        return;
      }
      final lookup = MobileNumber.getSimCards;
      if (lookup == null) {
        await _simUnavailable(StateError('SIM lookup is unavailable'));
        return;
      }
      final simCards = await lookup.timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (simCards.isEmpty) {
        // No SIM is normal on Wi-Fi; the number is simply typed.
        setState(() => _simStatusMessage = Speech.t.authSimNoneFound);
        unawaited(TtsService.speak(_simStatusMessage!));
      } else {
        setState(
          () => _simStatusMessage = Speech.t.authSimCardsDetected(
            '${simCards.length}',
          ),
        );
        unawaited(TtsService.speak(_simStatusMessage!));
        await _showSimSelectionDialog(simCards);
      }
    } on PlatformException catch (error) {
      await _simUnavailable(error);
    } on MissingPluginException catch (error) {
      await _simUnavailable(error);
    } on TimeoutException catch (error) {
      await _simUnavailable(error);
    } on FormatException catch (error) {
      await _simUnavailable(error);
    } on TypeError catch (error) {
      await _simUnavailable(error);
    } finally {
      if (mounted) {
        setState(() {
          _simRequestPending = false;
          _simDetecting = false;
        });
      }
    }
  }

  Future<void> _simUnavailable(Object error) async {
    debugPrint('SIM suggestion failed (${error.runtimeType})');
    if (!mounted) return;
    setState(() {
      _simDetecting = false;
      _simStatusMessage = Speech.t.authSimSuggestionUnavailable;
    });
    await TtsService.speak(_simStatusMessage!);
  }

  Future<void> _showSimSelectionDialog(List<SimCard> cards) async {
    if (!mounted) return;
    final selection = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SimSuggestionDialog(
        options: [
          for (var i = 0; i < cards.length; i++)
            (
              label: Speech.t.authSimOptionLabel(
                '${i + 1}',
                cards[i].carrierName ?? Speech.t.authSimUnknownCarrier,
              ),
              number: _stripCountryCode(cards[i].number ?? ''),
            ),
        ],
      ),
    );
    if (!mounted || selection == null) return;
    setState(() {
      phoneCtrl.text = selection;
      _simStatusMessage = Speech.t.authSimSelectedFilled;
    });
    await TtsService.speak(Speech.t.authSimSuggestionFilledSpoken);
  }

  // ── Sign in ────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    if (isLoading) return;
    final phone = phoneCtrl.text.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.replaceAll('+', '').length < 4) {
      _setError(Speech.t.loginErrorEnterPhone, _phoneFocus);
      return;
    }
    final code = codeCtrl.text.trim();
    if (_needsProfile && code.isEmpty) {
      _setError(Speech.t.loginErrorEnterProfile, _codeFocus);
      return;
    }
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });
    unawaited(TtsService.speak(Speech.t.loginSigningIn));
    try {
      final result = await ApiService.phoneLoginResult(
        phoneNumber: phone,
        profileCode: _needsProfile ? code : null,
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        _setError(
          result.failure!.message,
          _needsProfile ? _codeFocus : _phoneFocus,
        );
        return;
      }
      final data = result.data!;
      if (data['profile_required'] == true) {
        setState(() {
          _needsProfile = true;
          isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _keypadController.focusAndAnnounce(
            _codeFocus,
            Speech.t.loginEnterProfileCode,
          );
        });
        return;
      }
      await AuthSessionService.saveLoginState(data);
      if (!mounted) return;
      unawaited(NotificationService().registerSavedToken());
      unawaited(TtsService.speak(AuthText.loginSuccessful));
      openHomeForRole(context, '${data['role']}');
    } on FormatException {
      _setError(Speech.t.authErrorResponseNotVerified, _phoneFocus);
    } catch (error) {
      _setError(
        ApiService.mapFailure(error: error, context: 'phone login').message,
        _phoneFocus,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _changeNumber() {
    if (!_needsProfile) {
      unawaited(Navigator.of(context).maybePop());
      return;
    }
    setState(() {
      _needsProfile = false;
      _errorMessage = null;
      codeCtrl.clear();
    });
    _keypadController.focusAndAnnounce(_phoneFocus, Speech.t.loginPhoneField);
  }

  void _setError(String message, FocusNode target) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      isLoading = false;
    });
    _keypadController.focusAndAnnounce(target, ' ');
    TtsService.speak(message, priority: SpeechPriority.critical);
  }

  void _openAdminSignIn() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const AdminLoginScreen()));

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final simBusy = _simRequestPending || _simDetecting || isLoading;
    final labels = <int, String>{
      1: _needsProfile ? t.loginKeyContinue : t.loginKeySignIn,
      if (!_needsProfile) 2: t.loginKeySim,
      3: t.loginKeyAdmin,
      0: _needsProfile ? t.loginKeyChangeNumber : t.keyGoBack,
    };
    return KeypadInstructionWrapper(
      interactionPolicy: KeypadInteractionPolicy.numbered,
      screenName: t.loginScreenName,
      brief: _needsProfile ? t.loginEnterProfileCode : t.loginIntro,
      navigationController: _keypadController,
      initialFocusNode: _phoneFocus,
      labels: labels,
      actions: {
        1: _signIn,
        if (!_needsProfile) 2: _initMobileNumber,
        3: _openAdminSignIn,
        0: _changeNumber,
      },
      focusTargets: [
        KeypadFocusTarget(
          node: _phoneFocus,
          label: t.loginPhoneField,
          isTextField: true,
        ),
        if (_needsProfile)
          KeypadFocusTarget(
            node: _codeFocus,
            label: t.loginProfileField,
            isTextField: true,
          ),
        KeypadFocusTarget(
          node: _submitFocus,
          label: '1. ${labels[1]}',
          onActivate: _signIn,
          isEnabled: () => !isLoading,
        ),
        if (!_needsProfile)
          KeypadFocusTarget(
            node: _simFocus,
            label: '2. ${t.loginKeySim}',
            onActivate: _initMobileNumber,
            isEnabled: () => !simBusy,
          ),
        KeypadFocusTarget(
          node: _adminFocus,
          label: '3. ${t.loginKeyAdmin}',
          onActivate: _openAdminSignIn,
        ),
      ],
      child: PopScope(
        canPop: !_needsProfile,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _changeNumber();
        },
        child: Scaffold(
          backgroundColor: UIUtils.backgroundColor,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: UIUtils.paddingAll(context, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        t.loginScreenName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 22),
                          fontWeight: FontWeight.bold,
                          color: UIUtils.textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: UIUtils.spacing(context, 12)),
                    _field(
                      controller: phoneCtrl,
                      focusNode: _phoneFocus,
                      label: t.loginPhoneLabel,
                      icon: Icons.phone_iphone_rounded,
                      error: _needsProfile ? null : _errorMessage,
                      readOnly: _needsProfile,
                    ),
                    if (_needsProfile) ...[
                      SizedBox(height: UIUtils.spacing(context, 12)),
                      _field(
                        controller: codeCtrl,
                        focusNode: _codeFocus,
                        label: t.loginProfileLabel,
                        icon: Icons.pin_outlined,
                        error: _errorMessage,
                      ),
                    ],
                    SizedBox(height: UIUtils.spacing(context, 12)),
                    ElevatedButton(
                      focusNode: _submitFocus,
                      onPressed: isLoading ? null : _signIn,
                      child: isLoading
                          ? Semantics(
                              label: t.loginSigningIn,
                              child: const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Text('1: ${labels[1]}'),
                    ),
                    if (!_needsProfile)
                      TextButton(
                        focusNode: _simFocus,
                        onPressed: simBusy ? null : _initMobileNumber,
                        child: Text('2: ${t.loginKeySim}'),
                      ),
                    TextButton(
                      focusNode: _adminFocus,
                      onPressed: _openAdminSignIn,
                      child: Text('3: ${t.loginKeyAdmin}'),
                    ),
                    if (_simStatusMessage != null)
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _simStatusMessage!,
                          style: TextStyle(color: UIUtils.subtextColor),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? error,
    bool readOnly = false,
  }) => TextField(
    controller: controller,
    focusNode: focusNode,
    readOnly: readOnly,
    keyboardType: TextInputType.phone,
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]'))],
    onChanged: (_) {
      if (_errorMessage != null) setState(() => _errorMessage = null);
    },
    style: TextStyle(
      fontSize: UIUtils.fontSize(context, 18),
      color: UIUtils.textColor,
    ),
    decoration: InputDecoration(
      label: Text(label),
      errorText: error,
      errorMaxLines: 4,
      prefixIcon: ExcludeSemantics(
        child: Icon(icon, color: UIUtils.accentColor),
      ),
    ),
    onTap: () {
      _keypadController.enterTextEditing(focusNode);
      TtsService.speak(AuthText.enterPhone);
    },
  );
}

/// Administrators keep a password; this path never serves students or
/// teachers, and the number-only path never serves administrators.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _phoneFocus = FocusNode(debugLabel: 'admin-login-phone');
  final _passwordFocus = FocusNode(debugLabel: 'admin-login-password');
  final _submitFocus = FocusNode(debugLabel: 'admin-login-submit');
  final _keypadController = KeypadNavigationController();
  bool _busy = false;
  bool _visible = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _submitFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final phone = _phone.text.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isEmpty) {
      return _fail(Speech.t.loginErrorEnterPhone, _phoneFocus);
    }
    if (_password.text.isEmpty) {
      return _fail(Speech.t.authErrorEnterPassword, _passwordFocus);
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ApiService.loginResult(
        phoneNumber: phone,
        password: _password.text,
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        return _fail(result.failure!.message, _passwordFocus);
      }
      final data = result.data!;
      await AuthSessionService.saveLoginState(data);
      if (!mounted) return;
      _password.clear();
      if (data['must_change_password'] == true) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/change_password', (_) => false);
        return;
      }
      unawaited(TtsService.speak(AuthText.loginSuccessful));
      openHomeForRole(context, '${data['role']}');
    } on FormatException {
      _fail(Speech.t.authErrorResponseNotVerified, _phoneFocus);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _fail(String message, FocusNode target) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _busy = false;
    });
    _keypadController.focusAndAnnounce(target, ' ');
    TtsService.speak(message, priority: SpeechPriority.critical);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return KeypadInstructionWrapper(
      interactionPolicy: KeypadInteractionPolicy.numbered,
      screenName: t.adminLoginScreenName,
      brief: t.adminLoginIntro,
      navigationController: _keypadController,
      initialFocusNode: _phoneFocus,
      labels: {1: t.loginKeySignIn, 0: t.keyGoBack},
      actions: {1: _submit, 0: () => Navigator.of(context).maybePop()},
      focusTargets: [
        KeypadFocusTarget(
          node: _phoneFocus,
          label: t.loginPhoneField,
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _passwordFocus,
          label: t.authPasswordField,
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _submitFocus,
          label: '1. ${t.loginKeySignIn}',
          onActivate: _submit,
          isEnabled: () => !_busy,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: UIUtils.useStackedLayout(context)
              ? null
              : Text(t.adminLoginScreenName),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (UIUtils.useStackedLayout(context)) ...[
                  Semantics(
                    header: true,
                    child: Text(
                      t.adminLoginScreenName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _phone,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(label: Text(t.loginPhoneLabel)),
                  onTap: () => _keypadController.enterTextEditing(_phoneFocus),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  focusNode: _passwordFocus,
                  obscureText: !_visible,
                  decoration: InputDecoration(
                    label: Text(t.authPassword),
                    errorText: _error,
                    errorMaxLines: 4,
                    suffixIcon: IconButton(
                      tooltip: _visible
                          ? t.authHidePassword
                          : t.authShowPassword,
                      icon: Icon(
                        _visible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _visible = !_visible),
                    ),
                  ),
                  onTap: () =>
                      _keypadController.enterTextEditing(_passwordFocus),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  focusNode: _submitFocus,
                  onPressed: _busy ? null : _submit,
                  child: Text('1: ${t.loginKeySignIn}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
