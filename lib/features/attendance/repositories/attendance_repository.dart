/// Attendance Repository
///
/// Handles CRUD and query operations for daily attendance records.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for attendance operations.
class AttendanceRepository {
  /// Creates an [AttendanceRepository] with the given [database] and optional [syncQueueRepository].
  AttendanceRepository(this._database, [this._syncQueueRepository]);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;

  /// Watches all non-deleted attendance records for the given user,
  /// most recent first.
  Stream<List<AttendanceEntity>> watchAll(String userId) {
    try {
      return (_database.select(_database.attendance)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm.desc(t.date),
              (t) => OrderingTerm.desc(t.updatedAt),
            ]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch attendance for user: $userId', e);
    }
  }

  /// Watches a single non-deleted attendance record by ID.
  Stream<AttendanceEntity?> watchById(String userId, String id) {
    try {
      return (_database.select(_database.attendance)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch attendance record: $id', e);
    }
  }

  /// Gets a non-deleted attendance record by ID (one-time fetch).
  Future<AttendanceEntity?> getById(String userId, String id) async {
    try {
      return await (_database.select(_database.attendance)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to get attendance record: $id', e);
    }
  }

  /// Watches attendance for a specific subject, most recent first.
  Stream<List<AttendanceEntity>> watchBySubject(
    String userId,
    String subjectId,
  ) {
    try {
      return (_database.select(_database.attendance)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.subjectId.equals(subjectId) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();
    } catch (e) {
      throw DatabaseException(
        'Failed to watch attendance for subject: $subjectId',
        e,
      );
    }
  }

  /// Watches attendance for a single calendar date.
  Stream<List<AttendanceEntity>> watchOnDate(String userId, DateTime date) {
    try {
      return (_database.select(_database.attendance)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.date.equals(_dayKey(date)) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch attendance on date', e);
    }
  }

  /// Watches attendance within a date range (inclusive).
  Stream<List<AttendanceEntity>> watchByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    try {
      return (_database.select(_database.attendance)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.deletedAt.isNull() &
                  t.date.isBetweenValues(_dayKey(start), _dayKey(end)),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch attendance by date range', e);
    }
  }

  /// Creates a new attendance record. Returns the new row's ID.
  Future<String> create(AttendanceCompanion data) async {
    try {
      final result =
          await _database.into(_database.attendance).insertReturning(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'attendance',
        recordId: result.id,
        operation: 'INSERT',
      );
      return result.id;
    } catch (e) {
      throw DatabaseException('Failed to create attendance record', e);
    }
  }

  /// Updates an existing attendance record.
  Future<void> update(
    String userId,
    String id,
    AttendanceCompanion data,
  ) async {
    try {
      await (_database.update(_database.attendance)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'attendance',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to update attendance record: $id', e);
    }
  }

  /// Soft-deletes an attendance record.
  Future<void> delete(String userId, String id) async {
    try {
      await (_database.update(_database.attendance)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(
            AttendanceCompanion(
              deletedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          );
      await _syncQueueRepository?.enqueue(
        targetTable: 'attendance',
        recordId: id,
        operation: 'DELETE',
      );
    } catch (e) {
      throw DatabaseException('Failed to soft-delete attendance record: $id', e);
    }
  }

  /// Formats a [DateTime] as an ISO 8601 calendar date (`YYYY-MM-DD`).
  static String _dayKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
