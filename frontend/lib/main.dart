import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/session_screen.dart';
import 'screens/simple_session_screen.dart';
import 'screens/audio_library_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/invite_students_screen.dart';
import 'utils/ui_utils.dart';
import 'services/notification_services.dart';
import 'services/tts_service.dart';
import 'widgets/key_instruction_wrapper.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Global navigation key for handling deep links
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables FIRST (must be before anything that reads dotenv)
  // Try multiple paths, then fall back to hardcoded values so the app never crashes
  try {
    await dotenv.load(fileName: "assets/.env");
    print('[MAIN] Loaded assets/.env');
  } catch (e) {
    print('[MAIN] Failed to load assets/.env: $e');
    try {
      await dotenv.load(fileName: ".env");
      print('[MAIN] Loaded .env');
    } catch (e2) {
      print('[MAIN] Failed to load .env: $e2');
      // Hardcode fallback values so the app still works
      dotenv.testLoad(fileInput: '''
API_BASE_URL=http://responsible-tech.bits-hyderabad.ac.in/seeds
WS_BASE_URL=ws://responsible-tech.bits-hyderabad.ac.in/seeds
WEB_VAPID_KEY=BOYVjb77moWEwSyBY-HxCkiAFBuNrCncK9oSobRL1TubgfGicL1JOiw_B0Nod74jEbsn-xd5URPyRwj0BNzc7LE
      ''');
      print('[MAIN] Using hardcoded fallback env values');
    }
  }
  
  // Initialize Firebase with auto-generated config
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Set up notification tap handler
  notificationService.onNotificationTap = (data) async {
    print('[MAIN] Notification tapped: $data');
    
    // Handle session invitation
    if (data['type'] == 'session_invitation') {
      final sessionId = int.tryParse(data['session_id'] ?? '');
      final sessionTitle = data['session_title'];
      
      if (sessionId != null) {
        // Get user info
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('user_id');
        final userName = prefs.getString('user_name') ?? prefs.getString('name');
        
        if (userId != null && userName != null) {
          // Navigate to session
          navigatorKey.currentState?.pushNamed(
            '/session',
            arguments: {
              'sessionId': sessionId,
              'userId': userId,
              'userName': userName,
              'isTeacher': false,
            },
          );
          
          // Show dialog asking if they want to join
          Future.delayed(const Duration(milliseconds: 500), () {
            navigatorKey.currentState?.overlay?.context.let((context) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Session Invitation'),
                  content: Text('Would you like to join "$sessionTitle"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Later'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Already navigated above
                      },
                      child: const Text('Join Now'),
                    ),
                  ],
                ),
              );
            });
          });
        }
      }
    }
  };
  
  // Listen to notification stream for in-app handling
  notificationService.notificationStream.listen((data) {
    print('[MAIN] Notification received in-app: $data');
    
    // You can show in-app banners or dialogs here
    // For example, using a SnackBar or custom overlay
  });
  
  // Initialize TTS early
  await TtsService.init();
  
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessible Conference',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorSchemeSeed: UIUtils.accentColor,
        useMaterial3: true,
        scaffoldBackgroundColor: UIUtils.backgroundColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: UIUtils.backgroundColor,
          foregroundColor: UIUtils.textColor,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: UIUtils.cardColor,
        ),
      ),

      // Start with a welcome screen (choice between login/register)
      initialRoute: '/welcome',

      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/teacher_dashboard': (context) => const TeacherDashboard(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/settings': (context) => const SettingsScreen(),
      },

      onGenerateRoute: (settings) {
        // Session screen route
        if (settings.name == '/session') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            final sessionId = args['sessionId'];
            final userId = args['userId'];
            final userName = args['userName'];
            final isTeacher = args['isTeacher'] ?? false;

            if (sessionId is int && userId is int && userName is String) {
              return MaterialPageRoute(
                builder: (_) => SessionScreen(
                  sessionId: sessionId,
                  userId: userId,
                  userName: userName,
                  isTeacher: isTeacher,
                ),
                settings: settings,
              );
            }
          }
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }

        // Simple session screen route (for button phones)
        if (settings.name == '/simple_session') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            final sessionId = args['sessionId'];
            final userId = args['userId'];
            final userName = args['userName'];
            final isTeacher = args['isTeacher'] ?? false;

            if (sessionId is int && userId is int && userName is String) {
              return MaterialPageRoute(
                builder: (_) => SimpleSessionScreen(
                  sessionId: sessionId,
                  userId: userId,
                  userName: userName,
                  isTeacher: isTeacher,
                ),
                settings: settings,
              );
            }
          }
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }

        // Audio library screen route
        if (settings.name == '/audio_library') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            final sessionId = args['sessionId'] as int?;
            return MaterialPageRoute(
              builder: (_) => AudioLibraryScreen(sessionId: sessionId),
              settings: settings,
            );
          }
          return MaterialPageRoute(
            builder: (_) => const AudioLibraryScreen(),
            settings: settings,
          );
        }

        // Invite students screen route
        if (settings.name == '/invite_students') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            final sessionId = args['sessionId'];
            final sessionTitle = args['sessionTitle'];

            if (sessionId is int && sessionTitle is String) {
              return MaterialPageRoute(
                builder: (_) => InviteStudentsScreen(
                  sessionId: sessionId,
                  sessionTitle: sessionTitle,
                ),
                settings: settings,
              );
            }
          }
          return MaterialPageRoute(builder: (_) => const TeacherDashboard());
        }

        return null;
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      TtsService.speak("Welcome to Accessible Conference. Press 1 for Login, 2 for Register.");
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);
    final bool isKeypad = UIUtils.isKeypad(context);
    final s = UIUtils.scale(context);

    return KeypadInstructionWrapper(
      audioAsset: 'audio/welcome_instructions.mp3',
      ttsInstructions: "Welcome to SEEDS. Press 1 for Login, 2 for Register.",
      actions: {
        LogicalKeyboardKey.digit1: () => Navigator.pushNamed(context, '/login'),
        LogicalKeyboardKey.digit2: () => Navigator.pushNamed(context, '/register'),
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: UIUtils.paddingAll(context, 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Icon/Logo
                      Container(
                        width: 120 * s,
                        height: 120 * s,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.hearing_rounded,
                          size: UIUtils.iconSize(context, 64),
                          color: UIUtils.accentColor,
                        ),
                      ),
                      
                      SizedBox(height: UIUtils.spacing(context, 24)),
                      
                      // App Title
                      Text(
                        "SEEDS",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 42),
                          fontWeight: FontWeight.w800,
                          color: UIUtils.textColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                      
                      SizedBox(height: UIUtils.spacing(context, 12)),
                      
                      // Subtitle
                      Text(
                        "Connecting everyone, everywhere",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 16),
                          color: UIUtils.subtextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      SizedBox(height: UIUtils.spacing(context, 40)),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          icon: Icon(Icons.login, size: UIUtils.iconSize(context, 24)),
                          label: Text(
                            isKeypad ? "1. Login" : "Login",
                            style: TextStyle(fontSize: UIUtils.fontSize(context, 18), fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UIUtils.primaryColor,
                            foregroundColor: Colors.white,
                            padding: UIUtils.paddingSymmetric(context, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: UIUtils.spacing(context, 14)),
                      
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          icon: Icon(Icons.app_registration, size: UIUtils.iconSize(context, 24)),
                          label: Text(
                            isKeypad ? "2. Register" : "Register",
                            style: TextStyle(fontSize: UIUtils.fontSize(context, 18), fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: UIUtils.primaryColor,
                            side: const BorderSide(color: UIUtils.primaryColor, width: 1.5),
                            padding: UIUtils.paddingSymmetric(context, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: UIUtils.spacing(context, 20)),
                      
                      // Settings button
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/settings'),
                        icon: Icon(Icons.settings_outlined, color: UIUtils.subtextColor, size: UIUtils.iconSize(context, 20)),
                        label: Text(
                          'Settings',
                          style: TextStyle(
                            color: UIUtils.subtextColor,
                            fontSize: UIUtils.fontSize(context, 13),
                          ),
                        ),
                      ),
                      
                      // Hide features section on tiny screens to save space
                      if (!tiny) ...[
                        SizedBox(height: UIUtils.spacing(context, 16)),
                        Container(
                          padding: UIUtils.paddingAll(context, 16),
                          decoration: BoxDecoration(
                            color: UIUtils.backgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildFeature(context, Icons.mic_none_rounded, "Real-time Audio",
                                  "Crystal clear voice communication"),
                              const Divider(color: Colors.black12, height: 24),
                              _buildFeature(context, Icons.accessibility_new_rounded,
                                  "Fully Accessible", "TTS, large buttons & more"),
                              const Divider(color: Colors.black12, height: 24),
                              _buildFeature(context, Icons.groups_outlined,
                                  "Collaboration", "Raise hands and interact"),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String title, String description) {
    final bool tiny = UIUtils.isTiny(context);
    return Row(
      children: [
        Icon(icon, color: UIUtils.accentColor, size: UIUtils.iconSize(context, 28)),
        SizedBox(width: UIUtils.spacing(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: UIUtils.textColor,
                  fontSize: UIUtils.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!tiny) ...[
                SizedBox(height: UIUtils.spacing(context, 2)),
                Text(
                  description,
                  style: TextStyle(
                    color: UIUtils.subtextColor,
                    fontSize: UIUtils.fontSize(context, 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}


// Extension for context checking
extension ContextExtension on BuildContext? {
  void let(void Function(BuildContext) action) {
    if (this != null) action(this!);
  }
}