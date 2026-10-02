/// Widget tests for the Settings → Notifications section (#11).
///
/// Every switch reads from and writes to `user_settings`, the single source
/// of truth the reminder scheduler plans from. Before #11 the Lecture
/// Reminders switch only flipped widget state, so the scheduler never saw
/// it, and Push Notifications kept a second copy in SharedPreferences that
/// overrode the database.
library;

import 'dart:convert';

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/features/settings/repositories/user_settings_repository.dart';
import 'package:college_companion/features/settings/screens/settings_screen.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _uid = 'test_user_id';
const _iso = '2026-10-01T00:00:00.000Z';

class _SignedIn extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(uid: _uid, email: 'e@x.test', displayName: 'Test'),
  );
}

UserSettingsEntity _settings({
  bool push = true,
  bool lectures = true,
  String preferences = '{}',
}) => UserSettingsEntity(
  id: 'settings_$_uid',
  userId: _uid,
  notificationsEnabled: push,
  lectureRemindersEnabled: lectures,
  enabledModules: '{}',
  theme: 'system',
  preferences: preferences,
  createdAt: _iso,
  updatedAt: _iso,
);

/// A repository whose notification writes always fail.
class _FailingSettingsRepository extends UserSettingsRepository {
  _FailingSettingsRepository(super.database);

  @override
  Future<void> updateNotificationPreferences(
    String userId, {
    bool? notificationsEnabled,
    bool? lectureRemindersEnabled,
    bool? assignmentRemindersEnabled,
    bool? morningBriefingEnabled,
  }) async => throw const DatabaseException('disk I/O error');
}

const _labels = [
  'Push Notifications',
  'Lecture Reminders',
  'Assignment Reminders',
  'Morning Briefing',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late AppDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  // Reads go through a fixed stream (a live Drift watch inside a widget
  // test leaves a pending timer on dispose); writes hit the real database.
  Future<void> pumpSettings(WidgetTester tester, UserSettingsEntity row) async {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_SignedIn.new),
          databaseProvider.overrideWithValue(database),
          userSettingsStreamProvider.overrideWith(
            (ref, userId) => Stream.value(row),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.theme(Brightness.dark, Accent.jade),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  Switch switchFor(WidgetTester tester, String label) => tester.widget<Switch>(
    find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
      matching: find.byType(Switch),
    ),
  );

  Future<void> toggle(WidgetTester tester, String label) async {
    final finder = find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
      matching: find.byType(Switch),
    );
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<UserSettingsEntity> stored() => (database.select(
    database.userSettings,
  )..where((t) => t.userId.equals(_uid))).getSingle();

  testWidgets('shows a switch for every reminder channel', (tester) async {
    await pumpSettings(tester, _settings());

    for (final label in _labels) {
      expect(find.text(label), findsOneWidget, reason: label);
      expect(switchFor(tester, label).value, isTrue, reason: label);
    }
  });

  testWidgets('switches show the stored values', (tester) async {
    await pumpSettings(
      tester,
      _settings(
        lectures: false,
        preferences: jsonEncode({'morningBriefingEnabled': false}),
      ),
    );

    expect(switchFor(tester, 'Lecture Reminders').value, isFalse);
    expect(switchFor(tester, 'Morning Briefing').value, isFalse);
    expect(switchFor(tester, 'Assignment Reminders').value, isTrue);
  });

  testWidgets('turning off Lecture Reminders is persisted', (tester) async {
    await pumpSettings(tester, _settings());

    await toggle(tester, 'Lecture Reminders');

    final row = await stored();
    expect(row.lectureRemindersEnabled, isFalse);
    expect(row.notificationsEnabled, isTrue);
  });

  testWidgets('turning off Morning Briefing is persisted', (tester) async {
    await pumpSettings(tester, _settings());

    await toggle(tester, 'Morning Briefing');

    final prefs = jsonDecode((await stored()).preferences) as Map;
    expect(prefs['morningBriefingEnabled'], isFalse);
  });

  testWidgets('turning off Assignment Reminders is persisted', (tester) async {
    await pumpSettings(tester, _settings());

    await toggle(tester, 'Assignment Reminders');

    final prefs = jsonDecode((await stored()).preferences) as Map;
    expect(prefs['assignmentRemindersEnabled'], isFalse);
  });

  testWidgets('with push off, the channel switches are disabled', (
    tester,
  ) async {
    await pumpSettings(tester, _settings(push: false));

    expect(switchFor(tester, 'Push Notifications').onChanged, isNotNull);
    for (final label in _labels.skip(1)) {
      expect(switchFor(tester, label).onChanged, isNull, reason: label);
    }
  });

  testWidgets('Push Notifications reads the database, not a stale '
      'SharedPreferences copy', (tester) async {
    SharedPreferences.setMockInitialValues({'push_notifications': false});
    await pumpSettings(tester, _settings(push: true));
    await tester.pump();

    expect(switchFor(tester, 'Push Notifications').value, isTrue);
  });

  testWidgets('labels and explanations are not truncated on a 320dp '
      'screen', (tester) async {
    await pumpSettings(tester, _settings());
    tester.view.physicalSize = const Size(320, 2400);
    await tester.pump();

    for (final text in [
      'Push Notifications',
      'Lecture Reminders',
      'Assignment Reminders',
      'A day and 2 hours before',
      'A quiet summary of your day at 8 AM',
    ]) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
      expect(paragraph.didExceedMaxLines, isFalse, reason: text);
    }
  });

  testWidgets('a failed save tells the student instead of failing '
      'silently', (tester) async {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_SignedIn.new),
          databaseProvider.overrideWithValue(database),
          userSettingsRepositoryProvider.overrideWithValue(
            _FailingSettingsRepository(database),
          ),
          userSettingsStreamProvider.overrideWith(
            (ref, userId) => Stream.value(_settings()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.theme(Brightness.dark, Accent.jade),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    await toggle(tester, 'Morning Briefing');
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.textContaining("Couldn't save"), findsOneWidget);
  });

  testWidgets('switches stay inert until settings have loaded', (tester) async {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_SignedIn.new),
          databaseProvider.overrideWithValue(database),
          userSettingsStreamProvider.overrideWith(
            (ref, userId) => const Stream.empty(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.theme(Brightness.dark, Accent.jade),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    for (final label in _labels) {
      expect(switchFor(tester, label).onChanged, isNull, reason: label);
    }
  });
}
