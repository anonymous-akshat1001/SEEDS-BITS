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
import 'services/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Global navigation key for handling deep links
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with auto-generated config
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Load environment variables
  await dotenv.load(fileName: ".env");
  
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
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
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

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade600,
              Colors.indigo.shade400,
              Colors.teal.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon/Logo
                    Container(
                      width: 120,
                      height: 120,
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
                      child: const Icon(
                        Icons.hearing,
                        size: 64,
                        color: Colors.indigo,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // App Title
                    const Text(
                      "Accessible Conference",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    Text(
                      "Audio sessions designed for everyone",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        icon: const Icon(Icons.login, size: 24),
                        label: const Text(
                          "Login",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        icon: const Icon(Icons.app_registration, size: 24),
                        label: const Text(
                          "Register",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Settings button
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                      icon: const Icon(Icons.settings, color: Colors.white70),
                      label: Text(
                        'Settings & Accessibility',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Features
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildFeature(
                            Icons.mic,
                            "Real-time Audio",
                            "Crystal clear voice communication",
                          ),
                          const Divider(color: Colors.white30, height: 24),
                          _buildFeature(
                            Icons.accessibility_new,
                            "Fully Accessible",
                            "TTS, large buttons & more",
                          ),
                          const Divider(color: Colors.white30, height: 24),
                          _buildFeature(
                            Icons.groups,
                            "Interactive Sessions",
                            "Raise hands, chat, and collaborate",
                          ),
                        ],
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

  Widget _buildFeature(IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
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