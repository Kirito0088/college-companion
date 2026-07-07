/// Sync Queue DAO
///
/// Owns **all queue-level operations** for the local-only `sync_queue`
/// table. UI/feature code never touches this DAO directly — repositories
/// call `SyncRepository.enqueue()`, which delegates here.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Queue operations for the local sync queue.
class SyncQueueDao {
  SyncQueueDao(this._database);

  final AppDatabase _database;

  /// Enqueues a new sync operation. Merges duplicates — if a pending
  /// entry already exists for the same (recordId, table) pair, the
  /// existing one is left in place (Phase 5 batching deduplicates).
  Future<void> enqueue({
    required String tableName,
    required String recordId,
    required String operation,
  }) async {
    // Check for an existing pending entry for this record.
    final existing =
        await (_database.select(_database.syncQueueItems)..where(
              (t) =>
                  t.recordId.equals(recordId) &
                  t.operation.equals(operation) &
                  t.isSynced.equals(false),
            ))
            .getSingleOrNull();

    if (existing != null) return; // merge duplicate

    await _database
        .into(_database.syncQueueItems)
        .insert(
          SyncQueueItemsCompanion(
            recordId: Value(recordId),
            operation: Value(operation),
          ),
        );
  }

  /// Fetches the next batch of pending operations, ordered by creation
  /// time (FIFO), up to [limit].
  Future<List<SyncQueueItem>> fetchPending({int limit = 50}) {
    return (_database.select(_database.syncQueueItems)
          ..where((t) => t.isSynced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Marks a queue entry as synced.
  Future<void> markSynced(int id) {
    return (_database.update(_database.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .write(const SyncQueueItemsCompanion(isSynced: Value(true)));
  }

  /// Records a failed sync attempt (stores the error message and
  /// last-attempt timestamp). Note that `retryCount` is not bumped here —
  /// Drift Companions can't express `retry_count = retry_count + 1`.
  /// The Phase 5 sync engine will use `customStatement` for that.
  Future<void> recordError(int id, String error) {
    return (_database.update(
      _database.syncQueueItems,
    )..where((t) => t.id.equals(id))).write(
      SyncQueueItemsCompanion(
        error: Value(error),
        lastAttempt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Removes all synced entries older than [before].
  Future<void> purgeSynced(DateTime before) {
    return (_database.delete(_database.syncQueueItems)..where(
          (t) =>
              t.isSynced.equals(true) & t.createdAt.isSmallerThanValue(before),
        ))
        .go();
  }

  /// Counts pending operations.
  Future<int> getPendingCount() {
    final query = _database.selectOnly(_database.syncQueueItems)
      ..addColumns([_database.syncQueueItems.id.count()])
      ..where(_database.syncQueueItems.isSynced.equals(false));

    final countExpr = _database.syncQueueItems.id.count();
    return query.map((row) => row.read(countExpr)!).getSingle();
  }
}
