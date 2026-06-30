/// Sync Queue Table
///
/// Tracks pending synchronization operations.
/// Sync state is kept entirely in this table —
/// business tables contain only business data.
library;

import 'package:drift/drift.dart';

/// Sync operation status.
enum SyncOperationStatus { pending, syncing, failed }

/// The sync queue table tracks all local changes
/// that need to be synchronized to Supabase.
///
/// Key design decision:
/// - No payload storage — read current row state from business tables
/// - Merge duplicate operations for the same record
/// - Queue survives app restarts
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

  /// The name of the business table (e.g., 'semesters', 'subjects').
  @override
  String get tableName => 'sync_queue';

  /// The UUID of the record in the business table.
  TextColumn get recordId => text()();

  /// The operation type: 'INSERT', 'UPDATE', or 'DELETE'.
  TextColumn get operation => text()();

  /// Number of sync attempts (starts at 0).
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// ISO 8601 formatted timestamp.
  TextColumn get createdAt => text()();

  /// ISO 8601 formatted timestamp, NULL if never attempted.
  TextColumn get lastAttempt => text().nullable()();

  /// Error message if the last attempt failed.
  TextColumn get error => text().nullable()();

  /// Whether the operation has been synced.
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
