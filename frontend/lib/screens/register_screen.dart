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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [

                const Text(
                  "Register",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                
                
                // Input text fields 
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onTap: () => TtsService.speak("Enter name"),
                ),
                const SizedBox(height: 12),
                
                
                // Input Text Fields
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: "Phone number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  onTap: () => TtsService.speak("Enter phone number"),
                ),
                const SizedBox(height: 12),
                
                // Input Password
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  onTap: () => TtsService.speak("Enter password"),
                ),
                const SizedBox(height: 16),
                
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Register as Teacher?"),
                    Switch(
                      value: isTeacher,
                      onChanged: (v) => setState(() => isTeacher = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Register",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),


                // Add "Already have account" option
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
