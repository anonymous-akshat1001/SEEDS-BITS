import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
// Required to initialize Firebase
import 'package:firebase_core/firebase_core.dart';
// Firebase Cloud Messaging (FCM)
import 'package:firebase_messaging/firebase_messaging.dart';
// Shows local notifications on device
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';
import './tts_service.dart';
import '../firebase_options.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Firebase configuration class
class FirebaseConfig {
  // Replace with YOUR actual VAPID key
  static final String webVapidKey = dotenv.env['WEB_VAPID_KEY']!;
}

// Top-level handler for background messages
// Tells Dart VM that this function may be called even when app is killed and is required for background notifs on Andriod
@pragma('vm:entry-point')
// Called when notification arrives in background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase must be initialized again in background isolate
  await Firebase.initializeApp(
    // uses correct platform config
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('[FCM BG] Handling background message: ${message.messageId}');

  // You can process the message here if needed
  // For now, we'll just log it
}

// Singletion class of notification services
class NotificationService {
  static const privateTitle = 'SEEDS update';
  static const privateBody = 'Open SEEDS to review your updates.';
  static Map<String, dynamic> privatePayload(Map<String, dynamic> data) => {
    for (final key in [
      'type',
      'session_id',
      'quiz_id',
      'class_id',
      'subject_id',
    ])
      if (data.containsKey(key)) key: data[key],
  };
  // creates one single instance
  static final NotificationService _instance = NotificationService._internal();
  // factory constructor which returns the same instance
  factory NotificationService() => _instance;
  // private constructor which prevents external initialization
  NotificationService._internal();

  // Plugin for showing local notifications
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Firebase messaging instance - nullable becuase initialized later
  FirebaseMessaging? _messaging;
  // variable to prevent multiple initializations
  bool _initialized = false;

  // Callback for when notification is tapped
  Function(Map<String, dynamic>)? onNotificationTap;

  // Stream for real-time notifications - creates boradcast stream where multiple listeners allowed
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Public getter
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  /// Checks authorization without triggering an operating-system prompt.
  Future<bool> hasNotificationPermission() async {
    _messaging ??= FirebaseMessaging.instance;
    final settings = await _messaging!.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Initialize notification service
  Future<void> initialize() async {
    // prevents duplicate setup
    if (_initialized) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // platform specific setup
      if (kIsWeb) {
        await _initializeWeb();
      } else {
        await _initializeMobile();
      }

      _initialized = true;
      print('[NOTIFICATIONS] Initialized successfully');
    } catch (e) {
      print('[NOTIFICATIONS] Initialization error: $e');
    }
  }

  /// Initialize for mobile platforms
  Future<void> _initializeMobile() async {
    // get FCM instance
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notif permission
    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // user allowed notifs
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('[NOTIFICATIONS] User granted permission');

      // Get FCM token - unique device token, used by backend to send notfs
      String? token = await _messaging!.getToken();

      if (token != null) {
        // Send token to backend
        await _registerTokenWithBackend(token);
      }

      // Listen for token refresh
      _messaging!.onTokenRefresh.listen((newToken) {
        debugPrint('[NOTIFICATIONS] Push token refreshed');
        _registerTokenWithBackend(newToken);
      });

      // Configure local notifications
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initializes local notification system and registers tap handler
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Handle foreground messages when app open
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app was terminated
      _messaging!.getInitialMessage().then((message) {
        if (message != null) {
          _handleNotificationTap(message);
        }
      });
    } else {
      print('[NOTIFICATIONS] Permission denied');
    }
  }

  /// Initialize for web platform
  Future<void> _initializeWeb() async {
    try {
      _messaging = FirebaseMessaging.instance;

      // Request permission for web
      NotificationSettings settings = await _messaging!.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('[NOTIFICATIONS] Web notification permission granted');

        // Get web FCM token with VAPID key
        // You need to get this from Firebase Console -> Project Settings -> Cloud Messaging
        String? token = await _messaging!.getToken(
          vapidKey: FirebaseConfig.webVapidKey,
        );

        // Backend distinguishes device type
        if (token != null) {
          await _registerTokenWithBackend(token);
        }

        // Listen for token refresh and register token with backend
        _messaging!.onTokenRefresh.listen((newToken) {
          debugPrint('[NOTIFICATIONS] Web push token refreshed');
          _registerTokenWithBackend(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessageWeb);

        // Handle notification tap
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      } else {
        print('[NOTIFICATIONS] Web notification permission denied');
      }
    } catch (e) {
      print('[NOTIFICATIONS] Web init error: $e');
    }
  }

  /// Register FCM token with backend
  Future<void> registerSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('token');
      final token = prefs.getString('fcm_token');
      if (sessionToken == null ||
          token == null ||
          prefs.getBool('must_change_password') == true) {
        debugPrint(
          '[FCM] Registration deferred until a normal signed-in session and push token exist',
        );
        return;
      }
      final result = await ApiService.postAcknowledged(
        '/users/fcm-token',
        {'token': token, 'device_type': kIsWeb ? 'web' : 'mobile'},
        canSend: () =>
            prefs.getString('token') == sessionToken &&
            prefs.getString('fcm_token') == token &&
            prefs.getBool('must_change_password') != true,
      );
      if (!result.isSuccess) {
        await _registrationUnavailable();
      }
    } on PlatformException {
      await _registrationUnavailable();
    } on MissingPluginException {
      await _registrationUnavailable();
    }
  }

  Future<void> _registrationUnavailable() async {
    debugPrint('[FCM] Account notification registration unavailable');
    await TtsService.speak(
      'Notifications could not be registered. Refresh SEEDS to check class invitations.',
      priority: SpeechPriority.incidental,
      group:
          'Notifications could not be registered. Refresh SEEDS to check class invitations',
    );
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      // open local storage
      final prefs = await SharedPreferences.getInstance();

      // Save token locally first
      if (!await prefs.setString('fcm_token', token)) {
        await _registrationUnavailable();
        return;
      }
      await registerSavedToken();
    } on PlatformException {
      await _registrationUnavailable();
    } on MissingPluginException {
      await _registrationUnavailable();
    }
  }

  // Handle foreground message on mobile - called when app is open
  void _handleForegroundMessage(RemoteMessage message) {
    print('[NOTIFICATIONS] Foreground update received');

    // Show local notification manually - firebase doesn't auto show in foreground
    unawaited(showPrivateUpdate(message.data));

    // Emits event to stream(app listeners)
    _notificationController.add(privatePayload(message.data));
  }

  /// Handle foreground message on web
  void _handleForegroundMessageWeb(RemoteMessage message) {
    print('[NOTIFICATIONS] Web foreground update received');

    // Show browser notification (if supported)
    // Note: Browser notifications might not work in foreground depending on browser

    // Emit to stream
    _notificationController.add(privatePayload(message.data));
  }

  // Show local notification (mobile only)
  Future<bool> showPrivateUpdate(Map<String, dynamic> payload) async {
    // notification channel configuration
    const androidDetails = AndroidNotificationDetails(
      'session_channel',
      'Session Notifications',
      channelDescription: 'Notifications for session invitations and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.private,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // displays notification
    try {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        privateTitle,
        privateBody,
        details,
        payload: _encodePayload(privatePayload(payload)),
      );
      return true;
    } on PlatformException catch (error) {
      return _displayFailure(error);
    } on MissingPluginException catch (error) {
      return _displayFailure(error);
    }
  }

  Future<bool> _displayFailure(Object error) async {
    print(
      '[NOTIFICATIONS] Private update display failed (${error.runtimeType})',
    );
    await TtsService.speak(
      'An update arrived, but the phone notification could not be displayed. Open SEEDS to check updates.',
      priority: SpeechPriority.incidental,
      group: 'notification-display-failure',
    );
    return false;
  }

  // Handle notification tap from system tray
  void _handleNotificationTap(RemoteMessage message) {
    print('[NOTIFICATIONS] Update opened');

    if (onNotificationTap != null) {
      // delegates to UI callback
      onNotificationTap!(privatePayload(message.data));
    }

    // emits event
    _notificationController.add(privatePayload(message.data));
  }

  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // convert string to map(payload)
      final data = privatePayload(_decodePayload(response.payload!));

      if (onNotificationTap != null) {
        onNotificationTap!(data);
      }

      _notificationController.add(data);
    }
  }

  /// Encode payload(map) to string
  String _encodePayload(Map<String, dynamic> payload) {
    return payload.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  /// Decode payload from string
  Map<String, dynamic> _decodePayload(String payload) {
    final map = <String, dynamic>{};
    for (var pair in payload.split('&')) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }

  /// Get FCM token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Remove token from backend (call on logout)
  Future<void> removeToken() async {
    try {
      final token = await getToken();
      if (token != null) {
        final result = await ApiService.deleteResult(
          '/users/fcm-token',
          useAuth: true,
          context: 'notification token removal',
          data: {'token': token},
        );
        if (!result.isSuccess && kDebugMode) {
          print(
            '[FCM] Backend token removal will be cleaned up after token invalidation',
          );
        }
        await (_messaging ?? FirebaseMessaging.instance).deleteToken();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('fcm_token');
      }
    } catch (e) {
      print('[FCM] Error removing token: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationController.close();
  }
}
