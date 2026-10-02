/// The dashboard's Deadlines tile reads date-only deadlines correctly (#43).
///
/// `due.isAfter(startOfToday)` is false when the deadline parses to exactly
/// 00:00 today, so an assignment due today was never counted as due today.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _uid = 'u1';
const _iso = '2026-10-01T00:00:00.000Z';

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

void main() {
  test('an assignment due today (date only) counts as due today', () async {
    final container = ProviderContainer(
      overrides: [
        todayLecturesStreamProvider.overrideWith(
          (ref, u) => Stream.value(const []),
        ),
        calendarEventsStreamProvider.overrideWith(
          (ref, u) => Stream.value(const []),
        ),
        safeBunkStreamProvider.overrideWith(
          (ref, u) =>
              Stream.value(SafeBunkCalculator.calculate(attended: 0, total: 0)),
        ),
        subjectsStreamProvider.overrideWith((ref, u) => Stream.value(const [])),
        assignmentsStreamProvider.overrideWith(
          (ref, u) => Stream.value([
            AssignmentEntity(
              id: 'a1',
              userId: _uid,
              subjectId: 's1',
              title: 'Lab Report',
              dueDate: _date(DateTime.now()),
              status: 'pending',
              createdAt: _iso,
              updatedAt: _iso,
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(
      dashboardSnapshotProvider(_uid).future,
    );

    expect(snapshot.academicSnapshot.deadlinesState, '1 Due Today');
  });
}
