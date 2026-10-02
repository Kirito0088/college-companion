/// User Settings Repository
///
/// Handles CRUD and reactive stream operations for user settings in Drift database.
library;

import 'dart:convert';

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
      return (_database.select(
        _database.userSettings,
      )..where((t) => t.userId.equals(userId))).watchSingleOrNull();
    } catch (e) {
      throw DatabaseException(
        'Failed to watch user settings for user: $userId',
        e,
      );
    }
  }

  /// Gets user settings for a given [userId] (one-time fetch).
  Future<UserSettingsEntity?> getByUserId(String userId) async {
    try {
      return await (_database.select(
        _database.userSettings,
      )..where((t) => t.userId.equals(userId))).getSingleOrNull();
    } catch (e) {
      throw DatabaseException(
        'Failed to get user settings for user: $userId',
        e,
      );
    }
  }

  /// Theme a newly created row starts with: follow the device, matching
  /// `AppThemePreference.fallback` before any row exists.
  ///
  /// Written explicitly because the column's SQL default is `'dark'`, and
  /// SQLite bakes that into existing tables, so changing it in the schema
  /// would not reach installed databases (#37).
  static const String defaultTheme = 'system';

  /// Returns [userId]'s settings row, creating it first if there is none.
  ///
  /// Every settings write goes through this, so a first write (an accent
  /// pick, a toggle) changes only the setting it targets instead of
  /// inheriting column defaults for the rest of the row.
  Future<UserSettingsEntity> ensureForUser(String userId) async {
    final existing = await getByUserId(userId);
    if (existing != null) return existing;

    final id = 'settings_$userId';
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      // insertOrIgnore, not an upsert: if a concurrent first write created
      // the row in between, keep whatever it wrote.
      await _database
          .into(_database.userSettings)
          .insert(
            UserSettingsCompanion.insert(
              id: id,
              userId: userId,
              theme: const Value(defaultTheme),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      await _syncQueueRepository?.enqueue(
        targetTable: 'user_settings',
        recordId: id,
        operation: 'INSERT',
      );
    } catch (e) {
      throw DatabaseException(
        'Failed to create user settings for user: $userId',
        e,
      );
    }
    return (await getByUserId(userId))!;
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
      await (_database.update(
        _database.userSettings,
      )..where((t) => t.userId.equals(userId))).write(
        UserSettingsCompanion(theme: Value(theme), updatedAt: Value(now)),
      );
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

  /// Updates the accent color preference for a user (ADR-011).
  ///
  /// Stored inside the `preferences` JSONB catch-all column (rather than a
  /// new dedicated column) since it's exactly the "extensible, evolving
  /// preference" the column's docstring describes — no schema migration
  /// needed.
  Future<void> updateAccent(String userId, String accent) async {
    try {
      final existing = await getByUserId(userId);
      if (existing == null) {
        throw DatabaseException(
          'Cannot update accent: no settings row for user: $userId',
        );
      }
      final preferences = Map<String, dynamic>.from(
        jsonDecode(existing.preferences) as Map,
      )..['accent'] = accent;
      final now = DateTime.now().toUtc().toIso8601String();
      await (_database.update(
        _database.userSettings,
      )..where((t) => t.userId.equals(userId))).write(
        UserSettingsCompanion(
          preferences: Value(jsonEncode(preferences)),
          updatedAt: Value(now),
        ),
      );
      await _syncQueueRepository?.enqueue(
        targetTable: 'user_settings',
        recordId: existing.id,
        operation: 'UPDATE',
      );
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to update accent for user: $userId', e);
    }
  }

  /// Updates notifications enabled state for a user.
  Future<void> updateNotificationsEnabled(String userId, bool enabled) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await (_database.update(
        _database.userSettings,
      )..where((t) => t.userId.equals(userId))).write(
        UserSettingsCompanion(
          notificationsEnabled: Value(enabled),
          updatedAt: Value(now),
        ),
      );
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

  /// Updates lecture reminders enabled state for a user.
  Future<void> updateLectureRemindersEnabled(
    String userId,
    bool enabled,
  ) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await (_database.update(
        _database.userSettings,
      )..where((t) => t.userId.equals(userId))).write(
        UserSettingsCompanion(
          lectureRemindersEnabled: Value(enabled),
          updatedAt: Value(now),
        ),
      );
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
        'Failed to update lecture reminders enabled for user: $userId',
        e,
      );
    }
  }
}
