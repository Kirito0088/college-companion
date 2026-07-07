/// Checklist 7: CHECK constraints reject invalid data.
///
/// Note on foreign keys: the local Drift schema intentionally declares no
/// SQL-level foreign keys (offline-first denormalization; integrity enforced
/// in the cloud schema). The "invalid foreign key" scenario is therefore
/// documented — not rejected — locally; see schema_test.dart which pins that
/// behavior. These tests focus on the CHECK constraints that DO exist.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../support/test_db.dart';

void main() {
  late Backend backend;

  setUp(() => backend = Backend.memory());
  tearDown(() => backend.close());

  group('7. timetable constraints', () {
    test('invalid day_of_week (>6) is rejected', () async {
      expect(
        () => backend.db.into(backend.db.timetable).insert(
          TimetableCompanion.insert(
            id: 't1',
            userId: 'u',
            subjectId: 's',
            dayOfWeek: 9,
            startTime: '09:00',
            endTime: '10:00',
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('invalid lecture_type is rejected', () async {
      expect(
        () => backend.db.into(backend.db.timetable).insert(
          TimetableCompanion.insert(
            id: 't2',
            userId: 'u',
            subjectId: 's',
            dayOfWeek: 1,
            startTime: '09:00',
            endTime: '10:00',
            lectureType: const Value('seminar'),
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('end_time not after start_time is rejected', () async {
      expect(
        () => backend.db.into(backend.db.timetable).insert(
          TimetableCompanion.insert(
            id: 't3',
            userId: 'u',
            subjectId: 's',
            dayOfWeek: 1,
            startTime: '10:00',
            endTime: '09:00',
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('7. internal_marks constraints', () {
    test('negative marks_obtained is rejected', () async {
      expect(
        () => backend.db.into(backend.db.internalMarks).insert(
          InternalMarksCompanion.insert(
            id: 'm1',
            userId: 'u',
            subjectId: 's',
            examName: 'UT-1',
            marksObtained: -1,
            maxMarks: 20,
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('marks_obtained > max_marks is rejected', () async {
      expect(
        () => backend.db.into(backend.db.internalMarks).insert(
          InternalMarksCompanion.insert(
            id: 'm2',
            userId: 'u',
            subjectId: 's',
            examName: 'UT-1',
            marksObtained: 25,
            maxMarks: 20,
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('max_marks must be > 0', () async {
      expect(
        () => backend.db.into(backend.db.internalMarks).insert(
          InternalMarksCompanion.insert(
            id: 'm3',
            userId: 'u',
            subjectId: 's',
            examName: 'UT-1',
            marksObtained: 0,
            maxMarks: 0,
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('a valid marks row is accepted', () async {
      await backend.db.into(backend.db.internalMarks).insert(
        InternalMarksCompanion.insert(
          id: 'm4',
          userId: 'u',
          subjectId: 's',
          examName: 'UT-1',
          marksObtained: 18,
          maxMarks: 20,
        ),
      );
      final count = await backend.db
          .customSelect('SELECT COUNT(*) AS c FROM internal_marks')
          .getSingle();
      expect(count.data['c'], 1);
    });
  });

  group('7. enum CHECK constraints', () {
    test('invalid subject type is rejected', () async {
      expect(
        () => backend.db.into(backend.db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            userId: 'u',
            semesterId: 'sem',
            name: 'X',
            type: const Value('lab'),
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('invalid assignment status is rejected', () async {
      expect(
        () => backend.db.into(backend.db.assignments).insert(
          AssignmentsCompanion.insert(
            id: 'a1',
            userId: 'u',
            subjectId: 's',
            title: 'HW',
            dueDate: '2026-07-10',
            status: const Value('archived'),
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('7. lecture_records 1:1 UNIQUE constraint', () {
    test('duplicate timetable_id at the SQL layer is rejected', () async {
      final g = await seedGraph(backend.db);
      await backend.db.into(backend.db.lectureRecords).insert(
        LectureRecordsCompanion.insert(
          id: 'lr-1',
          timetableId: g.timetableId,
          subjectId: g.subjectId,
          semesterId: g.semesterId,
          userId: g.userId,
          statusText: 'present',
          recordedAt: DateTime.now().toUtc(),
          deviceTimezone: 'Asia/Kolkata',
          appVersion: '1.0.0',
        ),
      );
      expect(
        () => backend.db.into(backend.db.lectureRecords).insert(
          LectureRecordsCompanion.insert(
            id: 'lr-2',
            timetableId: g.timetableId, // same slot
            subjectId: g.subjectId,
            semesterId: g.semesterId,
            userId: g.userId,
            statusText: 'absent',
            recordedAt: DateTime.now().toUtc(),
            deviceTimezone: 'Asia/Kolkata',
            appVersion: '1.0.0',
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
