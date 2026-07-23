/// Semesters Table
///
/// Stores academic semesters belonging to a user.
/// Supports archiving and soft delete.
library;

import 'package:drift/drift.dart';

/// A semester record.
///
/// Matches Supabase schema in supabase/migrations/00001_mvp_foundation.sql
@TableIndex(name: 'idx_semesters_user_deleted', columns: {#userId, #deletedAt})
@TableIndex(name: 'idx_semesters_user_current', columns: {#userId, #isCurrent})
@DataClassName('SemesterEntity')
class Semesters extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User ID (Supabase Auth UID). Denormalized for RLS-like filtering.
  TextColumn get userId => text()();

  /// User-defined semester label (e.g., "Semester 5", "Fall 2026").
  TextColumn get name => text()();

  /// Array of working days (0=Monday, 6=Sunday). Matches timetable.day_of_week.
  /// Stored as JSON string since Drift does not have native array support.
  TextColumn get workingDays => text()();

  /// Whether this is the active semester.
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();

  /// Whether this semester has been archived.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get createdAt => text()();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get updatedAt => text()();

  /// Soft delete: NULL = active, timestamp = deleted.
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
