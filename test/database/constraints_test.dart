/// CHECK constraints reject invalid data.
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
      final now = DateTime.now().toUtc().toIso8601String();
      expect(
        () => backend.db
            .into(backend.db.timetable)
            .insert(
              TimetableCompanion.insert(
                id: 't1',
                userId: 'u',
                subjectId: 's',
                dayOfWeek: 9,
                startTime: '09:00',
                endTime: '10:00',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('7. internal_marks constraints', () {
    test('negative marks_obtained is rejected', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      expect(
        () => backend.db
            .into(backend.db.internalMarks)
            .insert(
              InternalMarksCompanion.insert(
                id: 'm1',
                userId: 'u',
                subjectId: 's',
                examName: 'UT-1',
                marksObtained: -1,
                maxMarks: 20,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('max_marks must be > 0', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      expect(
        () => backend.db
            .into(backend.db.internalMarks)
            .insert(
              InternalMarksCompanion.insert(
                id: 'm3',
                userId: 'u',
                subjectId: 's',
                examName: 'UT-1',
                marksObtained: 0,
                maxMarks: 0,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('a valid marks row is accepted', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      await backend.db
          .into(backend.db.internalMarks)
          .insert(
            InternalMarksCompanion.insert(
              id: 'm4',
              userId: 'u',
              subjectId: 's',
              examName: 'UT-1',
              marksObtained: 18,
              maxMarks: 20,
              createdAt: now,
              updatedAt: now,
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
      final now = DateTime.now().toUtc().toIso8601String();
      expect(
        () => backend.db
            .into(backend.db.subjects)
            .insert(
              SubjectsCompanion.insert(
                id: 's1',
                userId: 'u',
                semesterId: 'sem',
                name: 'X',
                type: const Value('lab'),
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
