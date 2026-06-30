/// Attendance Table
///
/// Stores daily attendance records.
/// One row per subject per lecture type per day.
library;

import 'package:drift/drift.dart';

/// Attendance status.
enum AttendanceStatus { present, absent, cancelled, facultyAbsent, holiday }

/// An attendance record.
///
/// Matches Supabase schema in supabase/migrations/00001_mvp_foundation.sql
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

  /// Attendance status: present, absent, cancelled, faculty_absent, or holiday.
  TextColumn get status => text()();

  /// Type of lecture: theory, practical, or tutorial.
  TextColumn get lectureType => text()();

  /// Supabase Storage URL for attendance proof image. Nullable.
  TextColumn get proofImageUrl => text().nullable()();

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
