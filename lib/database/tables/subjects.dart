/// Subjects Table
///
/// Stores subjects within a semester.
/// Central entity referenced by timetable, attendance, assignments, and internal_marks.
library;

import 'package:drift/drift.dart';

/// Subject type.
enum SubjectType { theory, practical, tutorial }

/// A subject record.
///
/// Matches Supabase schema in supabase/migrations/00001_mvp_foundation.sql
@TableIndex(name: 'idx_subjects_user_deleted', columns: {#userId, #deletedAt})
@DataClassName('SubjectEntity')
class Subjects extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  TextColumn get userId => text().customConstraint('NOT NULL')();

  /// Parent semester ID. Cascade deletes all subjects when semester is removed.
  TextColumn get semesterId => text().customConstraint('NOT NULL')();

  /// Subject name (e.g., "Data Structures", "Physics Lab").
  TextColumn get name => text().customConstraint('NOT NULL')();

  /// Faculty/professor name. Nullable.
  TextColumn get faculty => text().nullable()();

  /// Subject type: theory, practical, or tutorial.
  /// Defaults to 'theory'.
  TextColumn get type => text()
      .withDefault(const Constant('theory'))
      .customConstraint(
        "NOT NULL CHECK (type IN ('theory', 'practical', 'tutorial'))",
      )();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get createdAt => text().customConstraint('NOT NULL')();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get updatedAt => text().customConstraint('NOT NULL')();

  /// Soft delete: NULL = active, timestamp = deleted.
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, semesterId, name},
  ];
}
