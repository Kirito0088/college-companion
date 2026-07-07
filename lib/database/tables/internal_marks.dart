/// Internal Marks Table
///
/// Stores internal assessment scores (unit tests, quizzes, mid-terms, etc.).
/// Free-form exam names to accommodate diverse college naming conventions.
///
/// Carries the standard sync-metadata block (Phase 4 §2) via
/// [SyncableColumns]; syncs in Phase 5.
library;

import 'package:college_companion/database/syncable_columns.dart';
import 'package:drift/drift.dart';

/// An internal marks record.
///
/// Mirrors the Supabase schema in `supabase/migrations/00001_mvp_foundation.sql`
/// (business columns); local sync-metadata columns are local-only tracking.
@DataClassName('InternalMarkEntity')
class InternalMarks extends Table with SyncableColumns {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  TextColumn get userId => text()();

  /// The subject this assessment belongs to.
  TextColumn get subjectId => text()();

  /// Free-form assessment label (e.g., "UT-1", "Mid Sem", "Quiz 3", "Lab Viva").
  TextColumn get examName => text()();

  /// Score achieved. Must be >= 0 and <= max_marks.
  RealColumn get marksObtained => real()();

  /// Maximum possible score. Must be > 0.
  RealColumn get maxMarks => real()();

  /// Soft delete: NULL = active, timestamp = deleted.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (marks_obtained >= 0)",
    "CHECK (max_marks > 0)",
    "CHECK (marks_obtained <= max_marks)",
  ];
}
