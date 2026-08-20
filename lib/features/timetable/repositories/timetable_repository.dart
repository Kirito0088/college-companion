/// Timetable Repository
///
/// Handles CRUD and query operations for the weekly lecture schedule.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/lectures_dao.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:drift/drift.dart';

/// Repository for timetable operations.
class TimetableRepository {
  /// Creates a [TimetableRepository] with the given [database] and optional [syncQueueRepository] and [lecturesDao].
  TimetableRepository(
    this._database, [
    this._syncQueueRepository,
    LecturesDao? lecturesDao,
  ]) : _lecturesDao = lecturesDao ?? LecturesDao(_database);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;
  final LecturesDao _lecturesDao;

  /// Watches all non-deleted timetable entries joined with subject details for a given day of week.
  Stream<List<LectureScheduleItem>> watchLecturesForDay(
    String userId,
    int dayOfWeek,
  ) {
    try {
      return _lecturesDao.watchLecturesForDay(userId, dayOfWeek);
    } catch (e) {
      throw DatabaseException(
        'Failed to watch lecture schedule for day: $dayOfWeek',
        e,
      );
    }
  }

  /// Watches all weekly timetable entries joined with subject details.
  Stream<List<LectureScheduleItem>> watchAllWeeklyLectures(String userId) {
    try {
      return _lecturesDao.watchAllWeeklyLectures(userId);
    } catch (e) {
      throw DatabaseException(
        'Failed to watch all weekly lectures for user: $userId',
        e,
      );
    }
  }

  /// Watches all non-deleted timetable entries for the given user,
  /// ordered by day of week then start time.
  Stream<List<TimetableEntryEntity>> watchAll(String userId) {
    try {
      return (_database.select(_database.timetable)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm.asc(t.dayOfWeek),
              (t) => OrderingTerm.asc(t.startTime),
            ]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch timetable for user: $userId', e);
    }
  }

  /// Watches the lectures scheduled for a given day of week
  /// (0 = Monday … 6 = Sunday), ordered by start time.
  Stream<List<TimetableEntryEntity>> watchByDay(String userId, int dayOfWeek) {
    try {
      return (_database.select(_database.timetable)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.dayOfWeek.equals(dayOfWeek) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
          .watch();
    } catch (e) {
      throw DatabaseException(
        'Failed to watch timetable for day: $dayOfWeek',
        e,
      );
    }
  }

  /// Watches all timetable slots for a given subject.
  Stream<List<TimetableEntryEntity>> watchBySubject(
    String userId,
    String subjectId,
  ) {
    try {
      return (_database.select(_database.timetable)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.subjectId.equals(subjectId) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([
              (t) => OrderingTerm.asc(t.dayOfWeek),
              (t) => OrderingTerm.asc(t.startTime),
            ]))
          .watch();
    } catch (e) {
      throw DatabaseException(
        'Failed to watch timetable for subject: $subjectId',
        e,
      );
    }
  }

  /// Watches a single non-deleted timetable entry by ID.
  Stream<TimetableEntryEntity?> watchById(String userId, String id) {
    try {
      return (_database.select(_database.timetable)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch timetable entry: $id', e);
    }
  }

  /// Gets a non-deleted timetable entry by ID (one-time fetch).
  Future<TimetableEntryEntity?> getById(String userId, String id) async {
    try {
      return await (_database.select(_database.timetable)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to get timetable entry: $id', e);
    }
  }

  /// Creates a new timetable entry. Returns the new row's ID.
  Future<String> create(TimetableCompanion data) async {
    try {
      final result = await _database
          .into(_database.timetable)
          .insertReturning(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'timetable',
        recordId: result.id,
        operation: 'INSERT',
      );
      return result.id;
    } catch (e) {
      throw DatabaseException('Failed to create timetable entry', e);
    }
  }

  /// Updates an existing timetable entry.
  Future<void> update(String userId, String id, TimetableCompanion data) async {
    try {
      await (_database.update(
        _database.timetable,
      )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'timetable',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to update timetable entry: $id', e);
    }
  }

  /// Soft-deletes a timetable entry.
  Future<void> delete(String userId, String id) async {
    try {
      await (_database.update(
        _database.timetable,
      )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(
        TimetableCompanion(
          deletedAt: Value(DateTime.now().toUtc().toIso8601String()),
        ),
      );
      await _syncQueueRepository?.enqueue(
        targetTable: 'timetable',
        recordId: id,
        operation: 'DELETE',
      );
    } catch (e) {
      throw DatabaseException('Failed to soft-delete timetable entry: $id', e);
    }
  }
}
