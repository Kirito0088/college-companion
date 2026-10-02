/// The one-line sync summary on the Profile row (#16).
library;

import 'package:college_companion/providers/sync_status_provider.dart';
import 'package:college_companion/shared/widgets/sync_status_text.dart';
import 'package:flutter_test/flutter_test.dart';

SyncStatus _status({
  bool online = true,
  int pending = 0,
  int failed = 0,
  DateTime? lastSyncedAt,
}) => SyncStatus(
  online: online,
  syncing: false,
  pending: pending,
  failed: failed,
  lastSyncedAt: lastSyncedAt,
);

void main() {
  test('unknown until the status has loaded', () {
    expect(syncSummary(null), isNull);
  });

  test('when everything is synced, says when', () {
    final at = DateTime.now().subtract(const Duration(hours: 2));
    expect(syncSummary(_status(lastSyncedAt: at)), 'Last synced 2 hours ago');
  });

  test('never synced says so', () {
    expect(syncSummary(_status()), 'Not synced yet');
  });

  test('offline with changes is reassuring', () {
    expect(
      syncSummary(_status(online: false, pending: 1)),
      'Offline — changes saved on this device',
    );
  });

  test('counts waiting and given-up changes', () {
    expect(syncSummary(_status(pending: 2)), '2 changes waiting to sync');
    expect(syncSummary(_status(failed: 1)), "1 change couldn't sync");
  });
}
