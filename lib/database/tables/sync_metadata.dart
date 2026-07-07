/// Sync Metadata Table (LOCAL-ONLY — never synced)
///
/// A local-only key/value bookkeeping store for the sync engine
/// (Phase 4 §3 / §2 exceptions table): per-table cursors, the last
/// successful pull timestamp, watermark pointers. Not a business entity.
library;

import 'package:drift/drift.dart';

/// A sync-engine key/value bookkeeping row.
@DataClassName('SyncMetadataEntity')
class SyncMetadata extends Table {
  /// Stable bookkeeping key (e.g. "pull_cursor:timetable",
  /// "last_pull_at").
  TextColumn get key => text()();

  /// Bookkeeping value (opaque to the schema).
  TextColumn get value => text().nullable()();

  /// When this row was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};

  @override
  String get tableName => 'sync_metadata';
}
