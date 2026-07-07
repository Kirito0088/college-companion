/// User Settings Table
///
/// Stores per-user application preferences. Exactly one row per user
/// (`UNIQUE` on `user_id`).
///
/// Carries the standard sync-metadata block (Phase 4 §2) via
/// [SyncableColumns], **without** `deletedAt` — settings are 1:1 with the
/// user and cascade-removed with the user (Phase 4 §2 justified exception,
/// matching the cloud schema in `00001_mvp_foundation.sql` which also has
/// no `deleted_at` on `user_settings`).
library;

import 'package:college_companion/database/syncable_columns.dart';
import 'package:drift/drift.dart';

/// User settings record.
///
/// Mirrors the Supabase schema in `supabase/migrations/00001_mvp_foundation.sql`
/// (business columns); local sync-metadata columns are local-only tracking.
///
/// Hybrid approach: structured columns for stable, queryable settings;
/// JSON-stored text for extensible, evolving preferences.
@DataClassName('UserSettingsEntity')
class UserSettings extends Table with SyncableColumns {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Owner — 1:1 relationship with users. UNIQUE ensures one settings row
  /// per user (repair of the Phase 4 §A6 "missing user_settings UNIQUE" defect).
  TextColumn get userId => text()();

  /// Whether push notifications are enabled.
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Map of module names to enabled booleans.
  /// Stored as JSON text (e.g., `{"attendance": true, "assignments": true}`).
  TextColumn get enabledModules => text().withDefault(const Constant('{}'))();

  /// UI theme preference. Defaults to 'dark'.
  TextColumn get theme => text().withDefault(const Constant('dark'))();

  /// Flexible JSON catch-all for future user preferences.
  TextColumn get preferences => text().withDefault(const Constant('{}'))();

  // NOTE: No deletedAt — see the module doc comment (1:1 with user, never
  // independently soft-deleted).

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId},
  ];
}
