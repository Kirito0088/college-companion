/// Semesters Table
///
/// Stores academic semesters belonging to a user.
/// Supports archiving and soft delete.
///
/// Carries the standard sync-metadata block (Phase 4 §2) via
/// [SyncableColumns]; syncs in Phase 5.
library;

import 'package:college_companion/database/syncable_columns.dart';
import 'package:drift/drift.dart';

/// A semester record.
///
/// Mirrors the Supabase schema in `supabase/migrations/00001_mvp_foundation.sql`
/// (business columns); local sync-metadata columns are local-only tracking.
@DataClassName('SemesterEntity')
class Semesters extends Table with SyncableColumns {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User ID (Supabase Auth UID). Denormalized for RLS-like filtering.
  TextColumn get userId => text()();

  /// User-defined semester label (e.g., "Semester 5", "Fall 2026").
  TextColumn get name => text()();

  /// Array of working days (0=Monday, 6=Sunday). Matches timetable.day_of_week.
  /// Stored as JSON string since Drift has no native array support.
  TextColumn get workingDays => text()();

  /// Whether this is the active semester.
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();

  /// Whether this semester has been archived.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// Soft delete: NULL = active, timestamp = deleted.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
