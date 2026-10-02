/// Error-state coverage for the screens issue #25 found without one.
///
/// Attendance, Timetable, Subject Details and Focus either had no `error:`
/// branch, printed the raw exception, or read `valueOrNull` and so sat on
/// "Loading..." forever when a query failed. Each now hands the error to the
/// shared `CcErrorState`.
///
/// Every test fails the *source* on its first subscription and succeeds on
/// the second, then taps retry. That is the only way to prove the retry
/// invalidates the right provider: several of these screens read derived
/// providers, and invalidating a derived provider just recomputes the same
/// cached error from its still-failed source — the button would rebuild and
/// look fine while recovering nothing.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/screens/attendance_screen.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/focus/models/focus_timer_state.dart';
import 'package:college_companion/features/focus/providers/focus_timer_provider.dart';
import 'package:college_companion/features/focus/repositories/focus_repository.dart';
import 'package:college_companion/features/focus/screens/focus_screen.dart';
import 'package:college_companion/features/notifications/providers/notification_provider.dart';
import 'package:college_companion/features/notifications/screens/notifications_screen.dart';
import 'package:college_companion/features/subjects/providers/subject_detail_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/features/subjects/screens/subject_details_screen.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:college_companion/features/timetable/screens/timetable_screen.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_error_state.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const _userId = 'test_user_id';
const _subjectId = 'subj_1';
const _nowIso = '2026-01-01T00:00:00.000Z';

class _TestAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(uid: _userId, email: 'test@example.com', displayName: 'Test'),
  );
}

const _failure = DatabaseException('no such table: attendance');

/// A stream that errors on its first subscription and emits [value] on every
/// later one — i.e. a source that recovers once something re-subscribes.
Stream<T> Function() _failsOnceThen<T>(T value) {
  var calls = 0;
  return () {
    calls++;
    return calls == 1 ? Stream<T>.error(_failure) : Stream<T>.value(value);
  };
}

SubjectEntity _subject(String name) => SubjectEntity(
  id: _subjectId,
  userId: _userId,
  semesterId: 'sem_1',
  name: name,
  type: 'theory',
  createdAt: _nowIso,
  updatedAt: _nowIso,
);

Future<void> _pump(
  WidgetTester tester,
  Widget screen,
  List<Override> overrides,
) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(_TestAuthStateNotifier.new),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.theme(Brightness.dark, Accent.jade),
        home: screen,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _tapRetry(WidgetTester tester) async {
  final retry = find.descendant(
    of: find.byType(CcErrorState),
    matching: find.byType(FilledButton),
  );
  expect(retry, findsOneWidget, reason: 'error state must offer a retry');
  await tester.ensureVisible(retry);
  await tester.tap(retry);
  await tester.pump();
  await tester.pump();
}

Future<void> _openSubjectsTab(WidgetTester tester) async {
  await tester.tap(find.text('Subjects'));
  // Frame 1 starts the AnimatedSwitcher transition, frame 2 runs it to the
  // end, frame 3 drops the outgoing tab. Fewer frames leave the Overview's
  // own error state in the tree alongside the Subjects tab's.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

/// A [FocusRepository] whose history load fails until [recover] is called.
class _FlakyFocusRepository extends FocusRepository {
  bool failing = true;

  @override
  Future<List<FocusSession>> loadSessions() async {
    if (failing) throw _failure;
    return const [];
  }

  @override
  Future<bool> loadDndSetting() async => true;

  @override
  Future<void> saveDndSetting(bool enabled) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AttendanceScreen (#25)', () {
    testWidgets('Overview shows a retryable error instead of "Loading..." '
        'forever when the attendance query fails', (tester) async {
      final safeBunk = _failsOnceThen(
        SafeBunkCalculator.calculate(attended: 8, total: 10),
      );
      await _pump(tester, const AttendanceScreen(), [
        safeBunkStreamProvider.overrideWith((ref, userId) => safeBunk()),
        subjectsStreamProvider.overrideWith(
          (ref, userId) => Stream.value(const []),
        ),
        attendanceRecordsStreamProvider.overrideWith(
          (ref, userId) => Stream.value(const []),
        ),
      ]);

      expect(find.byType(CcErrorState), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);

      await _tapRetry(tester);

      expect(find.byType(CcErrorState), findsNothing);
      expect(find.text('80%'), findsWidgets);
    });

    testWidgets('Subjects tab shows a retryable error instead of the raw '
        'exception text when the subjects query fails', (tester) async {
      final subjects = _failsOnceThen<List<SubjectEntity>>(const []);
      await _pump(tester, const AttendanceScreen(), [
        safeBunkStreamProvider.overrideWith(
          (ref, userId) => const Stream.empty(),
        ),
        subjectsStreamProvider.overrideWith((ref, userId) => subjects()),
        attendanceRecordsStreamProvider.overrideWith(
          (ref, userId) => Stream.value(const []),
        ),
      ]);
      await _openSubjectsTab(tester);

      expect(find.byType(CcErrorState), findsOneWidget);
      expect(find.textContaining('Error loading subjects'), findsNothing);

      await _tapRetry(tester);

      expect(find.byType(CcErrorState), findsNothing);
      expect(find.byType(EmptySubjects), findsOneWidget);
    });

    testWidgets('Subjects tab shows an error rather than 0% for every '
        'subject when the records query fails', (tester) async {
      final records = _failsOnceThen<List<AttendanceEntity>>(const []);
      await _pump(tester, const AttendanceScreen(), [
        safeBunkStreamProvider.overrideWith(
          (ref, userId) => const Stream.empty(),
        ),
        subjectsStreamProvider.overrideWith(
          (ref, userId) => Stream.value([_subject('Data Structures')]),
        ),
        attendanceRecordsStreamProvider.overrideWith(
          (ref, userId) => records(),
        ),
      ]);
      await _openSubjectsTab(tester);

      expect(find.byType(CcErrorState), findsOneWidget);
      expect(find.text('Data Structures'), findsNothing);

      await _tapRetry(tester);

      expect(find.byType(CcErrorState), findsNothing);
      expect(find.text('Data Structures'), findsOneWidget);
    });
  });

  group('TimetableScreen (#25)', () {
    testWidgets('shows a retryable error that recovers', (tester) async {
      final lectures = _failsOnceThen<List<LectureScheduleItem>>(const []);
      await _pump(tester, const TimetableScreen(), [
        timetableForDayProvider.overrideWith((ref, day) => lectures()),
      ]);

      expect(find.byType(CcErrorState), findsOneWidget);
      expect(find.text('Failed to load timetable'), findsNothing);

      await _tapRetry(tester);

      expect(find.byType(CcErrorState), findsNothing);
      expect(find.text('No classes scheduled'), findsOneWidget);
    });
  });

  group('SubjectDetailsScreen (#25)', () {
    Future<void> pumpDetails(
      WidgetTester tester, {
      required Stream<SubjectEntity?> Function() subject,
      required Stream<List<AttendanceEntity>> Function() records,
    }) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await _pump(tester, const SubjectDetailsScreen(subjectId: _subjectId), [
        databaseProvider.overrideWithValue(database),
        subjectByIdStreamProvider.overrideWith((ref, params) => subject()),
        attendanceBySubjectStreamProvider.overrideWith(
          (ref, params) => records(),
        ),
      ]);
    }

    testWidgets('a failed subject query shows a retryable error that '
        'recovers', (tester) async {
      await pumpDetails(
        tester,
        subject: _failsOnceThen<SubjectEntity?>(_subject('Compilers')),
        records: () => Stream.value(const []),
      );

      expect(find.byType(CcErrorState), findsOneWidget);
      expect(find.textContaining('Error loading subject'), findsNothing);

      await _tapRetry(tester);

      expect(find.byType(CcErrorState), findsNothing);
      expect(find.text('Compilers'), findsWidgets);
    });

    testWidgets('a failed records query shows a retryable error that '
        'recovers', (tester) async {
      await pumpDetails(
        tester,
        subject: () => Stream.value(_subject('Compilers')),
        records: _failsOnceThen<List<AttendanceEntity>>(const []),
      );

      expect(find.byType(CcErrorState), findsOneWidget);

      await _tapRetry(tester);

      expect(find.byType(CcErrorState), findsNothing);
      expect(find.text('Compilers'), findsWidgets);
    });
  });

  group('NotificationsScreen (#25)', () {
    testWidgets('shows a retryable error that recovers', (tester) async {
      final notifications = _failsOnceThen<List<NotificationEntity>>(const []);
      await _pump(tester, const NotificationsScreen(), [
        notificationsStreamProvider.overrideWith(
          (ref, userId) => notifications(),
        ),
      ]);

      expect(find.byType(CcErrorState), findsOneWidget);

      await _tapRetry(tester);

      expect(find.byType(CcErrorState), findsNothing);
      expect(find.byType(EmptyNotifications), findsOneWidget);
    });
  });

  group('FocusScreen (#25)', () {
    testWidgets('a failed history load shows a retryable error in Recent '
        'Sessions while the timer stays usable', (tester) async {
      final repo = _FlakyFocusRepository();
      await _pump(tester, const FocusScreen(), [
        focusRepositoryProvider.overrideWithValue(repo),
      ]);

      expect(find.byType(CcErrorState), findsOneWidget);
      expect(
        find.text(
          'No study sessions recorded yet. Start your first session above!',
        ),
        findsNothing,
        reason: 'a failed load must not be worded as an empty history',
      );
      // The timer does not depend on history and must keep working.
      expect(find.text('Start Focus Session'), findsOneWidget);

      repo.failing = false;
      await _tapRetry(tester);

      expect(find.byType(CcErrorState), findsNothing);
      expect(
        find.text(
          'No study sessions recorded yet. Start your first session above!',
        ),
        findsOneWidget,
      );
    });
  });
}
