/// Database Startup and Runtime Schema Verification
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';

import '../support/test_db.dart';

Future<List<String>> _names(AppDatabase db, String type) async {
  final rows = await db
      .customSelect(
        'SELECT name FROM sqlite_master WHERE type = ? ORDER BY name',
        variables: [Variable<String>(type)],
      )
      .get();
  return rows.map((r) => r.data['name'] as String).toList();
}

void main() {
  late Backend backend;

  setUp(() => backend = Backend.memory());
  tearDown(() => backend.close());

  group('1. Database startup', () {
    test('database opens and executes a query', () async {
      final row = await backend.db.customSelect('SELECT 1 AS ok').getSingle();
      expect(row.data['ok'], 1);
    });

    test('schema version is 2 baseline', () async {
      expect(backend.db.schemaVersion, 2);
    });

    test('Drift reports schema version 2 via user_version pragma', () async {
      await backend.db.customSelect('SELECT 1').get();
      final row = await backend.db
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(row.data.values.first, 2);
    });
  });

  group('2. Schema — tables exist', () {
    test('all registered tables are created', () async {
      final tables = await _names(backend.db, 'table');
      const expected = [
        'semesters',
        'subjects',
        'timetable',
        'lecture_records',
        'assignments',
        'internal_marks',
        'user_settings',
        'calendar_events',
        'lecture_evidence',
        'users',
        'sync_queue',
        'sync_metadata',
        'resources',
      ];
      for (final t in expected) {
        expect(tables, contains(t), reason: 'missing table $t');
      }
    });
  });

  group('2. Schema — CHECK constraints exist', () {
    Future<String> ddl(String table) async {
      final row = await backend.db
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type='table' AND name = ?",
            variables: [Variable<String>(table)],
          )
          .getSingle();
      return row.data['sql'] as String;
    }

    test('timetable has day_of_week CHECK', () async {
      final sql = await ddl('timetable');
      expect(sql, contains('day_of_week BETWEEN 0 AND 6'));
    });

    test('internal_marks has marks-range CHECKs', () async {
      final sql = await ddl('internal_marks');
      expect(sql, contains('marks_obtained >= 0'));
      expect(sql, contains('max_marks > 0'));
    });

    test('subjects has type enum CHECK', () async {
      final sql = await ddl('subjects');
      expect(sql, contains("type IN ('theory', 'practical', 'tutorial')"));
    });
  });
}
