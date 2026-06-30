/// Assignments Table
///
/// Stores student assignments with due dates, status tracking,
/// and completion timestamps.
library;

import 'package:drift/drift.dart';

/// Assignment status.
enum AssignmentStatus { pending, completed }

/// An assignment record.
///
/// Matches Supabase schema in supabase/migrations/00001_mvp_foundation.sql
@DataClassName('AssignmentEntity')
class Assignments extends Table {
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

  /// The date the assignment is due.
  /// Stored as ISO 8601 date string (YYYY-MM-DD).
  TextColumn get dueDate => text()();

  /// Assignment status: pending or completed.
  TextColumn get status => text()();

  /// Timestamp when status changed to completed.
  /// NULL while pending.
  /// Stored as ISO 8601 datetime string.
  TextColumn get completedAt => text().nullable()();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get createdAt => text()();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get updatedAt => text()();

  /// Soft delete: NULL = active, timestamp = deleted.
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
