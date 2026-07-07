/// Sync Repository
///
/// Owns the sync queue and metadata bookkeeping (Phase 4 §3).
/// Exposes enqueue / fetchPending / markSynced / recordError.
///
/// Repositories call `enqueue()` after every local write; the Phase 5
/// sync engine consumes the queue and calls `markSynced()` / `recordError()`
/// as it pushes to Supabase.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/sync_queue_dao.dart';
import 'package:college_companion/database/daos/sync_metadata_dao.dart';

/// Central sync operations — queuing writes to sync and bookkeeping.
class SyncRepository {
  SyncRepository(this._queueDao, this._metadataDao);

  final SyncQueueDao _queueDao;
  final SyncMetadataDao _metadataDao;

  /// Enqueues a local write for eventual cloud push (Phase 4 enqueues;
  /// Phase 5 engine executes).
  Future<void> enqueue({
    required String tableName,
    required String recordId,
    required String operation,
  }) {
    return _queueDao.enqueue(
      tableName: tableName,
      recordId: recordId,
      operation: operation,
    );
  }

  /// Fetches the next batch of pending sync ops.
  Future<List<SyncQueueItem>> fetchPending({int limit = 50}) {
    return _queueDao.fetchPending(limit: limit);
  }

  /// Marks a queue entry as synced (called by the Phase 5 engine after a
  /// successful Supabase push, after also calling
  /// `LectureRecordDao.updateSyncState()` on the affected record).
  Future<void> markSynced(int queueId) => _queueDao.markSynced(queueId);

  /// Records an error on a failed queue entry.
  Future<void> recordError(int queueId, String error) =>
      _queueDao.recordError(queueId, error);

  /// Gets a sync-metadata bookkeeping value.
  Future<String?> getMetadata(String key) => _metadataDao.get(key);

  /// Sets a sync-metadata bookkeeping value.
  Future<void> setMetadata(String key, String value) =>
      _metadataDao.set(key, value);
}
