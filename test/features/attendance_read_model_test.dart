/// Checklist 4: Attendance read-model calculations.
///
/// All statistics must derive exclusively from lecture_records. These tests
/// seed representative records and assert the documented policy:
///   attended  = primary 'present'  (excluding secondary 'other')
///   absent    = primary 'absent'   (excluding 'holiday'/'faculty_absent')
///   excluded  = primary 'cancelled' OR secondary holiday/faculty_absent
///   total     = attended + absent
///   percent   = attended/total*100  (100 when total == 0)
///   canSkip   = attended - ceil(total * 75 / 100), floored at 0
library;

import 'package:college_companion/shared/models/lecture_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_db.dart';

void main() {
  late Backend backend;
  late SeededGraph g;
  var slot = 0;

  setUp(() async {
    backend = Backend.memory();
    g = await seedGraph(backend.db);
    slot = 0;
  });
  tearDown(() => backend.close());

  Future<void> add(LectureStatus status, {String? subjectId}) async {
    slot++;
    await backend.lectureRecords.create(
      userId: g.userId,
      timetableId: 'tt-$slot',
      subjectId: subjectId ?? g.subjectId,
      semesterId: g.semesterId,
      status: status,
      deviceTimezone: 'Asia/Kolkata',
      appVersion: '1.0.0',
    );
  }

  group('4. counts and percentage', () {
    test('mixed statuses produce correct attended/absent/excluded/percentage', () async {
      for (var i = 0; i < 6; i++) {
        await add(const LectureStatus.present());
      }
      await add(const LectureStatus.absent());
      await add(const LectureStatus.absent());
      await add(const LectureStatus.absentWith('holiday')); // excluded
      await add(const LectureStatus.cancelled()); // excluded
      await add(const LectureStatus.presentWithOther('field trip')); // ignored

      final stats = await backend.attendance.getSubjectStats(g.userId, g.subjectId);

      expect(stats.attended, 6);
      expect(stats.absent, 2);
      expect(stats.excluded, 2, reason: 'holiday + cancelled');
      expect(stats.totalLectures, 8);
      expect(stats.percentage, closeTo(75.0, 0.001));
      expect(stats.isAboveThreshold, isTrue);
    });

    test('empty history is 100% and above threshold (no divide-by-zero)', () async {
      final stats = await backend.attendance.getSubjectStats(g.userId, g.subjectId);
      expect(stats.totalLectures, 0);
      expect(stats.attended, 0);
      expect(stats.absent, 0);
      expect(stats.percentage, 100.0);
      expect(stats.isAboveThreshold, isTrue);
    });

    test('below-threshold case computes correctly', () async {
      await add(const LectureStatus.present());
      await add(const LectureStatus.absent());
      await add(const LectureStatus.absent());
      // 1 present / 3 total = 33.3%
      final stats = await backend.attendance.getSubjectStats(g.userId, g.subjectId);
      expect(stats.percentage, closeTo(33.333, 0.01));
      expect(stats.isAboveThreshold, isFalse);
      expect(stats.lecturesCanSkip, 0);
    });
  });

  group('4. cancelled handling', () {
    test('cancelled (plain and with secondary) is excluded from the denominator', () async {
      await add(const LectureStatus.present());
      await add(const LectureStatus.cancelled());
      await add(const LectureStatus.cancelledWith('faculty_absent'));
      final stats = await backend.attendance.getSubjectStats(g.userId, g.subjectId);
      expect(stats.attended, 1);
      expect(stats.absent, 0);
      expect(stats.excluded, 2);
      expect(stats.totalLectures, 1);
      expect(stats.percentage, 100.0);
    });

    test('faculty_absent and holiday absences do not count against attendance', () async {
      await add(const LectureStatus.present());
      await add(const LectureStatus.absentWith('faculty_absent'));
      await add(const LectureStatus.absentWith('holiday'));
      final stats = await backend.attendance.getSubjectStats(g.userId, g.subjectId);
      expect(stats.attended, 1);
      expect(stats.absent, 0);
      expect(stats.excluded, 2);
      expect(stats.percentage, 100.0);
    });
  });

  group('4. safe bunk (documented conservative-margin formula)', () {
    test('9 present / 1 absent → canSkip 1', () async {
      for (var i = 0; i < 9; i++) {
        await add(const LectureStatus.present());
      }
      await add(const LectureStatus.absent());
      final stats = await backend.attendance.getSubjectStats(g.userId, g.subjectId);
      expect(stats.totalLectures, 10);
      expect(stats.percentage, 90.0);
      // minAttended = ceil(10 * 0.75) = 8; canSkip = 9 - 8 = 1.
      expect(stats.lecturesCanSkip, 1);
      expect(stats.lecturesRemainingToSafeBunk, stats.lecturesCanSkip);
    });

    test('exactly at threshold → canSkip 0', () async {
      for (var i = 0; i < 6; i++) {
        await add(const LectureStatus.present());
      }
      await add(const LectureStatus.absent());
      await add(const LectureStatus.absent());
      final stats = await backend.attendance.getSubjectStats(g.userId, g.subjectId);
      expect(stats.percentage, 75.0);
      expect(stats.lecturesCanSkip, 0);
    });

    test('below threshold never returns negative canSkip', () async {
      await add(const LectureStatus.present());
      await add(const LectureStatus.absent());
      await add(const LectureStatus.absent());
      await add(const LectureStatus.absent());
      final stats = await backend.attendance.getSubjectStats(g.userId, g.subjectId);
      expect(stats.lecturesCanSkip, 0);
    });
  });

  group('4. derivation scope', () {
    test('overall stats aggregate across subjects; subject stats filter', () async {
      await add(const LectureStatus.present(), subjectId: 'sub-A');
      await add(const LectureStatus.absent(), subjectId: 'sub-A');
      await add(const LectureStatus.present(), subjectId: 'sub-B');

      final a = await backend.attendance.getSubjectStats(g.userId, 'sub-A');
      expect(a.totalLectures, 2);
      expect(a.attended, 1);

      final overall = await backend.attendance
          .watchOverallStats(g.userId)
          .first;
      expect(overall.totalLectures, 3);
      expect(overall.attended, 2);
    });

    test('watchSubjectStats is reactive to new records', () async {
      final stream = backend.attendance.watchSubjectStats(g.userId, g.subjectId);
      final future = stream.firstWhere((s) => s.totalLectures == 1);
      await add(const LectureStatus.present());
      final stats = await future.timeout(const Duration(seconds: 5));
      expect(stats.attended, 1);
    });
  });
}
