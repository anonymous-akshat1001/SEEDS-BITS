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
  const LoginScreen({super.key});

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

    if (phone.isEmpty || password.isEmpty) {
      _setLoginError("Please fill both phone number and password");
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _setLoginError('Enter a valid 10-digit phone number.');
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
          'This phone number is not registered as a $_selectedRole account.',
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

  void _setLoginError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      isLoading = false;
    });
    TtsService.speak(message);
  }

  void _selectRole(String role) {
    if (_selectedRole == role) {
      TtsService.speak('${_roleName(role)} account already selected');
      return;
    }
    setState(() => _selectedRole = role);
    TtsService.speak('${_roleName(role)} account selected');
  }

  void _moveRole(int direction) {
    const roles = ['student', 'teacher', 'admin'];
    final current = roles.indexOf(_selectedRole);
    var next = (current + direction) % roles.length;
    if (next < 0) next += roles.length;
    _selectRole(roles[next]);
  }

  String _roleName(String role) {
    if (role == 'admin') return 'Administrator';
    return '${role[0].toUpperCase()}${role.substring(1)}';
  }

  Future<void> _showRecoveryHelp() async {
    final close = FocusNode(debugLabel: 'recovery-help-close');
    const message =
        'Ask your school administrator for password recovery. They must verify your identity outside SEEDS. Do not send them your permanent password. A phone number or SIM suggestion alone does not verify identity. An administrator can issue a private 12-digit temporary credential, valid for 24 hours. After 10 wrong attempts, temporary-credential sign-in pauses for 15 minutes. Sign in with your phone number and temporary credential, then choose a new password. Ask the administrator for a replacement if the credential expires. Recovery requires internet and does not instantly revoke files on disconnected phones.';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: message,
        labels: const {0: 'Back to login'},
        actions: {0: () => Navigator.pop(dialogContext)},
        focusTargets: [
          KeypadFocusTarget(
            node: close,
            label: 'Back to login',
            onActivate: () => Navigator.pop(dialogContext),
          ),
        ],
        child: AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'School-admin recovery',
                  style: Theme.of(dialogContext).textTheme.headlineSmall,
                ),
                const Text(message),
                TextButton(
                  focusNode: close,
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('0: Back to login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    close.dispose();
  }

  // UI for the LOGIN SCREEN
  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: 'Login Screen',
      navigationSections:
          'phone number, password, account type, login, registration and recovery help',
      labels: {
        ...loginKeyLabels,
        6: 'Read optional SIM phone-number suggestions',
        7: 'School-admin password recovery help',
      },
      navigationController: _keypadController,
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
          label:
              '${_roleName(_selectedRole)} account selected. Use left or right to change account type',
          onActivate: () => _moveRole(1),
          onDecrease: () => _moveRole(-1),
          onIncrease: () => _moveRole(1),
        ),
        KeypadFocusTarget(
          node: _submitFocus,
          label: 'Login button',
          onActivate: isLoading ? null : _login,
          isEnabled: () => !isLoading,
        ),
        KeypadFocusTarget(
          node: _registerFocus,
          label: 'Register account link',
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
          label: 'School-admin password recovery help',
          onActivate: _showRecoveryHelp,
        ),
      ],
      actions: {
        1: () => _selectRole('student'),
        2: () => _selectRole('teacher'),
        3: () => _selectRole('admin'),
        4: _login,
        7: _showRecoveryHelp,
        5: () => Navigator.pushNamed(context, '/register'),
        6: _initMobileNumber,
      },
      child: Scaffold(
        backgroundColor: UIUtils.backgroundColor,
        body: Padding(
          padding: UIUtils.paddingAll(context, 16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 8)),

                  // ===== SIM DETECTION STATUS CARD =====
                  Container(
                    width: double.infinity,
                    padding: UIUtils.paddingSymmetric(
                      context,
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: UIUtils.isHighContrast
                          ? UIUtils.cardColor
                          : (!_simDetecting && _simCards.isNotEmpty
                                ? Colors.teal.shade50
                                : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: UIUtils.isHighContrast
                            ? UIUtils.accentColor
                            : (!_simDetecting && _simCards.isNotEmpty
                                  ? Colors.teal.shade300
                                  : Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon / spinner
                        if (_simDetecting)
                          SizedBox(
                            width: UIUtils.iconSize(context, 16),
                            height: UIUtils.iconSize(context, 16),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Icon(
                            _simCards.isNotEmpty
                                ? Icons.sim_card
                                : Icons.info_outline,
                            size: UIUtils.iconSize(context, 18),
                            color: UIUtils.isHighContrast
                                ? UIUtils.accentColor
                                : (_simCards.isNotEmpty
                                      ? Colors.teal
                                      : Colors.grey.shade700),
                          ),
                        SizedBox(width: UIUtils.spacing(context, 8)),
                        // Status text
                        Expanded(
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              _simStatusMessage,
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 12),
                                fontWeight: FontWeight.w500,
                                color: UIUtils.isHighContrast
                                    ? UIUtils.textColor
                                    : (_simDetecting
                                          ? Colors.grey.shade700
                                          : (_simCards.isNotEmpty
                                                ? Colors.teal.shade800
                                                : Colors.grey.shade700)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: UIUtils.spacing(context, 8)),

                  TextButton(
                    focusNode: _simFocus,
                    onPressed: _simRequestPending || _simDetecting || isLoading
                        ? null
                        : _initMobileNumber,
                    child: const Text('6: Read optional SIM suggestions'),
                  ),
                  TextButton(
                    focusNode: _recoveryFocus,
                    onPressed: _showRecoveryHelp,
                    child: const Text('7: School-admin password recovery help'),
                  ),
                  TextField(
                    controller: phoneCtrl,
                    focusNode: _phoneFocus,
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 14),
                      color: UIUtils.textColor,
                    ),
                    decoration: InputDecoration(
                      label: const Text("Phone number"),
                      labelStyle: TextStyle(
                        fontSize: UIUtils.fontSize(context, 13),
                        color: UIUtils.subtextColor,
                      ),
                      filled: true,
                      fillColor: UIUtils.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_iphone_rounded,
                        size: UIUtils.iconSize(context, 18),
                        color: UIUtils.accentColor,
                      ),
                      contentPadding: UIUtils.paddingSymmetric(
                        context,
                        horizontal: 16,
                        vertical: 16,
                      ),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.phone,
                    // TTS
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
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 14),
                      color: UIUtils.textColor,
                    ),
                    decoration: InputDecoration(
                      label: const Text("Password"),
                      labelStyle: TextStyle(
                        fontSize: UIUtils.fontSize(context, 13),
                        color: UIUtils.subtextColor,
                      ),
                      filled: true,
                      fillColor: UIUtils.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: UIUtils.iconSize(context, 18),
                        color: UIUtils.accentColor,
                      ),
                      suffixIcon: IconButton(
                        focusNode: _passwordVisibilityFocus,
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: UIUtils.iconSize(context, 18),
                          color: UIUtils.subtextColor,
                        ),
                        tooltip: _passwordVisible
                            ? 'Hide password'
                            : 'Show password',
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                      ),
                      errorText: _errorMessage,
                      errorMaxLines: 2,
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
                  SizedBox(height: UIUtils.spacing(context, 8)),

                  Focus(
                    focusNode: _roleFocus,
                    child: Semantics(
                      label:
                          'Account type. ${_roleName(_selectedRole)} selected. Use left and right arrows to change.',
                      liveRegion: true,
                      child: SegmentedButton<String>(
                        showSelectedIcon: true,
                        segments: const [
                          ButtonSegment(
                            value: 'student',
                            label: Text('1 Student'),
                            icon: Icon(Icons.school_outlined),
                          ),
                          ButtonSegment(
                            value: 'teacher',
                            label: Text('2 Teacher'),
                            icon: Icon(Icons.person_outline),
                          ),
                          ButtonSegment(
                            value: 'admin',
                            label: Text('3 Admin'),
                            icon: Icon(Icons.admin_panel_settings_outlined),
                          ),
                        ],
                        selected: {_selectedRole},
                        onSelectionChanged: (selection) =>
                            _selectRole(selection.first),
                      ),
                    ),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 8)),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      focusNode: _submitFocus,
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIUtils.primaryColor,
                        padding: UIUtils.paddingSymmetric(
                          context,
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: UIUtils.iconSize(context, 20),
                              width: UIUtils.iconSize(context, 20),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "4: Login as ${_roleName(_selectedRole)}",
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 16)),

                  // Add "Create account" option
                  TextButton(
                    focusNode: _registerFocus,
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text(
                      "5: Don't have an account? Register",
                      style: TextStyle(
                        fontSize: UIUtils.fontSize(context, 14),
                        color: UIUtils.accentColor,
                        fontWeight: FontWeight.w500,
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
