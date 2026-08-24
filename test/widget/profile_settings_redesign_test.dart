import 'dart:convert';

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/profile/widgets/profile_header_card.dart';
import 'package:college_companion/features/profile/widgets/profile_menu_list.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/features/settings/screens/settings_screen.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/shared/widgets/cc_list_row.dart';
import 'package:college_companion/shared/widgets/cc_section.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

class _TestAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(
      uid: 'test_user_id',
      email: 'test@example.com',
      displayName: 'Test Student',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CCListRow', () {
    testWidgets('renders label, subtitle, trailing text, and chevron', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CCListRow(
              icon: Symbols.sync,
              label: 'Data & Sync',
              subtitle: 'Last synced: Today',
              trailingText: '12.4 MB',
              showBorder: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Data & Sync'), findsOneWidget);
      expect(find.text('Last synced: Today'), findsOneWidget);
      expect(find.text('12.4 MB'), findsOneWidget);
      expect(find.byIcon(Symbols.chevron_right), findsOneWidget);

      await tester.tap(find.byType(CCListRow));
      expect(tapped, isTrue);
    });

    testWidgets('hides chevron when a custom trailing widget is given', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CCListRow(
              icon: Symbols.notifications,
              label: 'Push Notifications',
              showBorder: false,
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Symbols.chevron_right), findsNothing);
    });
  });

  group('CCSection', () {
    testWidgets('renders its title and children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: CCSection(
              title: 'Account',
              children: [Text('Account Information')],
            ),
          ),
        ),
      );

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Account Information'), findsOneWidget);
    });
  });

  group('Profile widgets render on the redesigned theme', () {
    testWidgets('ProfileHeaderCard renders name, email, and semester pill', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: ProfileHeaderCard(
              name: 'Jayesh',
              email: 'jayesh@example.com',
              semester: 'SEM 5',
              course: 'CSE',
            ),
          ),
        ),
      );

      expect(find.text('Jayesh'), findsOneWidget);
      expect(find.text('SEM 5 • CSE'), findsOneWidget);
    });

    testWidgets('ProfileMenuList renders every menu destination', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const Scaffold(body: ProfileMenuList()),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Data & Sync'), findsOneWidget);
      expect(find.text('About College Companion'), findsOneWidget);
    });
  });

  group('SettingsScreen Appearance section', () {
    late AppDatabase database;
    late UserSettingsEntity mockSettings;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      final now = DateTime.now().toUtc().toIso8601String();
      mockSettings = UserSettingsEntity(
        id: 'sett_test_user_id',
        userId: 'test_user_id',
        notificationsEnabled: true,
        lectureRemindersEnabled: false,
        enabledModules: '{}',
        theme: 'dark',
        preferences: '{"accent":"jade"}',
        createdAt: now,
        updatedAt: now,
      );
      await database
          .into(database.userSettings)
          .insert(
            UserSettingsCompanion.insert(
              id: mockSettings.id,
              userId: mockSettings.userId,
              theme: Value(mockSettings.theme),
              preferences: Value(mockSettings.preferences),
              createdAt: mockSettings.createdAt,
              updatedAt: mockSettings.updatedAt,
            ),
          );
    });

    // The UI reads through a fixed `Stream.value` override — same pattern as
    // core_screens_widget_test.dart — rather than the real Drift watch
    // stream, since that stream's async cancellation on widget dispose
    // leaves a pending zero-duration Timer that trips flutter_test's
    // post-test invariant check. Writes still go through the real in-memory
    // `database` via `userSettingsRepositoryProvider` so persistence is
    // verified for real.
    Future<void> pumpSettings(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_TestAuthStateNotifier.new),
            databaseProvider.overrideWithValue(database),
            userSettingsStreamProvider.overrideWith(
              (ref, userId) => Stream.value(mockSettings),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('shows Appearance section with theme and accent options', (
      tester,
    ) async {
      await pumpSettings(tester);

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Jade'), findsOneWidget);
      expect(find.text('Sand'), findsOneWidget);
      expect(find.text('Azure'), findsOneWidget);
    });

    testWidgets('tapping Sand persists the accent via the repository', (
      tester,
    ) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Sand'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final saved = await database
          .customSelect(
            'SELECT preferences FROM user_settings WHERE user_id = ?',
            variables: [Variable.withString('test_user_id')],
          )
          .getSingle();
      final preferences =
          jsonDecode(saved.data['preferences'] as String) as Map;
      expect(preferences['accent'], 'sand');
    });

    testWidgets('tapping Light persists the theme via the repository', (
      tester,
    ) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Light'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final saved = await (database.select(
        database.userSettings,
      )..where((t) => t.userId.equals('test_user_id'))).getSingle();
      expect(saved.theme, 'light');
    });
  });

  group('SettingsScreen Appearance section for a brand-new account', () {
    // Regression: a real account with no user_settings row yet threw
    // DatabaseException from UserSettingsRepository.updateAccent (it only
    // updates an existing row) as an unhandled Future error, so the tap
    // silently did nothing. No seeded row here, unlike the group above.
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    Future<void> pumpFreshSettings(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_TestAuthStateNotifier.new),
            databaseProvider.overrideWithValue(database),
            userSettingsStreamProvider.overrideWith(
              (ref, userId) => Stream.value(null),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('tapping Sand creates the settings row instead of throwing', (
      tester,
    ) async {
      await pumpFreshSettings(tester);

      await tester.tap(find.text('Sand'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final saved = await (database.select(
        database.userSettings,
      )..where((t) => t.userId.equals('test_user_id'))).getSingle();
      final preferences = jsonDecode(saved.preferences) as Map;
      expect(preferences['accent'], 'sand');
    });

    testWidgets('tapping Dark creates the settings row instead of no-op', (
      tester,
    ) async {
      await pumpFreshSettings(tester);

      await tester.tap(find.text('Dark'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final saved = await (database.select(
        database.userSettings,
      )..where((t) => t.userId.equals('test_user_id'))).getSingle();
      expect(saved.theme, 'dark');
    });
  });
}
