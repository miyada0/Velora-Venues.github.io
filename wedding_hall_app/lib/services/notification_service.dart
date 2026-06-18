import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';

/// ✅ FIX #7: Notification Service with Firebase Cloud Messaging
class NotificationService {
  final api = ApiService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Get local notifications from backend
  Future<List<dynamic>> getNotifications() async {
    final res = await api.dio.get("/notifications");
    return res.data;
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    await api.dio.put("/notifications/read/$id");
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> initializeFirebaseMessaging() async {
    try {
      print("📱 Initializing Firebase Cloud Messaging...");

      // Request notification permissions (iOS & Android 13+)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print("📋 Permission Status: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("✅ Notification permissions granted");
      } else {
        print("⚠️ Notification permissions not fully granted");
      }

      // Get FCM Token
      final token = await _firebaseMessaging.getToken();
      print("🔑 FCM Token: $token");

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("\n📬 Foreground Notification: ${message.notification?.title}");
      });

      // Handle background notifications
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print(
            "\n🔓 Background Notification Opened: ${message.notification?.title}");
      });

      print("✅ Firebase Cloud Messaging initialized");
    } catch (e) {
      print("❌ FCM Initialization Error: $e");
    }
  }
}
