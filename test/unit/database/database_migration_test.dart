import 'dart:io';

import 'package:college_companion/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Migration & Schema Tests', () {
    test('Drift database instantiates with schema version 4', () {
      expect(database.schemaVersion, 4);
    });

    test('All tables are registered in database schema', () {
      final tables = database.allTables.map((t) => t.actualTableName).toList();
      expect(tables.length, 15);
      expect(
        tables,
        containsAll([
          'users',
          'semesters',
          'subjects',
          'timetable',
          'attendance',
          'lecture_records',
          'assignments',
          'internal_marks',
          'user_settings',
          'sync_queue',
          'calendar_events',
          'resources',
          'lecture_evidence',
          'sync_metadata',
          'notifications',
        ]),
      );
    });

    test('Table structures and column definitions across all 11 tables', () {
      // 1. Users table
      final usersTable = database.users;
      expect(usersTable.actualTableName, 'users');
      expect(
        usersTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'name',
          'email',
          'profile_photo',
          'created_at',
          'updated_at',
          'college_name',
          'branch',
          'semester',
          'student_id',
          'university',
          'course',
          'department',
          'graduation_year',
        ]),
      );

      // 2. Semesters table
      final semestersTable = database.semesters;
      expect(semestersTable.actualTableName, 'semesters');
      expect(
        semestersTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'user_id',
          'name',
          'working_days',
          'is_current',
          'is_archived',
          'created_at',
          'updated_at',
          'deleted_at',
        ]),
      );

      // 3. Subjects table
      final subjectsTable = database.subjects;
      expect(subjectsTable.actualTableName, 'subjects');
      expect(
        subjectsTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'user_id',
          'semester_id',
          'name',
          'faculty',
          'type',
          'created_at',
          'updated_at',
          'deleted_at',
        ]),
      );

      // 4. Timetable table
      final timetableTable = database.timetable;
      expect(timetableTable.actualTableName, 'timetable');
      expect(
        timetableTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'user_id',
          'subject_id',
          'day_of_week',
          'start_time',
          'end_time',
          'room',
          'lecture_type',
          'created_at',
          'updated_at',
          'deleted_at',
        ]),
      );

      // 5. Attendance table
      final attendanceTable = database.attendance;
      expect(attendanceTable.actualTableName, 'attendance');
      expect(
        attendanceTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'user_id',
          'subject_id',
          'date',
          'primary_status',
          'secondary_status',
          'lecture_type',
          'proof_image_url',
          'local_image_path',
          'image_hash',
          'device_timezone',
          'notes',
          'created_at',
          'updated_at',
          'deleted_at',
        ]),
      );

      // 6. Assignments table
      final assignmentsTable = database.assignments;
      expect(assignmentsTable.actualTableName, 'assignments');
      expect(
        assignmentsTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'user_id',
          'subject_id',
          'title',
          'description',
          'due_date',
          'status',
          'completed_at',
          'created_at',
          'updated_at',
          'deleted_at',
        ]),
      );

      // 7. InternalMarks table
      final internalMarksTable = database.internalMarks;
      expect(internalMarksTable.actualTableName, 'internal_marks');
      expect(
        internalMarksTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'user_id',
          'subject_id',
          'exam_name',
          'marks_obtained',
          'max_marks',
          'created_at',
          'updated_at',
          'deleted_at',
        ]),
      );

      // 8. UserSettings table
      final userSettingsTable = database.userSettings;
      expect(userSettingsTable.actualTableName, 'user_settings');
      expect(
        userSettingsTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'user_id',
          'notifications_enabled',
          'lecture_reminders_enabled',
          'enabled_modules',
          'theme',
          'preferences',
          'created_at',
          'updated_at',
        ]),
      );

      // 9. SyncQueueItems table
      final syncQueueTable = database.syncQueueItems;
      expect(syncQueueTable.actualTableName, 'sync_queue');
      expect(
        syncQueueTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'target_table',
          'record_id',
          'operation',
          'retry_count',
          'created_at',
          'last_attempt',
          'error',
          'is_synced',
        ]),
      );

      // 10. CalendarEvents table
      final calendarEventsTable = database.calendarEvents;
      expect(calendarEventsTable.actualTableName, 'calendar_events');
      expect(
        calendarEventsTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'user_id',
          'title',
          'description',
          'start_date',
          'end_date',
          'is_all_day',
          'event_type',
          'created_at',
          'updated_at',
          'deleted_at',
        ]),
      );

      // 11. Resources table
      final resourcesTable = database.resources;
      expect(resourcesTable.actualTableName, 'resources');
      expect(
        resourcesTable.$columns.map((c) => c.name),
        containsAll([
          'id',
          'user_id',
          'title',
          'description',
          'url',
          'subject_id',
          'category',
          'created_at',
          'updated_at',
          'deleted_at',
        ]),
      );
    });

    test('SQLite indexes are created across all tables', () async {
      // Query sqlite_master for all created index names
      final results = await database
          .customSelect("SELECT name FROM sqlite_master WHERE type='index'")
          .get();

      final indexNames = results.map((r) => r.read<String>('name')).toList();

      expect(
        indexNames,
        containsAll([
          'idx_users_id',
          'idx_semesters_user_deleted',
          'idx_semesters_user_current',
          'idx_subjects_user_deleted',
          'idx_timetable_user_day',
          'idx_timetable_subject',
          'idx_attendance_user_date',
          'idx_attendance_subject',
          'idx_assignments_user_status',
          'idx_assignments_subject',
          'idx_assignments_due_date',
          'idx_internal_marks_subject',
          'idx_user_settings_user',
          'idx_calendar_events_user_date',
          'idx_resources_subject',
          'idx_sync_queue_record_id',
          'idx_sync_queue_operation',
          'idx_sync_queue_status',
          'idx_sync_queue_pending',
        ]),
      );
    });

    test('Table constraints are enforced at database level', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      // Check constraint: dayOfWeek must be between 0 and 6
      expect(
        () async => database.customInsert(
          'INSERT INTO timetable (id, user_id, subject_id, day_of_week, start_time, end_time, created_at, updated_at) '
          "VALUES ('tt_invalid', 'u1', 's1', 7, '09:00', '10:00', '$now', '$now')",
        ),
        throwsA(anything),
      );

      // Check constraint: marks_obtained >= 0
      expect(
        () async => database.customInsert(
          'INSERT INTO internal_marks (id, user_id, subject_id, exam_name, marks_obtained, max_marks, created_at, updated_at) '
          "VALUES ('mark_invalid', 'u1', 's1', 'Quiz', -5.0, 20.0, '$now', '$now')",
        ),
        throwsA(anything),
      );

      // Check constraint: subject type check
      expect(
        () async => database.customInsert(
          'INSERT INTO subjects (id, user_id, semester_id, name, type, created_at, updated_at) '
          "VALUES ('sub_invalid', 'u1', 'sem1', 'Math', 'invalid_type', '$now', '$now')",
        ),
        throwsA(anything),
      );
    });

    test(
      'upgrading from a v2 db missing lecture_reminders_enabled backfills the column',
      () async {
        // Reproduces a real on-device schema (schema_version 2, user_settings
        // created before `lectureRemindersEnabled` existed in the Dart table
        // definition) and asserts the v2 -> v3 migration repairs it in place.
        final tempDir = await Directory.systemTemp.createTemp('cc_migration');
        final dbFile = File('${tempDir.path}/legacy_v2.db');
        addTearDown(() => tempDir.delete(recursive: true));

        final raw = sqlite3.sqlite3.open(dbFile.path);
        raw.execute('''
          CREATE TABLE users (
            id TEXT NOT NULL,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            profile_photo TEXT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            PRIMARY KEY (id)
          );
        ''');
        raw.execute('''
          CREATE TABLE user_settings (
            id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            notifications_enabled INTEGER NOT NULL DEFAULT 1
              CHECK (notifications_enabled IN (0, 1)),
            enabled_modules TEXT NOT NULL DEFAULT '{}',
            theme TEXT NOT NULL DEFAULT 'dark',
            preferences TEXT NOT NULL DEFAULT '{}',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            PRIMARY KEY (id)
          );
        ''');
        raw.execute('''
          INSERT INTO user_settings
            (id, user_id, notifications_enabled, enabled_modules, theme, preferences, created_at, updated_at)
          VALUES
            ('settings_legacy_user', 'legacy_user', 1, '{}', 'dark', '{"accent":"sand"}', '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z');
        ''');
        raw.execute('PRAGMA user_version = 2;');
        raw.close();

        final migrated = AppDatabase.forTesting(NativeDatabase(dbFile));
        addTearDown(migrated.close);

        final row = await migrated
            .customSelect(
              'SELECT lecture_reminders_enabled FROM user_settings '
              "WHERE user_id = 'legacy_user'",
            )
            .getSingle();

        expect(row.data['lecture_reminders_enabled'], 1);
      },
    );

    test(
      'upgrading from a v3 db missing academic profile columns backfills them as null',
      () async {
        // Reproduces a real on-device schema (schema_version 3, users row
        // created before the academic-profile columns existed in the Dart
        // table definition) and asserts the v3 -> v4 migration adds them.
        final tempDir = await Directory.systemTemp.createTemp('cc_migration');
        final dbFile = File('${tempDir.path}/legacy_v3.db');
        addTearDown(() => tempDir.delete(recursive: true));

        final raw = sqlite3.sqlite3.open(dbFile.path);
        raw.execute('''
          CREATE TABLE users (
            id TEXT NOT NULL,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            profile_photo TEXT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            PRIMARY KEY (id)
          );
        ''');
        raw.execute('''
          INSERT INTO users (id, name, email, created_at, updated_at)
          VALUES
            ('legacy_user', 'Legacy User', 'legacy@college.edu', '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z');
        ''');
        raw.execute('PRAGMA user_version = 3;');
        raw.close();

        final migrated = AppDatabase.forTesting(NativeDatabase(dbFile));
        addTearDown(migrated.close);

        final row = await migrated
            .customSelect(
              "SELECT college_name, branch, semester FROM users WHERE id = 'legacy_user'",
            )
            .getSingle();

        expect(row.data['college_name'], isNull);
        expect(row.data['branch'], isNull);
        expect(row.data['semester'], isNull);
      },
    );
  });
}
