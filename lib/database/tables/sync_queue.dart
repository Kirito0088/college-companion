/// Sync Queue Table (LOCAL-ONLY — never synced)
///
/// Tracks pending synchronization operations. Per Phase 4 D3 (dual sync
/// model), per-row sync metadata lives on business tables; **this** queue
/// owns ordering / retry / batching / background sync.
///
/// Local-only tracking with its own lifecycle columns — not a business
/// entity, so it carries **no** sync-metadata block (Phase 4 §2 exception).
library;

import 'package:drift/drift.dart';

/// Sync operation status.
enum SyncOperationStatus { pending, syncing, failed }

/// The sync queue tracks local changes pending synchronization to Supabase.
///
/// Key design decisions:
/// - No payload storage — read current row state from business tables.
/// - Merge duplicate operations for the same record.
/// - Queue survives app restarts.
///
/// The SQL table name is `sync_queue` (not `sync_queue_items`) via the
/// explicit `tableName` override so queue entries reference business tables
/// by their canonical names; `tableName` here refers to the *target* table
/// of an operation.
@TableIndex(name: 'idx_sync_queue_record_id', columns: {#recordId})
@TableIndex(name: 'idx_sync_queue_operation', columns: {#operation})
@TableIndex(name: 'idx_sync_queue_status', columns: {#isSynced})
@TableIndex(
  name: 'idx_sync_queue_pending',
  columns: {#recordId, #isSynced, #retryCount},
)
class SyncQueueItems extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// The UUID of the record in the business table.
  TextColumn get recordId => text()();

  /// The operation type: 'INSERT', 'UPDATE', or 'DELETE'.
  TextColumn get operation => text()();

  /// Number of sync attempts (starts at 0).
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// UTC creation timestamp.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// UTC timestamp of the last attempt, or NULL if never attempted.
  DateTimeColumn get lastAttempt => dateTime().nullable()();

  /// Error message if the last attempt failed.
  TextColumn get error => text().nullable()();

  /// Whether the operation has been synced.
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  String get tableName => 'sync_queue';
}
