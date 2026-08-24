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

  /// User-entered college/institution name. Nullable until the user fills it in.
  TextColumn get collegeName => text().nullable()();

  /// User-entered academic branch/major. Nullable until the user fills it in.
  TextColumn get branch => text().nullable()();

  /// User-entered current semester. Nullable until the user fills it in.
  TextColumn get semester => text().nullable()();

  /// User-entered student ID. Nullable until the user fills it in.
  TextColumn get studentId => text().nullable()();

  /// User-entered university name. Nullable until the user fills it in.
  TextColumn get university => text().nullable()();

  /// User-entered course/degree name. Nullable until the user fills it in.
  TextColumn get course => text().nullable()();

  /// User-entered department name. Nullable until the user fills it in.
  TextColumn get department => text().nullable()();

  /// User-entered expected graduation year. Nullable until the user fills it in.
  TextColumn get graduationYear => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
