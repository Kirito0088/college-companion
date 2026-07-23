import 'package:college_companion/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Migration & Schema Tests', () {
    test('Drift database instantiates with schema version 1', () {
      expect(database.schemaVersion, 1);
    });

    test('All 11 tables are registered in database schema', () {
      final tables = database.allTables.map((t) => t.actualTableName).toList();
      expect(tables.length, 11);
      expect(tables, containsAll([
        'users',
        'semesters',
        'subjects',
        'timetable',
        'attendance',
        'assignments',
        'internal_marks',
        'user_settings',
        'sync_queue',
        'calendar_events',
        'resources',
      ]));
    });

    test('Table structures and column definitions across all 11 tables', () {
      // 1. Users table
      final usersTable = database.users;
      expect(usersTable.actualTableName, 'users');
      expect(usersTable.$columns.map((c) => c.name), containsAll([
        'id',
        'name',
        'email',
        'profile_photo',
        'created_at',
        'updated_at',
      ]));

      // 2. Semesters table
      final semestersTable = database.semesters;
      expect(semestersTable.actualTableName, 'semesters');
      expect(semestersTable.$columns.map((c) => c.name), containsAll([
        'id',
        'user_id',
        'name',
        'working_days',
        'is_current',
        'is_archived',
        'created_at',
        'updated_at',
        'deleted_at',
      ]));

      // 3. Subjects table
      final subjectsTable = database.subjects;
      expect(subjectsTable.actualTableName, 'subjects');
      expect(subjectsTable.$columns.map((c) => c.name), containsAll([
        'id',
        'user_id',
        'semester_id',
        'name',
        'faculty',
        'type',
        'created_at',
        'updated_at',
        'deleted_at',
      ]));

      // 4. Timetable table
      final timetableTable = database.timetable;
      expect(timetableTable.actualTableName, 'timetable');
      expect(timetableTable.$columns.map((c) => c.name), containsAll([
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
      ]));

      // 5. Attendance table
      final attendanceTable = database.attendance;
      expect(attendanceTable.actualTableName, 'attendance');
      expect(attendanceTable.$columns.map((c) => c.name), containsAll([
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
      ]));

      // 6. Assignments table
      final assignmentsTable = database.assignments;
      expect(assignmentsTable.actualTableName, 'assignments');
      expect(assignmentsTable.$columns.map((c) => c.name), containsAll([
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
      ]));

      // 7. InternalMarks table
      final internalMarksTable = database.internalMarks;
      expect(internalMarksTable.actualTableName, 'internal_marks');
      expect(internalMarksTable.$columns.map((c) => c.name), containsAll([
        'id',
        'user_id',
        'subject_id',
        'exam_name',
        'marks_obtained',
        'max_marks',
        'created_at',
        'updated_at',
        'deleted_at',
      ]));

      // 8. UserSettings table
      final userSettingsTable = database.userSettings;
      expect(userSettingsTable.actualTableName, 'user_settings');
      expect(userSettingsTable.$columns.map((c) => c.name), containsAll([
        'id',
        'user_id',
        'notifications_enabled',
        'enabled_modules',
        'theme',
        'preferences',
        'created_at',
        'updated_at',
      ]));

      // 9. SyncQueueItems table
      final syncQueueTable = database.syncQueueItems;
      expect(syncQueueTable.actualTableName, 'sync_queue');
      expect(syncQueueTable.$columns.map((c) => c.name), containsAll([
        'id',
        'target_table',
        'record_id',
        'operation',
        'retry_count',
        'created_at',
        'last_attempt',
        'error',
        'is_synced',
      ]));

      // 10. CalendarEvents table
      final calendarEventsTable = database.calendarEvents;
      expect(calendarEventsTable.actualTableName, 'calendar_events');
      expect(calendarEventsTable.$columns.map((c) => c.name), containsAll([
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
      ]));

      // 11. Resources table
      final resourcesTable = database.resources;
      expect(resourcesTable.actualTableName, 'resources');
      expect(resourcesTable.$columns.map((c) => c.name), containsAll([
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
      ]));
    });

    test('SQLite indexes are created across all tables', () async {
      // Query sqlite_master for all created index names
      final results = await database.customSelect(
        "SELECT name FROM sqlite_master WHERE type='index'",
      ).get();

      final indexNames = results.map((r) => r.read<String>('name')).toList();

      expect(indexNames, containsAll([
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
      ]));
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
  });
}
