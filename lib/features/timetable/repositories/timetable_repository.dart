/// Timetable Repository
///
/// Handles CRUD and query operations for the weekly lecture schedule
/// (per backend/database.md — timetable table).
///
/// Each row is one time slot on one day of the week for one subject.
/// Every read filters out soft-deleted rows (`deleted_at` IS NULL) and is
/// scoped to the requesting user's `userId`.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for timetable operations.
class TimetableRepository {
  /// Creates a [TimetableRepository] with the given [database].
  TimetableRepository(this._database);

  final AppDatabase _database;

  /// Watches all non-deleted timetable entries for the given user,
  /// ordered by day of week then start time.
  Stream<List<TimetableEntryEntity>> watchAll(String userId) {
    return (_database.select(_database.timetable)
          ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.dayOfWeek),
            (t) => OrderingTerm.asc(t.startTime),
          ]))
        .watch();
  }

  /// Watches the lectures scheduled for a given day of week
  /// (0 = Monday … 6 = Sunday), ordered by start time.
  Stream<List<TimetableEntryEntity>> watchByDay(String userId, int dayOfWeek) {
    return (_database.select(_database.timetable)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.dayOfWeek.equals(dayOfWeek) &
                t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .watch();
  }

  /// Watches all timetable slots for a given subject.
  Stream<List<TimetableEntryEntity>> watchBySubject(
    String userId,
    String subjectId,
  ) {
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
  }

  /// Watches a single non-deleted timetable entry by ID.
  Stream<TimetableEntryEntity?> watchById(String userId, String id) {
    return (_database.select(_database.timetable)..where(
          (t) =>
              t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
        ))
        .watchSingleOrNull();
  }

  /// Gets a non-deleted timetable entry by ID (one-time fetch).
  Future<TimetableEntryEntity?> getById(String userId, String id) {
    return (_database.select(_database.timetable)..where(
          (t) =>
              t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  /// Creates a new timetable entry. Returns the new row's ID.
  Future<String> create(TimetableCompanion data) async {
    final result = await _database
        .into(_database.timetable)
        .insertReturning(data);
    return result.id;
  }

  /// Updates an existing timetable entry.
  Future<void> update(String userId, String id, TimetableCompanion data) {
    return (_database.update(
      _database.timetable,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(data);
  }

  /// Soft-deletes a timetable entry.
  Future<void> delete(String userId, String id) {
    return (_database.update(
      _database.timetable,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(
      TimetableCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}
