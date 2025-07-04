import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static Future<void> show(int id, String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails('orders', 'Orders'),
    );
    await _notifications.show(id, title, body, details);
  }
}
