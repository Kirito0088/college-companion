/// Internal Marks Repository
///
/// Handles CRUD and query operations for internal assessment scores.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for internal marks operations.
class InternalMarksRepository {
  /// Creates an [InternalMarksRepository] with the given [database] and optional [syncQueueRepository].
  InternalMarksRepository(this._database, [this._syncQueueRepository]);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;

  /// Watches all non-deleted internal marks for the given user, most recent first.
  Stream<List<InternalMarkEntity>> watchAll(String userId) {
    try {
      return (_database.select(_database.internalMarks)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch internal marks for user: $userId', e);
    }
  }

  /// Watches internal marks for a specific subject.
  Stream<List<InternalMarkEntity>> watchBySubject(
    String userId,
    String subjectId,
  ) {
    try {
      return (_database.select(_database.internalMarks)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.subjectId.equals(subjectId) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch internal marks for subject: $subjectId', e);
    }
  }

  /// Watches a single non-deleted internal mark by ID.
  Stream<InternalMarkEntity?> watchById(String userId, String id) {
    try {
      return (_database.select(_database.internalMarks)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch internal mark: $id', e);
    }
  }

  /// Gets a non-deleted internal mark by ID (one-time fetch).
  Future<InternalMarkEntity?> getById(String userId, String id) async {
    try {
      return await (_database.select(_database.internalMarks)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to get internal mark: $id', e);
    }
  }

  /// Creates a new internal mark. Returns the new row's ID.
  Future<String> create(InternalMarksCompanion data) async {
    try {
      final result =
          await _database.into(_database.internalMarks).insertReturning(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'internal_marks',
        recordId: result.id,
        operation: 'INSERT',
      );
      return result.id;
    } catch (e) {
      throw DatabaseException('Failed to create internal mark', e);
    }
  }

  /// Updates an existing internal mark.
  Future<void> update(
    String userId,
    String id,
    InternalMarksCompanion data,
  ) async {
    try {
      await (_database.update(_database.internalMarks)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'internal_marks',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to update internal mark: $id', e);
    }
  }

  /// Soft-deletes an internal mark.
  Future<void> delete(String userId, String id) async {
    try {
      await (_database.update(_database.internalMarks)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(
            InternalMarksCompanion(
              deletedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          );
      await _syncQueueRepository?.enqueue(
        targetTable: 'internal_marks',
        recordId: id,
        operation: 'DELETE',
      );
    } catch (e) {
      throw DatabaseException('Failed to soft-delete internal mark: $id', e);
    }
  }
}
