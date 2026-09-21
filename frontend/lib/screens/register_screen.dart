// Uses the backend API /register to make a new account for a user

// imports flutter material design UI
import 'package:flutter/material.dart';
// kIsWeb is a flutter constant which tells us whether the app is running on mobile(false) or browser(true)
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend/screens/login_screen.dart';
// allows saving small data locally - similar to cookies
import 'package:shared_preferences/shared_preferences.dart';
// import other files
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../utils/keypad_actions.dart';
// import 'login_screen.dart';

// In flutter everything is a widget, we extend our Register screen to Stateful Widget which is a widget whose UI can be dynamic
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  // Link the Register Screen widget to its mutable state( _RegisterScreenState ) which holds variables, logic and UI updates
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// The underscore before the name means private
class _RegisterScreenState extends State<RegisterScreen> {
  // Take inputs from the user
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool isTeacher = false;
  bool isLoading = false;
  bool _passwordVisible = false;
  final KeypadNavigationController _keypadController =
      KeypadNavigationController();
  final FocusNode _nameFocus = FocusNode(debugLabel: 'register-name');
  final FocusNode _phoneFocus = FocusNode(debugLabel: 'register-phone');
  final FocusNode _passwordFocus = FocusNode(debugLabel: 'register-password');
  final FocusNode _passwordVisibilityFocus = FocusNode(
    debugLabel: 'register-password-visibility',
  );
  final FocusNode _roleFocus = FocusNode(debugLabel: 'register-role');
  final FocusNode _submitFocus = FocusNode(debugLabel: 'register-submit');
  final FocusNode _loginFocus = FocusNode(debugLabel: 'register-login');

  void _showRegistrationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    TtsService.speak(message);
  }

  // Register Function which is Future(operation takes time) and async(non-blocking)
  Future<void> register() async {
    final userName = nameCtrl.text.trim();
    final phoneNumber = phoneCtrl.text.trim();
    final password = passCtrl.text;
    if (userName.isEmpty || phoneNumber.isEmpty || password.isEmpty) {
      _showRegistrationError(
        'Please complete name, phone number, and password.',
      );
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      _showRegistrationError('Enter a valid 10-digit phone number.');
      return;
    }
    if (password.length < 6) {
      _showRegistrationError('Password must be at least 6 characters.');
      return;
    }

    // setState tells flutter that UI has been changed and hence rebuild it
    setState(() => isLoading = true);

    // The input we took using TextEditingController is accessed using <var>.text
    // A dart map which is to be sent to the backend
    final data = {
      'name': userName,
      'phone_number': phoneNumber,
      'password': password,
      'role': isTeacher ? 'teacher' : 'student',
    };

    // App waits for backend response and the UI does not freeze
    try {
      final result = await ApiService.postResult(
        '/auth/register',
        data,
        context: 'registration password',
      );
      if (!result.isSuccess) {
        _showRegistrationError(result.failure!.message);
        return;
      }
      final res = result.data!;

      // Opens local storage
      final prefs = await SharedPreferences.getInstance();

      final userId = int.tryParse((res['user_id'] ?? res['id']).toString());
      final registeredRole = (res['role'] ?? data['role'])
          .toString()
          .toLowerCase();

      if (userId != null) {
        // Saves data permanently
        await prefs.setInt('user_id', userId);
        await prefs.setString('role', registeredRole);

        // SAVE THE NAME HERE
        await prefs.setString('user_name', userName);
        await prefs.setString('name', userName); // Fallback key

        debugPrint(
          "User registered with ID: $userId, Name: $userName, Role: $registeredRole",
        );

        // Register FCM token after registration (non-blocking)
        _registerFCMTokenIfAvailable();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );

        // Removes Registration screen and Navigate to dashboard
        if (isTeacher) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint("Registration error: $e");
      _showRegistrationError(
        ApiService.mapFailure(error: e, context: 'registration').message,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _passwordVisibilityFocus.dispose();
    _roleFocus.dispose();
    _submitFocus.dispose();
    _loginFocus.dispose();
    super.dispose();
  }

  void _toggleRole() {
    setState(() => isTeacher = !isTeacher);
    TtsService.speak(
      isTeacher ? "Registering as teacher" : "Registering as student",
    );
  }

  // Register FCM token with backend after registration - private function
  Future<void> _registerFCMTokenIfAvailable() async {
    try {
      // Reads previously saved FCM Token
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');

      if (fcmToken != null && fcmToken.isNotEmpty) {
        print('[REGISTER] Registering saved FCM token with backend');

        final result = await ApiService.post('/users/fcm-token', {
          'token': fcmToken,
          'device_type': kIsWeb ? 'web' : 'mobile',
        }, useAuth: true);

        if (result != null && result['ok'] == true) {
          print('[REGISTER] FCM token registered successfully');
        } else {
          print('[REGISTER] FCM token registration response: $result');
        }
      } else {
        print('[REGISTER] No FCM token to register');
      }
    } catch (e) {
      print('[REGISTER] Error registering FCM token: $e');
      // Don't throw - not critical
    }
  }

  // Describe UI as a tree like structure and reruns everytime setState is called
  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: 'Registration Screen',
      labels: registerKeyLabels,
      navigationController: _keypadController,
      focusTargets: [
        KeypadFocusTarget(
          node: _nameFocus,
          label: 'Name field',
          isTextField: true,
        ),
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
              ? 'Register as teacher selected'
              : 'Register as student selected',
          onActivate: _toggleRole,
        ),
        KeypadFocusTarget(
          node: _submitFocus,
          label: 'Register button',
          onActivate: isLoading ? null : register,
          isEnabled: () => !isLoading,
        ),
        KeypadFocusTarget(
          node: _loginFocus,
          label: 'Go to login',
          onActivate: () => Navigator.pushNamed(context, '/login'),
        ),
      ],
      actions: {
        1: register,
        2: () => Navigator.pushNamed(context, '/login'),
        3: _toggleRole,
      },
      child: Scaffold(
        backgroundColor: UIUtils.backgroundColor,
        body: Padding(
          padding: UIUtils.paddingAll(context, 16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Register",
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 20)),

                  // Input text fields
                  TextField(
                    controller: nameCtrl,
                    focusNode: _nameFocus,
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 14),
                      color: UIUtils.textColor,
                    ),
                    decoration: InputDecoration(
                      labelText: "Name",
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
                        Icons.person_outline_rounded,
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
                    onTap: () {
                      _keypadController.enterTextEditing(_nameFocus);
                      TtsService.speak('Enter name');
                    },
                  ),
                  SizedBox(height: UIUtils.spacing(context, 12)),

                  // Input Text Fields
                  TextField(
                    controller: phoneCtrl,
                    focusNode: _phoneFocus,
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
                    onTap: () {
                      _keypadController.enterTextEditing(_phoneFocus);
                      TtsService.speak('Enter phone number');
                    },
                  ),
                  SizedBox(height: UIUtils.spacing(context, 12)),

                  // Input Password
                  TextField(
                    controller: passCtrl,
                    focusNode: _passwordFocus,
                    obscureText: !_passwordVisible,
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
                  SizedBox(height: UIUtils.spacing(context, 10)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Register as Teacher?",
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 13),
                        ),
                      ),
                      Transform.scale(
                        scale: UIUtils.scale(context),
                        child: Switch(
                          focusNode: _roleFocus,
                          value: isTeacher,
                          onChanged: (_) => _toggleRole(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: UIUtils.spacing(context, 12)),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      focusNode: _submitFocus,
                      onPressed: isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIUtils.primaryColor,
                        padding: UIUtils.paddingSymmetric(
                          context,
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
                              "1: Register",
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 16)),

                  // Add "Already have account" option
                  TextButton(
                    focusNode: _loginFocus,
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: Text(
                      "2: Already have an account? Login",
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
