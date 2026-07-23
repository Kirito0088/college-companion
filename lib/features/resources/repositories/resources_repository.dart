/// Resources Repository
///
/// Handles CRUD and query operations for study materials and links.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for resource operations.
class ResourcesRepository {
  /// Creates a [ResourcesRepository] with the given [database] and optional [syncQueueRepository].
  ResourcesRepository(this._database, [this._syncQueueRepository]);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;

  /// Watches all non-deleted resources for the given user, most recent first.
  Stream<List<ResourceEntity>> watchAll(String userId) {
    try {
      return (_database.select(_database.resources)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch resources for user: $userId', e);
    }
  }

  /// Watches resources belonging to a specific subject.
  Stream<List<ResourceEntity>> watchBySubject(
    String userId,
    String subjectId,
  ) {
    try {
      return (_database.select(_database.resources)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.subjectId.equals(subjectId) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch resources for subject: $subjectId', e);
    }
  }

  /// Watches resources of a specific category (e.g. past_papers, notes, syllabus).
  Stream<List<ResourceEntity>> watchByCategory(
    String userId,
    String category,
  ) {
    try {
      return (_database.select(_database.resources)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.category.equals(category) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch resources for category: $category', e);
    }
  }

  /// Watches a single non-deleted resource by ID.
  Stream<ResourceEntity?> watchById(String userId, String id) {
    try {
      return (_database.select(_database.resources)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch resource: $id', e);
    }
  }

  /// Gets a non-deleted resource by ID (one-time fetch).
  Future<ResourceEntity?> getById(String userId, String id) async {
    try {
      return await (_database.select(_database.resources)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to get resource: $id', e);
    }
  }

  /// Creates a new resource. Returns the new row's ID.
  Future<String> create(ResourcesCompanion data) async {
    try {
      final result =
          await _database.into(_database.resources).insertReturning(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'resources',
        recordId: result.id,
        operation: 'INSERT',
      );
      return result.id;
    } catch (e) {
      throw DatabaseException('Failed to create resource', e);
    }
  }

  /// Updates an existing resource.
  Future<void> update(
    String userId,
    String id,
    ResourcesCompanion data,
  ) async {
    try {
      await (_database.update(_database.resources)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'resources',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to update resource: $id', e);
    }
  }

  /// Soft-deletes a resource.
  Future<void> delete(String userId, String id) async {
    try {
      await (_database.update(_database.resources)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(
            ResourcesCompanion(
              deletedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          );
      await _syncQueueRepository?.enqueue(
        targetTable: 'resources',
        recordId: id,
        operation: 'DELETE',
      );
    } catch (e) {
      throw DatabaseException('Failed to soft-delete resource: $id', e);
    }
  }
}
