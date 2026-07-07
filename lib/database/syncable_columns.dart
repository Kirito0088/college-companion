/// Syncable Entity Convention — shared sync-metadata columns.
///
/// Architectural contract (Phase 4 §2 "Syncable Entity Convention"):
/// every syncable business table carries this standard block of columns
/// for per-row sync state tracking. The documentation is the contract;
/// deviations must be recorded as justified exceptions (Phase 4 §2).
///
/// This mixin shares only the column *declarations* at the
/// table-definition layer. The generated Drift data classes remain
/// independent — there is no shared base entity class and no inheritance
/// hierarchy, per the "composition over inheritance / no premature
/// abstraction" rule (CLAUDE.md, Phase 4 D6).
///
/// `deletedAt` is intentionally NOT part of this mixin because several
/// syncable tables are justified exceptions that never soft-delete:
/// - `lecture_records` — immutable ledger (spec §4 "No deletion")
/// - `user_settings` — 1:1 with the user, cascade-removed with the user
/// Tables that support soft delete add `deletedAt` explicitly.
library;

import 'package:drift/drift.dart';

/// Standard sync-metadata columns shared by every syncable business table.
///
/// Apply via `class MyTable extends Table with SyncableColumns`.
mixin SyncableColumns on Table {
  /// UTC creation timestamp.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// UTC last-modified timestamp — sync bookkeeping; bumped on every local
  /// write. Repositories set this explicitly (no local auto-touch trigger,
  /// to keep DateTime text-format consistency with Drift's reader).
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Per-row sync state: `pending`, `synced`, or `failed`.
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  /// Bumped on each local change; aids conflict detection (Phase 5).
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();

  /// Whether this row was created while offline (offline-first origin).
  BoolColumn get createdOffline =>
      boolean().withDefault(const Constant(true))();

  /// Timestamp of the last successful cloud push. NULL if never synced
  /// (spec §11 "Sync timestamp").
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
