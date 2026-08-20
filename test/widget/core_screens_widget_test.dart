import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/assignments/screens/assignments_screen.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/screens/attendance_screen.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/calendar/screens/calendar_screen.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/features/dashboard/screens/dashboard_screen.dart';
import 'package:college_companion/features/resources/providers/resources_provider.dart';
import 'package:college_companion/features/resources/screens/resources_screen.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/features/settings/screens/settings_screen.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('Core Screens Widget Tests with ProviderScope Overrides', () {
    testWidgets(
      'CalendarScreen renders wrapped in ProviderScope with stream provider override',
      (WidgetTester tester) async {
        final now = DateTime.now().toUtc().toIso8601String();
        final mockEvent = CalendarEventEntity(
          id: 'evt_1',
          userId: 'test_user_id',
          title: 'Algorithms Exam',
          startDate: now,
          endDate: now,
          eventType: 'exam',
          isAllDay: false,
          createdAt: now,
          updatedAt: now,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(_TestAuthStateNotifier.new),
              calendarEventsStreamProvider.overrideWith(
                (ref, userId) => Stream.value([mockEvent]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const CalendarScreen(),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(CalendarScreen), findsOneWidget);
      },
    );

    testWidgets(
      'AssignmentsScreen renders wrapped in ProviderScope with stream provider override',
      (WidgetTester tester) async {
        final now = DateTime.now().toUtc().toIso8601String();
        final mockAssignment = AssignmentEntity(
          id: 'asgn_1',
          userId: 'test_user_id',
          subjectId: 'sub_1',
          title: 'Database Assignment',
          dueDate: now,
          status: 'pending',
          createdAt: now,
          updatedAt: now,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(_TestAuthStateNotifier.new),
              assignmentsStreamProvider.overrideWith(
                (ref, userId) => Stream.value([mockAssignment]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const AssignmentsScreen(),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(AssignmentsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'ResourcesScreen renders wrapped in ProviderScope with stream provider override',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final now = DateTime.now().toUtc().toIso8601String();
        final mockResource = ResourceEntity(
          id: 'res_1',
          userId: 'test_user_id',
          title: 'Compiler Notes PDF',
          url: 'https://example.com/notes.pdf',
          category: 'Notes',
          createdAt: now,
          updatedAt: now,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(_TestAuthStateNotifier.new),
              resourcesStreamProvider.overrideWith(
                (ref, userId) => Stream.value([mockResource]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const ResourcesScreen(),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(ResourcesScreen), findsOneWidget);
      },
    );

    testWidgets(
      'SettingsScreen renders wrapped in ProviderScope with stream provider override',
      (WidgetTester tester) async {
        final now = DateTime.now().toUtc().toIso8601String();
        final mockSettings = UserSettingsEntity(
          id: 'sett_1',
          userId: 'test_user_id',
          notificationsEnabled: true,
          lectureRemindersEnabled: false,
          enabledModules: '{}',
          theme: 'dark',
          preferences: '{}',
          createdAt: now,
          updatedAt: now,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(_TestAuthStateNotifier.new),
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
        expect(find.byType(SettingsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'DashboardScreen renders wrapped in ProviderScope with stream provider override',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockSnapshot = DashboardSnapshot.empty();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(_TestAuthStateNotifier.new),
              dashboardSnapshotProvider.overrideWith(
                (ref, userId) => Future.value(mockSnapshot),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const DashboardScreen(),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(DashboardScreen), findsOneWidget);
      },
    );

    testWidgets(
      'AttendanceScreen renders wrapped in ProviderScope with stream provider override',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        const mockResult = SafeBunkResult(
          attended: 8,
          total: 10,
          targetPercentage: 75.0,
          currentPercentage: 80.0,
          safeBunks: 2,
          mustAttend: 0,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(_TestAuthStateNotifier.new),
              safeBunkStreamProvider.overrideWith(
                (ref, userId) => Stream.value(mockResult),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const MediaQuery(
                data: MediaQueryData(
                  size: Size(1200, 3000),
                  textScaler: TextScaler.noScaling,
                ),
                child: AttendanceScreen(),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(AttendanceScreen), findsOneWidget);
      },
    );
  });
}
