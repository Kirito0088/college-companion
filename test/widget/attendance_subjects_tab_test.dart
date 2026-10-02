/// Widget tests for the Attendance screen's Subjects tab states.
///
/// The tab used to render bare `Text` strings for its empty cases while every
/// other list in the app used the shared `CCEmptyState` family (issue #31).
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/screens/attendance_screen.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
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

SubjectEntity _subject(String id, String name) {
  final now = DateTime.now().toUtc().toIso8601String();
  return SubjectEntity(
    id: id,
    userId: 'test_user_id',
    semesterId: 'sem_1',
    name: name,
    type: 'theory',
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> _pumpSubjectsTab(
  WidgetTester tester, {
  required Stream<List<SubjectEntity>> subjects,
  Stream<List<AttendanceEntity>>? records,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(_TestAuthStateNotifier.new),
        safeBunkStreamProvider.overrideWith(
          (ref, userId) => const Stream.empty(),
        ),
        subjectsStreamProvider.overrideWith((ref, userId) => subjects),
        attendanceRecordsStreamProvider.overrideWith(
          (ref, userId) => records ?? Stream.value(const []),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.theme(Brightness.dark, Accent.jade),
        home: const AttendanceScreen(),
      ),
    ),
  );
  await tester.pump();

  await tester.tap(find.text('Subjects'));
  // Let the AnimatedSwitcher finish swapping tabs.
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Attendance Subjects tab empty states (#31)', () {
    testWidgets('no subjects renders the shared EmptySubjects widget', (
      tester,
    ) async {
      await _pumpSubjectsTab(tester, subjects: Stream.value(const []));

      expect(find.byType(EmptySubjects), findsOneWidget);
      expect(find.text('No subjects added yet.'), findsNothing);
    });

    testWidgets('a search with no matches renders the shared EmptySearch', (
      tester,
    ) async {
      await _pumpSubjectsTab(
        tester,
        subjects: Stream.value([_subject('s1', 'Data Structures')]),
      );

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();

      expect(find.byType(EmptySearch), findsOneWidget);
      expect(find.byType(EmptySubjects), findsNothing);
      expect(find.text('No subjects found matching query.'), findsNothing);
    });

    testWidgets('subjects render as cards, not an empty state', (tester) async {
      await _pumpSubjectsTab(
        tester,
        subjects: Stream.value([_subject('s1', 'Data Structures')]),
      );

      expect(find.text('Data Structures'), findsOneWidget);
      expect(find.byType(EmptySubjects), findsNothing);
      expect(find.byType(EmptySearch), findsNothing);
    });
  });
}
