/// User Settings Repository
///
/// Handles CRUD and reactive stream operations for user settings in Drift database.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for managing per-user application preferences.
class UserSettingsRepository {
  /// Creates a [UserSettingsRepository] with the given [database] and optional [syncQueueRepository].
  UserSettingsRepository(this._database, [this._syncQueueRepository]);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;

  /// Watches user settings for a given [userId].
  Stream<UserSettingsEntity?> watchByUserId(String userId) {
    try {
      return (_database.select(_database.userSettings)
            ..where((t) => t.userId.equals(userId)))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch user settings for user: $userId', e);
    }
  }

  /// Gets user settings for a given [userId] (one-time fetch).
  Future<UserSettingsEntity?> getByUserId(String userId) async {
    try {
      return await (_database.select(_database.userSettings)
            ..where((t) => t.userId.equals(userId)))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to get user settings for user: $userId', e);
    }
  }

  /// Upserts user settings for a given user.
  Future<void> saveSettings(UserSettingsCompanion settings) async {
    try {
      await _database
          .into(_database.userSettings)
          .insertOnConflictUpdate(settings);
      if (settings.id.present) {
        await _syncQueueRepository?.enqueue(
          targetTable: 'user_settings',
          recordId: settings.id.value,
          operation: 'UPDATE',
        );
      }
    } catch (e) {
      throw DatabaseException('Failed to save user settings', e);
    }
  }

  /// Updates theme preference for a user.
  Future<void> updateTheme(String userId, String theme) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await (_database.update(_database.userSettings)
            ..where((t) => t.userId.equals(userId)))
          .write(UserSettingsCompanion(
            theme: Value(theme),
            updatedAt: Value(now),
          ));
      final existing = await getByUserId(userId);
      if (existing != null) {
        await _syncQueueRepository?.enqueue(
          targetTable: 'user_settings',
          recordId: existing.id,
          operation: 'UPDATE',
        );
      }
    } catch (e) {
      throw DatabaseException('Failed to update theme for user: $userId', e);
    }
  }

  /// Updates notifications enabled state for a user.
  Future<void> updateNotificationsEnabled(String userId, bool enabled) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await (_database.update(_database.userSettings)
            ..where((t) => t.userId.equals(userId)))
          .write(UserSettingsCompanion(
            notificationsEnabled: Value(enabled),
            updatedAt: Value(now),
          ));
      final existing = await getByUserId(userId);
      if (existing != null) {
        await _syncQueueRepository?.enqueue(
          targetTable: 'user_settings',
          recordId: existing.id,
          operation: 'UPDATE',
        );
      }
    } catch (e) {
      throw DatabaseException(
        'Failed to update notifications enabled for user: $userId',
        e,
      );
    }
  }
}
