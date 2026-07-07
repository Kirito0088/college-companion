/// App Database (Drift / SQLite)
///
/// SQLite is the local source of truth (per backend/database.md).
///
/// Schema version 2 — Phase 4 foundation baseline (fresh `createAll`
/// since no production data exists; per Phase 4 §A1).
library;

import 'dart:io';

import 'package:college_companion/database/tables/assignments.dart';
import 'package:college_companion/database/tables/calendar_events.dart';
import 'package:college_companion/database/tables/internal_marks.dart';
import 'package:college_companion/database/tables/lecture_evidence.dart';
import 'package:college_companion/database/tables/lecture_records.dart';
import 'package:college_companion/database/tables/semesters.dart';
import 'package:college_companion/database/tables/subjects.dart';
import 'package:college_companion/database/tables/sync_metadata.dart';
import 'package:college_companion/database/tables/sync_queue.dart';
import 'package:college_companion/database/tables/timetable.dart';
import 'package:college_companion/database/tables/user_settings.dart';
import 'package:college_companion/database/tables/users.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// The application's local SQLite database.
///
/// Drift is the ORM. All tables are registered directly here.
@DriftDatabase(
  tables: [
    // Syncable business tables
    Semesters,
    Subjects,
    Timetable,
    LectureRecords,
    Assignments,
    InternalMarks,
    UserSettings,
    CalendarEvents,
    // Local-only tables (never synced)
    LectureEvidence,
    // Users — download-only projection (no sync block)
    Users,
    // Internal local-only tracking
    SyncQueueItems,
    SyncMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] with the default native connection.
  AppDatabase() : super(_openConnection());

  /// Creates an [AppDatabase] with a custom [QueryExecutor].
  ///
  /// Useful for testing with in-memory databases.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },

      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Phase 4 §A1: v2 is a fresh baseline — no production data to
          // preserve. Drop legacy v1 tables, then createAll the v2 set.
          // Triggers are ensured by beforeOpen (CREATE IF NOT EXISTS).
          final legacyTables = [
            'sync_queue',
            'user_settings',
            'attendance',
            'internal_marks',
            'assignments',
            'timetable',
            'subjects',
            'semesters',
            'users',
          ];
          for (final table in legacyTables) {
            await m.deleteTable(table);
          }
          await m.createAll();
        }
      },

      beforeOpen: (details) async {
        // ── Lecture Records Immutability Triggers (Phase 4 §4) ───────────
        //
        // These SQLite triggers are the runtime backstop (Layer 3 of the
        // three-layer immutability model). Business columns are frozen;
        // sync-bookkeeping columns (updated_at, sync_status, sync_version,
        // last_synced_at) remain writable for the sync engine (Phase 4 D5).
        //
        // Using CREATE IF NOT EXISTS so they survive both fresh install
        // and upgrade paths — beforeOpen fires after either.

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS trg_lecture_records_immutable_update
          BEFORE UPDATE ON lecture_records
          FOR EACH ROW
          WHEN OLD.status_text IS NOT NEW.status_text
            OR OLD.note IS NOT NEW.note
            OR OLD.recorded_at IS NOT NEW.recorded_at
            OR OLD.timetable_id IS NOT NEW.timetable_id
            OR OLD.subject_id IS NOT NEW.subject_id
            OR OLD.semester_id IS NOT NEW.semester_id
            OR OLD.user_id IS NOT NEW.user_id
            OR OLD.id IS NOT NEW.id
            OR OLD.device_timezone IS NOT NEW.device_timezone
            OR OLD.app_version IS NOT NEW.app_version
            OR OLD.created_at IS NOT NEW.created_at
            OR OLD.created_offline IS NOT NEW.created_offline
          BEGIN
            SELECT RAISE(ABORT,
              'lecture_records business fields are immutable');
          END;
        ''');

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS trg_lecture_records_no_delete
          BEFORE DELETE ON lecture_records
          FOR EACH ROW
          BEGIN
            SELECT RAISE(ABORT,
              'lecture_records cannot be deleted');
          END;
        ''');
      },
    );
  }
}

/// Opens a native SQLite connection.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/college_companion.db');
    return NativeDatabase.createInBackground(file);
  });
}
