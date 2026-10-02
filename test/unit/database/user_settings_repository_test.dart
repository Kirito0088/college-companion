import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/settings/models/notification_preferences.dart';
import 'package:college_companion/features/settings/repositories/user_settings_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late UserSettingsRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    repository = UserSettingsRepository(database, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'saveSettings and getByUserId saves settings and enqueues sync UPDATE',
    () async {
      final now = DateTime.now().toUtc().toIso8601String();

      final settings = UserSettingsCompanion(
        id: const Value('settings_1'),
        userId: const Value('user_1'),
        theme: const Value('dark'),
        notificationsEnabled: const Value(true),
        enabledModules: const Value('{"attendance":true}'),
        preferences: const Value('{"compactView":false}'),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      await repository.saveSettings(settings);

      final result = await repository.getByUserId('user_1');
      expect(result, isNotNull);
      expect(result?.userId, 'user_1');
      expect(result?.theme, 'dark');
      expect(result?.notificationsEnabled, true);
      expect(result?.enabledModules, '{"attendance":true}');
      expect(result?.preferences, '{"compactView":false}');

      final pendingSync = await syncQueueRepository.getPendingItems();
      expect(pendingSync.length, 1);
      expect(pendingSync.first.targetTable, 'user_settings');
      expect(pendingSync.first.recordId, 'settings_1');
      expect(pendingSync.first.operation, 'UPDATE');
    },
  );

  test('watchByUserId streams user settings changes', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.saveSettings(
      UserSettingsCompanion(
        id: const Value('settings_1'),
        userId: const Value('user_1'),
        theme: const Value('dark'),
        notificationsEnabled: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final stream = repository.watchByUserId('user_1');
    final entity = await stream.first;

    expect(entity, isNotNull);
    expect(entity?.theme, 'dark');
  });

  test(
    'updateTheme and updateNotificationsEnabled update preferences and enqueue sync queue items',
    () async {
      final now = DateTime.now().toUtc().toIso8601String();

      await repository.saveSettings(
        UserSettingsCompanion(
          id: const Value('settings_1'),
          userId: const Value('user_1'),
          theme: const Value('dark'),
          notificationsEnabled: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await repository.updateTheme('user_1', 'light');
      await repository.updateNotificationPreferences(
        'user_1',
        notificationsEnabled: false,
      );

      final updated = await repository.getByUserId('user_1');
      expect(updated?.theme, 'light');
      expect(updated?.notificationsEnabled, false);

      final pendingSync = await syncQueueRepository.getPendingItems();
      // 1 from initial saveSettings, 2 from updateTheme, 3 from updateNotificationPreferences
      expect(pendingSync.length, 3);
      expect(pendingSync.last.targetTable, 'user_settings');
      expect(pendingSync.last.operation, 'UPDATE');
    },
  );

  test(
    'updateAccent stores accent inside the preferences JSON and enqueues sync',
    () async {
      final now = DateTime.now().toUtc().toIso8601String();

      await repository.saveSettings(
        UserSettingsCompanion(
          id: const Value('settings_1'),
          userId: const Value('user_1'),
          theme: const Value('dark'),
          preferences: const Value('{"compactView":true}'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await repository.updateAccent('user_1', 'sand');

      final updated = await repository.getByUserId('user_1');
      expect(updated?.preferences, contains('"accent":"sand"'));
      // Pre-existing preference keys are preserved, not clobbered.
      expect(updated?.preferences, contains('"compactView":true'));

      final pendingSync = await syncQueueRepository.getPendingItems();
      expect(pendingSync.last.targetTable, 'user_settings');
      expect(pendingSync.last.operation, 'UPDATE');
    },
  );

  test(
    'updateAccent throws DatabaseException when no settings row exists',
    () async {
      expect(
        () async => repository.updateAccent('missing_user', 'azure'),
        throwsA(isA<DatabaseException>()),
      );
    },
  );

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.saveSettings(const UserSettingsCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });

  group('ensureForUser (#37)', () {
    test('creates a row that follows the system theme', () async {
      final created = await repository.ensureForUser('fresh_user');

      expect(created.userId, 'fresh_user');
      // Not the column's SQL default of 'dark'.
      expect(created.theme, 'system');
      expect(await repository.getByUserId('fresh_user'), isNotNull);
    });

    test('returns an existing row untouched', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      await repository.saveSettings(
        UserSettingsCompanion(
          id: const Value('settings_existing'),
          userId: const Value('existing_user'),
          theme: const Value('light'),
          preferences: const Value('{"accent":"azure"}'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final row = await repository.ensureForUser('existing_user');

      expect(row.id, 'settings_existing');
      expect(row.theme, 'light');
      expect(row.preferences, '{"accent":"azure"}');
    });

    test('updateAccent on a fresh user leaves the theme as system', () async {
      await repository.ensureForUser('fresh_user');
      await repository.updateAccent('fresh_user', 'sand');

      final row = await repository.getByUserId('fresh_user');
      expect(row!.theme, 'system');
      expect(row.preferences, contains('sand'));
    });
  });

  group('updateNotificationPreferences (#11)', () {
    test('writes the column switches and leaves the rest alone', () async {
      await repository.ensureForUser('u');
      await repository.updateAccent('u', 'azure');

      await repository.updateNotificationPreferences(
        'u',
        lectureRemindersEnabled: false,
      );

      final row = (await repository.getByUserId('u'))!;
      expect(row.lectureRemindersEnabled, isFalse);
      expect(row.notificationsEnabled, isTrue);
      expect(row.preferences, contains('azure'));
    });

    test('stores the per-channel switches in preferences', () async {
      await repository.ensureForUser('u');
      await repository.updateAccent('u', 'sand');

      await repository.updateNotificationPreferences(
        'u',
        morningBriefingEnabled: false,
        assignmentRemindersEnabled: false,
      );

      final row = (await repository.getByUserId('u'))!;
      final prefs = notificationPreferencesFrom(row);
      expect(prefs.morningBriefingEnabled, isFalse);
      expect(prefs.assignmentRemindersEnabled, isFalse);
      expect(prefs.lectureRemindersEnabled, isTrue);
      expect(row.preferences, contains('sand'));
    });

    test('defaults everything on for a missing row', () {
      final prefs = notificationPreferencesFrom(null);
      expect(prefs.notificationsEnabled, isTrue);
      expect(prefs.lectureRemindersEnabled, isTrue);
      expect(prefs.assignmentRemindersEnabled, isTrue);
      expect(prefs.morningBriefingEnabled, isTrue);
    });

    test('queues one sync update per change', () async {
      await repository.ensureForUser('u');
      final before = (await syncQueueRepository.getPendingItems()).length;

      await repository.updateNotificationPreferences(
        'u',
        notificationsEnabled: false,
        morningBriefingEnabled: false,
      );

      final after = await syncQueueRepository.getPendingItems();
      expect(after.length - before, 1);
      expect(after.last.operation, 'UPDATE');
    });
  });

  test('a corrupt preferences blob does not block notification writes '
      '(#11)', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    await repository.saveSettings(
      UserSettingsCompanion(
        id: const Value('settings_bad'),
        userId: const Value('bad'),
        preferences: const Value('not json'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await repository.updateNotificationPreferences(
      'bad',
      morningBriefingEnabled: false,
    );

    final prefs = notificationPreferencesFrom(
      await repository.getByUserId('bad'),
    );
    expect(prefs.morningBriefingEnabled, isFalse);
  });
}
