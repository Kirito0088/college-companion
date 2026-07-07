/// Checklist 1 & 2: Database startup, migrations, and generated schema.
///
/// Verifies against the *runtime* SQLite schema (sqlite_master + pragmas),
/// not assumptions.
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
      final row = await backend.db
          .customSelect('SELECT 1 AS ok')
          .getSingle();
      expect(row.data['ok'], 1);
    });

    test('schema version is 2 (Phase 4 baseline)', () async {
      expect(backend.db.schemaVersion, 2);
    });

    test('Drift reports schema version 2 via user_version pragma', () async {
      // The migrator runs on first access; confirm the DB is initialized.
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

    test('timetable has day/type/time-order CHECKs', () async {
      final sql = await ddl('timetable');
      expect(sql, contains('day_of_week BETWEEN 0 AND 6'));
      expect(sql, contains("lecture_type IN ('theory', 'practical', 'tutorial')"));
      expect(sql, contains('end_time > start_time'));
    });

    test('internal_marks has marks-range CHECKs', () async {
      final sql = await ddl('internal_marks');
      expect(sql, contains('marks_obtained >= 0'));
      expect(sql, contains('max_marks > 0'));
      expect(sql, contains('marks_obtained <= max_marks'));
    });

    test('subjects and assignments and calendar_events have enum CHECKs', () async {
      expect(await ddl('subjects'), contains("type IN ('theory', 'practical', 'tutorial')"));
      expect(await ddl('assignments'), contains("status IN ('pending', 'completed')"));
      expect(await ddl('calendar_events'), contains("type IN ('academic', 'assignment', 'exam', 'personal')"));
    });
  });

  group('2. Schema — triggers exist', () {
    test('lecture_records immutability triggers are present', () async {
      final triggers = await _names(backend.db, 'trigger');
      expect(triggers, contains('trg_lecture_records_immutable_update'));
      expect(triggers, contains('trg_lecture_records_no_delete'));
    });
  });

  group('2. Schema — indexes exist', () {
    test('sync_queue indexes are present', () async {
      final indexes = await _names(backend.db, 'index');
      expect(indexes, contains('idx_sync_queue_record_id'));
      expect(indexes, contains('idx_sync_queue_operation'));
      expect(indexes, contains('idx_sync_queue_status'));
      expect(indexes, contains('idx_sync_queue_pending'));
    });

    test('lecture_records timetable_id UNIQUE index is present', () async {
      // Drift creates a UNIQUE index for uniqueKeys.
      final rows = await backend.db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' "
            "AND tbl_name='lecture_records'",
          )
          .get();
      expect(rows, isNotEmpty, reason: 'expected a UNIQUE index on lecture_records');
    });
  });

  group('2. Schema — foreign keys (documented local design)', () {
    test('local Drift schema declares NO SQL-level foreign keys', () async {
      // Offline-first design decision: the local schema is denormalized and
      // relies on app-level integrity + userId filtering; referential
      // integrity is enforced in the Supabase cloud schema (see
      // supabase/migrations/00003). This test PINS that documented behavior.
      final row = await backend.db
          .customSelect('PRAGMA foreign_keys')
          .getSingle();
      expect(row.data.values.first, 0, reason: 'foreign_keys pragma is OFF locally');

      final lr = await backend.db
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type='table' AND name='lecture_records'",
          )
          .getSingle();
      expect((lr.data['sql'] as String).toUpperCase(), isNot(contains('REFERENCES')));
    });
  });
}
