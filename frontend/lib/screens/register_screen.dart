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
import 'package:flutter/services.dart';
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

  // Register Function which is Future(operation takes time) and async(non-blocking)
  Future<void> register() async {

    // setState tells flutter that UI has been changed and hence rebuild it
    setState(
      () => isLoading = true
    );

    // The input we took using TextEditingController is accessed using <var>.text
    final userName = nameCtrl.text.trim(); 
    // A dart map which is to be sent to the backend
    final data = {
      'name': userName,
      'phone_number': phoneCtrl.text.trim(),
      'password': passCtrl.text,
      'role': isTeacher ? 'teacher' : 'student',
    };

    // App waits for backend response and the UI does not freeze
    try {

      final res = await ApiService.post('/auth/register', data);

      if (res == null) {
        throw Exception("No response from server");
      }

      // If the backend message contains 'detail' then it means it encountered an error
      if (res.containsKey('detail')) {
        
        // mounted ensures the widget is still on screen
        if (mounted) {
          // Shows temporary messages at the bottom and used for errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${res['detail']}")),
          );
        }
        
        setState(
          () => isLoading = false
        );

        return;
      }

      // Opens local storage
      final prefs = await SharedPreferences.getInstance();

      final userId = int.tryParse(res['id'].toString());

      if (userId != null) {
        // Saves data permanently
        await prefs.setInt('user_id', userId);
        await prefs.setString('role', isTeacher ? 'teacher' : 'student');
        
        // SAVE THE NAME HERE
        await prefs.setString('user_name', userName);
        await prefs.setString('name', userName); // Fallback key
        
        debugPrint("User registered with ID: $userId, Name: $userName");
        
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Register FCM token with backend after registration - private function
  Future<void> _registerFCMTokenIfAvailable() async {
    try {
      // Reads previously saved FCM Token
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');
      
      if (fcmToken != null && fcmToken.isNotEmpty) {
        print('[REGISTER] Registering saved FCM token with backend');
        
        final result = await ApiService.post(
          '/users/fcm-token',
          {
            'token': fcmToken,
            'device_type': kIsWeb ? 'web' : 'mobile',
          },
          useAuth: true,
        );
        
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
      audioAsset: 'audio/register_instructions.mp3',
      ttsInstructions: "Registration Screen. Press 1 to register, 2 to go to login.",
      actions: {
        LogicalKeyboardKey.digit1: register,
        LogicalKeyboardKey.digit2: () => Navigator.pushNamed(context, '/login'),
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
                    style: TextStyle(fontSize: UIUtils.fontSize(context, 24), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 20)),
                  
                  // Input text fields 
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(fontSize: UIUtils.fontSize(context, 14), color: UIUtils.textColor),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(fontSize: UIUtils.fontSize(context, 13), color: UIUtils.subtextColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.person_outline_rounded, size: UIUtils.iconSize(context, 18), color: UIUtils.accentColor),
                      contentPadding: UIUtils.paddingSymmetric(context, horizontal: 16, vertical: 16),
                      isDense: true,
                    ),
                    onTap: () => TtsService.speak("Enter name"),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 12)),
                  
                  // Input Text Fields
                  TextField(
                    controller: phoneCtrl,
                    style: TextStyle(fontSize: UIUtils.fontSize(context, 14), color: UIUtils.textColor),
                    decoration: InputDecoration(
                      labelText: "Phone number",
                      labelStyle: TextStyle(fontSize: UIUtils.fontSize(context, 13), color: UIUtils.subtextColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.phone_iphone_rounded, size: UIUtils.iconSize(context, 18), color: UIUtils.accentColor),
                      contentPadding: UIUtils.paddingSymmetric(context, horizontal: 16, vertical: 16),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.phone,
                    onTap: () => TtsService.speak("Enter phone number"),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 12)),
                  
                  // Input Password
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    style: TextStyle(fontSize: UIUtils.fontSize(context, 14), color: UIUtils.textColor),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(fontSize: UIUtils.fontSize(context, 13), color: UIUtils.subtextColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: UIUtils.iconSize(context, 18), color: UIUtils.accentColor),
                      contentPadding: UIUtils.paddingSymmetric(context, horizontal: 16, vertical: 16),
                      isDense: true,
                    ),
                    onTap: () => TtsService.speak("Enter password"),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 10)),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Register as Teacher?", style: TextStyle(fontSize: UIUtils.fontSize(context, 13))),
                      Transform.scale(
                        scale: UIUtils.scale(context),
                        child: Switch(
                          value: isTeacher,
                          onChanged: (v) => setState(() => isTeacher = v),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: UIUtils.spacing(context, 12)),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIUtils.primaryColor,
                        padding: UIUtils.paddingSymmetric(context, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: UIUtils.iconSize(context, 20),
                              width: UIUtils.iconSize(context, 20),
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              "1: Register",
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 16), 
                                fontWeight: FontWeight.w600,
                                color: Colors.white
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 16)),

                  // Add "Already have account" option
                  TextButton(
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
