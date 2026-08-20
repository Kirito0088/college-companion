import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/features/subjects/repositories/subjects_repository.dart';
import 'package:college_companion/features/subjects/screens/subject_details_screen.dart';
import 'package:college_companion/features/subjects/widgets/subject_details_header.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(
      uid: 'user_1',
      email: 'student@example.com',
      displayName: 'Test Student',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SyncQueueRepository syncQueue;
  late SubjectRepository subjectRepo;
  late AttendanceRepository attendanceRepo;

  const testUserId = 'user_1';
  const testSubjectId = 'subj_data_struct';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueue = SyncQueueRepository(db);
    subjectRepo = SubjectRepository(db, syncQueue);
    attendanceRepo = AttendanceRepository(db, syncQueue);

    final nowIso = DateTime.now().toUtc().toIso8601String();

    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: testUserId,
            name: 'Test Student',
            email: 'test@example.com',
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );

    await db
        .into(db.semesters)
        .insert(
          SemestersCompanion.insert(
            id: 'sem_1',
            userId: testUserId,
            name: 'Semester 5',
            workingDays: '[0,1,2,3,4]',
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );

    await subjectRepo.create(
      SubjectsCompanion(
        id: const Value(testSubjectId),
        userId: const Value(testUserId),
        semesterId: const Value('sem_1'),
        name: const Value('Data Structures'),
        faculty: const Value('Prof. Alan Turing'),
        type: const Value('theory'),
        createdAt: Value(nowIso),
        updatedAt: Value(nowIso),
      ),
    );

    // Seed 5 attendance records: 3 Present, 1 Absent, 1 Cancelled
    // Total held = 3 + 1 = 4. Attended = 3. Current % = 75.0%.
    await attendanceRepo.create(
      AttendanceCompanion.insert(
        id: 'att_1',
        userId: testUserId,
        subjectId: testSubjectId,
        date: '2026-08-01',
        primaryStatus: 'present',
        lectureType: 'theory',
        notes: const Value('Binary Search Trees'),
        createdAt: '2026-08-01T09:00:00.000Z',
        updatedAt: '2026-08-01T09:00:00.000Z',
      ),
    );
    await attendanceRepo.create(
      AttendanceCompanion.insert(
        id: 'att_2',
        userId: testUserId,
        subjectId: testSubjectId,
        date: '2026-08-02',
        primaryStatus: 'present',
        lectureType: 'theory',
        notes: const Value('AVL Trees'),
        createdAt: '2026-08-02T09:00:00.000Z',
        updatedAt: '2026-08-02T09:00:00.000Z',
      ),
    );
    await attendanceRepo.create(
      AttendanceCompanion.insert(
        id: 'att_3',
        userId: testUserId,
        subjectId: testSubjectId,
        date: '2026-08-03',
        primaryStatus: 'present',
        lectureType: 'theory',
        notes: const Value('B-Trees'),
        createdAt: '2026-08-03T09:00:00.000Z',
        updatedAt: '2026-08-03T09:00:00.000Z',
      ),
    );
    await attendanceRepo.create(
      AttendanceCompanion.insert(
        id: 'att_4',
        userId: testUserId,
        subjectId: testSubjectId,
        date: '2026-08-04',
        primaryStatus: 'absent',
        lectureType: 'theory',
        notes: const Value('Red-Black Trees'),
        createdAt: '2026-08-04T09:00:00.000Z',
        updatedAt: '2026-08-04T09:00:00.000Z',
      ),
    );
    await attendanceRepo.create(
      AttendanceCompanion.insert(
        id: 'att_5',
        userId: testUserId,
        subjectId: testSubjectId,
        date: '2026-08-05',
        primaryStatus: 'cancelled',
        lectureType: 'theory',
        notes: const Value('Faculty On Leave'),
        createdAt: '2026-08-05T09:00:00.000Z',
        updatedAt: '2026-08-05T09:00:00.000Z',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubjectDetailsScreen() {
    return ProviderScope(
      overrides: [
        authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
        databaseProvider.overrideWithValue(db),
        syncQueueRepositoryProvider.overrideWithValue(syncQueue),
        subjectRepositoryProvider.overrideWithValue(subjectRepo),
        attendanceRepositoryProvider.overrideWithValue(attendanceRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const SubjectDetailsScreen(subjectId: testSubjectId),
      ),
    );
  }

  Future<void> pumpSubjectScreen(WidgetTester tester) async {
    await tester.pumpWidget(buildSubjectDetailsScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  group('SubjectDetailsScreen Widget & Integration Tests', () {
    testWidgets(
      'Renders subject details header with name, faculty, and type badge',
      (tester) async {
        await pumpSubjectScreen(tester);

        expect(find.text('Data Structures'), findsWidgets);
        expect(find.text('Prof. Alan Turing'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SubjectDetailsHeader),
            matching: find.text('THEORY'),
          ),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'Renders metric overview cards with current %, status badge, and bunk metrics',
      (tester) async {
        await pumpSubjectScreen(tester);

        // 3 present / 4 held = 75%
        expect(find.text('75%'), findsOneWidget);
        expect(find.text('On Track'), findsOneWidget);
        expect(find.text('3 / 4 Classes'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'Renders attendance log timeline list with present, absent, and cancelled records',
      (tester) async {
        await pumpSubjectScreen(tester);

        expect(find.text('Binary Search Trees'), findsOneWidget);
        expect(find.text('AVL Trees'), findsOneWidget);
        expect(find.text('B-Trees'), findsOneWidget);
        expect(find.text('Red-Black Trees'), findsOneWidget);
        expect(find.text('Faculty On Leave'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets('Filter chips filter timeline records by status', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpSubjectScreen(tester);

      // All records visible initially
      expect(find.text('Binary Search Trees'), findsOneWidget);
      expect(find.text('Red-Black Trees'), findsOneWidget);
      expect(find.text('Faculty On Leave'), findsOneWidget);

      // Tap 'Present' filter chip
      final presentChip = find.widgetWithText(FilterChip, 'Present (3)');
      expect(presentChip, findsOneWidget);
      await tester.ensureVisible(presentChip);
      await tester.tap(presentChip);
      await tester.pumpAndSettle();

      expect(find.text('Binary Search Trees'), findsOneWidget);
      expect(find.text('AVL Trees'), findsOneWidget);
      expect(find.text('B-Trees'), findsOneWidget);
      expect(find.text('Red-Black Trees'), findsNothing);
      expect(find.text('Faculty On Leave'), findsNothing);

      // Tap 'Absent' filter chip
      final absentChip = find.widgetWithText(FilterChip, 'Absent (1)');
      expect(absentChip, findsOneWidget);
      await tester.ensureVisible(absentChip);
      await tester.tap(absentChip);
      await tester.pumpAndSettle();

      expect(find.text('Red-Black Trees'), findsOneWidget);
      expect(find.text('Binary Search Trees'), findsNothing);
      expect(find.text('Faculty On Leave'), findsNothing);

      // Tap 'Cancelled' filter chip
      final cancelledChip = find.widgetWithText(FilterChip, 'Cancelled (1)');
      expect(cancelledChip, findsOneWidget);
      await tester.ensureVisible(cancelledChip);
      await tester.tap(cancelledChip);
      await tester.pumpAndSettle();

      expect(find.text('Faculty On Leave'), findsOneWidget);
      expect(find.text('Binary Search Trees'), findsNothing);
      expect(find.text('Red-Black Trees'), findsNothing);

      // Tap 'All' filter chip
      final allChip = find.widgetWithText(FilterChip, 'All (5)');
      expect(allChip, findsOneWidget);
      await tester.ensureVisible(allChip);
      await tester.tap(allChip);
      await tester.pumpAndSettle();

      expect(find.text('Binary Search Trees'), findsOneWidget);
      expect(find.text('Red-Black Trees'), findsOneWidget);
      expect(find.text('Faculty On Leave'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'Quick attendance mark action dialog adds new attendance and updates UI reactively',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpSubjectScreen(tester);

        // Tap "Mark Attendance" FAB / button
        final markButton = find.byKey(const Key('mark_attendance_fab'));
        expect(markButton, findsOneWidget);
        await tester.tap(markButton);
        await tester.pumpAndSettle();

        // Verify modal/sheet opened
        expect(find.text('Mark Attendance'), findsWidgets);

        // Enter notes
        final notesField = find.byKey(const Key('attendance_notes_field'));
        expect(notesField, findsOneWidget);
        await tester.enterText(notesField, 'Graph Algorithms');

        // Select 'Present' status
        final presentOption = find.byKey(const Key('status_present_option'));
        expect(presentOption, findsOneWidget);
        await tester.tap(presentOption);
        await tester.pumpAndSettle();

        // Tap Save
        final saveButton = find.byKey(const Key('save_attendance_button'));
        expect(saveButton, findsOneWidget);
        await tester.tap(saveButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // UI should now show 4 / 5 classes attended = 80% (4 present, 1 absent out of 5 held)
        expect(find.text('Graph Algorithms'), findsOneWidget);
        expect(find.text('80%'), findsOneWidget);
        expect(find.text('4 / 5 Classes'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );
  });
}
