/// Data & Sync tells the truth about sync (#16).
///
/// The screen used to simulate a sync (a two-second delay, then "Data synced
/// successfully!" whatever the queue held), hardcode another person's email,
/// invent storage sizes, offer three switches that did nothing, and claim
/// local data is encrypted when the database is plain SQLite.
library;

import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/settings/screens/data_sync_screen.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/providers/sync_status_provider.dart';
import 'package:college_companion/services/sync_service.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _SignedIn extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(uid: 'u1', email: 'student@college.test', displayName: 'Asha'),
  );
}

/// Records Sync Now's upload request instead of reaching Supabase.
class _FakeSyncService implements SyncService {
  int syncCalls = 0;

  @override
  Future<void> syncPendingMutations() async => syncCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late AppDatabase db;
  late _FakeSyncService sync;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    sync = _FakeSyncService();
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, SyncStatus status) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_SignedIn.new),
          databaseProvider.overrideWithValue(db),
          syncServiceProvider.overrideWithValue(sync),
          syncStatusProvider.overrideWith((ref) => status),
        ],
        child: MaterialApp(
          theme: AppTheme.theme(Brightness.dark, Accent.jade),
          home: const DataSyncScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('up to date: says so and when', (tester) async {
    await pump(
      tester,
      _status(
        lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    );

    expect(find.text('All changes synced'), findsOneWidget);
    expect(find.textContaining('Last synced 5 minutes ago'), findsOneWidget);
  });

  testWidgets('never synced: no invented time', (tester) async {
    await pump(tester, _status());

    expect(find.text('Not synced yet'), findsOneWidget);
    expect(find.textContaining('Last synced'), findsNothing);
  });

  testWidgets('changes waiting: counts them', (tester) async {
    await pump(tester, _status(pending: 3));
    expect(find.text('3 changes waiting to sync'), findsOneWidget);
  });

  testWidgets('offline: reassures that changes are safe', (tester) async {
    await pump(tester, _status(online: false, pending: 1));

    expect(find.text("You're offline"), findsOneWidget);
    expect(
      find.text(
        'Your changes are safe on this device and will sync '
        'automatically.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('given-up changes are reported and Sync Now retries them', (
    tester,
  ) async {
    final queue = SyncQueueRepository(db);
    // Real database I/O runs outside the test's fake-async zone.
    await tester.runAsync(() async {
      final id = await queue.enqueue(
        targetTable: 'subjects',
        recordId: 's1',
        operation: 'UPDATE',
      );
      for (var i = 0; i < SyncQueueRepository.maxRetries; i++) {
        await queue.recordFailure(id, 'RLS', i);
      }
    });
    await pump(tester, _status(failed: 1));

    expect(find.text("1 change couldn't sync"), findsOneWidget);

    await tester.tap(find.text('Sync Now'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

    expect(sync.syncCalls, 1);
    final counts = await tester.runAsync(() => queue.watchCounts().first);
    expect(counts!.failed, 0);
    expect(counts.pending, 1);
  });

  testWidgets('shows the signed-in account and nothing invented', (
    tester,
  ) async {
    await pump(tester, _status());

    expect(find.text('student@college.test'), findsOneWidget);
    for (final fake in [
      'jayeshpatil@gmail.com',
      '12.4 MB',
      '45.1 MB',
      '8.2 MB',
      'Auto Sync',
      'Sync over Wi-Fi only',
      'Background Sync',
    ]) {
      expect(find.text(fake), findsNothing, reason: fake);
    }
    expect(find.textContaining('encrypted'), findsNothing);
  });
}
