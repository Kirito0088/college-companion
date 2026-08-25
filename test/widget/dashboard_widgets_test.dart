import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/dashboard/widgets/academic_snapshot_section.dart';
import 'package:college_companion/features/dashboard/widgets/attendance_ring.dart';
import 'package:college_companion/features/dashboard/widgets/next_lecture_card.dart';
import 'package:college_companion/features/dashboard/widgets/quick_actions_section.dart';
import 'package:college_companion/features/dashboard/widgets/today_overview_section.dart';
import 'package:college_companion/features/dashboard/widgets/upcoming_assignments_section.dart';
import 'package:college_companion/features/dashboard/widgets/welcome_section.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Dashboard Widget Tests', () {
    testWidgets('WelcomeSection renders greeting', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: WelcomeSection()),
          ),
        ),
      );

      expect(find.byType(WelcomeSection), findsOneWidget);
    });

    testWidgets('WelcomeSection bell exposes an accessible label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: WelcomeSection()),
          ),
        ),
      );

      expect(find.byTooltip('Notifications'), findsOneWidget);
    });

    testWidgets('WelcomeSection bell navigates to the notifications route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
          ],
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const Scaffold(body: WelcomeSection()),
                ),
                GoRoute(
                  path: RoutePaths.notifications,
                  builder: (context, state) =>
                      const Scaffold(body: Text('Notifications Route')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications Route'), findsOneWidget);
    });

    testWidgets('NextLectureCard renders next action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: NextLectureCard()),
          ),
        ),
      );

      expect(find.byType(NextLectureCard), findsOneWidget);
    });

    testWidgets('TodayOverviewSection renders empty-day state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: TodayOverviewSection()),
          ),
        ),
      );

      expect(find.byType(TodayOverviewSection), findsOneWidget);
      expect(find.text('No classes scheduled for today'), findsOneWidget);
    });

    testWidgets('AcademicSnapshotSection renders an AttendanceRing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: AcademicSnapshotSection()),
          ),
        ),
      );

      expect(find.byType(AcademicSnapshotSection), findsOneWidget);
      expect(find.byType(AttendanceRing), findsOneWidget);
    });

    testWidgets('UpcomingAssignmentsSection renders empty state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: UpcomingAssignmentsSection()),
          ),
        ),
      );

      expect(find.byType(UpcomingAssignmentsSection), findsOneWidget);
      expect(find.text('No upcoming assignments'), findsOneWidget);
    });

    testWidgets('QuickActionsSection renders all four action tiles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: QuickActionsSection()),
        ),
      );

      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Assignments'), findsOneWidget);
      expect(find.text('Focus Mode'), findsOneWidget);
    });
  });

  group('AttendanceRing Widget Tests', () {
    testWidgets('renders the rounded percentage label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AttendanceRing(percentage: 82.4, isSafe: true),
          ),
        ),
      );

      expect(find.text('82%'), findsOneWidget);
    });
  });
}
