import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import '../services/tts_service.dart';
import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/notification_services.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../utils/keypad_actions.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../widgets/sim_suggestion_dialog.dart';

// Defining the Login screen widget as a statefu widget - loading state/input/switch toggle reloads UI
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.justRegistered = false, this.initialRole});

  /// Set after a successful registration: says so and focuses the phone field.
  final bool justRegistered;

  /// Preselected account type: 'student', 'teacher' or 'admin'.
  final String? initialRole;

  // Links UI to logic/state
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Defining the State class - where the logic lives
class _LoginScreenState extends State<LoginScreen> {
  // store text typed by user
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // state variables
  String _selectedRole = 'student';
  bool isLoading = false;
  bool _passwordVisible = false;
  String? _errorMessage;
  bool _errorOnPhone = false;
  final KeypadNavigationController _keypadController =
      KeypadNavigationController();
  final FocusNode _phoneFocus = FocusNode(debugLabel: 'login-phone');
  final FocusNode _passwordFocus = FocusNode(debugLabel: 'login-password');
  final FocusNode _passwordVisibilityFocus = FocusNode(
    debugLabel: 'login-password-visibility',
  );
  final FocusNode _roleFocus = FocusNode(debugLabel: 'login-role');
  final FocusNode _submitFocus = FocusNode(debugLabel: 'login-submit');
  final FocusNode _registerFocus = FocusNode(debugLabel: 'login-register');
  final FocusNode _simFocus = FocusNode(debugLabel: 'login-sim-suggestion');
  final FocusNode _recoveryFocus = FocusNode(debugLabel: 'login-recovery-help');
  bool _simRequestPending = false;

  // SIM detection state
  List<SimCard> _simCards = [];
  bool _simDetecting = false; // true while detection is in progress
  String _simStatusMessage = "SIM phone-number autofill is optional";

  /// Strips the leading '91' country code from Indian phone numbers
  String _stripCountryCode(String number) {
    // Remove any spaces, dashes, or plus signs first
    String cleaned = number.replaceAll(RegExp(r'[\s\-\+]'), '');
    // Strip leading 91 if the result would be a 10-digit number
    if (cleaned.startsWith('91') && cleaned.length > 10) {
      cleaned = cleaned.substring(2);
    }
    return cleaned;
  }

  @override
  void initState() {
    super.initState();
    const roles = ['student', 'teacher', 'admin'];
    if (roles.contains(widget.initialRole)) _selectedRole = widget.initialRole!;
    if (widget.justRegistered) {
      // Runs before the keypad wrapper's own first-frame focus request, so
      // this message replaces the plain field announcement.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _keypadController.focusAndAnnounce(
          _phoneFocus,
          'Registered. Now log in. Phone number field. Press star for help.',
        );
      });
    }
  }

  @override
  void dispose() {
    phoneCtrl.dispose();
    passCtrl.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _passwordVisibilityFocus.dispose();
    _roleFocus.dispose();
    _submitFocus.dispose();
    _registerFocus.dispose();
    _simFocus.dispose();
    _recoveryFocus.dispose();
    super.dispose();
  }

  Future<void> _initMobileNumber() async {
    if (_simRequestPending || _simDetecting || isLoading) return;
    // On web, SIM detection is not supported
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      if (mounted) {
        setState(() {
          _simDetecting = false;
          _simStatusMessage =
              "SIM suggestions are unavailable on this device. Enter the phone number manually.";
        });
        await TtsService.speak(_simStatusMessage);
      }
      return;
    }

    setState(() => _simRequestPending = true);
    try {
      final continueWithSim = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const KeypadConfirmationDialog(
          title: 'Optional SIM autofill',
          message:
              'Read optional phone-number suggestions from this device? You will choose a suggestion before it replaces the phone field. This does not verify who owns an account. SIM access is never required for login, registration, Wi-Fi, or joining a session.',
          confirmLabel: 'Read SIM suggestions',
        ),
      );
      if (continueWithSim != true) {
        if (!mounted) return;
        setState(() {
          _simDetecting = false;
          _simStatusMessage =
              'SIM autofill skipped. Enter the phone number manually.';
        });
        return;
      }
      if (!mounted) return;
      var status = await Permission.phone.status.timeout(
        const Duration(seconds: 10),
      );
      if (!mounted) return;

      if (mounted) {
        setState(() {
          _simDetecting = true;
          _simStatusMessage = 'Detecting SIM card...';
        });
      }

      // Step 1: Request phone permission via permission_handler
      if (!status.isGranted) {
        status = await Permission.phone.request();
      }
      if (!mounted) return;

      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _simDetecting = false;
            _simStatusMessage =
                "SIM autofill unavailable. Enter the phone number manually.";
          });
        }
        TtsService.speak(
          "SIM autofill unavailable. Enter the phone number manually.",
        );
        return;
      }

      // Step 2: Also check the plugin's own permission
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
      if (!mounted) return;

      // Step 3: Read SIM cards
      final lookup = MobileNumber.getSimCards;
      if (lookup == null) {
        await _simUnavailable(StateError('SIM lookup is unavailable'));
        return;
      }
      final simCards = await lookup.timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (simCards.isEmpty) {
        // ------- NO SIM FOUND -------
        setState(() {
          _simCards = [];
          _simDetecting = false;
          _simStatusMessage =
              "No SIM card found. Enter the phone number manually.";
        });
        TtsService.speak(_simStatusMessage);
      } else {
        // ------- MULTIPLE SIMs -------
        setState(() {
          _simCards = simCards;
          _simDetecting = false;
          _simStatusMessage =
              "${simCards.length} SIM cards detected. Please choose one.";
        });
        TtsService.speak(
          "${simCards.length} SIM cards detected. Please choose one.",
        );
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
      _simStatusMessage =
          'SIM suggestion unavailable. Enter the phone number manually.';
    });
    await TtsService.speak(_simStatusMessage);
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
              label:
                  'SIM ${i + 1}, ${cards[i].carrierName ?? 'Unknown carrier'}',
              number: _stripCountryCode(cards[i].number ?? ''),
            ),
        ],
      ),
    );
    if (!mounted || selection == null) return;
    setState(() {
      phoneCtrl.text = selection;
      _simStatusMessage =
          'Selected suggestion filled. This is not proof of account ownership.';
    });
    await TtsService.speak(
      'Phone-number suggestion filled. Enter your password to sign in. No sign-in was sent.',
    );
  }

  // defining the login function
  Future<void> _login() async {
    // get text input by the user
    final phone = phoneCtrl.text.trim();
    final password = passCtrl.text;

    if (phone.isEmpty) {
      _setLoginError('Enter your phone number.', fix: _phoneFocus);
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _setLoginError('Enter a valid 10-digit phone number.', fix: _phoneFocus);
      return;
    }

    if (password.isEmpty) {
      _setLoginError('Enter your password.');
      return;
    }

    if (password.length < 6) {
      _setLoginError('Password must be at least 6 characters.');
      return;
    }

    // State changed → rebuild UI
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.loginResult(
        phoneNumber: phone,
        password: password,
      );
      if (!result.isSuccess) {
        _setLoginError(result.failure!.message);
        return;
      }
      final data = result.data!;
      if (!mounted) return;

      // access backend response fields
      final accessToken = data['access_token'];
      final userId = data['user_id'];
      final role = data['role'];

      if (accessToken == null || userId == null || role == null) {
        _setLoginError("Invalid response from server");
        debugPrint("Login response missing required fields");
        return;
      }

      final roleText = role.toString().trim().toLowerCase();

      if (roleText != _selectedRole) {
        _setLoginError(
          'This phone number is not registered as a $_selectedRole account. '
          'Press 1, 2 or 3 to choose the account type.',
          fix: _roleFocus,
        );
        return;
      }

      await AuthSessionService.saveLoginState(data);
      if (!mounted) return;
      passCtrl.clear();
      if (data['must_change_password'] == true) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/change_password', (_) => false);
        return;
      }
      unawaited(NotificationService().registerSavedToken());

      TtsService.speak("Login successful");

      // Navigate based on actual backend role - prevents crash in case of unexpected events
      if (!mounted) {
        return;
      }

      // navigate to different dashboard based on the role
      if (roleText == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else if (roleText == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      }
    } on FormatException {
      _setLoginError(
        'The sign-in response could not be verified. Please try again.',
      );
    } catch (e) {
      _setLoginError(ApiService.mapFailure(error: e, context: 'login').message);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Shows [message] on the field to fix, moves focus there and speaks the
  /// error with critical priority so it is never lost behind navigation.
  void _setLoginError(String message, {FocusNode? fix}) {
    if (!mounted) return;
    final target = fix ?? _passwordFocus;
    setState(() {
      _errorMessage = message;
      _errorOnPhone = identical(target, _phoneFocus);
      isLoading = false;
    });
    final fieldName = identical(target, _phoneFocus)
        ? 'phone number field'
        : identical(target, _roleFocus)
        ? 'account type'
        : 'password field';
    // An empty override keeps the focus move silent so it cannot cut off
    // the critical error below.
    _keypadController.focusAndAnnounce(target, ' ');
    final sentence = message.trimRight();
    TtsService.speak(
      '$sentence${sentence.endsWith('.') ? '' : '.'} Moved to $fieldName.',
      priority: SpeechPriority.critical,
    );
  }

  void _selectRole(String role) {
    if (_selectedRole == role) {
      TtsService.speak('${_roleName(role)} account already selected');
      return;
    }
    setState(() => _selectedRole = role);
    TtsService.speak('${_roleName(role)} account selected');
  }

  void _moveRole(int direction) => _selectRole(_neighbourRole(direction));

  String _roleName(String role) {
    if (role == 'admin') return 'Administrator';
    return '${role[0].toUpperCase()}${role.substring(1)}';
  }

  static const _recoverySteps = [
    'Ask your school administrator to reset your password. They must check '
        'who you are in person. A phone number or SIM alone does not prove it. '
        'Never send anyone your permanent password.',
    'The administrator gives you a private 12-digit temporary password. '
        'It works for 24 hours. Ask for a new one if it expires.',
    'Sign in with your phone number and the temporary password, then choose '
        'a new password.',
    'After 10 wrong tries, sign-in pauses for 15 minutes. Recovery needs '
        'internet. Files already on other phones are not removed instantly.',
  ];

  Future<void> _showRecoveryHelp() async {
    final close = FocusNode(debugLabel: 'recovery-help-close');
    final stepNodes = [
      for (var i = 0; i < _recoverySteps.length; i++)
        FocusNode(debugLabel: 'recovery-help-step-${i + 1}'),
    ];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: 'Password recovery help',
        introduction:
            '${_recoverySteps.length} short steps. Press down to hear each step.',
        labels: const {0: 'Back to login'},
        actions: {0: () => Navigator.pop(dialogContext)},
        focusTargets: [
          for (var i = 0; i < _recoverySteps.length; i++)
            KeypadFocusTarget(
              node: stepNodes[i],
              label: 'Step ${i + 1}. ${_recoverySteps[i]}',
              onActivate: () =>
                  TtsService.speak('Step ${i + 1}. ${_recoverySteps[i]}'),
            ),
          KeypadFocusTarget(
            node: close,
            label: 'Back to login, button',
            onActivate: () => Navigator.pop(dialogContext),
          ),
        ],
        child: AlertDialog(
          backgroundColor: UIUtils.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: UIUtils.cardBorderColor, width: 1.5),
          ),
          insetPadding: const EdgeInsets.all(8),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Password recovery help',
                    style: TextStyle(
                      color: UIUtils.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (var i = 0; i < _recoverySteps.length; i++)
                  Focus(
                    focusNode: stepNodes[i],
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '${i + 1}. ${_recoverySteps[i]}',
                        style: TextStyle(
                          color: UIUtils.textColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  focusNode: close,
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    '0: Back to login',
                    style: TextStyle(
                      color: UIUtils.accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    close.dispose();
    for (final node in stepNodes) {
      node.dispose();
    }
  }

  // UI for the LOGIN SCREEN
  /// One full-width account-type choice for narrow screens. Semantics come
  /// from the single "Account type" control that wraps all three rows.
  Widget _roleRow({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) => Material(
    color: selected ? UIUtils.accentColor : UIUtils.cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(
        color: selected ? UIUtils.accentColor : UIUtils.cardBorderColor,
        width: 1.5,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      canRequestFocus: false,
      borderRadius: BorderRadius.circular(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : icon,
                color: selected ? UIUtils.onAccentColor : UIUtils.textColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? UIUtils.onAccentColor : UIUtils.textColor,
                    fontSize: UIUtils.fontSize(context, 16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                Text(
                  'Selected',
                  style: TextStyle(
                    color: UIUtils.onAccentColor,
                    fontSize: UIUtils.fontSize(context, 14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final roleName = _roleName(_selectedRole);
    final roleLabel =
        'Account type: $roleName, selected. Press 1, 2 or 3 to change';
    OutlineInputBorder fieldBorder(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
    final labelStyle = TextStyle(
      fontSize: UIUtils.fontSize(context, 14),
      color: UIUtils.subtextColor,
    );
    final fieldStyle = TextStyle(
      fontSize: UIUtils.fontSize(context, 16),
      color: UIUtils.textColor,
    );
    final simBusy = _simRequestPending || _simDetecting || isLoading;

    return KeypadInstructionWrapper(
      screenName: 'Login Screen',
      initialFocusNode: widget.justRegistered ? _phoneFocus : null,
      navigationSections:
          'phone number, password, account type, login, registration, SIM suggestions and recovery help',
      labels: {
        ...loginKeyLabels,
        6: 'Read optional SIM phone-number suggestions',
        7: 'School-admin password recovery help',
      },
      navigationController: _keypadController,
      // Same order as the controls appear on screen, top to bottom.
      focusTargets: [
        KeypadFocusTarget(
          node: _phoneFocus,
          label: 'Phone number field',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _passwordFocus,
          label: 'Password field',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _passwordVisibilityFocus,
          label: _passwordVisible ? 'Hide password' : 'Show password',
          onActivate: () =>
              setState(() => _passwordVisible = !_passwordVisible),
        ),
        KeypadFocusTarget(
          node: _roleFocus,
          label: '$roleLabel, or use left and right',
          onActivate: () => _moveRole(1),
          onDecrease: () => _moveRole(-1),
          onIncrease: () => _moveRole(1),
        ),
        KeypadFocusTarget(
          node: _submitFocus,
          label: 'Login as $roleName, button',
          onActivate: isLoading ? null : _login,
          isEnabled: () => !isLoading,
        ),
        KeypadFocusTarget(
          node: _registerFocus,
          label: 'Register a new account, button',
          onActivate: () => Navigator.pushNamed(context, '/register'),
        ),
        KeypadFocusTarget(
          node: _simFocus,
          label:
              'Read optional SIM phone-number suggestions. Manual entry always works.',
          isEnabled: () => !_simRequestPending && !_simDetecting && !isLoading,
          onActivate: _initMobileNumber,
        ),
        KeypadFocusTarget(
          node: _recoveryFocus,
          label: 'Forgot password? School-admin recovery help',
          onActivate: _showRecoveryHelp,
        ),
      ],
      actions: {
        1: () => _selectRole('student'),
        2: () => _selectRole('teacher'),
        3: () => _selectRole('admin'),
        4: _login,
        5: () => Navigator.pushNamed(context, '/register'),
        6: _initMobileNumber,
        7: _showRecoveryHelp,
      },
      child: Scaffold(
        backgroundColor: UIUtils.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: UIUtils.paddingAll(context, 16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 22),
                          fontWeight: FontWeight.bold,
                          color: UIUtils.textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: UIUtils.spacing(context, 12)),
                    if (widget.justRegistered) ...[
                      // Already spoken as part of the screen announcement.
                      ExcludeSemantics(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: UIUtils.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: UIUtils.successColor,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            'Registered. Now log in.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: UIUtils.successColor,
                              fontSize: UIUtils.fontSize(context, 16),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: UIUtils.spacing(context, 12)),
                    ],

                    TextField(
                      controller: phoneCtrl,
                      focusNode: _phoneFocus,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                      style: fieldStyle,
                      decoration: InputDecoration(
                        label: const Text('Phone number'),
                        labelStyle: labelStyle,
                        filled: true,
                        fillColor: UIUtils.cardColor,
                        border: fieldBorder(UIUtils.cardBorderColor, 1.5),
                        enabledBorder: fieldBorder(
                          UIUtils.cardBorderColor,
                          1.5,
                        ),
                        focusedBorder: fieldBorder(UIUtils.accentColor, 3),
                        errorText: _errorOnPhone ? _errorMessage : null,
                        errorMaxLines: 4,
                        errorStyle: TextStyle(
                          color: UIUtils.errorColor,
                          fontSize: UIUtils.fontSize(context, 14),
                        ),
                        prefixIcon: ExcludeSemantics(
                          child: Icon(
                            Icons.phone_iphone_rounded,
                            size: UIUtils.iconSize(context, 18),
                            color: UIUtils.accentColor,
                          ),
                        ),
                        contentPadding: UIUtils.paddingSymmetric(
                          context,
                          horizontal: 16,
                          vertical: 16,
                        ),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.phone,
                      onTap: () {
                        _keypadController.enterTextEditing(_phoneFocus);
                        TtsService.speak('Enter phone number');
                      },
                    ),
                    SizedBox(height: UIUtils.spacing(context, 12)),

                    TextField(
                      controller: passCtrl,
                      focusNode: _passwordFocus,
                      obscureText: !_passwordVisible,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                      style: fieldStyle,
                      decoration: InputDecoration(
                        label: const Text('Password'),
                        labelStyle: labelStyle,
                        filled: true,
                        fillColor: UIUtils.cardColor,
                        border: fieldBorder(UIUtils.cardBorderColor, 1.5),
                        enabledBorder: fieldBorder(
                          UIUtils.cardBorderColor,
                          1.5,
                        ),
                        focusedBorder: fieldBorder(UIUtils.accentColor, 3),
                        prefixIcon: ExcludeSemantics(
                          child: Icon(
                            Icons.lock_outline_rounded,
                            size: UIUtils.iconSize(context, 18),
                            color: UIUtils.accentColor,
                          ),
                        ),
                        suffixIcon: IconButton(
                          focusNode: _passwordVisibilityFocus,
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: UIUtils.iconSize(context, 18),
                            color: UIUtils.textColor,
                          ),
                          tooltip: _passwordVisible
                              ? 'Hide password'
                              : 'Show password',
                          onPressed: () => setState(
                            () => _passwordVisible = !_passwordVisible,
                          ),
                        ),
                        errorText: _errorOnPhone ? null : _errorMessage,
                        errorMaxLines: 4,
                        errorStyle: TextStyle(
                          color: UIUtils.errorColor,
                          fontSize: UIUtils.fontSize(context, 14),
                        ),
                        contentPadding: UIUtils.paddingSymmetric(
                          context,
                          horizontal: 16,
                          vertical: 16,
                        ),
                        isDense: true,
                      ),
                      onTap: () {
                        _keypadController.enterTextEditing(_passwordFocus);
                        TtsService.speak('Enter password');
                      },
                    ),
                    SizedBox(height: UIUtils.spacing(context, 12)),

                    // One control for screen readers: the value changes,
                    // the three segments are not separate stops.
                    Focus(
                      focusNode: _roleFocus,
                      child: Semantics(
                        container: true,
                        label: 'Account type',
                        value: '$roleName, selected. Press 1, 2 or 3 to change',
                        increasedValue: _roleName(_neighbourRole(1)),
                        decreasedValue: _roleName(_neighbourRole(-1)),
                        onIncrease: () => _moveRole(1),
                        onDecrease: () => _moveRole(-1),
                        onTap: () => _moveRole(1),
                        excludeSemantics: true,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const roles = [
                              ('student', '1 Student', Icons.school_outlined),
                              ('teacher', '2 Teacher', Icons.person_outline),
                              (
                                'admin',
                                '3 Admin',
                                Icons.admin_panel_settings_outlined,
                              ),
                            ];
                            // Three segments do not fit a 240 px keypad
                            // screen; stack full-width rows there instead.
                            if (constraints.maxWidth < 330 ||
                                UIUtils.useStackedLayout(context)) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final (value, label, icon) in roles)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: _roleRow(
                                        label: label,
                                        icon: icon,
                                        selected: _selectedRole == value,
                                        onTap: () => _selectRole(value),
                                      ),
                                    ),
                                ],
                              );
                            }
                            return SegmentedButton<String>(
                              showSelectedIcon: true,
                              style: SegmentedButton.styleFrom(
                                foregroundColor: UIUtils.textColor,
                                selectedForegroundColor: UIUtils.onAccentColor,
                                selectedBackgroundColor: UIUtils.accentColor,
                                side: BorderSide(
                                  color: UIUtils.cardBorderColor,
                                  width: 1.5,
                                ),
                                textStyle: TextStyle(
                                  fontSize: UIUtils.fontSize(context, 14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              segments: [
                                for (final (value, label, icon) in roles)
                                  ButtonSegment(
                                    value: value,
                                    label: Text(label),
                                    icon: Icon(icon),
                                  ),
                              ],
                              selected: {_selectedRole},
                              onSelectionChanged: (selection) =>
                                  _selectRole(selection.first),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: UIUtils.spacing(context, 12)),

                    ElevatedButton(
                      focusNode: _submitFocus,
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIUtils.primaryColor,
                        foregroundColor: UIUtils.onPrimaryColor,
                        disabledBackgroundColor: UIUtils.cardColor,
                        padding: UIUtils.paddingSymmetric(
                          context,
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: UIUtils.cardBorderColor,
                            width: 1.5,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? Semantics(
                              liveRegion: true,
                              label: 'Signing in, please wait',
                              child: SizedBox(
                                height: UIUtils.iconSize(context, 20),
                                width: UIUtils.iconSize(context, 20),
                                child: CircularProgressIndicator(
                                  color: UIUtils.accentColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Text(
                              '4: Login as $roleName',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                                color: UIUtils.onPrimaryColor,
                              ),
                            ),
                    ),
                    SizedBox(height: UIUtils.spacing(context, 12)),

                    TextButton(
                      focusNode: _registerFocus,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: Text(
                        "5: Don't have an account? Register",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 16),
                          color: UIUtils.accentColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: UIUtils.spacing(context, 12)),

                    // ===== OPTIONAL SIM SUGGESTIONS =====
                    Container(
                      padding: UIUtils.paddingSymmetric(
                        context,
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: UIUtils.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: UIUtils.cardBorderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          ExcludeSemantics(
                            child: _simDetecting
                                ? SizedBox(
                                    width: UIUtils.iconSize(context, 16),
                                    height: UIUtils.iconSize(context, 16),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: UIUtils.accentColor,
                                    ),
                                  )
                                : Icon(
                                    _simCards.isNotEmpty
                                        ? Icons.sim_card
                                        : Icons.info_outline,
                                    size: UIUtils.iconSize(context, 18),
                                    color: UIUtils.accentColor,
                                  ),
                          ),
                          SizedBox(width: UIUtils.spacing(context, 8)),
                          Expanded(
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                _simStatusMessage,
                                style: TextStyle(
                                  fontSize: UIUtils.fontSize(context, 14),
                                  fontWeight: FontWeight.w500,
                                  color: UIUtils.textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      focusNode: _simFocus,
                      onPressed: simBusy ? null : _initMobileNumber,
                      child: Text(
                        '6: Read optional SIM suggestions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 16),
                          color: simBusy
                              ? UIUtils.subtextColor
                              : UIUtils.accentColor,
                        ),
                      ),
                    ),
                    TextButton(
                      focusNode: _recoveryFocus,
                      onPressed: _showRecoveryHelp,
                      child: Text(
                        '7: Forgot password? Recovery help',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 16),
                          color: UIUtils.accentColor,
                        ),
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

  String _neighbourRole(int direction) {
    const roles = ['student', 'teacher', 'admin'];
    var next = (roles.indexOf(_selectedRole) + direction) % roles.length;
    if (next < 0) next += roles.length;
    return roles[next];
  }
}
