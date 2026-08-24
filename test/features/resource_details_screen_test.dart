import 'dart:io';

import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/resources/providers/resources_provider.dart';
import 'package:college_companion/features/resources/repositories/resources_repository.dart';
import 'package:college_companion/features/resources/screens/resource_details_screen.dart';
import 'package:college_companion/features/subjects/repositories/subjects_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/services/resource_file_service.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_filex/open_filex.dart';

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
  late ResourcesRepository resourcesRepo;
  late SubjectRepository subjectRepo;
  late Directory tempDir;
  late List<String> openedPaths;

  const testUserId = 'user_1';
  const testSubjectId = 'subj_ds';
  const testResourceId = 'res_1';
  const testRelativePath = 'files/compiler_design_notes.pdf';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueue = SyncQueueRepository(db);
    resourcesRepo = ResourcesRepository(db, syncQueue);
    subjectRepo = SubjectRepository(db, syncQueue);
    tempDir = Directory.systemTemp.createTempSync('resource_details_test_');
    openedPaths = [];

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

    await resourcesRepo.create(
      ResourcesCompanion(
        id: const Value(testResourceId),
        userId: const Value(testUserId),
        subjectId: const Value(testSubjectId),
        title: const Value('Compiler Design Notes'),
        url: const Value(testRelativePath),
        category: const Value('notes'),
        createdAt: Value(nowIso),
        updatedAt: Value(nowIso),
      ),
    );

    // 2560 bytes on disk -> 2.5 KB once formatted.
    final file = File('${tempDir.path}/$testRelativePath');
    file.createSync(recursive: true);
    file.writeAsBytesSync(List<int>.filled(2560, 1));
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget buildScreen(String resourceId) {
    return ProviderScope(
      overrides: [
        authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
        databaseProvider.overrideWithValue(db),
        syncQueueRepositoryProvider.overrideWithValue(syncQueue),
        resourceFileServiceProvider.overrideWithValue(
          ResourceFileService(
            getAppDocDir: () async => tempDir,
            openFile: (path) async {
              openedPaths.add(path);
              return OpenResult(type: ResultType.done, message: 'done');
            },
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: ResourceDetailsScreen(resourceId: resourceId),
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester, String resourceId) async {
    await tester.pumpWidget(buildScreen(resourceId));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  group('ResourceDetailsScreen', () {
    testWidgets(
      'Renders real title, subject, extension badge, size, and path — no hardcoded data',
      (tester) async {
        await pumpScreen(tester, testResourceId);

        expect(find.text('Compiler Design Notes'), findsOneWidget);
        expect(find.text('Operating Systems Unit 3 Notes'), findsNothing);
        expect(find.textContaining('Data Structures'), findsWidgets);
        expect(find.text('PDF'), findsOneWidget);
        expect(find.text('2.5 KB'), findsOneWidget);
        expect(find.textContaining(testRelativePath), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'Tapping Open launches the native file viewer at the resolved absolute path',
      (tester) async {
        await pumpScreen(tester, testResourceId);

        final openAction = find.byKey(const Key('resource_action_open'));
        expect(openAction, findsOneWidget);
        await tester.tap(openAction);
        await tester.pumpAndSettle();

        expect(openedPaths, ['${tempDir.path}/$testRelativePath']);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets('Shows a not-found empty state for an unknown resource id', (
      tester,
    ) async {
      await pumpScreen(tester, 'does_not_exist');

      expect(find.text('Resource not found'), findsOneWidget);
      expect(find.byKey(const Key('resource_action_open')), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'Flags a missing local file instead of claiming it is stored locally',
      (tester) async {
        await resourcesRepo.create(
          ResourcesCompanion(
            id: const Value('res_missing'),
            userId: const Value(testUserId),
            subjectId: const Value(testSubjectId),
            title: const Value('Deleted From Disk Notes'),
            url: const Value('files/does_not_exist_on_disk.pdf'),
            category: const Value('notes'),
            createdAt: Value(DateTime.now().toUtc().toIso8601String()),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );

        await pumpScreen(tester, 'res_missing');

        expect(
          find.textContaining('not available on this device'),
          findsOneWidget,
        );
        final openAction = tester.widget<IconButton>(
          find.byKey(const Key('resource_action_open')),
        );
        expect(openAction.onPressed, isNull);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );
  });
}
