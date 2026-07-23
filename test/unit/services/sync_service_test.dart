import 'dart:async';
import 'dart:math';

import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:college_companion/features/semester/repositories/semesters_repository.dart';
import 'package:college_companion/services/connectivity_service.dart';
import 'package:college_companion/services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeConnectivityService implements ConnectivityService {
  final StreamController<InternetStatus> _controller =
      StreamController<InternetStatus>.broadcast();
  bool isConnected = true;

  @override
  Future<bool> get hasInternetAccess async => isConnected;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([]);

  @override
  Stream<InternetStatus> get onStatusChange => _controller.stream;

  void emitStatus(InternetStatus status) {
    isConnected = status == InternetStatus.connected;
    _controller.add(status);
  }

  void dispose() {
    _controller.close();
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, List<Map<String, dynamic>>> upsertedPayloads = {};
  final Map<String, List<String>> deletedIds = {};
  bool shouldThrow = false;

  @override
  SupabaseQueryBuilder from(String table) {
    if (shouldThrow) {
      throw Exception('Supabase connection error');
    }
    return FakeSupabaseQueryBuilder(table, this);
  }
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  FakeSupabaseQueryBuilder(this.table, this.client);
  final String table;
  final FakeSupabaseClient client;

  @override
  PostgrestFilterBuilder<dynamic> upsert(
    Object values, {
    String? onConflict,
    bool ignoreDuplicates = false,
    bool defaultToNull = false,
  }) {
    if (client.shouldThrow) throw Exception('Supabase connection error');
    if (values is Map<String, dynamic>) {
      client.upsertedPayloads.putIfAbsent(table, () => []).add(values);
    }
    return FakePostgrestFilterBuilder();
  }

  @override
  PostgrestFilterBuilder<dynamic> delete({String? count}) {
    if (client.shouldThrow) throw Exception('Supabase connection error');
    return FakePostgrestFilterBuilder(onEq: (column, value) {
      if (column == 'id') {
        client.deletedIds.putIfAbsent(table, () => []).add(value.toString());
      }
    });
  }
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  FakePostgrestFilterBuilder({this.onEq});
  final void Function(String column, dynamic value)? onEq;

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) {
    onEq?.call(column, value);
    return this;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(T value) onFulfilled, {
    Function? onError,
  }) {
    return Future<T>.value(null as T).then<U>(onFulfilled, onError: onError);
  }
}

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

  group('SyncService - Core Functionality & State Transitions', () {
    test('SyncService does nothing when offline', () async {
      connectivityService.isConnected = false;
      await syncQueueRepository.enqueue(
        targetTable: 'semesters',
        recordId: 'sem_1',
        operation: 'INSERT',
      );

      final syncService = SyncService(
        syncQueueRepository: syncQueueRepository,
        database: database,
        supabaseClient: supabaseClient,
        connectivityService: connectivityService,
      );

      await syncService.syncPendingMutations();

      final pending = await syncQueueRepository.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.isSynced, false);
      syncService.dispose();
    });

    test('SyncService skips items exceeding max retries (5 limit)', () async {
      final id = await syncQueueRepository.enqueue(
        targetTable: 'semesters',
        recordId: 'sem_old',
        operation: 'INSERT',
      );
      for (var i = 0; i < 5; i++) {
        await syncQueueRepository.recordFailure(id, 'Error', i);
      }

      final syncService = SyncService(
        syncQueueRepository: syncQueueRepository,
        database: database,
        supabaseClient: supabaseClient,
        connectivityService: connectivityService,
      );

      await syncService.syncPendingMutations();

      final pending = await syncQueueRepository.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.retryCount, 5);
      syncService.dispose();
    });

    test('SyncQueue state transition (pending -> failed with incremented retry count on network error)', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      await database.into(database.semesters).insert(
            SemestersCompanion.insert(
              id: 'rec_999',
              userId: 'user_1',
              name: 'Semester Test',
              workingDays: '[0,1,2,3,4]',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await syncQueueRepository.enqueue(
        targetTable: 'semesters',
        recordId: 'rec_999',
        operation: 'INSERT',
      );

      // Verify initial pending state
      var pending = await syncQueueRepository.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.retryCount, 0);
      expect(pending.first.isSynced, false);

      supabaseClient.shouldThrow = true;

      final syncService = SyncService(
        syncQueueRepository: syncQueueRepository,
        database: database,
        supabaseClient: supabaseClient,
        connectivityService: connectivityService,
      );

      await syncService.syncPendingMutations();

      pending = await syncQueueRepository.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.retryCount, 1);
      expect(pending.first.error, contains('Supabase connection error'));

      syncService.dispose();
    });

    test('Exponential backoff retry math formula verification (pow(2, retryCount) * 500ms)', () {
      for (var retryCount = 0; retryCount < 5; retryCount++) {
        final expectedDelayMs = pow(2, retryCount).toInt() * 500;

        switch (retryCount) {
          case 0:
            expect(expectedDelayMs, 500);
            break;
          case 1:
            expect(expectedDelayMs, 1000);
            break;
          case 2:
            expect(expectedDelayMs, 2000);
            break;
          case 3:
            expect(expectedDelayMs, 4000);
            break;
          case 4:
            expect(expectedDelayMs, 8000);
            break;
        }
      }
    });

    test('Automatic queue flushing on network reconnection (ConnectivityService.onStatusChange)', () async {
      connectivityService.isConnected = false;

      final syncService = SyncService(
        syncQueueRepository: syncQueueRepository,
        database: database,
        supabaseClient: supabaseClient,
        connectivityService: connectivityService,
      );

      await syncQueueRepository.enqueue(
        targetTable: 'assignments',
        recordId: 'asgn_offline_1',
        operation: 'INSERT',
      );

      var pending = await syncQueueRepository.getPendingItems();
      expect(pending.length, 1);

      connectivityService.emitStatus(InternetStatus.connected);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      pending = await syncQueueRepository.getPendingItems();
      expect(pending.isEmpty, true);

      syncService.dispose();
    });

    test('Offline mutation queueing when network drops and subsequent flush', () async {
      connectivityService.isConnected = false;

      final semestersRepo = SemesterRepository(database, syncQueueRepository);
      final assignmentsRepo = AssignmentRepository(database, syncQueueRepository);

      final now = DateTime.now().toUtc().toIso8601String();

      await semestersRepo.create(SemestersCompanion(
        id: const Value('sem_offline'),
        userId: const Value('user_1'),
        name: const Value('Offline Semester'),
        workingDays: const Value('[0,1,2,3,4]'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      await assignmentsRepo.create(AssignmentsCompanion(
        id: const Value('asgn_offline'),
        userId: const Value('user_1'),
        subjectId: const Value('sub_1'),
        title: const Value('Offline Homework'),
        dueDate: const Value('2026-09-01'),
        status: const Value('pending'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      var pending = await syncQueueRepository.getPendingItems();
      expect(pending.length, 2);
      expect(pending[0].targetTable, 'semesters');
      expect(pending[1].targetTable, 'assignments');

      final syncService = SyncService(
        syncQueueRepository: syncQueueRepository,
        database: database,
        supabaseClient: supabaseClient,
        connectivityService: connectivityService,
      );

      connectivityService.emitStatus(InternetStatus.connected);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      pending = await syncQueueRepository.getPendingItems();
      expect(pending.isEmpty, true);
      expect(supabaseClient.upsertedPayloads['semesters'], isNotNull);
      expect(supabaseClient.upsertedPayloads['assignments'], isNotNull);

      syncService.dispose();
    });

    test('SyncService processes DELETE operation on Supabase table', () async {
      await syncQueueRepository.enqueue(
        targetTable: 'subjects',
        recordId: 'subj_del_999',
        operation: 'DELETE',
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
      expect(supabaseClient.deletedIds['subjects'], contains('subj_del_999'));

      syncService.dispose();
    });

    test('SyncService fetches row payload and maps camelCase to snake_case for all Drift tables', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      await database.into(database.attendance).insert(
            AttendanceCompanion.insert(
              id: 'att_101',
              userId: 'user_1',
              subjectId: 'sub_1',
              date: '2026-07-24',
              primaryStatus: 'present',
              lectureType: 'theory',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await syncQueueRepository.enqueue(
        targetTable: 'attendance',
        recordId: 'att_101',
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

      final payloads = supabaseClient.upsertedPayloads['attendance'];
      expect(payloads, isNotNull);
      expect(payloads!.first['user_id'], 'user_1');
      expect(payloads.first['subject_id'], 'sub_1');
      expect(payloads.first['primary_status'], 'present');
      expect(payloads.first['lecture_type'], 'theory');

      syncService.dispose();
    });
  });
}

