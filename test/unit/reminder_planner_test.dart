/// Unit tests for the reminder planner (#10).
///
/// The planner is a pure function from the student's timetable, pending
/// assignments and notification preferences to the dated reminders the OS
/// should fire. Everything stateful (the OS schedule, the notifications
/// table) lives in ReminderScheduler; these tests pin *what* gets planned.
library;

import 'package:college_companion/features/notifications/services/reminder_planner.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:flutter_test/flutter_test.dart';

// 2026-10-05 is a Monday; dayOfWeek 0 = Monday.
final _monday = DateTime(2026, 10, 5);

LectureScheduleItem _lecture({
  String id = 'tt1',
  String subject = 'Advanced Mathematics',
  int day = 0,
  String start = '09:00',
  String? room = '302',
}) => LectureScheduleItem(
  id: id,
  userId: 'u1',
  subjectId: 's1',
  subjectName: subject,
  dayOfWeek: day,
  startTime: start,
  endTime: '10:00',
  room: room,
);

ReminderAssignment _assignment({
  String id = 'a1',
  String title = 'DBMS Lab Report',
  String? subject = 'Databases',
  required DateTime due,
}) => ReminderAssignment(id: id, title: title, subjectName: subject, due: due);

const _allOn = ReminderPreferences(
  notificationsEnabled: true,
  lectureRemindersEnabled: true,
);

List<PlannedReminder> _plan({
  List<LectureScheduleItem> lectures = const [],
  List<ReminderAssignment> assignments = const [],
  ReminderPreferences preferences = _allOn,
  required DateTime now,
}) => planReminders(
  lectures: lectures,
  assignments: assignments,
  preferences: preferences,
  now: now,
);

Iterable<PlannedReminder> _of(
  List<PlannedReminder> plan,
  ReminderChannel channel,
) => plan.where((r) => r.channel == channel);

void main() {
  group('pre-lecture warning', () {
    test('Scenario 1: a 09:00 lecture is announced at 08:50', () {
      final plan = _plan(
        lectures: [_lecture()],
        now: _monday.add(const Duration(hours: 8)),
      );

      final first = _of(plan, ReminderChannel.lectures).first;
      expect(first.fireAt, _monday.add(const Duration(hours: 8, minutes: 50)));
      expect(first.title, 'Upcoming Class');
      expect(first.body, 'Advanced Mathematics in Room 302 in 10m');
      expect(first.targetRoute, '/timetable');
    });

    test('a reminder whose time has passed rolls to next week', () {
      final plan = _plan(
        lectures: [_lecture()],
        now: _monday.add(const Duration(hours: 8, minutes: 55)),
      );

      final lectures = _of(plan, ReminderChannel.lectures).toList();
      expect(lectures, hasLength(1));
      expect(
        lectures.single.fireAt,
        _monday.add(const Duration(days: 7, hours: 8, minutes: 50)),
      );
    });

    test('reads a room that already names its kind as-is', () {
      final plan = _plan(
        lectures: [_lecture(room: 'Lab 3')],
        now: _monday,
      );
      expect(
        _of(plan, ReminderChannel.lectures).first.body,
        'Advanced Mathematics in Lab 3 in 10m',
      );
    });

    test('omits the room when there is none', () {
      final plan = _plan(lectures: [_lecture(room: null)], now: _monday);
      expect(
        _of(plan, ReminderChannel.lectures).first.body,
        'Advanced Mathematics in 10m',
      );
    });

    test('accepts HH:MM:SS start times', () {
      final plan = _plan(
        lectures: [_lecture(start: '14:30:00')],
        now: _monday,
      );
      expect(
        _of(plan, ReminderChannel.lectures).first.fireAt,
        _monday.add(const Duration(hours: 14, minutes: 20)),
      );
    });

    test('are skipped when lecture reminders are off', () {
      final plan = _plan(
        lectures: [_lecture()],
        assignments: [
          _assignment(due: _monday.add(const Duration(days: 2, hours: 12))),
        ],
        preferences: const ReminderPreferences(
          notificationsEnabled: true,
          lectureRemindersEnabled: false,
        ),
        now: _monday,
      );
      expect(_of(plan, ReminderChannel.lectures), isEmpty);
      expect(_of(plan, ReminderChannel.assignments), isNotEmpty);
    });
  });

  group('assignment reminders', () {
    final now = _monday.add(const Duration(hours: 10));
    final dueTomorrowNight = DateTime(2026, 10, 6, 23, 59);

    test('Scenario 2: due tomorrow 11:59 PM gets a calm 24h reminder', () {
      final plan = _plan(
        assignments: [_assignment(due: dueTomorrowNight)],
        now: now,
      );

      final reminders = _of(plan, ReminderChannel.assignments).toList();
      final dayBefore = reminders.firstWhere(
        (r) => r.fireAt == DateTime(2026, 10, 5, 23, 59),
      );
      expect(dayBefore.title, 'Due tomorrow');
      expect(dayBefore.body, contains('DBMS Lab Report'));
      expect(dayBefore.body, contains('11:59 PM'));
      // Calm tone: no alarm language.
      for (final word in ['!', 'urgent', 'hurry', 'overdue', 'last chance']) {
        expect(dayBefore.title.toLowerCase(), isNot(contains(word)));
        expect(dayBefore.body.toLowerCase(), isNot(contains(word)));
      }
      expect(dayBefore.targetRoute, '/assignments');
    });

    test('also reminds 2 hours before the deadline', () {
      final plan = _plan(
        assignments: [_assignment(due: dueTomorrowNight)],
        now: now,
      );
      final twoHours = _of(
        plan,
        ReminderChannel.assignments,
      ).firstWhere((r) => r.fireAt == DateTime(2026, 10, 6, 21, 59));
      expect(twoHours.title, 'Due in 2 hours');
    });

    test('skips reminders whose time has already passed', () {
      final plan = _plan(
        assignments: [_assignment(due: now.add(const Duration(hours: 1)))],
        now: now,
      );
      expect(_of(plan, ReminderChannel.assignments), isEmpty);
    });

    test('ignores deadlines beyond the planning horizon', () {
      final plan = _plan(
        assignments: [_assignment(due: now.add(const Duration(days: 10)))],
        now: now,
      );
      expect(_of(plan, ReminderChannel.assignments), isEmpty);
    });
  });

  group('daily morning briefing', () {
    test('summarises the day at 08:00', () {
      final plan = _plan(
        lectures: [
          _lecture(id: 'a', start: '11:00'),
          _lecture(id: 'b', subject: 'Compilers', start: '09:30'),
        ],
        now: _monday.add(const Duration(hours: 7)),
      );

      final briefing = _of(plan, ReminderChannel.briefing).first;
      expect(briefing.fireAt, _monday.add(const Duration(hours: 8)));
      expect(briefing.title, 'Good morning');
      expect(briefing.body, '2 classes today, first at 9:30 AM.');
    });

    test('mentions assignments due that day', () {
      final plan = _plan(
        lectures: [_lecture()],
        assignments: [_assignment(due: _monday.add(const Duration(hours: 17)))],
        now: _monday.add(const Duration(hours: 7)),
      );
      expect(
        _of(plan, ReminderChannel.briefing).first.body,
        '1 class today, at 9:00 AM. 1 assignment due today.',
      );
    });

    test('stays quiet on a day with nothing scheduled or due', () {
      // Only a Monday lecture: Tuesday–Sunday have nothing to brief.
      final plan = _plan(lectures: [_lecture()], now: _monday);
      final briefingDays = _of(
        plan,
        ReminderChannel.briefing,
      ).map((r) => r.fireAt.weekday).toSet();
      expect(briefingDays, {DateTime.monday});
    });
  });

  group('preferences and identity', () {
    test('nothing is planned when notifications are off', () {
      final plan = _plan(
        lectures: [_lecture()],
        assignments: [_assignment(due: _monday.add(const Duration(days: 2)))],
        preferences: const ReminderPreferences(
          notificationsEnabled: false,
          lectureRemindersEnabled: true,
        ),
        now: _monday,
      );
      expect(plan, isEmpty);
    });

    test('keys are stable across runs and unique within a plan', () {
      PlanArgs args() => (
        lectures: [
          _lecture(),
          _lecture(id: 'tt2', day: 2),
        ],
        assignments: [
          _assignment(due: _monday.add(const Duration(days: 3, hours: 12))),
        ],
      );
      final a = _plan(
        lectures: args().lectures,
        assignments: args().assignments,
        now: _monday,
      );
      final b = _plan(
        lectures: args().lectures,
        assignments: args().assignments,
        now: _monday.add(const Duration(minutes: 1)),
      );

      expect(a.map((r) => r.key).toSet(), hasLength(a.length));
      expect(a.map((r) => r.key).toSet(), b.map((r) => r.key).toSet());
      for (final r in a) {
        expect(r.key, startsWith(PlannedReminder.keyPrefix));
        expect(r.notificationId, inInclusiveRange(0, 0x7fffffff));
      }
      expect(
        a.map((r) => r.notificationId).toSet(),
        hasLength(a.length),
        reason: 'notification ids must not collide within a plan',
      );
    });

    test('everything planned is in the future and within 7 days', () {
      final now = _monday.add(const Duration(hours: 12));
      final plan = _plan(
        lectures: [for (var d = 0; d < 7; d++) _lecture(id: 'tt$d', day: d)],
        now: now,
      );
      for (final r in plan) {
        expect(r.fireAt.isAfter(now), isTrue);
        expect(r.fireAt.isAfter(now.add(const Duration(days: 7))), isFalse);
      }
    });
  });
}

typedef PlanArgs = ({
  List<LectureScheduleItem> lectures,
  List<ReminderAssignment> assignments,
});
