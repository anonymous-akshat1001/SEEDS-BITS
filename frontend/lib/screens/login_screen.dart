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
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import 'package:flutter/services.dart';

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

  // SIM detection state
  List<SimCard> _simCards = [];
  bool _simDetecting = true;   // true while detection is in progress
  bool _simDetectionDone = false;
  String _simStatusMessage = "Detecting SIM card...";

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
    _initMobileNumber();
  }

  Future<void> _initMobileNumber() async {
    // On web, SIM detection is not supported
    if (kIsWeb) {
      if (mounted) {
        setState(() {
          _simDetecting = false;
          _simDetectionDone = true;
          _simStatusMessage = "SIM detection not supported on web";
        });
      }
      return;
    }

    try {
      // Step 1: Request phone permission via permission_handler
      var status = await Permission.phone.status;
      if (!status.isGranted) {
        status = await Permission.phone.request();
      }

      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _simDetecting = false;
            _simDetectionDone = true;
            _simStatusMessage = "Phone permission denied. Cannot detect SIM.";
          });
        }
        TtsService.speak("Phone permission denied. Cannot detect SIM card.");
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
          _simDetectionDone = true;
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
          _simDetectionDone = true;
          _simStatusMessage = (number != null && number.isNotEmpty)
              ? "SIM Detected: $number ($carrier)"
              : "SIM Detected: $carrier (number unavailable)";
        });
        if (number != null && number.isNotEmpty) {
          phoneCtrl.text = number;
          TtsService.speak("Phone number found. $number");
        } else {
          TtsService.speak("SIM card detected from $carrier but number is not available");
        }
      } else {
        // ------- MULTIPLE SIMs -------
        setState(() {
          _simCards = simCards;
          _simDetecting = false;
          _simDetectionDone = true;
          _simStatusMessage = "${simCards.length} SIM cards detected. Please choose one.";
        });
        TtsService.speak("${simCards.length} SIM cards detected. Please choose one.");
        _showSimSelectionDialog(simCards);
      }
    } catch (e) {
      debugPrint("Error initializing mobile number: $e");
      if (mounted) {
        setState(() {
          _simDetecting = false;
          _simDetectionDone = true;
          _simStatusMessage = "Error detecting SIM card";
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
                  title: Text(carrier, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(number),
                  onTap: () {
                    final cleanNumber = (card.number != null && card.number!.isNotEmpty)
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
                _simStatusMessage = "${cards.length} SIM cards available. Tap to choose.";
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
    return KeypadInstructionWrapper(
      audioAsset: 'audio/login_instructions.mp3',
      ttsInstructions: "Login Screen. Press 1 to login, 2 to go to registration.",
      actions: {
        LogicalKeyboardKey.digit1: _login,
        LogicalKeyboardKey.digit2: () => Navigator.pushNamed(context, '/register'),
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
                    style: TextStyle(fontSize: UIUtils.fontSize(context, 22), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 8)),

                  // ===== SIM DETECTION STATUS CARD =====
                  Container(
                    width: double.infinity,
                    padding: UIUtils.paddingSymmetric(context, horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: _simDetecting
                          ? Colors.grey.shade100
                          : (_simCards.isNotEmpty
                              ? Colors.teal.shade50
                              : Colors.red.shade50),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _simDetecting
                            ? Colors.grey.shade300
                            : (_simCards.isNotEmpty
                                ? Colors.teal.shade300
                                : Colors.red.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon / spinner
                        if (_simDetecting)
                          SizedBox(
                            width: UIUtils.iconSize(context, 16),
                            height: UIUtils.iconSize(context, 16),
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(
                            _simCards.isNotEmpty
                                ? Icons.sim_card
                                : Icons.sim_card_alert,
                            size: UIUtils.iconSize(context, 18),
                            color: _simCards.isNotEmpty
                                ? Colors.teal
                                : Colors.red.shade600,
                          ),
                        SizedBox(width: UIUtils.spacing(context, 8)),
                        // Status text
                        Expanded(
                          child: Text(
                            _simStatusMessage,
                            style: TextStyle(
                              fontSize: UIUtils.fontSize(context, 12),
                              fontWeight: FontWeight.w500,
                              color: _simDetecting
                                  ? Colors.grey.shade700
                                  : (_simCards.isNotEmpty
                                      ? Colors.teal.shade800
                                      : Colors.red.shade700),
                            ),
                          ),
                        ),
                        // Re-select button for multiple SIMs
                        if (!_simDetecting && _simCards.length > 1)
                          GestureDetector(
                            onTap: () => _showSimSelectionDialog(_simCards),
                            child: Icon(Icons.swap_horiz,
                                size: UIUtils.iconSize(context, 18),
                                color: Colors.teal.shade600),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: UIUtils.spacing(context, 8)),

                  TextField(
                    controller: phoneCtrl,
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 14),
                      color: UIUtils.textColor,
                    ),
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
                    // TTS
                    onTap: () => TtsService.speak("Enter phone number"),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 12)),
                  
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 14),
                      color: UIUtils.textColor,
                    ),
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
                  SizedBox(height: UIUtils.spacing(context, 8)),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Login as Teacher?", style: TextStyle(fontSize: UIUtils.fontSize(context, 13))),
                      Transform.scale(
                        scale: UIUtils.scale(context),
                        child: Switch(
                          value: isTeacher,
                          onChanged: (v) => setState(() => isTeacher = v),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: UIUtils.spacing(context, 8)),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIUtils.primaryColor,
                        padding: UIUtils.paddingSymmetric(context, horizontal: 24, vertical: 14),
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
                              "1: Login",
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 16), 
                                fontWeight: FontWeight.w600,
                                color: Colors.white
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 16)),
                  
                  // Add "Create account" option
                  TextButton(
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