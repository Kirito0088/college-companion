/// Timetable Table
///
/// Stores the weekly lecture schedule.
/// Each row is one time slot on one day for one subject.
library;

import 'package:drift/drift.dart';

/// Lecture type.
enum LectureType { theory, practical, tutorial }

/// A timetable entry.
///
/// Matches Supabase schema in supabase/migrations/00001_mvp_foundation.sql
@TableIndex(name: 'idx_timetable_user_day', columns: {#userId, #dayOfWeek, #deletedAt})
@TableIndex(name: 'idx_timetable_subject', columns: {#subjectId})
@DataClassName('TimetableEntryEntity')
class Timetable extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  TextColumn get userId => text()();

  /// The subject taught in this slot.
  /// Semester is resolved via subjects.semester_id.
  TextColumn get subjectId => text()();

  /// ISO 8601 day: 0=Monday, 6=Sunday.
  IntColumn get dayOfWeek => integer().customConstraint(
    'NOT NULL CHECK (day_of_week BETWEEN 0 AND 6)',
  )();

  /// Lecture start time (local). Stored as HH:MM:SS.
  TextColumn get startTime => text()();

  /// Lecture end time (local). Must be after start_time.
  TextColumn get endTime => text()();

  /// Classroom or lab identifier. Nullable.
  TextColumn get room => text().nullable()();

  /// Type of lecture: theory, practical, or tutorial.
  TextColumn get lectureType => text().withDefault(const Constant('theory'))();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get createdAt => text()();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get updatedAt => text()();

  /// Soft delete: NULL = active, timestamp = deleted.
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
