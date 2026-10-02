/// Reminder Planner (#10)
///
/// Pure planning for local academic reminders: given the student's weekly
/// timetable, pending assignments and notification preferences, decides
/// which reminders should fire over the next [reminderHorizon] and with
/// what content. No I/O — [ReminderScheduler] applies the plan to the OS
/// and the notifications table.
///
/// Reminders are planned as concrete one-shot instants, re-planned whenever
/// the inputs change, rather than as OS-repeating alarms. That keeps the
/// morning briefing's per-day content accurate (a repeating notification
/// cannot change its text) and every fire time correct across DST, without
/// depending on the device's IANA time zone name.
library;

import 'package:college_companion/features/settings/models/notification_preferences.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// How far ahead reminders are planned. Re-planning on every app start,
/// resume and data change rolls the window forward.
const Duration reminderHorizon = Duration(days: 7);

/// The Android channel (and settings group) a reminder belongs to.
enum ReminderChannel { lectures, assignments, briefing }

/// A pending assignment, reduced to what reminders need.
@immutable
class ReminderAssignment {
  const ReminderAssignment({
    required this.id,
    required this.title,
    required this.due,
    this.subjectName,
  });

  final String id;
  final String title;
  final String? subjectName;

  /// Deadline, in local time.
  final DateTime due;
}

/// One reminder the OS should fire.
@immutable
class PlannedReminder {
  const PlannedReminder({
    required this.key,
    required this.fireAt,
    required this.title,
    required this.body,
    required this.channel,
    required this.type,
    required this.targetRoute,
  });

  /// Prefix of every reminder [key], which doubles as the notifications
  /// table row id. Lets the scheduler tell its rows from any others.
  static const String keyPrefix = 'reminder:';

  /// Stable identity: the same lecture/day or assignment/offset always
  /// produces the same key, so re-planning updates instead of duplicating.
  final String key;

  /// When to fire, local time.
  final DateTime fireAt;
  final String title;
  final String body;
  final ReminderChannel channel;

  /// The `notifications.type` the delivered row is stored with.
  final String type;

  /// Route opened when the student taps the notification.
  final String targetRoute;

  /// The integer id the OS schedule uses for this reminder.
  int get notificationId => idForKey(key);

  /// A 31-bit FNV-1a hash of [key]: stable across runs and processes,
  /// unlike [String.hashCode].
  static int idForKey(String key) {
    var hash = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }
}

final DateFormat _time = DateFormat('h:mm a');
final DateFormat _day = DateFormat('yyyy-MM-dd');

/// Plans every reminder due in `(now, now + reminderHorizon]`.
List<PlannedReminder> planReminders({
  required List<LectureScheduleItem> lectures,
  required List<ReminderAssignment> assignments,
  required NotificationPreferences preferences,
  required DateTime now,
}) {
  if (!preferences.notificationsEnabled) return const [];

  final end = now.add(reminderHorizon);
  bool inWindow(DateTime t) => t.isAfter(now) && !t.isAfter(end);

  final plan = <PlannedReminder>[];
  final today = DateTime(now.year, now.month, now.day);

  // Day 0 through day 7 inclusive: a lecture whose warning already passed
  // today still has next week's occurrence inside the window.
  for (var offset = 0; offset <= reminderHorizon.inDays; offset++) {
    final date = DateTime(today.year, today.month, today.day + offset);
    final dayLectures =
        lectures
            .where((l) => l.dayOfWeek == date.weekday - 1)
            .map((l) => (lecture: l, start: l.startOn(date)))
            .where((e) => e.start != null)
            .toList()
          ..sort((a, b) => a.start!.compareTo(b.start!));

    if (preferences.lectureRemindersEnabled) {
      for (final (:lecture, :start) in dayLectures) {
        final fireAt = start!.subtract(lectureReminderLead);
        if (!inWindow(fireAt)) continue;
        plan.add(
          PlannedReminder(
            key:
                '${PlannedReminder.keyPrefix}lecture:${lecture.id}:'
                '${_day.format(date)}',
            fireAt: fireAt,
            title: 'Upcoming Class',
            body:
                '${lecture.subjectName}${_where(lecture.room)} in '
                '${lectureReminderLead.inMinutes}m',
            channel: ReminderChannel.lectures,
            type: 'lecture_reminder',
            targetRoute: '/timetable',
          ),
        );
      }
    }

    final briefingAt = DateTime(
      date.year,
      date.month,
      date.day,
      morningBriefingTime.hour,
      morningBriefingTime.minute,
    );
    final dueToday = assignments.where((a) => _sameDay(a.due, date)).length;
    final briefing = _briefing(
      dayLectures.map((e) => e.start!).toList(),
      dueToday,
    );
    if (preferences.morningBriefingEnabled &&
        briefing != null &&
        inWindow(briefingAt)) {
      plan.add(
        PlannedReminder(
          key: '${PlannedReminder.keyPrefix}briefing:${_day.format(date)}',
          fireAt: briefingAt,
          title: 'Good morning',
          body: briefing,
          channel: ReminderChannel.briefing,
          type: 'daily_briefing',
          targetRoute: '/',
        ),
      );
    }
  }

  for (final a
      in preferences.assignmentRemindersEnabled
          ? assignments
          : const <ReminderAssignment>[]) {
    final what = a.subjectName == null || a.subjectName!.isEmpty
        ? a.title
        : '${a.title} (${a.subjectName})';
    final at = _time.format(a.due);
    for (final (offset, label, title, body) in [
      (
        assignmentDayBeforeReminder,
        '24h',
        'Due tomorrow',
        '$what is due at $at. Plenty of time to wrap it up.',
      ),
      (
        assignmentFinalReminder,
        '2h',
        'Due in ${assignmentFinalReminder.inHours} hours',
        '$what is due at $at.',
      ),
    ]) {
      final fireAt = a.due.subtract(offset);
      if (!inWindow(fireAt)) continue;
      plan.add(
        PlannedReminder(
          key: '${PlannedReminder.keyPrefix}assignment:${a.id}:$label',
          fireAt: fireAt,
          title: title,
          body: body,
          channel: ReminderChannel.assignments,
          type: 'assignment_reminder',
          targetRoute: '/assignments',
        ),
      );
    }
  }

  return plan..sort((a, b) => a.fireAt.compareTo(b.fireAt));
}

/// The briefing text for a day, or null when there is nothing to say —
/// a daily ping about an empty day is noise, not reassurance.
String? _briefing(List<DateTime> starts, int dueToday) {
  if (starts.isEmpty && dueToday == 0) return null;
  final parts = <String>[
    if (starts.length == 1)
      '1 class today, at ${_time.format(starts.first)}.'
    else if (starts.length > 1)
      '${starts.length} classes today, first at ${_time.format(starts.first)}.'
    else
      'No classes today.',
    if (dueToday == 1)
      '1 assignment due today.'
    else if (dueToday > 1)
      '$dueToday assignments due today.',
  ];
  return parts.join(' ');
}

/// " in Room 302" for a bare room number, " in Lab 3" for a named room.
String _where(String? room) {
  final r = room?.trim() ?? '';
  if (r.isEmpty) return '';
  return RegExp(r'^\d').hasMatch(r) ? ' in Room $r' : ' in $r';
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
