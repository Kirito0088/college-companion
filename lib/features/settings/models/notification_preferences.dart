/// Notification Preferences (#11)
///
/// The student's notification switches as stored in `user_settings`: the
/// master switch and lecture reminders are columns; the per-channel
/// switches added later live in the `preferences` JSON, like the accent, so
/// no schema migration was needed.
library;

import 'dart:convert';

import 'package:college_companion/database/app_database.dart';
import 'package:flutter/foundation.dart';

/// What each switch schedules. The reminder planner and the Settings copy
/// both read these, so the words on screen cannot drift from the behaviour.
const Duration lectureReminderLead = Duration(minutes: 10);

/// The earlier of the two assignment reminders: a day before the deadline.
const Duration assignmentDayBeforeReminder = Duration(hours: 24);

/// The final assignment reminder before the deadline.
const Duration assignmentFinalReminder = Duration(hours: 2);

/// When the morning briefing fires, local time.
const ({int hour, int minute}) morningBriefingTime = (hour: 8, minute: 0);

/// JSON key in `user_settings.preferences` for assignment reminders.
const String assignmentRemindersKey = 'assignmentRemindersEnabled';

/// JSON key in `user_settings.preferences` for the morning briefing.
const String morningBriefingKey = 'morningBriefingEnabled';

/// Decodes the `user_settings.preferences` JSON object.
///
/// Missing or unreadable JSON decodes to an empty map, so readers fall back
/// to defaults and writers start a fresh object rather than failing every
/// write on one corrupt blob.
Map<String, dynamic> decodePreferences(String? json) {
  if (json == null) return {};
  try {
    final decoded = jsonDecode(json);
    return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
  } on FormatException {
    return {};
  }
}

/// Which reminders the student wants.
@immutable
class NotificationPreferences {
  const NotificationPreferences({
    required this.notificationsEnabled,
    required this.lectureRemindersEnabled,
    this.assignmentRemindersEnabled = true,
    this.morningBriefingEnabled = true,
  });

  /// Master switch: when off, nothing is sent.
  final bool notificationsEnabled;

  /// A heads-up 10 minutes before each lecture.
  final bool lectureRemindersEnabled;

  /// Reminders a day and two hours before each deadline.
  final bool assignmentRemindersEnabled;

  /// The 8 AM summary of the day.
  final bool morningBriefingEnabled;
}

/// Reads [NotificationPreferences] from a settings row.
///
/// A missing row, a missing key, or unreadable JSON all mean "on", matching
/// the column defaults: a student who never touched Settings gets reminders.
NotificationPreferences notificationPreferencesFrom(UserSettingsEntity? row) {
  final json = decodePreferences(row?.preferences);
  bool flag(String key) => json[key] is bool ? json[key] as bool : true;

  return NotificationPreferences(
    notificationsEnabled: row?.notificationsEnabled ?? true,
    lectureRemindersEnabled: row?.lectureRemindersEnabled ?? true,
    assignmentRemindersEnabled: flag(assignmentRemindersKey),
    morningBriefingEnabled: flag(morningBriefingKey),
  );
}
