/// The quiet sync chip above the bottom navigation (#16).
///
/// Shows only when useful (sync-engine.md, Sync Indicators): offline with
/// changes waiting, an upload in progress, and a brief confirmation once a
/// sync finishes with nothing left. Otherwise it stays out of the way.
library;

import 'package:college_companion/providers/sync_status_provider.dart';
import 'package:college_companion/shared/widgets/sync_status_chip.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

SyncStatus _status({
  bool online = true,
  bool syncing = false,
  int pending = 0,
}) => SyncStatus(
  online: online,
  syncing: syncing,
  pending: pending,
  failed: 0,
  lastSyncedAt: null,
);

final _testStatus = StateProvider<SyncStatus?>((ref) => null);

Future<ProviderContainer> _pump(
  WidgetTester tester,
  SyncStatus? initial,
) async {
  final container = ProviderContainer(
    overrides: [
      syncStatusProvider.overrideWith((ref) => ref.watch(_testStatus)),
    ],
  );
  addTearDown(container.dispose);
  container.read(_testStatus.notifier).state = initial;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.theme(Brightness.light, Accent.jade),
        home: const Scaffold(body: Center(child: SyncStatusChip())),
      ),
    ),
  );
  await tester.pump();
  return container;
}

Future<void> _set(
  WidgetTester tester,
  ProviderContainer container,
  SyncStatus status,
) async {
  container.read(_testStatus.notifier).state = status;
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('says nothing while everything is synced', (tester) async {
    await _pump(tester, _status());
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('says nothing before the status is known', (tester) async {
    await _pump(tester, null);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('offline with changes: queued locally', (tester) async {
    await _pump(tester, _status(online: false, pending: 2));
    expect(find.text('Offline — queued locally'), findsOneWidget);
  });

  testWidgets('offline with nothing waiting says nothing', (tester) async {
    await _pump(tester, _status(online: false));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('shows syncing, then confirms for 3 seconds and goes away', (
    tester,
  ) async {
    final c = await _pump(tester, _status(pending: 1));
    await _set(tester, c, _status(syncing: true, pending: 1));
    expect(find.text('Syncing…'), findsOneWidget);

    await _set(tester, c, _status());
    expect(find.text('All changes synced'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('All changes synced'), findsNothing);
  });

  testWidgets('a sync that leaves changes behind claims nothing', (
    tester,
  ) async {
    final c = await _pump(tester, _status(pending: 2));
    await _set(tester, c, _status(syncing: true, pending: 2));
    await _set(tester, c, _status(pending: 1));

    expect(find.text('All changes synced'), findsNothing);
  });

  testWidgets('is announced to screen readers', (tester) async {
    await _pump(tester, _status(online: false, pending: 1));
    final semantics = tester.getSemantics(
      find.text('Offline — queued locally'),
    );
    expect(semantics.flagsCollection.isLiveRegion, isTrue);
  });
}
