/// Users Table
///
/// Stores user profile information synced from Supabase Auth.
/// This table mirrors the Supabase users table for local access.
library;

import 'package:drift/drift.dart';

/// A user profile record.
///
/// Matches Supabase schema in supabase/migrations/00001_mvp_foundation.sql
@TableIndex(name: 'idx_users_id', columns: {#id})
@DataClassName('UserEntity')
class Users extends Table {
  /// Supabase user ID (text, not UUID).
  TextColumn get id => text()();

  /// User's display name from Google account.
  TextColumn get name => text()();

  /// User's email address from Google account.
  TextColumn get email => text()();

  /// Google profile photo URL. Nullable.
  TextColumn get profilePhoto => text().nullable()();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get createdAt => text()();

  /// ISO 8601 formatted UTC timestamp.
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
