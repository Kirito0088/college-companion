import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SyncQueueRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('enqueue and fetch pending items ordered by creation time', () async {
    final id1 = await repository.enqueue(
      targetTable: 'semesters',
      recordId: 'rec_100',
      operation: 'INSERT',
    );

    final id2 = await repository.enqueue(
      targetTable: 'subjects',
      recordId: 'rec_101',
      operation: 'UPDATE',
    );

    expect(id1, greaterThan(0));
    expect(id2, greaterThan(id1));

    final pending = await repository.getPendingItems();
    expect(pending.length, 2);
    expect(pending.first.targetTable, 'semesters');
    expect(pending.first.recordId, 'rec_100');
    expect(pending.first.operation, 'INSERT');
    expect(pending.first.isSynced, false);

    expect(pending.last.targetTable, 'subjects');
    expect(pending.last.recordId, 'rec_101');
    expect(pending.last.operation, 'UPDATE');
  });

  test(
    'markSynced marks item synced and purgeSyncedItems removes it',
    () async {
      final id = await repository.enqueue(
        targetTable: 'subjects',
        recordId: 'rec_200',
        operation: 'UPDATE',
      );

      await repository.markSynced(id);

      final pending = await repository.getPendingItems();
      expect(pending.isEmpty, true);

      final purgedCount = await repository.purgeSyncedItems();
      expect(purgedCount, 1);
    },
  );

  test(
    'recordFailure increments retry count, updates error, and sets lastAttempt',
    () async {
      final id = await repository.enqueue(
        targetTable: 'attendance',
        recordId: 'rec_300',
        operation: 'DELETE',
      );

      await repository.recordFailure(id, 'Network timeout', 0);

      var pending = await repository.getPendingItems();
      expect(pending.first.retryCount, 1);
      expect(pending.first.error, 'Network timeout');
      expect(pending.first.lastAttempt, isNotNull);

      await repository.recordFailure(id, 'Server 500 error', 1);

      pending = await repository.getPendingItems();
      expect(pending.first.retryCount, 2);
      expect(pending.first.error, 'Server 500 error');
    },
  );

  group('status counts (#16)', () {
    Future<int> enqueue(String id) => repository.enqueue(
      targetTable: 'semesters',
      recordId: id,
      operation: 'UPDATE',
    );

    Future<void> exhaust(int queueId) async {
      for (var i = 0; i < SyncQueueRepository.maxRetries; i++) {
        await repository.recordFailure(queueId, 'RLS', i);
      }
    }

    test('splits waiting changes from ones that gave up', () async {
      await enqueue('a');
      await enqueue('b');
      await exhaust(await enqueue('c'));
      final synced = await enqueue('d');
      await repository.markSynced(synced);

      final counts = await repository.watchCounts().first;

      expect(counts.pending, 2);
      expect(counts.failed, 1);
    });

    test('updates as the queue changes', () async {
      final seen = <int>[];
      final sub = repository.watchCounts().listen((c) => seen.add(c.pending));
      addTearDown(sub.cancel);

      await pumpEventQueue();
      final id = await enqueue('a');
      await pumpEventQueue();
      await repository.markSynced(id);
      await pumpEventQueue();

      expect(seen, [0, 1, 0]);
    });

    test('retryFailed makes given-up changes pending again', () async {
      await exhaust(await enqueue('c'));

      await repository.retryFailed();

      final counts = await repository.watchCounts().first;
      expect(counts.failed, 0);
      expect(counts.pending, 1);
    });
  });
}
