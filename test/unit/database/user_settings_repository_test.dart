import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
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

  test('saveSettings and getByUserId saves settings and enqueues sync UPDATE', () async {
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
  });

  test('watchByUserId streams user settings changes', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.saveSettings(UserSettingsCompanion(
      id: const Value('settings_1'),
      userId: const Value('user_1'),
      theme: const Value('dark'),
      notificationsEnabled: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    final stream = repository.watchByUserId('user_1');
    final entity = await stream.first;

    expect(entity, isNotNull);
    expect(entity?.theme, 'dark');
  });

  test('updateTheme and updateNotificationsEnabled update preferences and enqueue sync queue items', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.saveSettings(UserSettingsCompanion(
      id: const Value('settings_1'),
      userId: const Value('user_1'),
      theme: const Value('dark'),
      notificationsEnabled: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.updateTheme('user_1', 'light');
    await repository.updateNotificationsEnabled('user_1', false);

    final updated = await repository.getByUserId('user_1');
    expect(updated?.theme, 'light');
    expect(updated?.notificationsEnabled, false);

    final pendingSync = await syncQueueRepository.getPendingItems();
    // 1 from initial saveSettings, 2 from updateTheme, 3 from updateNotificationsEnabled
    expect(pendingSync.length, 3);
    expect(pendingSync.last.targetTable, 'user_settings');
    expect(pendingSync.last.operation, 'UPDATE');
  });

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.saveSettings(const UserSettingsCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });
}
