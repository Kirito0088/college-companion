import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/repositories/subjects_repository.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:college_companion/features/timetable/repositories/timetable_repository.dart';
import 'package:college_companion/features/timetable/screens/timetable_screen.dart';
import 'package:college_companion/features/timetable/widgets/add_edit_timetable_entry_dialog.dart';
import 'package:college_companion/features/timetable/widgets/day_selector_segmented_button.dart';
import 'package:college_companion/features/timetable/widgets/lecture_card.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/shared/widgets/cc_empty_state.dart';
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

  final mondayLectures = [
    const LectureScheduleItem(
      id: 'tt_1',
      userId: 'user_1',
      subjectId: 'subj_1',
      subjectName: 'Data Structures',
      faculty: 'Prof. Alan Turing',
      dayOfWeek: 0,
      startTime: '09:00:00',
      endTime: '10:00:00',
      room: 'Room 302',
      lectureType: 'theory',
      isCurrent: true,
    ),
    const LectureScheduleItem(
      id: 'tt_2',
      userId: 'user_1',
      subjectId: 'subj_2',
      subjectName: 'Algorithms Lab',
      faculty: 'Dr. Ada Lovelace',
      dayOfWeek: 0,
      startTime: '11:00:00',
      endTime: '13:00:00',
      room: 'Lab 1',
      lectureType: 'practical',
      isCurrent: false,
    ),
  ];

  final tuesdayLectures = [
    const LectureScheduleItem(
      id: 'tt_3',
      userId: 'user_1',
      subjectId: 'subj_3',
      subjectName: 'Operating Systems',
      faculty: 'Prof. Dennis Ritchie',
      dayOfWeek: 1,
      startTime: '14:00:00',
      endTime: '15:00:00',
      room: 'Room 101',
      lectureType: 'theory',
      isCurrent: false,
    ),
  ];

  group('TimetableScreen Widget Tests', () {
    testWidgets(
      'Renders empty state when no classes are scheduled for selected day',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
              selectedDayProvider.overrideWith((ref) => 6), // Sunday
              timetableForDayProvider(
                6,
              ).overrideWith((ref) => Stream.value([])),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const TimetableScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(DaySelectorSegmentedButton), findsOneWidget);
        expect(find.byType(CcEmptyState), findsOneWidget);
        expect(find.text('No classes scheduled'), findsOneWidget);
        expect(find.text('Enjoy your free day'), findsOneWidget);
        expect(find.byType(LectureCard), findsNothing);
      },
    );

    testWidgets(
      'Populates multiple lecture cards chronologically with details for selected day',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
              selectedDayProvider.overrideWith((ref) => 0), // Monday
              timetableForDayProvider(
                0,
              ).overrideWith((ref) => Stream.value(mondayLectures)),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const TimetableScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(LectureCard), findsNWidgets(2));
        expect(find.text('Data Structures'), findsOneWidget);
        expect(find.text('Prof. Alan Turing'), findsOneWidget);
        expect(find.text('Room 302'), findsOneWidget);

        expect(find.text('Algorithms Lab'), findsOneWidget);
        expect(find.text('Dr. Ada Lovelace'), findsOneWidget);
        expect(find.text('Lab 1'), findsOneWidget);

        expect(find.byType(CcEmptyState), findsNothing);
      },
    );

    testWidgets('Highlights active/current lecture slot', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
            selectedDayProvider.overrideWith((ref) => 0), // Monday
            timetableForDayProvider(
              0,
            ).overrideWith((ref) => Stream.value(mondayLectures)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const TimetableScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Active indicator text (e.g. 'NOW' or 'ACTIVE')
      expect(find.text('NOW'), findsOneWidget);
    });

    testWidgets('Day selector switches day and updates schedule view', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
          selectedDayProvider.overrideWith((ref) => 0),
          timetableForDayProvider(
            0,
          ).overrideWith((ref) => Stream.value(mondayLectures)),
          timetableForDayProvider(
            1,
          ).overrideWith((ref) => Stream.value(tuesdayLectures)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const TimetableScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Data Structures'), findsOneWidget);
      expect(find.text('Operating Systems'), findsNothing);

      // Tap on Tuesday ('Tue') tab
      final tueTab = find.text('Tue');
      expect(tueTab, findsOneWidget);
      await tester.tap(tueTab);
      await tester.pumpAndSettle();

      expect(container.read(selectedDayProvider), 1);
      expect(find.text('Operating Systems'), findsOneWidget);
      expect(find.text('Data Structures'), findsNothing);
    });

    testWidgets(
      'Tapping FAB opens AddEditTimetableEntryDialog and saves new lecture',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final database = AppDatabase.forTesting(NativeDatabase.memory());
        final syncQueue = SyncQueueRepository(database);
        final timetableRepo = TimetableRepository(database, syncQueue);
        final subjectRepo = SubjectRepository(database, syncQueue);

        final nowIso = DateTime.now().toUtc().toIso8601String();
        await database
            .into(database.users)
            .insert(
              UsersCompanion.insert(
                id: 'user_1',
                name: 'Test Student',
                email: 'test@example.com',
                createdAt: nowIso,
                updatedAt: nowIso,
              ),
            );

        await database
            .into(database.semesters)
            .insert(
              SemestersCompanion.insert(
                id: 'sem_1',
                userId: 'user_1',
                name: 'Semester 1',
                workingDays: '[0,1,2,3,4]',
                createdAt: nowIso,
                updatedAt: nowIso,
              ),
            );

        await subjectRepo.create(
          SubjectsCompanion(
            id: const Value('subj_math'),
            userId: const Value('user_1'),
            semesterId: const Value('sem_1'),
            name: const Value('Calculus I'),
            type: const Value('theory'),
            createdAt: Value(nowIso),
            updatedAt: Value(nowIso),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
              selectedDayProvider.overrideWith((ref) => 0),
              databaseProvider.overrideWithValue(database),
              syncQueueRepositoryProvider.overrideWithValue(syncQueue),
              timetableRepositoryProvider.overrideWithValue(timetableRepo),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const TimetableScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap FAB
        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);
        await tester.tap(fab);
        await tester.pumpAndSettle();

        // Dialog is open
        expect(find.byType(AddEditTimetableEntryDialog), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AddEditTimetableEntryDialog),
            matching: find.text('Add Class'),
          ),
          findsOneWidget,
        );

        // Enter Room
        await tester.enterText(
          find.byKey(const Key('timetable_room_field')),
          'Room 404',
        );

        // Select Subject from Dropdown
        final dropdownFinder = find.byKey(
          const Key('timetable_subject_dropdown'),
        );
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        final mathItem = find.text('Calculus I').last;
        await tester.tap(mathItem);
        await tester.pumpAndSettle();

        // Tap Save
        final saveBtn = find.byKey(const Key('timetable_save_button'));
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 1));

        // Verify inserted in DB and sync queue enqueued
        await tester.runAsync(() async {
          final savedLectures = await timetableRepo
              .watchLecturesForDay('user_1', 0)
              .first;
          expect(savedLectures.isNotEmpty, isTrue);
          expect(savedLectures.first.subjectName, 'Calculus I');
          expect(savedLectures.first.room, 'Room 404');

          final pending = await syncQueue.getPendingItems();
          expect(
            pending.any(
              (p) => p.targetTable == 'timetable' && p.operation == 'INSERT',
            ),
            isTrue,
          );

          await database.close();
        });
      },
    );
  });
}
