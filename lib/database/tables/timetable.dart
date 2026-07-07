/// Timetable Table
///
/// Stores the weekly lecture schedule. Each row is one time slot on one
/// day for one subject.
///
/// Carries the standard sync-metadata block (Phase 4 §2) via
/// [SyncableColumns]; syncs in Phase 5.
library;

import 'package:college_companion/database/syncable_columns.dart';
import 'package:drift/drift.dart';

/// Lecture type.
enum LectureType { theory, practical, tutorial }

/// A timetable entry.
///
/// Mirrors the Supabase schema in `supabase/migrations/00001_mvp_foundation.sql`
/// (business columns); local sync-metadata columns are local-only tracking.
@DataClassName('TimetableEntryEntity')
class Timetable extends Table with SyncableColumns {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  TextColumn get userId => text()();

  /// The subject taught in this slot. Semester is resolved via
  /// subjects.semesterId.
  TextColumn get subjectId => text()();

  /// ISO 8601 day: 0=Monday, 6=Sunday.
  IntColumn get dayOfWeek => integer()();

  /// Lecture start time (local). Stored as zero-padded `HH:MM[:SS]`.
  TextColumn get startTime => text()();

  /// Lecture end time (local). Must be after start_time (enforced by the
  /// `chk_timetable_time_order` table constraint; lexicographic comparison
  /// is valid for zero-padded times).
  TextColumn get endTime => text()();

  /// Classroom or lab identifier. Nullable.
  TextColumn get room => text().nullable()();

  /// Type of lecture: theory, practical, or tutorial.
  TextColumn get lectureType => text().withDefault(const Constant('theory'))();

  /// Soft delete: NULL = active, timestamp = deleted.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (day_of_week BETWEEN 0 AND 6)",
    "CHECK (lecture_type IN ('theory', 'practical', 'tutorial'))",
    "CHECK (end_time > start_time)",
  ];
}
