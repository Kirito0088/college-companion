/// Attendance insights must be computed only from subjects that have
/// records (#38). A subject with no lectures has no percentage; counting it
/// as 0% dragged the average down, marked it "below target", and rendered
/// "N/A (0%)" for an account with no data at all.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _now = '2026-10-01T00:00:00.000Z';

SubjectEntity _subject(String id, String name) => SubjectEntity(
  id: id,
  userId: 'u1',
  semesterId: 's1',
  name: name,
  type: 'theory',
  createdAt: _now,
  updatedAt: _now,
);

AttendanceEntity _record(String id, String subjectId, String status) =>
    AttendanceEntity(
      id: id,
      userId: 'u1',
      subjectId: subjectId,
      date: '2026-10-01',
      primaryStatus: status,
      lectureType: 'theory',
      createdAt: _now,
      updatedAt: _now,
    );

Future<AttendanceInsights?> _insights(
  List<SubjectEntity> subjects,
  List<AttendanceEntity> records,
) async {
  final container = ProviderContainer(
    overrides: [
      subjectsStreamProvider.overrideWith((ref, u) => Stream.value(subjects)),
      attendanceRecordsStreamProvider.overrideWith(
        (ref, u) => Stream.value(records),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.listen(attendanceInsightsProvider('u1'), (_, _) {});
  await container.read(subjectsStreamProvider('u1').future);
  await container.read(attendanceRecordsStreamProvider('u1').future);
  return container.read(attendanceInsightsProvider('u1')).requireValue;
}

void main() {
  test('no subjects means no insights', () async {
    expect(await _insights(const [], const []), isNull);
  });

  test('subjects without any records mean no insights', () async {
    expect(await _insights([_subject('a', 'DSA')], const []), isNull);
  });

  test('subjects without records are excluded, not counted as 0%', () async {
    final insights = await _insights(
      [_subject('a', 'DSA'), _subject('b', 'Networks')],
      [_record('1', 'a', 'present'), _record('2', 'a', 'present')],
    );

    expect(insights, isNotNull);
    expect(insights!.averagePercentage, 100);
    expect(insights.subjectsBelowTarget, 0);
    expect(insights.lowestSubject, 'DSA');
  });
}
