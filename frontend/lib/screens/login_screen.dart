// imports Dart's JSON utilities
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Imports HTTP networking library
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_service.dart';
import '../services/api_service.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Backend URL
final baseUrl = dotenv.env['API_BASE_URL'];

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

  // defining the login function
  Future<void> _login() async {
    // get text input by the user
    final phone = phoneCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      TtsService.speak("Please fill all fields");
      return;
    }

    // State changed → rebuild UI
    setState(() => isLoading = true);

    try {
      // send http POST request and wait for backend response
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        // meaning backend expects form data not json
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': phone,
          'password': password,
        },
      );

      // response handling - login credentials are correct
      if (res.statusCode == 200) {
        // convert json text to dart map
        final data = jsonDecode(res.body);

        // access backend response fields
        final accessToken = data['access_token'];
        final userId = data['user_id'];
        final role = data['role'];
        final userName = data['name']; 

        if (accessToken == null || userId == null || role == null) {
          TtsService.speak("Invalid response from server");
          debugPrint("Login response missing keys: $data");
          return;
        }

        // open persistant local storage
        final prefs = await SharedPreferences.getInstance();

        // save login session
        await prefs.setString('token', accessToken);
        await prefs.setInt('user_id', userId);
        await prefs.setString('role', role);
        
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
        if (!mounted){
          return;
        }
        
        // navigate to different dashboard based on the role
        if (role.toLowerCase() == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } 
        else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } 
      else if (res.statusCode == 401) {
        TtsService.speak("Invalid credentials");
      } 
      else {
        TtsService.speak("Login failed: ${res.statusCode}");
        debugPrint("Login response: ${res.body}");
      }
    } catch (e) {
      TtsService.speak("Login failed. Check network or credentials.");
      debugPrint("Login error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Register FCM token with backend after login
  Future<void> _registerFCMTokenIfAvailable() async {
    try {
      // read the stored push notification token
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');
      
      if (fcmToken != null && fcmToken.isNotEmpty) {
        print('[LOGIN] Registering saved FCM token with backend');
        
        final result = await ApiService.post(
          '/users/fcm-token',
          {
            'token': fcmToken,
            'device_type': kIsWeb ? 'web' : 'mobile',
          },
          useAuth: true,
        );
        
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: "Phone number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  // TTS
                  onTap: () => TtsService.speak("Enter phone number"),
                ),
                const SizedBox(height: 16),
                
                
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
                const SizedBox(height: 12),
                
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Login as Teacher?"),
                    Switch(
                      value: isTeacher,
                      onChanged: (v) => setState(() => isTeacher = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                
                // Add "Create account" option
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    "Don't have an account? Register",
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