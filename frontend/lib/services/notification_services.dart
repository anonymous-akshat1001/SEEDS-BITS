import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
// Required to initialize Firebase
import 'package:firebase_core/firebase_core.dart';
// Firebase Cloud Messaging (FCM)
import 'package:firebase_messaging/firebase_messaging.dart';
// Shows local notifications on device
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';
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
  // creates one single instance
  static final NotificationService _instance = NotificationService._internal();
  // factory constructor which returns the same instance
  factory NotificationService() => _instance;
  // private constructor which prevents external initialization
  NotificationService._internal();

  // Plugin for showing local notifications
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
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

  /// Initialize notification service
  Future<void> initialize() async {
    
    // prevents duplicate setup
    if (_initialized){
      return;
    }
    
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // platform specific setup
      if (kIsWeb) {
        await _initializeWeb();
      } else {
        await _initializeMobile();
      }
      
      _initialized = true;
      print('[NOTIFICATIONS] Initialized successfully');
    } 
    catch (e) {
      print('[NOTIFICATIONS] Initialization error: $e');
    }
  }

  /// Initialize for mobile platforms
  Future<void> _initializeMobile() async {
    // get FCM instance
    _messaging = FirebaseMessaging.instance;

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
      print('[NOTIFICATIONS] FCM Token: $token');
      
      if (token != null) {
        // Send token to backend
        await _registerTokenWithBackend(token, 'mobile');
      }
      
      // Listen for token refresh
      _messaging!.onTokenRefresh.listen((newToken) {
        print('[NOTIFICATIONS] Token refreshed: $newToken');
        _registerTokenWithBackend(newToken, 'mobile');
      });
      
      // Configure local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
          print('[NOTIFICATIONS] Web FCM Token: $token');
          await _registerTokenWithBackend(token, 'web');
        }
        
        // Listen for token refresh and register token with backend
        _messaging!.onTokenRefresh.listen((newToken) {
          print('[NOTIFICATIONS] Web token refreshed: $newToken');
          _registerTokenWithBackend(newToken, 'web');
        });
        
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessageWeb);
        
        // Handle notification tap
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      } 
      else {
        print('[NOTIFICATIONS] Web notification permission denied');
      }
    } 
    catch (e) {
      print('[NOTIFICATIONS] Web init error: $e');
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend(String token, String deviceType) async {
    try {
      // open local storage
      final prefs = await SharedPreferences.getInstance();
      
      // Save token locally first
      await prefs.setString('fcm_token', token);
      print('[FCM] Token saved locally: ${token.substring(0, 20)}...');
      
      // Check if user is logged in
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        print('[FCM] User not logged in yet - will register token after login');
        return; // Skip registration for now
      }
      
      // Send to backend
      try {
        final result = await ApiService.post(
          '/users/fcm-token',
          {'token': token, 'device_type': deviceType},
          useAuth: true,
        );
        
        if (result != null && result['ok'] == true) {
          print('[FCM] Token registered with backend successfully');
        } else {
          print('[FCM] Token registration returned: $result');
        }
      } 
      catch (e) {
        print('[FCM] Error registering token with backend: $e');
        // Don't throw - token is saved locally, will retry after login
      }
    } catch (e) {
      print('[FCM] Error in token registration: $e');
    }
  }

  // Handle foreground message on mobile - called when app is open
  void _handleForegroundMessage(RemoteMessage message) {
    print('[NOTIFICATIONS] Foreground message: ${message.notification?.title}');
    
    // Show local notification manually - firebase doesn't auto show in foreground
    _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data,
    );
    
    // Emits event to stream(app listeners)
    _notificationController.add(message.data);
  }

  /// Handle foreground message on web
  void _handleForegroundMessageWeb(RemoteMessage message) {
    print('[NOTIFICATIONS] Web foreground message: ${message.notification?.title}');
    
    // Show browser notification (if supported)
    // Note: Browser notifications might not work in foreground depending on browser
    
    // Emit to stream
    _notificationController.add(message.data);
  }

  // Show local notification (mobile only)
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
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
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload != null ? _encodePayload(payload) : null,
    );
  }


  // Handle notification tap from system tray
  void _handleNotificationTap(RemoteMessage message) {
    print('[NOTIFICATIONS] Notification tapped: ${message.data}');
    
    if (onNotificationTap != null) {
      // delegates to UI callback
      onNotificationTap!(message.data);
    }
    
    // emits event
    _notificationController.add(message.data);
  }


  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // convert string to map(payload)
      final data = _decodePayload(response.payload!);
      
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
        await ApiService.delete('/users/fcm-token?token=$token', useAuth: true);
        
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