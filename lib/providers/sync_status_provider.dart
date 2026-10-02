/// Sync Status Providers (#16)
///
/// What the student is told about their data's safety, derived from the
/// real sync state: connectivity, an upload in flight, the queue's pending
/// and failed counts, and when the queue last drained cleanly. Read by the
/// shell's sync chip, the Data & Sync screen and the Profile row.
library;

import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/daos/sync_metadata_dao.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/services/sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// What the sync surfaces should convey, most urgent first.
enum SyncPhase {
  /// Offline with changes waiting: they are safe here and will sync later.
  offlineQueued,

  /// Offline with nothing waiting.
  offline,

  /// An upload is in progress.
  syncing,

  /// Some changes gave up after repeated failures; a manual retry helps.
  needsAttention,

  /// Online with changes waiting for the next batch.
  waiting,

  /// Everything is synced.
  upToDate,
}

/// A snapshot of the sync state.
@immutable
class SyncStatus {
  const SyncStatus({
    required this.online,
    required this.syncing,
    required this.pending,
    required this.failed,
    required this.lastSyncedAt,
  });

  final bool online;
  final bool syncing;

  /// Changes still being retried.
  final int pending;

  /// Changes that gave up after [SyncQueueRepository.maxRetries] attempts.
  final int failed;

  /// When the queue last drained without a failure, local time; null if it
  /// never has.
  final DateTime? lastSyncedAt;

  SyncPhase get phase {
    if (!online) {
      return pending + failed > 0 ? SyncPhase.offlineQueued : SyncPhase.offline;
    }
    if (syncing) return SyncPhase.syncing;
    if (failed > 0) return SyncPhase.needsAttention;
    if (pending > 0) return SyncPhase.waiting;
    return SyncPhase.upToDate;
  }
}

/// Whether the device can reach the internet.
final isOnlineProvider = StreamProvider.autoDispose<bool>((ref) async* {
  final connectivity = ref.watch(connectivityServiceProvider);
  yield await connectivity.hasInternetAccess;
  yield* connectivity.onStatusChange.map(
    (status) => status == InternetStatus.connected,
  );
});

/// Whether an upload batch is in progress.
final syncInFlightProvider = StreamProvider.autoDispose<bool>((ref) async* {
  final sync = ref.watch(syncServiceProvider);
  yield sync.isSyncing;
  yield* sync.syncing;
});

/// Live pending and failed counts from the sync queue.
final syncQueueCountsProvider =
    StreamProvider.autoDispose<({int pending, int failed})>(
      (ref) => ref.watch(syncQueueRepositoryProvider).watchCounts(),
    );

/// When the queue last drained cleanly, local time; null if never.
final lastSyncedAtProvider = StreamProvider.autoDispose<DateTime?>(
  (ref) => SyncMetadataDao(ref.watch(databaseProvider))
      .watch(lastSyncAtKey)
      .map((value) => DateTime.tryParse(value ?? '')?.toLocal()),
);

/// The combined [SyncStatus], or null until every input has reported.
final syncStatusProvider = Provider.autoDispose<SyncStatus?>((ref) {
  final online = ref.watch(isOnlineProvider).valueOrNull;
  final syncing = ref.watch(syncInFlightProvider).valueOrNull;
  final counts = ref.watch(syncQueueCountsProvider).valueOrNull;
  final lastSyncedAt = ref.watch(lastSyncedAtProvider);
  if (online == null ||
      syncing == null ||
      counts == null ||
      !lastSyncedAt.hasValue) {
    return null;
  }
  return SyncStatus(
    online: online,
    syncing: syncing,
    pending: counts.pending,
    failed: counts.failed,
    lastSyncedAt: lastSyncedAt.value,
  );
});
