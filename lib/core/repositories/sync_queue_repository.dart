/// Sync Queue Repository
///
/// Handles adding, querying, and updating offline sync operations in Drift.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for sync queue operations.
class SyncQueueRepository {
  /// Creates a [SyncQueueRepository] with the given [database].
  SyncQueueRepository(this._database);

  final AppDatabase _database;

  /// Enqueues a sync operation for a business record.
  Future<int> enqueue({
    required String targetTable,
    required String recordId,
    required String operation,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    return _database.into(_database.syncQueueItems).insert(
          SyncQueueItemsCompanion.insert(
            targetTable: targetTable,
            recordId: recordId,
            operation: operation,
            createdAt: now,
          ),
        );
  }

  /// Fetches pending unsynced queue items ordered by creation time.
  Future<List<SyncQueueItem>> getPendingItems({int limit = 50}) {
    return (_database.select(_database.syncQueueItems)
          ..where((t) => t.isSynced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Marks a sync queue item as successfully synced.
  Future<void> markSynced(int id) {
    return (_database.update(_database.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .write(const SyncQueueItemsCompanion(
      isSynced: Value(true),
    ));
  }

  /// Increments retry count and records error message for a failed sync item.
  Future<void> recordFailure(int id, String errorMessage, int currentRetries) {
    final now = DateTime.now().toUtc().toIso8601String();
    return (_database.update(_database.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .write(SyncQueueItemsCompanion(
      retryCount: Value(currentRetries + 1),
      lastAttempt: Value(now),
      error: Value(errorMessage),
    ));
  }

  /// Deletes synced items older than a specified date to keep queue table lean.
  Future<int> purgeSyncedItems() {
    return (_database.delete(_database.syncQueueItems)
          ..where((t) => t.isSynced.equals(true)))
        .go();
  }
}
