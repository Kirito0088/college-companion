/// App Database (Drift / SQLite)
///
/// SQLite is the local source of truth (per backend/database.md).
library;

import 'dart:io';

import 'package:college_companion/database/tables/assignments.dart';
import 'package:college_companion/database/tables/attendance.dart';
import 'package:college_companion/database/tables/calendar_events.dart';
import 'package:college_companion/database/tables/internal_marks.dart';
import 'package:college_companion/database/tables/lecture_evidence.dart';
import 'package:college_companion/database/tables/lecture_records.dart';
import 'package:college_companion/database/tables/notifications.dart';
import 'package:college_companion/database/tables/resources.dart';
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
    Users,
    Semesters,
    Subjects,
    Timetable,
    Attendance,
    LectureRecords,
    Assignments,
    InternalMarks,
    UserSettings,
    SyncQueueItems,
    CalendarEvents,
    Resources,
    LectureEvidence,
    SyncMetadata,
    Notifications,
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
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(semesters, semesters.startDate);
          await m.addColumn(semesters, semesters.expectedCompletionDate);
        }
        if (from < 3) {
          await m.addColumn(userSettings, userSettings.lectureRemindersEnabled);
        }
        if (from < 4) {
          await m.addColumn(users, users.collegeName);
          await m.addColumn(users, users.branch);
          await m.addColumn(users, users.semester);
          await m.addColumn(users, users.studentId);
          await m.addColumn(users, users.university);
          await m.addColumn(users, users.course);
          await m.addColumn(users, users.department);
          await m.addColumn(users, users.graduationYear);
        }
        if (from < 5) {
          // lectureRecords, syncMetadata, and notifications were added to
          // the schema at v2, but that upgrade step never created them —
          // only onCreate (fresh installs) did. `createTable` emits
          // `CREATE TABLE IF NOT EXISTS`, so it's safe to call unconditionally
          // for both the broken-upgrade case and installs that already have
          // these tables via onCreate.
          await m.createTable(lectureRecords);
          await m.createTable(syncMetadata);
          await m.createTable(notifications);

          // Unlike createTable, createIndex has no "IF NOT EXISTS" — calling
          // it on a device that already has idxNotificationsUser (any fresh
          // install) would throw, so it needs an explicit existence check.
          final indexExists = await customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' AND name = ?",
            variables: const [Variable<String>('idx_notifications_user')],
          ).getSingleOrNull();
          if (indexExists == null) {
            await m.createIndex(idxNotificationsUser);
          }
        }
        if (from < 6) {
          // The v5 step above repaired only the three tables issue #28
          // happened to name. A physical device (CPH2455) pulled after that
          // migration ran showed the real damage: 9 of 15 tables were still
          // missing, including `attendance` and `sync_queue`, because no
          // onUpgrade step had ever created them. Since v5 had already
          // stamped user_version, that step could never run again — a
          // partial repair under forward-only migrations is permanent.
          //
          // So repair generically instead of naming tables: create anything
          // the current schema declares that this database does not actually
          // have. Driven by `allSchemaEntities` (tables and indexes alike),
          // it stays correct as new tables are added rather than needing a
          // hand-written step per table, which is what failed twice already.
          await _createMissingSchemaEntities(m);
        }
      },
    );
  }

  /// Creates every entity the current schema declares that is missing from
  /// this database, leaving existing ones untouched.
  ///
  /// Checked against `sqlite_master` rather than relying on `IF NOT EXISTS`,
  /// because `Migrator.createIndex` emits no such guard and throws on an
  /// index that already exists.
  Future<void> _createMissingSchemaEntities(Migrator m) async {
    final existing = await customSelect(
      "SELECT name FROM sqlite_master WHERE type IN ('table', 'index')",
    ).get().then((rows) => rows.map((r) => r.read<String>('name')).toSet());

    for (final entity in allSchemaEntities) {
      if (existing.contains(entity.entityName)) continue;
      await m.create(entity);
    }
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
