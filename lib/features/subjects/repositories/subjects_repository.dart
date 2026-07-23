/// Subjects Repository
///
/// Handles CRUD and query operations for subjects.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for subject operations.
class SubjectRepository {
  /// Creates a [SubjectRepository] with the given [database] and optional [syncQueueRepository].
  SubjectRepository(this._database, [this._syncQueueRepository]);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;

  /// Watches all non-deleted subjects for the given user, alphabetical by name.
  Stream<List<SubjectEntity>> watchAll(String userId) {
    try {
      return (_database.select(_database.subjects)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch subjects for user: $userId', e);
    }
  }

  /// Watches all non-deleted subjects for the given semester, alphabetical.
  Stream<List<SubjectEntity>> watchBySemester(
    String userId,
    String semesterId,
  ) {
    try {
      return (_database.select(_database.subjects)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.semesterId.equals(semesterId) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch subjects for semester: $semesterId', e);
    }
  }

  /// Gets non-deleted subjects for the given semester (one-time fetch).
  Future<List<SubjectEntity>> getBySemester(
    String userId,
    String semesterId,
  ) async {
    try {
      return await (_database.select(_database.subjects)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.semesterId.equals(semesterId) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();
    } catch (e) {
      throw DatabaseException('Failed to fetch subjects for semester: $semesterId', e);
    }
  }

  /// Watches a single non-deleted subject by ID.
  Stream<SubjectEntity?> watchById(String userId, String id) {
    try {
      return (_database.select(_database.subjects)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch subject: $id', e);
    }
  }

  /// Gets a non-deleted subject by ID (one-time fetch).
  Future<SubjectEntity?> getById(String userId, String id) async {
    try {
      return await (_database.select(_database.subjects)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to get subject: $id', e);
    }
  }

  /// Creates a new subject. Returns the new row's ID.
  Future<String> create(SubjectsCompanion data) async {
    try {
      final result =
          await _database.into(_database.subjects).insertReturning(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'subjects',
        recordId: result.id,
        operation: 'INSERT',
      );
      return result.id;
    } catch (e) {
      throw DatabaseException('Failed to create subject', e);
    }
  }

  /// Updates an existing subject.
  Future<void> update(
    String userId,
    String id,
    SubjectsCompanion data,
  ) async {
    try {
      await (_database.update(_database.subjects)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'subjects',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to update subject: $id', e);
    }
  }

  /// Soft-deletes a subject and performs cascade soft-deletes on all related
  /// timetable slots, attendance records, assignments, internal marks, and resources
  /// in a single transaction.
  Future<void> delete(String userId, String id) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await _database.transaction(() async {
        // 1. Soft-delete subject
        await (_database.update(_database.subjects)..where(
              (t) => t.userId.equals(userId) & t.id.equals(id),
            ))
            .write(SubjectsCompanion(deletedAt: Value(now)));

        // 2. Soft-delete related timetable entries
        await (_database.update(_database.timetable)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.subjectId.equals(id) &
                  t.deletedAt.isNull(),
            ))
            .write(TimetableCompanion(deletedAt: Value(now)));

        // 3. Soft-delete related attendance records
        await (_database.update(_database.attendance)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.subjectId.equals(id) &
                  t.deletedAt.isNull(),
            ))
            .write(AttendanceCompanion(deletedAt: Value(now)));

        // 4. Soft-delete related assignments
        await (_database.update(_database.assignments)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.subjectId.equals(id) &
                  t.deletedAt.isNull(),
            ))
            .write(AssignmentsCompanion(deletedAt: Value(now)));

        // 5. Soft-delete related internal marks
        await (_database.update(_database.internalMarks)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.subjectId.equals(id) &
                  t.deletedAt.isNull(),
            ))
            .write(InternalMarksCompanion(deletedAt: Value(now)));

        // 6. Soft-delete related resources
        await (_database.update(_database.resources)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.subjectId.equals(id) &
                  t.deletedAt.isNull(),
            ))
            .write(ResourcesCompanion(deletedAt: Value(now)));
      });
      await _syncQueueRepository?.enqueue(
        targetTable: 'subjects',
        recordId: id,
        operation: 'DELETE',
      );
    } catch (e) {
      throw DatabaseException('Failed to soft-delete subject: $id', e);
    }
  }
}
