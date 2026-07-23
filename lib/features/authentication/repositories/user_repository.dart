/// User Repository
///
/// Handles user profile storage in local SQLite (via Drift) and
/// synchronization with Supabase Auth / database.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository responsible for offline-first user profile operations.
class UserRepository {
  /// Creates a [UserRepository] with local [database] and optional Supabase [client] and [syncQueueRepository].
  UserRepository(this._database, [this._client, this._syncQueueRepository]);

  static const String _tag = 'UserRepository';
  static const String _tableName = 'users';

  final AppDatabase _database;
  final SupabaseClient? _client;
  final SyncQueueRepository? _syncQueueRepository;

  /// Creates or updates the user record in local SQLite, then syncs to Supabase.
  Future<void> upsertUser(AppUser user) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final companion = UsersCompanion(
      id: Value(user.uid),
      name: Value(user.displayName),
      email: Value(user.email),
      profilePhoto: Value(user.photoUrl),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    try {
      await _database.into(_database.users).insertOnConflictUpdate(companion);
      AppLogger.info('User profile saved to local SQLite', tag: _tag);
      await _syncQueueRepository?.enqueue(
        targetTable: 'users',
        recordId: user.uid,
        operation: 'UPDATE',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to save user profile to local SQLite',
        error: e,
        stackTrace: st,
      );
      throw DatabaseException('Failed to upsert user profile locally', e);
    }

    if (_client != null) {
      try {
        await _client.from(_tableName).upsert({
          'id': user.uid,
          'name': user.displayName,
          'email': user.email,
          'profile_photo': user.photoUrl,
          'updated_at': now,
        }, onConflict: 'id');
        AppLogger.info('User profile synced to Supabase', tag: _tag);
      } on Exception catch (error, stackTrace) {
        AppLogger.error(
          'Failed to sync user profile to Supabase (non-blocking)',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Creates a new user row in local SQLite.
  Future<String> create(UsersCompanion data) async {
    try {
      final result =
          await _database.into(_database.users).insertReturning(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'users',
        recordId: result.id,
        operation: 'INSERT',
      );
      return result.id;
    } catch (e) {
      throw DatabaseException('Failed to create user', e);
    }
  }

  /// Gets a user profile by ID from local SQLite (one-time fetch).
  Future<UserEntity?> getUserById(String id) async {
    return getById(id);
  }

  /// Gets a user profile by ID from local SQLite (one-time fetch).
  Future<UserEntity?> getById(String id) async {
    try {
      return await (_database.select(_database.users)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to fetch user by id: $id', e);
    }
  }

  /// Watches a single user profile by ID from local SQLite.
  Stream<UserEntity?> watchUser(String id) {
    return watchById(id);
  }

  /// Watches a single user profile by ID from local SQLite.
  Stream<UserEntity?> watchById(String id) {
    try {
      return (_database.select(_database.users)
            ..where((t) => t.id.equals(id)))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch user by id: $id', e);
    }
  }

  /// Watches all user profiles in local SQLite.
  Stream<List<UserEntity>> watchAll() {
    try {
      return (_database.select(_database.users)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch all users', e);
    }
  }

  /// Updates an existing user profile in local SQLite.
  Future<void> update(String id, UsersCompanion data) async {
    try {
      await (_database.update(_database.users)
            ..where((t) => t.id.equals(id)))
          .write(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'users',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to update user: $id', e);
    }
  }

  /// Deletes a user profile from local SQLite.
  Future<void> delete(String id) async {
    try {
      await (_database.delete(_database.users)
            ..where((t) => t.id.equals(id)))
          .go();
      await _syncQueueRepository?.enqueue(
        targetTable: 'users',
        recordId: id,
        operation: 'DELETE',
      );
    } catch (e) {
      throw DatabaseException('Failed to delete user: $id', e);
    }
  }
}
