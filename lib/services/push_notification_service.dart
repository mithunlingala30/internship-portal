import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../firebase_options.dart';
import 'local_notification_service.dart';
import 'firestore_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler — only runs on mobile (Android/iOS)
  // Ensure Firebase is initialized in the background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  if (message.notification != null) {
    await LocalNotificationService.showNotification(
      id: message.hashCode,
      title: message.notification!.title ?? 'New Notification',
      body: message.notification!.body ?? '',
      payload: 'fcm_payload',
    );
  }
}

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      // Request permissions (works on iOS, Android 13+, and web)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('FCM: User granted permission');
      }

      // Background handler is NOT supported on web
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      }

      // Get FCM token and save to Firestore
      // On web without a VAPID key this may return null — handle gracefully
      try {
        String? token = await _fcm.getToken();
        if (token != null) {
          _saveTokenToFirestore(token);
        }
      } catch (e) {
        print('FCM: Could not get token: $e');
      }

      // Listen for token refreshes
      _fcm.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          // On web, flutter_local_notifications is not supported —
          // LocalNotificationService.showNotification() already guards for kIsWeb
          LocalNotificationService.showNotification(
            id: message.hashCode,
            title: message.notification!.title ?? 'New Notification',
            body: message.notification!.body ?? '',
            payload: 'fcm_payload',
          );
        }
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('FCM: App opened from notification');
      });
    } catch (e) {
      // Never let FCM errors crash the app
      print('FCM: Initialization error (non-fatal): $e');
    }
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirestoreService().updateUserFcmToken(uid, token);
      }
    } catch (e) {
      print('FCM: Could not save token: $e');
    }
  }
}
