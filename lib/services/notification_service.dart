import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/customer.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return; // Skip on web

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> checkAndNotifyLatePayments(
      List<Customer> customers,
      bool notificationsEnabled,
      ) async {
    if (!notificationsEnabled || kIsWeb) return;

    final lateCustomers = customers.where((c) => c.isLatePayment).toList();
    if (lateCustomers.isEmpty) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'late_payments_channel',
      'Late Payment Alerts',
      channelDescription: 'Notifications for payments delayed more than 7 days',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Late Payment Reminder (${lateCustomers.length})',
      '${lateCustomers.first.name} and ${lateCustomers.length - 1} others have payments overdue by >7 days.',
      platformDetails,
    );
  }
}