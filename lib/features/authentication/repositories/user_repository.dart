/// User Repository
///
/// Drift-first write-through (Phase 4 §3): upserts the local `users`
/// table first, then fires a non-blocking Supabase upsert. Supabase
/// Auth owns authentication; the local users table is a download-only
/// projection (no sync queue — Phase 4 §2 justified exception).
library;

import 'dart:async';

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository responsible for synchronizing user data with Supabase.
///
/// Drift-first: writes to the local `users` table immediately, then
/// pushes to Supabase in a fire-and-forget call. The local table is
/// always up-to-date regardless of connectivity.
class UserRepository {
  UserRepository(this._database, this._client);

  static const String _tag = 'UserRepository';
  static const String _tableName = 'users';

  final AppDatabase _database;
  final SupabaseClient _client;

  /// Creates or updates the user record locally, then pushes to Supabase.
  ///
  /// Step 1 (Drift-first): upsert local immediately — UI can read the
  /// local row without waiting for Supabase.
  ///
  /// Step 2 (non-blocking): fire-and-forget Supabase upsert. Failure is
  /// logged; the app is offline-first.
  Future<void> upsertUser(AppUser user) async {
    final now = DateTime.now().toUtc();

    // 1. Local upsert — always succeeds (offline-first).
    await _database
        .into(_database.users)
        .insertOnConflictUpdate(
          UsersCompanion(
            id: Value(user.uid),
            name: Value(user.displayName),
            email: Value(user.email),
            profilePhoto: user.photoUrl != null
                ? Value(user.photoUrl)
                : const Value.absent(),
            updatedAt: Value(now),
          ),
        );

    // 2. Fire-and-forget Supabase upsert.
    unawaited(_supabaseUpsert(user, now));
  }

  /// Non-blocking Supabase push. Failure is logged silently — sync is
  /// retried on next app launch or auth state change.
  Future<void> _supabaseUpsert(AppUser user, DateTime now) async {
    try {
      await _client.from(_tableName).upsert({
        'id': user.uid,
        'name': user.displayName,
        'email': user.email,
        'profile_photo': user.photoUrl,
        'updated_at': now.toIso8601String(),
      }, onConflict: 'id');
      AppLogger.info('User profile synced to Supabase', tag: _tag);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Failed to sync user profile to Supabase',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
