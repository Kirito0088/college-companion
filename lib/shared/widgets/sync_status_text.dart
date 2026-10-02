/// Sync Status Wording (#16)
///
/// One place that turns a [SyncStatus] into words, so the Data & Sync
/// screen and the Profile row can never disagree. Calm and non-technical
/// (sync-engine.md, Sync Indicators and Error Handling).
library;

import 'package:college_companion/providers/sync_status_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

String _changes(int n) => n == 1 ? '1 change' : '$n changes';

/// A headline and an optional detail line describing [status].
({String headline, String? detail}) describeSync(SyncStatus status) {
  return switch (status.phase) {
    SyncPhase.offlineQueued || SyncPhase.offline => (
      headline: "You're offline",
      detail:
          'Your changes are safe on this device and will sync '
          'automatically.',
    ),
    SyncPhase.syncing => (headline: 'Syncing…', detail: null),
    SyncPhase.needsAttention => (
      headline: "${_changes(status.failed)} couldn't sync",
      detail: 'They are safe on this device. Sync Now tries again.',
    ),
    SyncPhase.waiting => (
      headline: '${_changes(status.pending)} waiting to sync',
      detail: null,
    ),
    SyncPhase.upToDate => switch (status.lastSyncedAt) {
      final at? => (
        headline: 'All changes synced',
        detail: 'Last synced ${timeago.format(at)}',
      ),
      null => (headline: 'Not synced yet', detail: null),
    },
  };
}

/// A one-line summary of [status] for compact rows, or null while unknown.
String? syncSummary(SyncStatus? status) {
  if (status == null) return null;
  return switch (status.phase) {
    SyncPhase.offlineQueued => 'Offline — changes saved on this device',
    SyncPhase.offline => 'Offline',
    SyncPhase.upToDate when status.lastSyncedAt != null => describeSync(
      status,
    ).detail,
    _ => describeSync(status).headline,
  };
}
