/// The sync status the student sees, derived from real sync state (#16).
library;

import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/sync_metadata_dao.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/providers/sync_status_provider.dart';
import 'package:college_companion/services/sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

SyncStatus _status({
  bool online = true,
  bool syncing = false,
  int pending = 0,
  int failed = 0,
}) => SyncStatus(
  online: online,
  syncing: syncing,
  pending: pending,
  failed: failed,
  lastSyncedAt: null,
);

void main() {
  group('SyncStatus.phase', () {
    test('offline with unsynced changes is queued locally', () {
      expect(_status(online: false, pending: 2).phase, SyncPhase.offlineQueued);
    });

    test('offline with nothing waiting is just offline', () {
      expect(_status(online: false).phase, SyncPhase.offline);
    });

    test('an upload in flight is syncing', () {
      expect(_status(syncing: true, pending: 1).phase, SyncPhase.syncing);
    });

    test('changes that gave up need attention', () {
      expect(_status(failed: 1).phase, SyncPhase.needsAttention);
    });

    test('changes waiting online are waiting', () {
      expect(_status(pending: 3).phase, SyncPhase.waiting);
    });

    test('nothing waiting online is up to date', () {
      expect(_status().phase, SyncPhase.upToDate);
    });
  });

  group('syncStatusProvider over a real queue', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          isOnlineProvider.overrideWith((ref) => Stream.value(true)),
          syncInFlightProvider.overrideWith((ref) => Stream.value(false)),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    Future<SyncStatus> settle() async {
      final sub = container.listen(syncStatusProvider, (_, _) {});
      addTearDown(sub.close);
      for (var i = 0; i < 50 && sub.read() == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      await pumpEventQueue();
      return sub.read()!;
    }

    test('counts queued changes and reads the last sync time', () async {
      await SyncQueueRepository(
        db,
      ).enqueue(targetTable: 'subjects', recordId: 's1', operation: 'UPDATE');
      await SyncMetadataDao(db).set(lastSyncAtKey, '2026-10-02T10:00:00.000Z');

      final status = await settle();

      expect(status.pending, 1);
      expect(status.failed, 0);
      expect(status.lastSyncedAt, DateTime.utc(2026, 10, 2, 10).toLocal());
      expect(status.phase, SyncPhase.waiting);
    });

    test('never synced reads as no last-sync time', () async {
      final status = await settle();

      expect(status.lastSyncedAt, isNull);
      expect(status.phase, SyncPhase.upToDate);
    });
  });
}
