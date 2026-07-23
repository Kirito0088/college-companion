/// Assignments Repository
///
/// Handles CRUD and query operations for assignments.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/tables/assignments.dart';
import 'package:drift/drift.dart';

/// Repository for assignment operations.
class AssignmentRepository {
  /// Creates an [AssignmentRepository] with the given [database] and optional [syncQueueRepository].
  AssignmentRepository(this._database, [this._syncQueueRepository]);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;

  /// Watches all non-deleted assignments for the given user,
  /// soonest due first.
  Stream<List<AssignmentEntity>> watchAll(String userId) {
    try {
      return (_database.select(_database.assignments)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch assignments for user: $userId', e);
    }
  }

  /// Watches pending assignments, soonest due first.
  Stream<List<AssignmentEntity>> watchPending(String userId) {
    try {
      return (_database.select(_database.assignments)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.status.equals(AssignmentStatus.pending.name) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch pending assignments', e);
    }
  }

  /// Watches completed assignments, most recently completed first.
  Stream<List<AssignmentEntity>> watchCompleted(String userId) {
    try {
      return (_database.select(_database.assignments)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.status.equals(AssignmentStatus.completed.name) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch completed assignments', e);
    }
  }

  /// Watches assignments due on a specific calendar date.
  Stream<List<AssignmentEntity>> watchDueOn(String userId, DateTime date) {
    try {
      return (_database.select(_database.assignments)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.dueDate.equals(_dayKey(date)) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch assignments due on date', e);
    }
  }

  /// Watches pending assignments due on or before [end], soonest first.
  Stream<List<AssignmentEntity>> watchUpcoming(String userId, DateTime end) {
    try {
      return (_database.select(_database.assignments)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.status.equals(AssignmentStatus.pending.name) &
                  t.deletedAt.isNull() &
                  t.dueDate.isSmallerOrEqualValue(_dayKey(end)),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch upcoming assignments', e);
    }
  }

  /// Watches non-deleted assignments for a specific subject.
  Stream<List<AssignmentEntity>> watchBySubject(
    String userId,
    String subjectId,
  ) {
    try {
      return (_database.select(_database.assignments)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.subjectId.equals(subjectId) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch assignments for subject: $subjectId', e);
    }
  }

  /// Watches a single non-deleted assignment by ID.
  Stream<AssignmentEntity?> watchById(String userId, String id) {
    try {
      return (_database.select(_database.assignments)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch assignment: $id', e);
    }
  }

  /// Gets a non-deleted assignment by ID (one-time fetch).
  Future<AssignmentEntity?> getById(String userId, String id) async {
    try {
      return await (_database.select(_database.assignments)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to get assignment: $id', e);
    }
  }

  /// Creates a new assignment. Returns the new row's ID.
  Future<String> create(AssignmentsCompanion data) async {
    try {
      final result =
          await _database.into(_database.assignments).insertReturning(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'assignments',
        recordId: result.id,
        operation: 'INSERT',
      );
      return result.id;
    } catch (e) {
      throw DatabaseException('Failed to create assignment', e);
    }
  }

  /// Updates an existing assignment.
  Future<void> update(
    String userId,
    String id,
    AssignmentsCompanion data,
  ) async {
    try {
      await (_database.update(_database.assignments)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'assignments',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to update assignment: $id', e);
    }
  }

  /// Marks an assignment as completed now.
  Future<void> markCompleted(String userId, String id) async {
    try {
      await (_database.update(_database.assignments)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(
            AssignmentsCompanion(
              status: Value(AssignmentStatus.completed.name),
              completedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          );
      await _syncQueueRepository?.enqueue(
        targetTable: 'assignments',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to mark assignment completed: $id', e);
    }
  }

  /// Soft-deletes an assignment.
  Future<void> delete(String userId, String id) async {
    try {
      await (_database.update(_database.assignments)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(
            AssignmentsCompanion(
              deletedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          );
      await _syncQueueRepository?.enqueue(
        targetTable: 'assignments',
        recordId: id,
        operation: 'DELETE',
      );
    } catch (e) {
      throw DatabaseException('Failed to soft-delete assignment: $id', e);
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
