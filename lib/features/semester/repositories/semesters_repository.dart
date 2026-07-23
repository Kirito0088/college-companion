/// Semester Repository
///
/// Handles CRUD operations for semesters.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for semester operations.
class SemesterRepository {
  /// Creates a [SemesterRepository] with the given [database] and optional [syncQueueRepository].
  SemesterRepository(this._database, [this._syncQueueRepository]);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;

  /// Watches all non-deleted semesters for the given user.
  Stream<List<SemesterEntity>> watchAll(String userId) {
    try {
      return (_database.select(_database.semesters)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch semesters for user: $userId', e);
    }
  }

  /// Watches a single non-deleted semester by ID.
  Stream<SemesterEntity?> watchById(String userId, String id) {
    try {
      return (_database.select(_database.semesters)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch semester: $id', e);
    }
  }

  /// Gets a non-deleted semester by ID (one-time fetch).
  Future<SemesterEntity?> getById(String userId, String id) async {
    try {
      return await (_database.select(_database.semesters)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to get semester: $id', e);
    }
  }

  /// Creates a new semester.
  Future<String> create(SemestersCompanion data) async {
    try {
      final result =
          await _database.into(_database.semesters).insertReturning(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'semesters',
        recordId: result.id,
        operation: 'INSERT',
      );
      return result.id;
    } catch (e) {
      throw DatabaseException('Failed to create semester', e);
    }
  }

  /// Updates an existing semester.
  Future<void> update(
    String userId,
    String id,
    SemestersCompanion data,
  ) async {
    try {
      await (_database.update(_database.semesters)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'semesters',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to update semester: $id', e);
    }
  }

  /// Soft-deletes a semester and performs cascade soft-deletes on all related
  /// subjects, timetable slots, attendance, assignments, internal marks, and resources.
  Future<void> delete(String userId, String id) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await _database.transaction(() async {
        // 1. Soft-delete the semester
        await (_database.update(_database.semesters)
              ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
            .write(SemestersCompanion(deletedAt: Value(now)));

        // 2. Find all active subjects in this semester
        final subjects = await (_database.select(_database.subjects)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.semesterId.equals(id) &
                  t.deletedAt.isNull(),
            ))
            .get();

        final subjectIds = subjects.map((s) => s.id).toList();

        // 3. Soft-delete all subjects in this semester
        await (_database.update(_database.subjects)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.semesterId.equals(id) &
                  t.deletedAt.isNull(),
            ))
            .write(SubjectsCompanion(deletedAt: Value(now)));

        // 4. Cascade soft-delete for related tables
        if (subjectIds.isNotEmpty) {
          await (_database.update(_database.timetable)..where(
                (t) =>
                    t.userId.equals(userId) &
                    t.subjectId.isIn(subjectIds) &
                    t.deletedAt.isNull(),
              ))
              .write(TimetableCompanion(deletedAt: Value(now)));

          await (_database.update(_database.attendance)..where(
                (t) =>
                    t.userId.equals(userId) &
                    t.subjectId.isIn(subjectIds) &
                    t.deletedAt.isNull(),
              ))
              .write(AttendanceCompanion(deletedAt: Value(now)));

          await (_database.update(_database.assignments)..where(
                (t) =>
                    t.userId.equals(userId) &
                    t.subjectId.isIn(subjectIds) &
                    t.deletedAt.isNull(),
              ))
              .write(AssignmentsCompanion(deletedAt: Value(now)));

          await (_database.update(_database.internalMarks)..where(
                (t) =>
                    t.userId.equals(userId) &
                    t.subjectId.isIn(subjectIds) &
                    t.deletedAt.isNull(),
              ))
              .write(InternalMarksCompanion(deletedAt: Value(now)));

          await (_database.update(_database.resources)..where(
                (t) =>
                    t.userId.equals(userId) &
                    t.subjectId.isIn(subjectIds) &
                    t.deletedAt.isNull(),
              ))
              .write(ResourcesCompanion(deletedAt: Value(now)));
        }
      });
      await _syncQueueRepository?.enqueue(
        targetTable: 'semesters',
        recordId: id,
        operation: 'DELETE',
      );
    } catch (e) {
      throw DatabaseException('Failed to soft-delete semester: $id', e);
    }
  }

  /// Watches the current (active) semester.
  Stream<SemesterEntity?> watchCurrent(String userId) {
    try {
      return (_database.select(_database.semesters)..where(
            (t) =>
                t.userId.equals(userId) &
                t.isCurrent.equals(true) &
                t.deletedAt.isNull(),
          ))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch current semester for user: $userId', e);
    }
  }

  /// Sets a semester as current (unsets others first).
  ///
  /// Verifies the requested semester exists before modifying any rows.
  /// The entire operation is transactional.
  Future<void> setCurrent(String userId, String id) async {
    try {
      final semester = await (_database.select(_database.semesters)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .getSingleOrNull();

      if (semester == null) return;

      await _database.transaction(() async {
        // Unset all current semesters for this user (only non-deleted ones).
        await (_database.update(_database.semesters)
              ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull()))
            .write(const SemestersCompanion(isCurrent: Value(false)));

        // Set the specified semester as current.
        await (_database.update(_database.semesters)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.id.equals(id) &
                  t.deletedAt.isNull(),
            ))
            .write(const SemestersCompanion(isCurrent: Value(true)));
      });
      await _syncQueueRepository?.enqueue(
        targetTable: 'semesters',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to set current semester: $id', e);
    }
  }
}
