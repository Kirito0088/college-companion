/// Assignments Table
///
/// Stores student assignments with due dates, status tracking, and
/// completion timestamps.
///
/// Carries the standard sync-metadata block (Phase 4 §2) via
/// [SyncableColumns]; syncs in Phase 5.
library;

import 'package:college_companion/database/syncable_columns.dart';
import 'package:drift/drift.dart';

/// Assignment status.
enum AssignmentStatus { pending, completed }

/// An assignment record.
///
/// Mirrors the Supabase schema in `supabase/migrations/00001_mvp_foundation.sql`
/// (business columns); local sync-metadata columns are local-only tracking.
@DataClassName('AssignmentEntity')
class Assignments extends Table with SyncableColumns {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  TextColumn get userId => text()();

  /// The subject this assignment belongs to.
  TextColumn get subjectId => text()();

  /// Assignment title.
  TextColumn get title => text()();

  /// Optional detailed description of the assignment.
  TextColumn get description => text().nullable()();

  /// The date the assignment is due, as ISO 8601 `YYYY-MM-DD`.
  /// Kept as text (date-only) so lexicographic order matches date order.
  TextColumn get dueDate => text()();

  /// Assignment status: pending or completed.
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Timestamp when status changed to completed. NULL while pending.
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Soft delete: NULL = active, timestamp = deleted.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (status IN ('pending', 'completed'))",
  ];
}
