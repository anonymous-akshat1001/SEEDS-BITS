import 'dart:async';

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
import 'widgets/keypad_confirmation_dialog.dart';
import 'utils/keypad_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Global navigation key for handling deep links
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SeedsStartup());
}

class SeedsStartup extends StatefulWidget {
  const SeedsStartup({super.key});

  @override
  State<SeedsStartup> createState() => _SeedsStartupState();
}

class _SeedsStartupState extends State<SeedsStartup> {
  bool _ready = false;
  String? _startupError;
  String _initialRoute = '/welcome';

  @override
  void initState() {
    super.initState();
    _initializeEssentialServices();
  }

  Future<void> _initializeEssentialServices() async {
    try {
      await dotenv.load(fileName: 'assets/.env');
      debugPrint('[MAIN] Loaded assets/.env');
    } catch (e) {
      debugPrint('[MAIN] Failed to load assets/.env: $e');
      try {
        await dotenv.load(fileName: '.env');
        debugPrint('[MAIN] Loaded .env');
      } catch (e2) {
        debugPrint('[MAIN] Failed to load .env: $e2');
        dotenv.testLoad(
          fileInput: '''
API_BASE_URL=http://responsible-tech.bits-hyderabad.ac.in/seeds
WS_BASE_URL=ws://responsible-tech.bits-hyderabad.ac.in/seeds
WEB_VAPID_KEY=BOYVjb77moWEwSyBY-HxCkiAFBuNrCncK9oSobRL1TubgfGicL1JOiw_B0Nod74jEbsn-xd5URPyRwj0BNzc7LE
      ''',
        );
        debugPrint('[MAIN] Using hardcoded fallback env values');
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      UIUtils.setHighContrastMode(prefs.getBool('high_contrast_mode') ?? false);
      UIUtils.setTextScale(prefs.getDouble('text_scale') ?? 1.0);
      await TtsService.loadFromPreferences();
      final token = prefs.getString('token');
      final role = prefs.getString('role');
      if (token != null && token.isNotEmpty && role == 'teacher') {
        _initialRoute = '/teacher_dashboard';
      } else if (token != null && token.isNotEmpty && role == 'student') {
        _initialRoute = '/student_dashboard';
      }
    } catch (error) {
      debugPrint('[MAIN] Essential preference initialization failed: $error');
      _startupError =
          'Some preferences could not be loaded. Defaults are being used.';
    }

    if (!mounted) return;
    setState(() => _ready = true);

    // Firebase and permission prompts are non-critical and must not hold the
    // first usable Flutter frame on low-spec devices.
    unawaited(
      Future<void>.delayed(
        const Duration(milliseconds: 500),
        _initializeNotifications,
      ),
    );
  }

  Future<void> _initializeNotifications() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final notificationService = NotificationService();
      if (!await notificationService.hasNotificationPermission()) {
        if (!mounted) return;
        final context = navigatorKey.currentContext;
        if (context == null || !context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const KeypadConfirmationDialog(
            title: 'Session notifications',
            message:
                'SEEDS uses notifications to tell you about session invitations and updates. You can continue using the app if you choose Not now.',
            confirmLabel: 'Enable notifications',
          ),
        );
        if (confirmed != true) return;
      }
      await notificationService.initialize();
      notificationService.onNotificationTap = _handleNotificationTap;
      notificationService.notificationStream.listen(
        (data) => debugPrint('[MAIN] Notification received in-app: $data'),
      );
    } catch (error) {
      debugPrint('[MAIN] Deferred notification initialization failed: $error');
    }
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> data) async {
    if (data['type'] != 'session_invitation') return;
    final sessionId = int.tryParse(data['session_id']?.toString() ?? '');
    if (sessionId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final userName = prefs.getString('user_name') ?? prefs.getString('name');
    if (userId == null || userName == null) return;
    navigatorKey.currentState?.pushNamed(
      '/session',
      arguments: {
        'sessionId': sessionId,
        'userId': userId,
        'userName': userName,
        'isTeacher': false,
        'sessionTitle': data['session_title'] ?? 'Session',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return MyApp(initialRoute: _initialRoute);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SeedsLoadingScreen(message: _startupError),
    );
  }
}

class SeedsLoadingScreen extends StatefulWidget {
  const SeedsLoadingScreen({super.key, this.message});

  final String? message;

  @override
  State<SeedsLoadingScreen> createState() => _SeedsLoadingScreenState();
}

class _SeedsLoadingScreenState extends State<SeedsLoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TtsService.speak('SEEDS is loading');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B3D62),
      body: Semantics(
        liveRegion: true,
        label: 'SEEDS is loading',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hearing_rounded, color: Colors.white, size: 72),
              const SizedBox(height: 16),
              const Text(
                'SEEDS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 18),
              const CircularProgressIndicator(color: Color(0xFFFFD600)),
              const SizedBox(height: 12),
              Text(
                widget.message ?? 'Loading accessible learning tools…',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Global route observer — allows widgets (like KeypadInstructionWrapper)
/// to detect when they become visible again after a pushed route is popped.
class SeedsRouteObserver extends RouteObserver<ModalRoute<void>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    unawaited(TtsService.stop());
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    unawaited(TtsService.stop());
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    unawaited(TtsService.stop());
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

final RouteObserver<ModalRoute<void>> routeObserver = SeedsRouteObserver();

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialRoute = '/welcome'});

  final String initialRoute;

  ThemeData _buildTheme(bool highContrast) {
    final brightness = highContrast ? Brightness.dark : Brightness.light;
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: UIUtils.accentColor,
        brightness: brightness,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: UIUtils.backgroundColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      focusColor: highContrast
          ? const Color(0xFFFFD600)
          : const Color(0xFF005BBB).withValues(alpha: 0.22),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: UIUtils.backgroundColor,
        foregroundColor: UIUtils.textColor,
      ),
      cardTheme: CardThemeData(
        elevation: highContrast ? 0 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: UIUtils.cardColor,
      ),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
        bodyColor: UIUtils.textColor,
        displayColor: UIUtils.textColor,
      ),
      listTileTheme: ListTileThemeData(
        textColor: UIUtils.textColor,
        iconColor: UIUtils.textColor,
      ),
      dialogTheme: DialogThemeData(backgroundColor: UIUtils.cardColor),
      dividerColor: highContrast ? UIUtils.accentColor : Colors.black12,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: highContrast ? const Color(0xFF111111) : Colors.white,
        labelStyle: TextStyle(color: UIUtils.subtextColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: highContrast ? UIUtils.accentColor : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: UIUtils.accentColor, width: 2),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return BorderSide(color: UIUtils.accentColor, width: 3);
            }
            return BorderSide.none;
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: UIUtils.highContrastListenable,
      builder: (context, highContrast, _) {
        return ValueListenableBuilder<double>(
          valueListenable: UIUtils.textScaleListenable,
          builder: (context, appTextScale, _) => MaterialApp(
            title: 'SEEDS',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            navigatorObservers: [routeObserver],
            theme: _buildTheme(highContrast),
            builder: (context, child) {
              if (child == null) return const SizedBox.shrink();
              if (appTextScale == 1.0) return child;
              final mediaQuery = MediaQuery.of(context);
              final systemScale = mediaQuery.textScaler.scale(1.0);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(
                    (systemScale * appTextScale).clamp(0.8, 2.0),
                  ),
                ),
                child: child,
              );
            },

            // Start with a welcome screen (choice between login/register)
            initialRoute: initialRoute,

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
                  final sessionTitle = args['sessionTitle'] ?? 'Session';

                  if (sessionId is int && userId is int && userName is String) {
                    return MaterialPageRoute(
                      builder: (_) => SessionScreen(
                        sessionId: sessionId,
                        userId: userId,
                        userName: userName,
                        isTeacher: isTeacher,
                        sessionTitle: sessionTitle,
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
                return MaterialPageRoute(
                  builder: (_) => const TeacherDashboard(),
                );
              }

              // Offline audio library route
              if (settings.name == '/offline_audio_library') {
                return MaterialPageRoute(
                  builder: (_) => const AudioLibraryScreen(),
                  settings: settings,
                );
              }

              return null;
            },
          ),
        );
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
  final FocusNode _brandFocusNode = FocusNode(debugLabel: 'welcome-brand');
  final FocusNode _subtitleFocusNode = FocusNode(
    debugLabel: 'welcome-subtitle',
  );
  final FocusNode _loginFocusNode = FocusNode(debugLabel: 'welcome-login');
  final FocusNode _registerFocusNode = FocusNode(
    debugLabel: 'welcome-register',
  );
  final FocusNode _settingsFocusNode = FocusNode(
    debugLabel: 'welcome-settings',
  );
  final FocusNode _repeatFocusNode = FocusNode(
    debugLabel: 'welcome-repeat-instructions',
  );
  final FocusNode _audioFeatureFocusNode = FocusNode(
    debugLabel: 'welcome-feature-audio',
  );
  final FocusNode _accessibilityFeatureFocusNode = FocusNode(
    debugLabel: 'welcome-feature-accessibility',
  );
  final FocusNode _collaborationFeatureFocusNode = FocusNode(
    debugLabel: 'welcome-feature-collaboration',
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _brandFocusNode.dispose();
    _subtitleFocusNode.dispose();
    _loginFocusNode.dispose();
    _registerFocusNode.dispose();
    _settingsFocusNode.dispose();
    _repeatFocusNode.dispose();
    _audioFeatureFocusNode.dispose();
    _accessibilityFeatureFocusNode.dispose();
    _collaborationFeatureFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);
    final bool isKeypad = UIUtils.isKeypad(context);
    final s = UIUtils.scale(context);

    return KeypadInstructionWrapper(
      screenName: 'Welcome to SEEDS',
      labels: welcomeKeyLabels,
      actions: {
        1: () => Navigator.pushNamed(context, '/login'),
        2: () => Navigator.pushNamed(context, '/register'),
        3: () => Navigator.pushNamed(context, '/settings'),
      },
      focusTargets: [
        KeypadFocusTarget(
          node: _brandFocusNode,
          label: 'SEEDS. Accessible learning.',
          onActivate: () => TtsService.speak('SEEDS. Accessible learning.'),
        ),
        KeypadFocusTarget(
          node: _subtitleFocusNode,
          label: 'Connecting everyone, everywhere',
          onActivate: () => TtsService.speak('Connecting everyone, everywhere'),
        ),
        if (!tiny) ...[
          KeypadFocusTarget(
            node: _audioFeatureFocusNode,
            label: 'Real-time Audio. Crystal clear voice communication.',
            onActivate: () => TtsService.speak(
              'Real-time Audio. Crystal clear voice communication.',
            ),
          ),
          KeypadFocusTarget(
            node: _accessibilityFeatureFocusNode,
            label: 'Fully Accessible. Text to speech, large buttons and more.',
            onActivate: () => TtsService.speak(
              'Fully Accessible. Text to speech, large buttons and more.',
            ),
          ),
          KeypadFocusTarget(
            node: _collaborationFeatureFocusNode,
            label: 'Collaboration. Raise hands and interact.',
            onActivate: () =>
                TtsService.speak('Collaboration. Raise hands and interact.'),
          ),
        ],
        KeypadFocusTarget(
          node: _loginFocusNode,
          label: 'Login button',
          onActivate: () => Navigator.pushNamed(context, '/login'),
        ),
        KeypadFocusTarget(
          node: _registerFocusNode,
          label: 'Register button',
          onActivate: () => Navigator.pushNamed(context, '/register'),
        ),
        KeypadFocusTarget(
          node: _settingsFocusNode,
          label: 'Settings button',
          onActivate: () => Navigator.pushNamed(context, '/settings'),
        ),
        KeypadFocusTarget(
          node: _repeatFocusNode,
          label: 'Repeat instructions',
          onActivate: _repeatWelcomeInstructions,
        ),
      ],
      child: Scaffold(
        backgroundColor: UIUtils.backgroundColor,
        body: Container(
          color: UIUtils.backgroundColor,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: UIUtils.paddingAll(context, 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Icon/Logo
                      Semantics(
                        label: 'SEEDS. Accessible learning.',
                        button: true,
                        child: Focus(
                          focusNode: _brandFocusNode,
                          child: GestureDetector(
                            onTap: () =>
                                TtsService.speak('SEEDS. Accessible learning.'),
                            child: Container(
                              width: 120 * s,
                              height: 120 * s,
                              decoration: BoxDecoration(
                                color: UIUtils.cardColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: UIUtils.accentColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.hearing_rounded,
                                semanticLabel: 'SEEDS accessible learning logo',
                                size: UIUtils.iconSize(context, 64),
                                color: UIUtils.accentColor,
                              ),
                            ),
                          ),
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
                      Semantics(
                        label: 'Connecting everyone, everywhere',
                        button: true,
                        child: Focus(
                          focusNode: _subtitleFocusNode,
                          child: GestureDetector(
                            onTap: () => TtsService.speak(
                              'Connecting everyone, everywhere',
                            ),
                            child: Text(
                              'Connecting everyone, everywhere',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 16),
                                color: UIUtils.subtextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: UIUtils.spacing(context, 40)),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          focusNode: _loginFocusNode,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          icon: Icon(
                            Icons.login,
                            size: UIUtils.iconSize(context, 24),
                          ),
                          label: Text(
                            isKeypad ? "1. Login" : "Login",
                            style: TextStyle(
                              fontSize: UIUtils.fontSize(context, 18),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UIUtils.primaryColor,
                            foregroundColor: Colors.white,
                            padding: UIUtils.paddingSymmetric(
                              context,
                              vertical: 16,
                            ),
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
                          focusNode: _registerFocusNode,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          icon: Icon(
                            Icons.app_registration,
                            size: UIUtils.iconSize(context, 24),
                          ),
                          label: Text(
                            isKeypad ? "2. Register" : "Register",
                            style: TextStyle(
                              fontSize: UIUtils.fontSize(context, 18),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: UIUtils.primaryColor,
                            side: BorderSide(
                              color: UIUtils.primaryColor,
                              width: 1.5,
                            ),
                            padding: UIUtils.paddingSymmetric(
                              context,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: UIUtils.spacing(context, 20)),

                      // Settings button
                      TextButton.icon(
                        focusNode: _settingsFocusNode,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                        icon: Icon(
                          Icons.settings_outlined,
                          color: UIUtils.subtextColor,
                          size: UIUtils.iconSize(context, 20),
                        ),
                        label: Text(
                          isKeypad ? '3. Settings' : 'Settings',
                          style: TextStyle(
                            color: UIUtils.subtextColor,
                            fontSize: UIUtils.fontSize(context, 13),
                          ),
                        ),
                      ),

                      TextButton.icon(
                        focusNode: _repeatFocusNode,
                        onPressed: _repeatWelcomeInstructions,
                        icon: Icon(
                          Icons.replay_rounded,
                          color: UIUtils.subtextColor,
                          size: UIUtils.iconSize(context, 20),
                        ),
                        label: Text(
                          'Repeat instructions',
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
                              _buildFeature(
                                context,
                                _audioFeatureFocusNode,
                                Icons.mic_none_rounded,
                                "Real-time Audio",
                                "Crystal clear voice communication",
                              ),
                              const Divider(color: Colors.black12, height: 24),
                              _buildFeature(
                                context,
                                _accessibilityFeatureFocusNode,
                                Icons.accessibility_new_rounded,
                                "Fully Accessible",
                                "TTS, large buttons & more",
                              ),
                              const Divider(color: Colors.black12, height: 24),
                              _buildFeature(
                                context,
                                _collaborationFeatureFocusNode,
                                Icons.groups_outlined,
                                "Collaboration",
                                "Raise hands and interact",
                              ),
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

  Widget _buildFeature(
    BuildContext context,
    FocusNode focusNode,
    IconData icon,
    String title,
    String description,
  ) {
    final bool tiny = UIUtils.isTiny(context);
    return Semantics(
      button: true,
      label: '$title. $description',
      child: InkWell(
        focusNode: focusNode,
        onTap: () => TtsService.speak('$title. $description'),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(
              icon,
              color: UIUtils.accentColor,
              size: UIUtils.iconSize(context, 28),
            ),
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
        ),
      ),
    );
  }

  void _repeatWelcomeInstructions() {
    TtsService.speak(
      '${buildTtsInstructions(welcomeKeyLabels, screenName: 'Welcome to SEEDS')} '
      'Use the direction keys to move and OK to select.',
    );
  }
}

// Extension for context checking
extension ContextExtension on BuildContext? {
  void let(void Function(BuildContext) action) {
    if (this != null) action(this!);
  }
}
