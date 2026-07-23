/// Attendance Table
///
/// Stores daily attendance records.
/// One row per subject per lecture type per day.
library;

import 'package:drift/drift.dart';

/// Primary attendance status.
enum PrimaryStatus { present, absent, cancelled }

/// Secondary attendance context.
enum SecondaryStatus { facultyAbsent, holiday, practicalCancelled, extraLecture, other }

/// An attendance record.
///
/// Matches Supabase schema in supabase/migrations/00001_mvp_foundation.sql
@TableIndex(name: 'idx_attendance_user_date', columns: {#userId, #date, #deletedAt})
@TableIndex(name: 'idx_attendance_subject', columns: {#subjectId})
@DataClassName('AttendanceEntity')
class Attendance extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  TextColumn get userId => text()();

  /// The subject this attendance record belongs to.
  TextColumn get subjectId => text()();

  /// The calendar date of the lecture.
  /// Stored as ISO 8601 date string (YYYY-MM-DD).
  TextColumn get date => text()();

  /// Primary attendance status.
  TextColumn get primaryStatus => text()();

  /// Optional secondary context.
  TextColumn get secondaryStatus => text().nullable()();

  /// Type of lecture: theory, practical, or tutorial.
  TextColumn get lectureType => text()();

  /// Supabase Storage URL for attendance proof image. Nullable.
  TextColumn get proofImageUrl => text().nullable()();

  /// Local path for the image (used before sync or if kept local).
  TextColumn get localImagePath => text().nullable()();

  /// SHA-256 hash of the evidence image.
  TextColumn get imageHash => text().nullable()();

  /// Device timezone when the record was created.
  TextColumn get deviceTimezone => text().nullable()();

  /// Optional notes about the attendance record.
  TextColumn get notes => text().nullable()();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get createdAt => text()();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get updatedAt => text()();

  /// Soft delete: NULL = active, timestamp = deleted.
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
