import 'dart:io';

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart' show Variable;
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
    test('Drift database instantiates with schema version 6', () {
      expect(database.schemaVersion, 6);
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

    test(
      'upgrading from a v1 db predating lecture_records/sync_metadata/notifications '
      'creates all three tables',
      () async {
        // Reproduces a real on-device schema (schema_version 1, created
        // before lecture_records, sync_metadata, and notifications existed
        // in the Dart table definitions) and asserts the v1 -> v5 migration
        // creates all three rather than leaving them missing, which is the
        // failure mode from issue #28 (SqliteException: no such table:
        // notifications).
        final tempDir = await Directory.systemTemp.createTemp('cc_migration');
        final dbFile = File('${tempDir.path}/legacy_v1.db');
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
          CREATE TABLE semesters (
            id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            working_days TEXT NOT NULL DEFAULT '{}',
            is_current INTEGER NOT NULL DEFAULT 0,
            is_archived INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            deleted_at TEXT NULL,
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
          INSERT INTO users (id, name, email, created_at, updated_at)
          VALUES
            ('legacy_user', 'Legacy User', 'legacy@college.edu', '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z');
        ''');
        raw.execute('PRAGMA user_version = 1;');
        raw.close();

        final migrated = AppDatabase.forTesting(NativeDatabase(dbFile));
        addTearDown(migrated.close);

        final tableNames = await migrated
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
            .get()
            .then((rows) => rows.map((r) => r.data['name'] as String).toSet());

        expect(tableNames, contains('lecture_records'));
        expect(tableNames, contains('sync_metadata'));
        expect(tableNames, contains('notifications'));

        // notifications also declares idx_notifications_user, which fresh
        // installs get via onCreate's createAll() — the repair migration
        // must create it too, not just the bare table.
        final indexNames = await migrated
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
            .get()
            .then((rows) => rows.map((r) => r.data['name'] as String).toSet());
        expect(indexNames, contains('idx_notifications_user'));

        // The table must actually be queryable, not just present — this is
        // the exact query NotificationsScreen runs.
        final notifications = await migrated
            .customSelect(
              'SELECT * FROM notifications WHERE user_id = ? AND deleted_at IS NULL',
              variables: [const Variable<String>('legacy_user')],
            )
            .get();
        expect(notifications, isEmpty);
      },
    );

    test(
      'a v5 db missing most of its tables is fully repaired to the current schema',
      () async {
        // Reproduces the EXACT schema pulled off a physical device (CPH2455)
        // after the v5 repair had already run and stamped user_version = 5:
        // only 6 of the 15 tables existed. The v5 step repaired the three
        // tables issue #28 named, but nine others -- including `attendance`
        // and `sync_queue` -- were never created by any onUpgrade step, and
        // because the version was already stamped, v5 could never run again.
        //
        // Symptoms on device: `no such table: sync_queue` thrown out of
        // SyncService on every launch, and the whole Attendance Overview
        // stuck rendering placeholders because `no such table: attendance`
        // failed every stream behind it.
        final tempDir = await Directory.systemTemp.createTemp('cc_migration');
        final dbFile = File('${tempDir.path}/partial_v5.db');
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
            college_name TEXT NULL,
            branch TEXT NULL,
            semester TEXT NULL,
            student_id TEXT NULL,
            university TEXT NULL,
            course TEXT NULL,
            department TEXT NULL,
            graduation_year TEXT NULL,
            PRIMARY KEY (id)
          );
        ''');
        raw.execute('''
          CREATE TABLE semesters (
            id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            working_days TEXT NOT NULL DEFAULT '{}',
            is_current INTEGER NOT NULL DEFAULT 0,
            is_archived INTEGER NOT NULL DEFAULT 0,
            start_date TEXT NULL,
            expected_completion_date TEXT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            deleted_at TEXT NULL,
            PRIMARY KEY (id)
          );
        ''');
        raw.execute('''
          CREATE TABLE user_settings (
            id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            notifications_enabled INTEGER NOT NULL DEFAULT 1
              CHECK (notifications_enabled IN (0, 1)),
            lecture_reminders_enabled INTEGER NOT NULL DEFAULT 1
              CHECK (lecture_reminders_enabled IN (0, 1)),
            enabled_modules TEXT NOT NULL DEFAULT '{}',
            theme TEXT NOT NULL DEFAULT 'dark',
            preferences TEXT NOT NULL DEFAULT '{}',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            PRIMARY KEY (id)
          );
        ''');
        raw.execute('''
          CREATE TABLE notifications (
            id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            type TEXT NOT NULL DEFAULT 'upcoming',
            target_route TEXT NULL,
            is_read INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            deleted_at TEXT NULL,
            PRIMARY KEY (id)
          );
        ''');
        raw.execute(
          'CREATE INDEX idx_notifications_user ON notifications (user_id);',
        );
        raw.execute('''
          CREATE TABLE lecture_records (id TEXT NOT NULL, PRIMARY KEY (id));
        ''');
        raw.execute('''
          CREATE TABLE sync_metadata (id TEXT NOT NULL, PRIMARY KEY (id));
        ''');
        raw.execute('''
          INSERT INTO users (id, name, email, created_at, updated_at)
          VALUES
            ('legacy_user', 'Legacy User', 'legacy@college.edu', '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z');
        ''');
        raw.execute('PRAGMA user_version = 5;');
        raw.close();

        final migrated = AppDatabase.forTesting(NativeDatabase(dbFile));
        addTearDown(migrated.close);

        final present = await migrated
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type IN ('table', 'index')",
            )
            .get()
            .then((rows) => rows.map((r) => r.data['name'] as String).toSet());

        // Every entity the current schema declares must now exist -- not just
        // the handful any single past issue happened to name.
        for (final entity in migrated.allSchemaEntities) {
          expect(
            present,
            contains(entity.entityName),
            reason: '${entity.entityName} was never created by onUpgrade',
          );
        }

        // The two queries that actually failed on the device must now run.
        await expectLater(
          migrated
              .customSelect(
                'SELECT * FROM attendance WHERE user_id = ? AND deleted_at IS NULL',
                variables: [const Variable<String>('legacy_user')],
              )
              .get(),
          completion(isEmpty),
        );
        await expectLater(
          migrated
              .customSelect(
                'SELECT * FROM sync_queue WHERE is_synced = ?',
                variables: [const Variable<bool>(false)],
              )
              .get(),
          completion(isEmpty),
        );
      },
    );

    test('upgrading from a v4 db that already has notifications and its index '
        'does not throw', () async {
      // A device that did a fresh install between v2 and v4 already has
      // notifications (and idx_notifications_user) via onCreate's
      // createAll(). The v4 -> v5 repair step must not try to recreate
      // either: createTable is IF NOT EXISTS-safe, but createIndex has no
      // such guard and throws "index already exists" if called blindly.
      final tempDir = await Directory.systemTemp.createTemp('cc_migration');
      final dbFile = File('${tempDir.path}/existing_v4.db');
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
            college_name TEXT NULL,
            branch TEXT NULL,
            semester TEXT NULL,
            student_id TEXT NULL,
            university TEXT NULL,
            course TEXT NULL,
            department TEXT NULL,
            graduation_year TEXT NULL,
            PRIMARY KEY (id)
          );
        ''');
      raw.execute('''
          CREATE TABLE notifications (
            id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            type TEXT NOT NULL DEFAULT 'upcoming',
            target_route TEXT NULL,
            is_read INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            deleted_at TEXT NULL,
            PRIMARY KEY (id)
          );
        ''');
      raw.execute(
        'CREATE INDEX idx_notifications_user ON notifications (user_id);',
      );
      raw.execute('''
          INSERT INTO users (id, name, email, created_at, updated_at)
          VALUES
            ('legacy_user', 'Legacy User', 'legacy@college.edu', '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z');
        ''');
      raw.execute('PRAGMA user_version = 4;');
      raw.close();

      final migrated = AppDatabase.forTesting(NativeDatabase(dbFile));
      addTearDown(migrated.close);

      await expectLater(
        migrated.customSelect('SELECT 1').getSingle(),
        completes,
      );
    });
  });
}
