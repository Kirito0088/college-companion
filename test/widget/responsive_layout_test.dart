/// Regression coverage for GitHub issue #32 — app-wide layout
/// responsiveness.
///
/// Two failure modes are in scope (see the issue's Scenario 1 & 2):
/// RenderFlex overflow / clipped text at narrow widths, and labels that
/// wrap mid-word instead of staying on one line. This suite targets the
/// exact shape the issue's static audit flagged — a [Text] sharing a
/// [Row] with a sibling and no [Expanded]/[Flexible] — at the four
/// target widths (320/360/411/600dp), portrait and landscape for the
/// bottom nav bar (named explicitly in the issue), plus a width-extremes
/// smoke sweep across the core screens and the individual widgets found
/// to carry unbounded row text during the audit.
library;

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
import 'package:college_companion/features/dashboard/widgets/next_lecture_card.dart';
import 'package:college_companion/features/resources/providers/resources_provider.dart';
import 'package:college_companion/features/resources/screens/resources_screen.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/features/settings/screens/settings_screen.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/features/timetable/widgets/lecture_card.dart';
import 'package:college_companion/routing/scaffold_with_nav_bar.dart';
import 'package:college_companion/shared/widgets/section_header.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

/// The four target widths from issue #32, dp.
const _targetWidths = [320.0, 360.0, 411.0, 600.0];

/// A tall reference height so width-driven (not height-driven) overflow
/// is what gets exercised in portrait pumps.
const _portraitHeight = 800.0;

Future<void> _pumpAtSize(
  WidgetTester tester,
  Widget widget, {
  required double width,
  required double height,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

/// Fails if the [Text]/[RichText] found by [finder] wrapped onto more
/// than one line — the mid-word-wrap failure mode Scenario 2 forbids.
///
/// Lays out the same [InlineSpan] again with unbounded width to get its
/// natural single-line height, then compares that against the height it
/// actually rendered at under the real (constrained) layout.
void _expectSingleLine(WidgetTester tester, Finder finder) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final naturalHeight = (TextPainter(
    text: paragraph.text,
    textDirection: TextDirection.ltr,
    textScaler: paragraph.textScaler,
  )..layout()).height;
  expect(
    paragraph.size.height,
    lessThan(naturalHeight * 1.5),
    reason: '$finder wrapped onto multiple lines at the current width',
  );
}

GoRouter _navBarRouter() {
  Widget page(String label) => Center(child: Text(label));
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (c, s) => page('Home Page')),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/attendance',
                builder: (c, s) => page('Attendance Page'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (c, s) => page('Calendar Page'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assignments',
                builder: (c, s) => page('Assignments Page'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (c, s) => page('Profile Page'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Nav bar — Scenario 1 & 2 (no overflow, no mid-word wrap)', () {
    for (final width in _targetWidths) {
      for (final isLandscape in [false, true]) {
        final w = isLandscape ? _portraitHeight : width;
        final h = isLandscape ? width : _portraitHeight;
        final orientation = isLandscape ? 'landscape' : 'portrait';

        testWidgets('${width.toInt()}dp $orientation: all 5 labels clean', (
          tester,
        ) async {
          await _pumpAtSize(
            tester,
            MaterialApp.router(
              theme: AppTheme.darkTheme,
              routerConfig: _navBarRouter(),
            ),
            width: w,
            height: h,
          );

          expect(tester.takeException(), isNull);
          for (final label in const [
            'Home',
            'Attendance',
            'Calendar',
            'Assignments',
            'Profile',
          ]) {
            expect(find.text(label), findsOneWidget);
            _expectSingleLine(tester, find.text(label));
          }
        });
      }
    }
  });

  group('SectionHeader — Scenario 3 (long user content)', () {
    testWidgets('long title next to a See All button does not overflow', (
      tester,
    ) async {
      await _pumpAtSize(
        tester,
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SectionHeader(
              title:
                  'A Very Long Section Title That Would Never Fit Next To A Button',
              onSeeAllPressed: () {},
            ),
          ),
        ),
        width: 320,
        height: _portraitHeight,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('LectureCard — Scenario 3 (long user content)', () {
    LectureScheduleItem lecture({
      required String subjectName,
      String? room,
      String? faculty,
    }) {
      return LectureScheduleItem(
        id: 'lec_1',
        userId: 'u1',
        subjectId: 'subj_1',
        subjectName: subjectName,
        faculty: faculty,
        dayOfWeek: 0,
        startTime: '09:00',
        endTime: '10:00',
        room: room,
      );
    }

    testWidgets('long subject name, room, and faculty do not overflow', (
      tester,
    ) async {
      await _pumpAtSize(
        tester,
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: LectureCard(
              lecture: lecture(
                subjectName:
                    'Advanced Distributed Systems and Cloud Native Architecture',
                room: 'Block C, Second Floor, Engineering Wing, Room 301-A',
                faculty: 'Prof. Alexandria Montgomery-Fitzgerald III',
              ),
            ),
          ),
        ),
        width: 320,
        height: _portraitHeight,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('NextLectureCard — Scenario 3 (long user content)', () {
    testWidgets('long location does not overflow', (tester) async {
      const snapshot = DashboardSnapshot(
        greetingContext: '1 lecture today',
        nextAction: HeroAction(
          title: 'Advanced Distributed Systems',
          timeString: '9:00 AM',
          location: 'Block C, Second Floor, Engineering Wing, Room 301-A',
          urgencyString: 'Starts in 10m',
        ),
        timelineEvents: [],
        academicSnapshot: AcademicSnapshot(
          attendanceState: 'On Track',
          workloadState: 'Clear',
          deadlinesState: 'All clear',
          nextBreakState: 'N/A',
          attendancePercentage: 80,
          isAttendanceSafe: true,
          hasAttendanceData: true,
        ),
        upcomingAssignments: [],
      );

      await _pumpAtSize(
        tester,
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_TestAuthStateNotifier.new),
            dashboardSnapshotProvider.overrideWith(
              (ref, userId) => Future.value(snapshot),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: NextLectureCard()),
          ),
        ),
        width: 320,
        height: _portraitHeight,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(NextLectureCard), findsOneWidget);
    });
  });

  group('Core screens — Scenario 1 (width extremes smoke sweep)', () {
    final now = DateTime.now().toUtc().toIso8601String();

    final screens = <String, Widget Function(double width)>{
      'CalendarScreen': (width) => ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_TestAuthStateNotifier.new),
          calendarEventsStreamProvider.overrideWith(
            (ref, userId) => Stream.value([
              CalendarEventEntity(
                id: 'evt_1',
                userId: 'test_user_id',
                title: 'Algorithms Exam',
                startDate: now,
                endDate: now,
                eventType: 'exam',
                isAllDay: false,
                createdAt: now,
                updatedAt: now,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const CalendarScreen(),
        ),
      ),
      'AssignmentsScreen': (width) => ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_TestAuthStateNotifier.new),
          assignmentsStreamProvider.overrideWith(
            (ref, userId) => Stream.value([
              AssignmentEntity(
                id: 'asgn_1',
                userId: 'test_user_id',
                subjectId: 'sub_1',
                title:
                    'A Very Long Assignment Title That Might Overflow The Card',
                dueDate: now,
                status: 'pending',
                createdAt: now,
                updatedAt: now,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const AssignmentsScreen(),
        ),
      ),
      'ResourcesScreen': (width) => ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_TestAuthStateNotifier.new),
          resourcesStreamProvider.overrideWith(
            (ref, userId) => Stream.value([
              ResourceEntity(
                id: 'res_1',
                userId: 'test_user_id',
                title: 'Compiler Notes PDF',
                url: 'https://example.com/notes.pdf',
                category: 'Notes',
                createdAt: now,
                updatedAt: now,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ResourcesScreen(),
        ),
      ),
      'SettingsScreen': (width) => ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_TestAuthStateNotifier.new),
          userSettingsStreamProvider.overrideWith(
            (ref, userId) => Stream.value(
              UserSettingsEntity(
                id: 'sett_1',
                userId: 'test_user_id',
                notificationsEnabled: true,
                lectureRemindersEnabled: false,
                enabledModules: '{}',
                theme: 'dark',
                preferences: '{}',
                createdAt: now,
                updatedAt: now,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      ),
      'DashboardScreen': (width) => ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_TestAuthStateNotifier.new),
          dashboardSnapshotProvider.overrideWith(
            (ref, userId) => Future.value(DashboardSnapshot.empty()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const DashboardScreen(),
        ),
      ),
      'AttendanceScreen': (width) => ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_TestAuthStateNotifier.new),
          safeBunkStreamProvider.overrideWith(
            (ref, userId) => Stream.value(
              const SafeBunkResult(
                attended: 8,
                total: 10,
                targetPercentage: 75.0,
                currentPercentage: 80.0,
                safeBunks: 2,
                mustAttend: 0,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 3000),
              textScaler: TextScaler.noScaling,
            ),
            child: const AttendanceScreen(),
          ),
        ),
      ),
    };

    for (final width in [320.0, 600.0]) {
      for (final entry in screens.entries) {
        testWidgets('${width.toInt()}dp: ${entry.key} has no overflow', (
          tester,
        ) async {
          await _pumpAtSize(
            tester,
            entry.value(width),
            width: width,
            height: 3000,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
