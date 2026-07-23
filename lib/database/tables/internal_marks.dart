/// Internal Marks Table
///
/// Stores internal assessment scores (unit tests, quizzes, mid-terms, etc.).
/// Free-form exam names to accommodate diverse college naming conventions.
library;

import 'package:drift/drift.dart';

/// An internal marks record.
///
/// Matches Supabase schema in supabase/migrations/00001_mvp_foundation.sql
@TableIndex(name: 'idx_internal_marks_subject', columns: {#subjectId, #deletedAt})
@DataClassName('InternalMarkEntity')
class InternalMarks extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  TextColumn get userId => text()();

  /// The subject this assessment belongs to.
  TextColumn get subjectId => text()();

  /// Free-form assessment label (e.g., "UT-1", "Mid Sem", "Quiz 3", "Lab Viva").
  TextColumn get examName => text()();

  /// Score achieved. Must be >= 0 and <= max_marks.
  RealColumn get marksObtained =>
      real().customConstraint('NOT NULL CHECK (marks_obtained >= 0)')();

  /// Maximum possible score. Must be > 0.
  RealColumn get maxMarks =>
      real().customConstraint('NOT NULL CHECK (max_marks > 0)')();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get createdAt => text()();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get updatedAt => text()();

  /// Soft delete: NULL = active, timestamp = deleted.
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
