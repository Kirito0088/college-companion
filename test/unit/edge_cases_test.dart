import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/repositories/user_repository.dart';
import 'package:college_companion/features/settings/repositories/user_settings_repository.dart';
import 'package:college_companion/features/subjects/repositories/subjects_repository.dart';
import 'package:college_companion/services/sync_service.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'services/sync_service_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late FakeConnectivityService connectivityService;
  late FakeSupabaseClient supabaseClient;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    connectivityService = FakeConnectivityService();
    supabaseClient = FakeSupabaseClient();
  });

  tearDown(() async {
    connectivityService.dispose();
    await database.close();
  });

  group('Edge Case Tests - Network Drops', () {
    test('Handles sudden network drop gracefully during sync operation', () async {
      final syncService = SyncService(
        syncQueueRepository: syncQueueRepository,
        database: database,
        supabaseClient: supabaseClient,
        connectivityService: connectivityService,
      );

      // Enqueue item
      await syncQueueRepository.enqueue(
        targetTable: 'assignments',
        recordId: 'asgn_net_drop',
        operation: 'INSERT',
      );

      // Network drops before sync execution starts
      connectivityService.isConnected = false;

      await syncService.syncPendingMutations();

      // Mutation remains queued and unsynced
      final pending = await syncQueueRepository.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.isSynced, false);

      syncService.dispose();
    });

    test('Prevents re-entrant sync execution while sync is already in progress', () async {
      final syncService = SyncService(
        syncQueueRepository: syncQueueRepository,
        database: database,
        supabaseClient: supabaseClient,
        connectivityService: connectivityService,
      );

      expect(syncService.isSyncing, false);

      // Call syncPendingMutations concurrently
      final future1 = syncService.syncPendingMutations();
      final future2 = syncService.syncPendingMutations();

      await Future.wait([future1, future2]);

      expect(syncService.isSyncing, false);
      syncService.dispose();
    });
  });

  group('Edge Case Tests - Malformed Payload & Input Handling', () {
    test('Handles Unicode characters, emojis, and special symbols in fields', () async {
      final repo = AssignmentRepository(database, syncQueueRepository);
      final now = DateTime.now().toUtc().toIso8601String();

      const unicodeTitle = '📚 Math H.W. #1: 🔥 "Calculus & ∑(x^2)" <script>alert(1)</script>';
      const unicodeDesc = 'Testing 中文 / 日本語 / Español / Ñ / 💥 Unicode ⚡️';

      final id = await repo.create(AssignmentsCompanion(
        id: const Value('asgn_unicode'),
        userId: const Value('user_unicode'),
        subjectId: const Value('sub_1'),
        title: const Value(unicodeTitle),
        description: const Value(unicodeDesc),
        dueDate: const Value('2026-09-01'),
        status: const Value('pending'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final fetched = await repo.getById('user_unicode', id);
      expect(fetched, isNotNull);
      expect(fetched?.title, unicodeTitle);
      expect(fetched?.description, unicodeDesc);
    });

    test('Handles empty strings and extreme payload boundary values', () async {
      final repo = AssignmentRepository(database);
      final now = DateTime.now().toUtc().toIso8601String();

      final longString = 'A' * 5000; // 5KB title string

      await repo.create(AssignmentsCompanion(
        id: const Value('asgn_extreme'),
        userId: const Value('user_1'),
        subjectId: const Value('sub_1'),
        title: Value(longString),
        description: const Value(''),
        dueDate: const Value('2026-12-31'),
        status: const Value('pending'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final fetched = await repo.getById('user_1', 'asgn_extreme');
      expect(fetched?.title.length, 5000);
      expect(fetched?.description, '');
    });

    test('Handles unknown targetTable gracefully during sync queue processing', () async {
      await syncQueueRepository.enqueue(
        targetTable: 'unknown_nonexistent_table',
        recordId: 'rec_unknown',
        operation: 'UPDATE',
      );

      final syncService = SyncService(
        syncQueueRepository: syncQueueRepository,
        database: database,
        supabaseClient: supabaseClient,
        connectivityService: connectivityService,
      );

      await syncService.syncPendingMutations();

      final pending = await syncQueueRepository.getPendingItems();
      expect(pending.isEmpty, true);

      syncService.dispose();
    });
  });

  group('Edge Case Tests - Duplicate Record Conflicts', () {
    test('UserRepository upsertUser handles duplicate user IDs cleanly without duplicate key crash', () async {
      final userRepo = UserRepository(database, null, syncQueueRepository);

      const userV1 = AppUser(
        uid: 'user_duplicate',
        displayName: 'Original Name',
        email: 'original@college.edu',
      );

      await userRepo.upsertUser(userV1);

      const userV2 = AppUser(
        uid: 'user_duplicate',
        displayName: 'Updated Name',
        email: 'updated@college.edu',
      );

      // Upserting same UID updates existing row
      await userRepo.upsertUser(userV2);

      final fetched = await userRepo.getById('user_duplicate');
      expect(fetched, isNotNull);
      expect(fetched?.name, 'Updated Name');
      expect(fetched?.email, 'updated@college.edu');
    });

    test('SubjectRepository throws DatabaseException when violating unique constraint (userId, semesterId, name)', () async {
      final subjectRepo = SubjectRepository(database);
      final now = DateTime.now().toUtc().toIso8601String();

      await subjectRepo.create(SubjectsCompanion(
        id: const Value('sub_1'),
        userId: const Value('user_1'),
        semesterId: const Value('sem_1'),
        name: const Value('Physics 101'),
        type: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Attempt to insert duplicate subject with same (userId, semesterId, name)
      expect(
        () async => subjectRepo.create(SubjectsCompanion(
          id: const Value('sub_2'),
          userId: const Value('user_1'),
          semesterId: const Value('sem_1'),
          name: const Value('Physics 101'),
          type: const Value('theory'),
          createdAt: Value(now),
          updatedAt: Value(now),
        )),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('UserSettingsRepository handles repeated saveSettings for same user ID', () async {
      final settingsRepo = UserSettingsRepository(database, syncQueueRepository);
      final now = DateTime.now().toUtc().toIso8601String();

      await settingsRepo.saveSettings(UserSettingsCompanion(
        id: const Value('sett_1'),
        userId: const Value('user_1'),
        theme: const Value('dark'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      await settingsRepo.saveSettings(UserSettingsCompanion(
        id: const Value('sett_1'),
        userId: const Value('user_1'),
        theme: const Value('light'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final fetched = await settingsRepo.getByUserId('user_1');
      expect(fetched?.theme, 'light');
    });
  });
}
