import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_service.dart';
import '../services/api_service.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../utils/keypad_actions.dart';
import '../widgets/keypad_confirmation_dialog.dart';

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
  bool isTeacher = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initMobileNumber());
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
    super.dispose();
  }

  Future<void> _initMobileNumber() async {
    // On web, SIM detection is not supported
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      if (mounted) {
        setState(() {
          _simDetecting = false;
          _simStatusMessage = "SIM detection not supported on web";
        });
      }
      return;
    }

    try {
      var status = await Permission.phone.status;
      if (!status.isGranted) {
        if (!mounted) return;
        final continueWithSim = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const KeypadConfirmationDialog(
            title: 'Optional SIM autofill',
            message:
                'SEEDS can read phone information only to fill the login phone number from this device. SIM access is not required for login, registration, or joining a session.',
            confirmLabel: 'Use SIM autofill',
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
      }

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
      final bool hasPhonePermission = await MobileNumber.hasPhonePermission;
      if (!hasPhonePermission) {
        await MobileNumber.requestPhonePermission;
      }

      // Step 3: Read SIM cards
      final List<SimCard> simCards = (await MobileNumber.getSimCards) ?? [];

      if (!mounted) return;

      if (simCards.isEmpty) {
        // ------- NO SIM FOUND -------
        setState(() {
          _simCards = [];
          _simDetecting = false;
          _simStatusMessage = "No SIM card found";
        });
        TtsService.speak("No SIM card found on this device");
      } else if (simCards.length == 1) {
        // ------- SINGLE SIM -------
        final rawNumber = simCards[0].number;
        final carrier = simCards[0].carrierName ?? "Unknown carrier";
        final number = (rawNumber != null && rawNumber.isNotEmpty)
            ? _stripCountryCode(rawNumber)
            : null;
        setState(() {
          _simCards = simCards;
          _simDetecting = false;
          _simStatusMessage = (number != null && number.isNotEmpty)
              ? "SIM Detected: $number ($carrier)"
              : "SIM Detected: $carrier (number unavailable)";
        });
        if (number != null && number.isNotEmpty) {
          phoneCtrl.text = number;
          TtsService.speak("Phone number found. $number");
        } else {
          TtsService.speak(
            "SIM card detected from $carrier but number is not available",
          );
        }
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
        _showSimSelectionDialog(simCards);
      }
    } catch (e) {
      debugPrint("Error initializing mobile number: $e");
      if (mounted) {
        setState(() {
          _simDetecting = false;
          _simStatusMessage =
              "SIM autofill unavailable. Enter the phone number manually.";
        });
      }
    }
  }

  void _showSimSelectionDialog(List<SimCard> cards) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.sim_card, color: Colors.teal),
            SizedBox(width: 8),
            Text("Select SIM Card"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final carrier = card.carrierName ?? "SIM ${index + 1}";
              final number = card.number ?? "Number unavailable";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    carrier,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(number),
                  onTap: () {
                    final cleanNumber =
                        (card.number != null && card.number!.isNotEmpty)
                        ? _stripCountryCode(card.number!)
                        : number;
                    setState(() {
                      if (card.number != null && card.number!.isNotEmpty) {
                        phoneCtrl.text = cleanNumber;
                      }
                      _simStatusMessage = "Selected: $carrier ($cleanNumber)";
                    });
                    TtsService.speak("Phone number found. $cleanNumber");
                    Navigator.pop(ctx);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _simStatusMessage =
                    "${cards.length} SIM cards available. Tap to choose.";
              });
              Navigator.pop(ctx);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // defining the login function
  Future<void> _login() async {
    // get text input by the user
    final phone = phoneCtrl.text.trim();
    final password = passCtrl.text.trim();

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

      // access backend response fields
      final accessToken = data['access_token'];
      final userId = data['user_id'];
      final role = data['role'];
      final userName = data['name'];

      if (accessToken == null || userId == null || role == null) {
        _setLoginError("Invalid response from server");
        debugPrint("Login response missing keys: $data");
        return;
      }

      final roleText = role.toString().trim().toLowerCase();

      if (isTeacher && roleText != 'teacher' && roleText != 'admin') {
        _setLoginError("This phone number is registered as a student account");
        return;
      }

      // open persistant local storage
      final prefs = await SharedPreferences.getInstance();

      // save login session
      await prefs.setString('token', accessToken);
      await prefs.setInt('user_id', userId);
      await prefs.setString('role', roleText);

      // SAVE USER NAME
      if (userName != null) {
        await prefs.setString('user_name', userName);
        await prefs.setString('name', userName); // Fallback key
        debugPrint("Login successful for user: $userName");
      } else {
        debugPrint("Warning: No name in login response");
      }

      // Register FCM token after login (non-blocking)
      _registerFCMTokenIfAvailable();

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

  // Register FCM token with backend after login
  Future<void> _registerFCMTokenIfAvailable() async {
    try {
      // read the stored push notification token
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');

      if (fcmToken != null && fcmToken.isNotEmpty) {
        print('[LOGIN] Registering saved FCM token with backend');

        final result = await ApiService.post('/users/fcm-token', {
          'token': fcmToken,
          'device_type': kIsWeb ? 'web' : 'mobile',
        }, useAuth: true);

        if (result != null && result['ok'] == true) {
          print('[LOGIN] FCM token registered successfully');
        } else {
          print('[LOGIN] FCM token registration response: $result');
        }
      } else {
        print('[LOGIN] No FCM token to register');
      }
    } catch (e) {
      print('[LOGIN] Error registering FCM token: $e');
      // Don't throw - not critical for login
    }
  }

  // UI for the LOGIN SCREEN
  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: 'Login Screen',
      labels: loginKeyLabels,
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
          label: isTeacher
              ? 'Teacher account selected'
              : 'Student account selected',
          onActivate: () {
            setState(() => isTeacher = !isTeacher);
            TtsService.speak(
              isTeacher
                  ? 'Teacher account expected'
                  : 'Student account expected',
            );
          },
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
      ],
      actions: {
        1: _login,
        2: () => Navigator.pushNamed(context, '/register'),
        3: () {
          setState(() => isTeacher = !isTeacher);
          TtsService.speak(
            isTeacher ? "Teacher account expected" : "Student account expected",
          );
        },
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
                          : (_simDetecting
                                ? Colors.grey.shade100
                                : (_simCards.isNotEmpty
                                      ? Colors.teal.shade50
                                      : Colors.red.shade50)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: UIUtils.isHighContrast
                            ? UIUtils.accentColor
                            : (_simDetecting
                                  ? Colors.grey.shade300
                                  : (_simCards.isNotEmpty
                                        ? Colors.teal.shade300
                                        : Colors.red.shade300)),
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
                                : Icons.sim_card_alert,
                            size: UIUtils.iconSize(context, 18),
                            color: UIUtils.isHighContrast
                                ? UIUtils.accentColor
                                : (_simCards.isNotEmpty
                                      ? Colors.teal
                                      : Colors.red.shade600),
                          ),
                        SizedBox(width: UIUtils.spacing(context, 8)),
                        // Status text
                        Expanded(
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
                                              : Colors.red.shade700)),
                            ),
                          ),
                        ),
                        // Re-select button for multiple SIMs
                        if (!_simDetecting && _simCards.length > 1)
                          GestureDetector(
                            onTap: () => _showSimSelectionDialog(_simCards),
                            child: Icon(
                              Icons.swap_horiz,
                              size: UIUtils.iconSize(context, 18),
                              color: Colors.teal.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: UIUtils.spacing(context, 8)),

                  TextField(
                    controller: phoneCtrl,
                    focusNode: _phoneFocus,
                    onChanged: (_) {
                      if (_errorMessage != null)
                        setState(() => _errorMessage = null);
                    },
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 14),
                      color: UIUtils.textColor,
                    ),
                    decoration: InputDecoration(
                      labelText: "Phone number",
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
                      if (_errorMessage != null)
                        setState(() => _errorMessage = null);
                    },
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 14),
                      color: UIUtils.textColor,
                    ),
                    decoration: InputDecoration(
                      labelText: "Password",
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Teacher account?",
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 13),
                        ),
                      ),
                      Transform.scale(
                        scale: UIUtils.scale(context),
                        child: Switch(
                          focusNode: _roleFocus,
                          value: isTeacher,
                          onChanged: (v) {
                            setState(() => isTeacher = v);
                            TtsService.speak(
                              v
                                  ? "Teacher account expected"
                                  : "Student account expected",
                            );
                          },
                        ),
                      ),
                    ],
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
                              "1: Login",
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
                      "2: Don't have an account? Register",
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
