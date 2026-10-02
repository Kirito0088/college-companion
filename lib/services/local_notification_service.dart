/// Local Notification Service (#10)
///
/// The OS side of reminders, over flutter_local_notifications: Android
/// notification channels, the Android 13+ runtime permission, and one-shot
/// scheduling at absolute instants.
///
/// Reminders are scheduled in UTC from instants the planner computed in
/// local time, so no time zone database or device zone name is needed and
/// DST cannot shift a reminder.
library;

import 'dart:async';
import 'dart:convert';

import 'package:college_companion/features/notifications/models/reminder_planner.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// A reminder the student tapped: where to go and which row to mark read.
typedef ReminderTap = ({String route, String id});

/// Schedules and shows reminders through the OS.
class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Set once the student has been asked for notification permission, so
  /// a "no" is respected rather than re-asked on every launch.
  static const String permissionRequestedKey =
      'notification_permission_requested';

  /// Monochrome status-bar icon (`res/drawable/ic_stat_notification.xml`).
  static const String _icon = 'ic_stat_notification';

  static const Map<ReminderChannel, AndroidNotificationChannel> _channels = {
    ReminderChannel.lectures: AndroidNotificationChannel(
      'lecture_reminders',
      'Lecture reminders',
      description: 'A heads-up 10 minutes before each class.',
      importance: Importance.high,
    ),
    ReminderChannel.assignments: AndroidNotificationChannel(
      'assignment_reminders',
      'Assignment reminders',
      description: 'A day and two hours before each deadline.',
    ),
    ReminderChannel.briefing: AndroidNotificationChannel(
      'daily_briefing',
      'Morning briefing',
      description: 'A quiet 8 AM summary of your day.',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    ),
  };

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<ReminderTap> _taps =
      StreamController<ReminderTap>.broadcast();
  Future<bool>? _ready;
  AndroidScheduleMode? _scheduleMode;

  /// Reminders the student tapped while the app was running.
  Stream<ReminderTap> get taps => _taps.stream;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Initialises the plugin and channels once. False where reminders are
  /// unsupported: the app targets Android only.
  Future<bool> _initialize() => _ready ??= () async {
    final android = _android;
    if (android == null) return false;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
      ),
      onDidReceiveNotificationResponse: (response) {
        final tap = _decode(response.payload);
        if (tap != null) _taps.add(tap);
      },
    );
    for (final channel in _channels.values) {
      await android.createNotificationChannel(channel);
    }
    return true;
  }();

  /// The reminder that launched the app from a cold start, if any.
  Future<ReminderTap?> launchTap() async {
    if (!await _initialize()) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return _decode(details.notificationResponse?.payload);
  }

  /// Whether reminders can be shown. Asks for the Android 13+ permission
  /// the first time only, so a "no" is respected.
  Future<bool> canNotify() async {
    if (!await _initialize()) return false;
    final android = _android!;
    if (await android.areNotificationsEnabled() ?? false) return true;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(permissionRequestedKey) ?? false) return false;
    await prefs.setBool(permissionRequestedKey, true);
    return await android.requestNotificationsPermission() ?? false;
  }

  /// Ids of reminders the OS still has scheduled.
  Future<Set<int>> pendingIds() async {
    if (!await _initialize()) return <int>{};
    final pending = await _plugin.pendingNotificationRequests();
    return {for (final request in pending) request.id};
  }

  /// Schedules [reminder], replacing any pending one with the same id.
  Future<void> schedule(PlannedReminder reminder) async {
    if (!await _initialize()) return;
    final channel = _channels[reminder.channel]!;
    await _plugin.zonedSchedule(
      reminder.notificationId,
      reminder.title,
      reminder.body,
      tz.TZDateTime.from(reminder.fireAt.toUtc(), tz.UTC),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: channel.importance == Importance.high
              ? Priority.high
              : Priority.defaultPriority,
          icon: _icon,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
      androidScheduleMode: await _resolveScheduleMode(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({'route': reminder.targetRoute, 'id': reminder.key}),
    );
  }

  /// Exact while idle when the student has allowed exact alarms (granted by
  /// default before Android 14), otherwise inexact. Inexact may run a few
  /// minutes late, which is acceptable for a 10-minute heads-up and better
  /// than nagging for a special permission.
  Future<AndroidScheduleMode> _resolveScheduleMode() async {
    if (_scheduleMode case final mode?) return mode;
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    return _scheduleMode = exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Cancels the pending reminder with [id], if any.
  Future<void> cancel(int id) async {
    if (!await _initialize()) return;
    await _plugin.cancel(id);
  }

  /// Cancels every pending reminder.
  Future<void> cancelAll() async {
    if (!await _initialize()) return;
    await _plugin.cancelAll();
  }

  static ReminderTap? _decode(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final route = map['route'];
      final id = map['id'];
      if (route is! String || id is! String) return null;
      return (route: route, id: id);
    } on FormatException {
      return null;
    }
  }
}
