/// On-device QA for issue #7 — LectureRecordScreen wired to the immutable
/// lecture_records ledger. Bypasses login the same way as
/// `authenticated_app_test.dart`, then exercises Scenario 1 (create) and
/// Scenario 2 (locked view) against a real Impeller-rendered widget tree
/// on the virtual device, backed by a seeded in-memory database so the
/// flow is deterministic.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/screens/lecture_record_screen.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/test_db.dart' show seedGraph;

const _userId = 'test-student-123';

class _MockAuthenticatedNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(
      uid: _userId,
      displayName: 'Alex TestStudent',
      email: 'alex.student@college.edu',
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Record Lecture: create on first visit, locked ledger on second visit',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final seeded = await seedGraph(database, userId: _userId);

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const SizedBox()),
          GoRoute(
            path: '/lecture-record/:timetableId',
            builder: (context, state) => LectureRecordScreen(
              timetableId: state.pathParameters['timetableId']!,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_MockAuthenticatedNotifier.new),
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp.router(
            theme: AppTheme.theme(Brightness.dark, Accent.jade),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.push('/lecture-record/${seeded.timetableId}');
      await tester.pumpAndSettle();

      // Scenario 1: real subject data renders, not fake placeholders.
      expect(find.text('Data Structures'), findsOneWidget);
      expect(find.text('Advanced Mathematics II'), findsNothing);

      await tester.tap(find.text('Present'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Lecture Record'));
      await tester.pumpAndSettle();

      final records = await database.select(database.lectureRecords).get();
      expect(records, hasLength(1));
      expect(records.single.timetableId, seeded.timetableId);
      expect(records.single.statusText, 'present');

      final legacyAttendance = await database.select(database.attendance).get();
      expect(legacyAttendance, isEmpty);

      // Scenario 2: reopening the same slot now shows the locked view.
      router.push('/lecture-record/${seeded.timetableId}');
      await tester.pumpAndSettle();

      expect(
        find.text('This record is permanent and cannot be edited.'),
        findsOneWidget,
      );
      expect(find.text('Save Lecture Record'), findsNothing);
    },
  );
}
