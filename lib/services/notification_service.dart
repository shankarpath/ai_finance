import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../utils/nav_bus.dart';

/// Local notifications for budget alerts, spend-moment alerts, the AI daily
/// digest, and the weekly report nudge. Everything is on-device; nothing is
/// sent anywhere. Tapping any coach-flavoured notification opens the Coach tab.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _coachPayload = 'coach';

  static const _alertsChannel = AndroidNotificationDetails(
    'alerts',
    'Spending alerts',
    channelDescription: 'Budget limits, large transactions and reminders',
    importance: Importance.high,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(''),
  );
  static const _summaryChannel = AndroidNotificationDetails(
    'daily_summary',
    'Coach digest',
    channelDescription: 'The coach\'s nightly recap and weekly report',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    styleInformation: BigTextStyleInformation(''),
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
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == _coachPayload) NavBus.openCoach();
      },
    );
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
      payload: _coachPayload,
    );
  }

  /// (Re)schedules the nightly digest notification at [hour] with the given
  /// body (AI-written when available).
  Future<void> scheduleDailySummary(String body, {int hour = 20}) async {
    if (!_ready) return;
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id: 900001,
      title: 'Tonight\'s money check-in',
      body: body,
      scheduledDate: when,
      notificationDetails: const NotificationDetails(android: _summaryChannel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _coachPayload,
    );
  }

  /// Weekly nudge every Sunday evening pointing at the report card.
  Future<void> scheduleWeeklyReportNudge({int hour = 18}) async {
    if (!_ready) return;
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    while (when.weekday != DateTime.sunday || !when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: 900002,
      title: 'Your weekly report card is ready',
      body: 'See your grade, wins and leaks for the week.',
      scheduledDate: when,
      notificationDetails: const NotificationDetails(android: _summaryChannel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: _coachPayload,
    );
  }
}
