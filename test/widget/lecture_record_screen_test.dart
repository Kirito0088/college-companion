/// Widget tests for issue #7 — [LectureRecordScreen] must write to the
/// immutable `lecture_records` ledger via [LectureRecordRepository], not
/// the legacy mutable `attendance` table, and must render a locked
/// read-only view instead of the editable form once a slot already has a
/// record.
///
/// Uses a real in-memory [AppDatabase] so the actual repository write path
/// (`lectureRecordRepositoryProvider`) is exercised end-to-end. The screen's
/// read-side providers are overridden with fake streams built from
/// one-time fetches against that same database — the same
/// fake-stream-for-reads approach as `attendance_redesign_test.dart` and
/// `slice7_redesign_test.dart`'s `_pump` helper, which avoids a Drift
/// watch-stream dispose-timer issue when a live `watch()` query runs
/// inside a widget test.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/attendance_evidence_dao.dart';
import 'package:college_companion/features/attendance/providers/attendance_evidence_provider.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/screens/lecture_record_screen.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/providers/subject_detail_provider.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../support/test_db.dart' show seedGraph;

class _TestAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(
      uid: _userId,
      email: 'test@example.com',
      displayName: 'Test Student',
    ),
  );
}

const _userId = 'test_user_id';

/// Avoids a live Drift `.watch()` query inside a widget test (see file
/// doc comment) for `EvidenceThumbnailStrip`'s evidence stream — the
/// screen renders it in both the form and the locked view, but evidence
/// capture itself is out of scope for issue #7.
class _FakeEvidenceDao extends AttendanceEvidenceDao {
  _FakeEvidenceDao(super.database);

  @override
  Stream<List<LectureEvidenceEntity>> watchEvidenceForRecord(String recordId) =>
      Stream.value(const []);
}

Future<void> _pumpScreen(
  WidgetTester tester,
  AppDatabase database,
  String timetableId,
  String subjectId, {
  required LectureRecordEntity? existingRecord,
}) async {
  final timetableEntry = await database.select(database.timetable).getSingle();
  final subject = await (database.select(
    database.subjects,
  )..where((t) => t.id.equals(subjectId))).getSingle();

  // A real back-stack entry so `context.pop()` in the screen's save
  // handler has somewhere to go — the production router always pushes
  // this screen on top of an existing route (e.g. from `LectureCard`'s
  // "Record Lecture" action). Navigating via a real tap (rather than
  // calling `router.push` directly) matches that production path and
  // keeps the router's `RouteInformationProvider` in sync within the
  // test's frame scheduling.
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.push('/lecture-record/$timetableId'),
              child: const Text('Open Lecture Record'),
            ),
          ),
        ),
      ),
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
        authStateProvider.overrideWith(_TestAuthStateNotifier.new),
        databaseProvider.overrideWithValue(database),
        timetableEntryByIdProvider.overrideWith(
          (ref, id) => Stream.value(timetableEntry),
        ),
        subjectByIdStreamProvider.overrideWith(
          (ref, params) => Stream.value(subject),
        ),
        lectureRecordByTimetableIdProvider.overrideWith(
          (ref, params) => Stream.value(existingRecord),
        ),
        attendanceEvidenceDaoProvider.overrideWith(
          (ref) => _FakeEvidenceDao(database),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.theme(Brightness.dark, Accent.jade),
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();

  await tester.tap(find.text('Open Lecture Record'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('LectureRecordScreen (issue #7)', () {
    testWidgets(
      'Scenario 1: renders real timetable/subject data, and saving writes '
      'to lecture_records — not the legacy attendance table',
      (tester) async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);
        final seeded = await seedGraph(database, userId: _userId);

        await _pumpScreen(
          tester,
          database,
          seeded.timetableId,
          seeded.subjectId,
          existingRecord: null,
        );

        // Real subject name from the DB, not the old hardcoded fake info.
        expect(find.text('Data Structures'), findsOneWidget);
        expect(find.text('Advanced Mathematics II'), findsNothing);
        expect(find.text('Room 402'), findsNothing);
        expect(find.text('Dr. A. Sharma'), findsNothing);

        await tester.tap(find.text('Present'));
        await tester.pump();
        await tester.tap(find.text('Save Lecture Record'));
        await tester.pumpAndSettle();

        final records = await database.select(database.lectureRecords).get();
        expect(records, hasLength(1));
        expect(records.single.timetableId, seeded.timetableId);
        expect(records.single.subjectId, seeded.subjectId);
        expect(records.single.semesterId, seeded.semesterId);
        expect(records.single.statusText, 'present');

        final legacyAttendance = await database
            .select(database.attendance)
            .get();
        expect(
          legacyAttendance,
          isEmpty,
          reason: 'must not fall back to the legacy attendance table',
        );
      },
    );

    testWidgets(
      'Scenario 2: an existing record renders a locked read-only view, '
      'not the editable form, and does not allow a second save',
      (tester) async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);
        final seeded = await seedGraph(database, userId: _userId);

        final now = DateTime.now().toUtc();
        final record = await database
            .into(database.lectureRecords)
            .insertReturning(
              LectureRecordsCompanion.insert(
                id: 'rec-1',
                timetableId: seeded.timetableId,
                subjectId: seeded.subjectId,
                semesterId: seeded.semesterId,
                userId: _userId,
                statusText: 'absent|holiday',
                recordedAt: now,
                deviceTimezone: 'Asia/Kolkata',
                appVersion: '1.0.0',
              ),
            );

        await _pumpScreen(
          tester,
          database,
          seeded.timetableId,
          seeded.subjectId,
          existingRecord: record,
        );

        expect(
          find.text('This record is permanent and cannot be edited.'),
          findsOneWidget,
        );
        expect(find.text('Save Lecture Record'), findsNothing);
        expect(find.text('Absent'), findsOneWidget);

        // Still exactly one record — nothing re-created a duplicate.
        final records = await database.select(database.lectureRecords).get();
        expect(records, hasLength(1));
      },
    );
  });
}
