/// The dashboard's "today" includes the timetable (#42).
///
/// The greeting, Today's Flow, the hero Next Action and Next Break used to
/// read calendar events only, so a student with a timetable lecture today
/// saw "0 lectures today" while its reminder fired from the timetable.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _uid = 'u1';
const _iso = '2026-10-01T00:00:00.000Z';

LectureScheduleItem _lecture(String subject, String start, String end) =>
    LectureScheduleItem(
      id: 'tt-$subject',
      userId: _uid,
      subjectId: 's1',
      subjectName: subject,
      dayOfWeek: DateTime.now().weekday - 1,
      startTime: start,
      endTime: end,
      room: '302',
    );

CalendarEventEntity _event(String title, DateTime start, DateTime end) =>
    CalendarEventEntity(
      id: 'ev-$title',
      userId: _uid,
      title: title,
      startDate: start.toUtc().toIso8601String(),
      endDate: end.toUtc().toIso8601String(),
      eventType: 'exam',
      isAllDay: false,
      createdAt: _iso,
      updatedAt: _iso,
    );

Future<DashboardSnapshot> _snapshot({
  List<LectureScheduleItem> lectures = const [],
  List<CalendarEventEntity> events = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      todayLecturesStreamProvider.overrideWith(
        (ref, u) => Stream.value(lectures),
      ),
      calendarEventsStreamProvider.overrideWith(
        (ref, u) => Stream.value(events),
      ),
      assignmentsStreamProvider.overrideWith(
        (ref, u) => Stream.value(const []),
      ),
      safeBunkStreamProvider.overrideWith(
        (ref, u) =>
            Stream.value(SafeBunkCalculator.calculate(attended: 0, total: 0)),
      ),
      subjectsStreamProvider.overrideWith((ref, u) => Stream.value(const [])),
    ],
  );
  addTearDown(container.dispose);
  return container.read(dashboardSnapshotProvider(_uid).future);
}

void main() {
  test('a timetable lecture today is counted and shown', () async {
    final snapshot = await _snapshot(
      lectures: [_lecture('Compilers', '00:00', '23:59')],
    );

    expect(snapshot.greetingContext, '1 lecture today');
    expect(snapshot.timelineEvents.map((e) => e.title), ['Compilers']);
    expect(snapshot.timelineEvents.single.location, '302');
  });

  test('lectures and calendar events appear together in time order', () async {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final snapshot = await _snapshot(
      lectures: [_lecture('Compilers', '00:20', '00:40')],
      events: [
        _event(
          'Mid-sem exam',
          day.add(const Duration(minutes: 10)),
          day.add(const Duration(minutes: 15)),
        ),
      ],
    );

    expect(snapshot.greetingContext, '2 lectures today');
    expect(snapshot.timelineEvents.map((e) => e.title), [
      'Mid-sem exam',
      'Compilers',
    ]);
  });

  test('event times are shown in local time', () async {
    final today = DateTime.now();
    final nine = DateTime(today.year, today.month, today.day, 9);
    final snapshot = await _snapshot(
      events: [_event('Seminar', nine, nine.add(const Duration(hours: 1)))],
    );

    final event = snapshot.timelineEvents.single;
    expect('${event.timeString} ${event.meridiem}', '09:00 AM');
  });

  test('a lecture in progress counts down to the next break', () async {
    final snapshot = await _snapshot(
      lectures: [_lecture('Compilers', '00:00', '23:59')],
    );

    expect(snapshot.academicSnapshot.nextBreakState, startsWith('In '));
    expect(snapshot.nextAction?.title, 'Compilers');
  });

  test('no placeholder location for an event without one', () async {
    final today = DateTime.now();
    final noon = DateTime(today.year, today.month, today.day, 12);
    final snapshot = await _snapshot(
      events: [_event('Seminar', noon, noon.add(const Duration(hours: 1)))],
    );

    expect(snapshot.timelineEvents.single.location, isEmpty);
  });
}
