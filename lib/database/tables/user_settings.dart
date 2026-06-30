/// User Settings Table
///
/// Stores per-user application preferences.
/// Exactly one row per user (UNIQUE on user_id).
library;

import 'package:drift/drift.dart';

/// User settings record.
///
/// Matches Supabase schema in supabase/migrations/00001_mvp_foundation.sql
///
/// Hybrid approach: structured columns for stable, queryable settings;
/// JSONB (stored as text) for extensible, evolving preferences.
@DataClassName('UserSettingsEntity')
class UserSettings extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Owner — 1:1 relationship with users.
  /// UNIQUE ensures one settings row per user.
  TextColumn get userId => text()();

  /// Whether push notifications are enabled.
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Map of module names to enabled booleans.
  /// Stored as JSON string (e.g., {"attendance": true, "assignments": true}).
  TextColumn get enabledModules => text().withDefault(const Constant('{}'))();

  /// UI theme preference. Defaults to 'dark'.
  TextColumn get theme => text().withDefault(const Constant('dark'))();

  /// Flexible JSONB catch-all for future user preferences.
  TextColumn get preferences => text().withDefault(const Constant('{}'))();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get createdAt => text()();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
