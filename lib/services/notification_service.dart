import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications for budget alerts, large transactions, and the daily
/// spending summary. Everything is on-device; nothing is sent anywhere.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _alertsChannel = AndroidNotificationDetails(
    'alerts',
    'Spending alerts',
    channelDescription: 'Budget limits, large transactions and reminders',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _summaryChannel = AndroidNotificationDetails(
    'daily_summary',
    'Daily summary',
    channelDescription: 'A nightly recap of the day\'s spending',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      // The user is in IST; fall back to UTC if the zone is unavailable.
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
        settings: const InitializationSettings(android: android));
    _ready = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> showAlert(int id, String title, String body) async {
    if (!_ready) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: _alertsChannel),
    );
  }

  /// (Re)schedules a daily summary notification at [hour] with the given body.
  Future<void> scheduleDailySummary(String body, {int hour = 20}) async {
    if (!_ready) return;
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id: 900001,
      title: 'Today\'s spending',
      body: body,
      scheduledDate: when,
      notificationDetails: const NotificationDetails(android: _summaryChannel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
