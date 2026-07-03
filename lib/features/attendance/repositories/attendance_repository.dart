/// Attendance Repository
///
/// Handles CRUD and query operations for daily attendance records
/// (per backend/database.md — attendance table).
///
/// Attendance records are one row per subject per lecture type per day.
/// All reads filter out soft-deleted rows (`deleted_at` IS NULL) and are
/// scoped to the requesting user's `userId`, mirroring the established
/// [SemesterRepository] pattern.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for attendance operations.
class AttendanceRepository {
  /// Creates an [AttendanceRepository] with the given [database].
  AttendanceRepository(this._database);

  final AppDatabase _database;

  /// Watches all non-deleted attendance records for the given user,
  /// most recent first.
  Stream<List<AttendanceEntity>> watchAll(String userId) {
    return (_database.select(_database.attendance)
          ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  /// Watches a single non-deleted attendance record by ID.
  Stream<AttendanceEntity?> watchById(String userId, String id) {
    return (_database.select(_database.attendance)..where(
          (t) =>
              t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
        ))
        .watchSingleOrNull();
  }

  /// Gets a non-deleted attendance record by ID (one-time fetch).
  Future<AttendanceEntity?> getById(String userId, String id) {
    return (_database.select(_database.attendance)..where(
          (t) =>
              t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  /// Watches attendance for a specific subject, most recent first.
  Stream<List<AttendanceEntity>> watchBySubject(
    String userId,
    String subjectId,
  ) {
    return (_database.select(_database.attendance)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.subjectId.equals(subjectId) &
                t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Watches attendance for a single calendar date.
  Stream<List<AttendanceEntity>> watchOnDate(String userId, DateTime date) {
    return (_database.select(_database.attendance)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.date.equals(_dayKey(date)) &
                t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Watches attendance within a date range (inclusive).
  Stream<List<AttendanceEntity>> watchByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return (_database.select(_database.attendance)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.deletedAt.isNull() &
                t.date.isBetweenValues(_dayKey(start), _dayKey(end)),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Creates a new attendance record. Returns the new row's ID.
  Future<String> create(AttendanceCompanion data) async {
    final result = await _database
        .into(_database.attendance)
        .insertReturning(data);
    return result.id;
  }

  /// Updates an existing attendance record.
  Future<void> update(String userId, String id, AttendanceCompanion data) {
    return (_database.update(
      _database.attendance,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(data);
  }

  /// Soft-deletes an attendance record.
  Future<void> delete(String userId, String id) {
    return (_database.update(
      _database.attendance,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(
      AttendanceCompanion(
        deletedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  /// Formats a [DateTime] as an ISO 8601 calendar date (`YYYY-MM-DD`).
  ///
  /// Matches the storage format of the `date` column so that lexicographic
  /// string comparisons behave as ordered date comparisons.
  static String _dayKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
