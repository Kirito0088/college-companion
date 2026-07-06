/// User Repository
///
/// Handles Supabase user profile synchronization.
/// Supabase Auth owns authentication. Supabase owns data storage.
/// This repository only stores the minimum user information
/// documented in `backend/database.md`.
library;

import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository responsible for synchronizing user data with Supabase.
///
/// Uses upsert to create or update the user record.
/// Respects Row Level Security (per backend/security.md).
class UserRepository {
  /// Creates a [UserRepository] with the given Supabase [client].
  const UserRepository(this._client);

  static const String _tag = 'UserRepository';
  static const String _tableName = 'users';

  final SupabaseClient _client;

  /// Creates or updates the user record in Supabase.
  ///
  /// Stores only: uid, display name, email, profile photo URL.
  /// Uses upsert with the Supabase UID as the conflict key.
  Future<void> upsertUser(AppUser user) async {
    try {
      await _client.from(_tableName).upsert({
        'id': user.uid,
        'name': user.displayName,
        'email': user.email,
        'profile_photo': user.photoUrl,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'id');
      AppLogger.info('User profile synced to Supabase', tag: _tag);
    } on Exception catch (error, stackTrace) {
      // Supabase sync failure should not prevent the user from using the app.
      // The app is offline-first — authentication is handled by Supabase Auth.
      AppLogger.error(
        'Failed to sync user profile to Supabase',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
