// Uses the backend API /register to make a new account for a user

// imports flutter material design UI
import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
// allows saving small data locally - similar to cookies
import 'package:shared_preferences/shared_preferences.dart';
// import other files
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../services/notification_services.dart';
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
  String? _errorMessage;
  FocusNode? _errorField;

  /// Shows the error on [field] (or under Register for server errors),
  /// moves focus to the field to fix and speaks it at critical priority.
  void _showRegistrationError(String message, {FocusNode? field}) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _errorField = field;
      isLoading = false;
    });
    var spoken = message.trimRight();
    if (!spoken.endsWith('.')) spoken = '$spoken.';
    if (field != null) {
      final name = identical(field, _nameFocus)
          ? 'name field'
          : identical(field, _phoneFocus)
          ? 'phone number field'
          : 'password field';
      spoken = '$spoken Moved to $name.';
      // Silent focus move so the error below is not interrupted.
      _keypadController.focusAndAnnounce(field, ' ');
    }
    TtsService.speak(spoken, priority: SpeechPriority.critical);
  }

  void _clearError() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  // Register Function which is Future(operation takes time) and async(non-blocking)
  Future<void> register() async {
    final userName = nameCtrl.text.trim();
    final phoneNumber = phoneCtrl.text.trim();
    final password = passCtrl.text;
    if (userName.isEmpty) {
      _showRegistrationError('Enter your name.', field: _nameFocus);
      return;
    }
    if (phoneNumber.isEmpty) {
      _showRegistrationError('Enter your phone number.', field: _phoneFocus);
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      _showRegistrationError(
        'Enter a valid 10-digit phone number.',
        field: _phoneFocus,
      );
      return;
    }
    if (password.isEmpty) {
      _showRegistrationError('Enter a password.', field: _passwordFocus);
      return;
    }
    if (password.length < 6) {
      _showRegistrationError(
        'Password must be at least 6 characters.',
        field: _passwordFocus,
      );
      return;
    }

    // setState tells flutter that UI has been changed and hence rebuild it
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });
    TtsService.speak('Registering, please wait.');

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
        // The login screen speaks "Registered. Now log in." and focuses
        // its phone field once it is shown.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              justRegistered: true,
              initialRole: registeredRole == 'teacher' ? 'teacher' : 'student',
            ),
          ),
        );
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
    await NotificationService().registerSavedToken();
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
    required FocusNode node,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
    return InputDecoration(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: UIUtils.fontSize(context, 14),
        color: UIUtils.subtextColor,
      ),
      filled: true,
      fillColor: UIUtils.cardColor,
      border: border(UIUtils.cardBorderColor, 1.5),
      enabledBorder: border(UIUtils.cardBorderColor, 1.5),
      focusedBorder: border(UIUtils.accentColor, 3),
      errorText: identical(_errorField, node) ? _errorMessage : null,
      errorMaxLines: 4,
      errorStyle: TextStyle(
        color: UIUtils.errorColor,
        fontSize: UIUtils.fontSize(context, 14),
      ),
      prefixIcon: ExcludeSemantics(
        child: Icon(
          icon,
          size: UIUtils.iconSize(context, 18),
          color: UIUtils.accentColor,
        ),
      ),
      suffixIcon: suffixIcon,
      contentPadding: UIUtils.paddingSymmetric(
        context,
        horizontal: 16,
        vertical: 16,
      ),
      isDense: true,
    );
  }

  // Describe UI as a tree like structure and reruns everytime setState is called
  @override
  Widget build(BuildContext context) {
    final fieldStyle = TextStyle(
      fontSize: UIUtils.fontSize(context, 16),
      color: UIUtils.textColor,
    );
    final serverError = _errorField == null ? _errorMessage : null;
    return KeypadInstructionWrapper(
      screenName: 'Registration Screen',
      navigationSections:
          'name, phone number, password, student or teacher account type, register, and login',
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
              ? 'Account type: Teacher. Press OK or 3 to switch to student'
              : 'Account type: Student. Press OK or 3 to switch to teacher',
          onActivate: _toggleRole,
        ),
        KeypadFocusTarget(
          node: _submitFocus,
          label: 'Register as ${isTeacher ? 'teacher' : 'student'}, button',
          onActivate: isLoading ? null : register,
          isEnabled: () => !isLoading,
        ),
        KeypadFocusTarget(
          node: _loginFocus,
          label: 'Already have an account? Go to login',
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
        body: SafeArea(
          child: Padding(
            padding: UIUtils.paddingAll(context, 16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Register',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 24),
                          fontWeight: FontWeight.bold,
                          color: UIUtils.textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: UIUtils.spacing(context, 20)),

                    TextField(
                      controller: nameCtrl,
                      focusNode: _nameFocus,
                      style: fieldStyle,
                      onChanged: (_) => _clearError(),
                      decoration: _fieldDecoration(
                        context,
                        label: 'Name',
                        icon: Icons.person_outline_rounded,
                        node: _nameFocus,
                      ),
                      onTap: () {
                        _keypadController.enterTextEditing(_nameFocus);
                        TtsService.speak('Enter name');
                      },
                    ),
                    SizedBox(height: UIUtils.spacing(context, 12)),

                    TextField(
                      controller: phoneCtrl,
                      focusNode: _phoneFocus,
                      style: fieldStyle,
                      onChanged: (_) => _clearError(),
                      decoration: _fieldDecoration(
                        context,
                        label: 'Phone number',
                        icon: Icons.phone_iphone_rounded,
                        node: _phoneFocus,
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
                      style: fieldStyle,
                      onChanged: (_) => _clearError(),
                      decoration: _fieldDecoration(
                        context,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        node: _passwordFocus,
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
                      ),
                      onTap: () {
                        _keypadController.enterTextEditing(_passwordFocus);
                        TtsService.speak('Enter password');
                      },
                    ),
                    SizedBox(height: UIUtils.spacing(context, 10)),

                    Container(
                      decoration: BoxDecoration(
                        color: UIUtils.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: UIUtils.cardBorderColor,
                          width: 1.5,
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        focusNode: _roleFocus,
                        activeThumbColor: UIUtils.onAccentColor,
                        activeTrackColor: UIUtils.accentColor,
                        title: Text(
                          "3: Register as ${isTeacher ? 'Teacher' : 'Student'}. Change account type",
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 16),
                            color: UIUtils.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: isTeacher,
                        onChanged: (_) => _toggleRole(),
                      ),
                    ),
                    SizedBox(height: UIUtils.spacing(context, 12)),

                    if (serverError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: UIUtils.errorColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          serverError,
                          style: TextStyle(
                            color: UIUtils.errorColor,
                            fontSize: UIUtils.fontSize(context, 16),
                          ),
                        ),
                      ),
                      SizedBox(height: UIUtils.spacing(context, 12)),
                    ],

                    ElevatedButton(
                      focusNode: _submitFocus,
                      onPressed: isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIUtils.primaryColor,
                        foregroundColor: UIUtils.onPrimaryColor,
                        disabledBackgroundColor: UIUtils.cardColor,
                        padding: UIUtils.paddingSymmetric(
                          context,
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
                              label: 'Registering, please wait',
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
                              '1: Register',
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                                color: UIUtils.onPrimaryColor,
                              ),
                            ),
                    ),
                    SizedBox(height: UIUtils.spacing(context, 16)),

                    TextButton(
                      focusNode: _loginFocus,
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text(
                        '2: Already have an account? Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 16),
                          color: UIUtils.accentColor,
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
