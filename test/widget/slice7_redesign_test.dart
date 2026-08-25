/// Widget tests covering the Slice 7 (Assignments, Focus, Resources,
/// Semester, Notifications) redesign — the last slice with no dedicated
/// coverage before this file.
///
/// Each screen is smoke-tested under both brightnesses with real
/// provider-driven data (via the same fake-stream-for-reads override
/// pattern used by `attendance_redesign_test.dart` and
/// `subject_details_redesign_test.dart`), plus its empty state where one is
/// wired. `AssignmentsScreen` additionally gets its `NetworkErrorWidget`
/// path exercised since it is the only Slice 7 screen with a real error
/// branch (`assignments_screen.dart:164`) — Attendance/Timetable/Subject
/// Details/Focus/Notifications have none (filed as a defect, not fixed
/// here).
///
/// The `SemesterDetailsScreen` case is deliberately `skip`ped: it renders
/// `EmptySubjects` (its *empty*-state widget) as its error state too
/// (`semester_details_screen.dart:373`), so a failed query is
/// indistinguishable from "no data" to the user. This test documents that
/// defect and will start passing once it's fixed — do not delete the skip
/// to force it green.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/assignments/screens/assignments_screen.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/focus/screens/focus_screen.dart';
import 'package:college_companion/features/notifications/providers/notification_provider.dart';
import 'package:college_companion/features/notifications/screens/notifications_screen.dart';
import 'package:college_companion/features/resources/providers/resources_provider.dart';
import 'package:college_companion/features/resources/screens/resources_screen.dart';
import 'package:college_companion/features/semester/providers/semester_provider.dart';
import 'package:college_companion/features/semester/screens/semester_details_screen.dart';
import 'package:college_companion/features/semester/screens/semesters_list_screen.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

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

const _userId = 'test_user_id';
const _nowIso = '2026-01-01T00:00:00.000Z';

AppDatabase _memoryDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  required List<Override> overrides,
  Brightness brightness = Brightness.dark,
}) async {
  final database = _memoryDatabase();
  addTearDown(database.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(_TestAuthStateNotifier.new),
        databaseProvider.overrideWithValue(database),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.theme(brightness, Accent.jade),
        home: screen,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AssignmentsScreen', () {
    AssignmentEntity assignment(String title) => AssignmentEntity(
      id: 'a1',
      userId: _userId,
      subjectId: 'subj_1',
      title: title,
      dueDate: '2026-06-01',
      status: 'pending',
      createdAt: _nowIso,
      updatedAt: _nowIso,
    );

    for (final brightness in [Brightness.dark, Brightness.light]) {
      testWidgets('renders real assignment data in $brightness', (
        tester,
      ) async {
        await _pump(
          tester,
          const AssignmentsScreen(),
          brightness: brightness,
          overrides: [
            assignmentsStreamProvider.overrideWith(
              (ref, userId) => Stream.value([assignment('Lab Report 3')]),
            ),
          ],
        );

        expect(find.text('Lab Report 3'), findsOneWidget);
      });
    }

    testWidgets('shows EmptyAssignments when there are no assignments', (
      tester,
    ) async {
      await _pump(
        tester,
        const AssignmentsScreen(),
        overrides: [
          assignmentsStreamProvider.overrideWith(
            (ref, userId) => Stream.value([]),
          ),
        ],
      );

      expect(find.byType(EmptyAssignments), findsOneWidget);
    });

    testWidgets('shows NetworkErrorWidget when the stream errors', (
      tester,
    ) async {
      await _pump(
        tester,
        const AssignmentsScreen(),
        overrides: [
          assignmentsStreamProvider.overrideWith(
            (ref, userId) => Stream<List<AssignmentEntity>>.error('boom'),
          ),
        ],
      );

      expect(find.byType(NetworkErrorWidget), findsOneWidget);
    });
  });

  group('ResourcesScreen', () {
    ResourceEntity resource(String title) => ResourceEntity(
      id: 'r1',
      userId: _userId,
      title: title,
      url: '/local/storage/notes.pdf',
      category: 'notes',
      createdAt: _nowIso,
      updatedAt: _nowIso,
    );

    for (final brightness in [Brightness.dark, Brightness.light]) {
      testWidgets('renders real resource data in $brightness', (tester) async {
        await _pump(
          tester,
          const ResourcesScreen(),
          brightness: brightness,
          overrides: [
            resourcesStreamProvider.overrideWith(
              (ref, userId) => Stream.value([resource('Unit 3 Notes')]),
            ),
          ],
        );

        expect(find.text('Unit 3 Notes'), findsWidgets);
      });
    }

    testWidgets('renders without exception when there are no resources', (
      tester,
    ) async {
      await _pump(
        tester,
        const ResourcesScreen(),
        overrides: [
          resourcesStreamProvider.overrideWith(
            (ref, userId) => Stream.value([]),
          ),
        ],
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('NotificationsScreen', () {
    NotificationEntity notification(String title) => NotificationEntity(
      id: 'n1',
      userId: _userId,
      title: title,
      message: 'Body text',
      type: 'upcoming',
      isRead: false,
      createdAt: _nowIso,
    );

    for (final brightness in [Brightness.dark, Brightness.light]) {
      testWidgets('renders real notification data in $brightness', (
        tester,
      ) async {
        await _pump(
          tester,
          const NotificationsScreen(),
          brightness: brightness,
          overrides: [
            notificationsStreamProvider.overrideWith(
              (ref, userId) =>
                  Stream.value([notification('Class moved to 3pm')]),
            ),
          ],
        );

        expect(find.text('Class moved to 3pm'), findsOneWidget);
      });
    }

    testWidgets('renders without exception when there are no notifications '
        '(EmptyNotifications is not wired here — filed as a defect)', (
      tester,
    ) async {
      await _pump(
        tester,
        const NotificationsScreen(),
        overrides: [
          notificationsStreamProvider.overrideWith(
            (ref, userId) => Stream.value([]),
          ),
        ],
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('FocusScreen', () {
    for (final brightness in [Brightness.dark, Brightness.light]) {
      testWidgets('renders the timer without exception in $brightness', (
        tester,
      ) async {
        await _pump(
          tester,
          const FocusScreen(),
          brightness: brightness,
          overrides: [],
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('SemestersListScreen', () {
    SemesterEntity semester(String name) => SemesterEntity(
      id: 's1',
      userId: _userId,
      name: name,
      workingDays: '[1,2,3,4,5]',
      isCurrent: true,
      isArchived: false,
      createdAt: _nowIso,
      updatedAt: _nowIso,
    );

    for (final brightness in [Brightness.dark, Brightness.light]) {
      testWidgets('renders real semester data in $brightness', (tester) async {
        await _pump(
          tester,
          const SemestersListScreen(),
          brightness: brightness,
          overrides: [
            semestersStreamProvider.overrideWith(
              (ref, userId) => Stream.value([semester('Semester 5')]),
            ),
          ],
        );

        expect(find.text('Semester 5'), findsOneWidget);
      });
    }

    testWidgets(
      'shows the empty state via EmptySubjects when there are no semesters',
      (tester) async {
        await _pump(
          tester,
          const SemestersListScreen(),
          overrides: [
            semestersStreamProvider.overrideWith(
              (ref, userId) => Stream.value([]),
            ),
          ],
        );

        expect(find.byType(EmptySubjects), findsOneWidget);
      },
    );
  });

  group('SemesterDetailsScreen error/empty distinguishability', () {
    testWidgets(
      'a failed semester query must not render the same empty-state widget '
      'as an actual empty result (currently both hit EmptySubjects — '
      'semester_details_screen.dart:373)',
      (tester) async {
        await _pump(
          tester,
          const SemesterDetailsScreen(semesterId: 'sem_error'),
          overrides: [
            semesterByIdStreamProvider.overrideWith(
              (ref, params) => Stream<SemesterEntity?>.error('boom'),
            ),
          ],
        );

        expect(
          find.byType(NetworkErrorWidget),
          findsOneWidget,
          reason:
              'An error should render an error widget, not the empty-data '
              'widget — see docs/qa defect C.',
        );
      },
      // Known defect: SemesterDetailsScreen renders EmptySubjects on error
      // instead of an error widget (semester_details_screen.dart:373).
      // Filed as https://github.com/Kirito0088/college-companion/issues/24 —
      // unskip once fixed.
      skip: true,
    );
  });
}
