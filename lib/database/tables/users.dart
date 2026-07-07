/// Users Table
///
/// Stores user profile information synced from Supabase Auth. This table
/// mirrors the Supabase users table for local (offline-first) access.
///
/// A download-only projection of Supabase Auth (Phase 4 §2 justified
/// exception): `UserRepository` upserts directly and never pushes through
/// the sync queue, so it carries only `createdAt`/`updatedAt` (no
/// sync-status block).
library;

import 'package:drift/drift.dart';

/// A user profile record.
///
/// Mirrors the Supabase schema in `supabase/migrations/00001_mvp_foundation.sql`.
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

  /// UTC creation timestamp.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// UTC last-modified timestamp.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
