/// Sync Metadata DAO
///
/// Local-only key/value bookkeeping store for the sync engine.
/// Stores per-table cursors, pull timestamps, and watermark pointers.
/// Never imported by UI/feature code.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Key/value operations for the local-only `sync_metadata` store.
class SyncMetadataDao {
  SyncMetadataDao(this._database);

  final AppDatabase _database;

  /// Gets the value for a bookkeeping [key], or null.
  Future<String?> get(String key) async {
    final row = await (_database.select(
      _database.syncMetadata,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// Sets (inserts or replaces) a key/value pair.
  Future<void> set(String key, String value) {
    return _database
        .into(_database.syncMetadata)
        .insertOnConflictUpdate(
          SyncMetadataCompanion(
            key: Value(key),
            value: Value(value),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  /// Deletes a bookkeeping key.
  Future<void> delete(String key) {
    return (_database.delete(
      _database.syncMetadata,
    )..where((t) => t.key.equals(key))).go();
  }
}
