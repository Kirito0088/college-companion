/// Subjects Table
///
/// Stores subjects within a semester. Central entity referenced by
/// timetable, lecture_records, assignments, and internal_marks.
///
/// Carries the standard sync-metadata block (Phase 4 §2) via
/// [SyncableColumns]; syncs in Phase 5.
library;

import 'package:college_companion/database/syncable_columns.dart';
import 'package:drift/drift.dart';

/// Subject type.
enum SubjectType { theory, practical, tutorial }

/// A subject record.
///
/// Mirrors the Supabase schema in `supabase/migrations/00001_mvp_foundation.sql`
/// (business columns); local sync-metadata columns are local-only tracking.
@DataClassName('SubjectEntity')
class Subjects extends Table with SyncableColumns {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  TextColumn get userId => text()();

  /// Parent semester ID. Cascade deletes all subjects when semester is removed.
  TextColumn get semesterId => text()();

  /// Subject name (e.g., "Data Structures", "Physics Lab").
  TextColumn get name => text()();

  /// Faculty/professor name. Nullable.
  TextColumn get faculty => text().nullable()();

  /// Subject type: theory, practical, or tutorial. Defaults to 'theory'.
  TextColumn get type => text().withDefault(const Constant('theory'))();

  /// Soft delete: NULL = active, timestamp = deleted.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (type IN ('theory', 'practical', 'tutorial'))",
  ];

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, semesterId, name},
  ];
}
