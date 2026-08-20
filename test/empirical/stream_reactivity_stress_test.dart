import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/features/resources/providers/resources_provider.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testUserId = 'test_user_empirical_1';

  group('Group 1: Reactive Emission Empirical Stress Tests', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('assignmentsStreamProvider emits on insert, update, and soft-delete', () async {
      final emittedValues = <List<AssignmentEntity>>[];
      final subscription = container.listen<AsyncValue<List<AssignmentEntity>>>(
        assignmentsStreamProvider(testUserId),
        (_, next) {
          if (next.hasValue) {
            emittedValues.add(next.value!);
          }
        },
        fireImmediately: true,
      );

      // Give initial emission a microtask
      await pumpEventQueue();

      final repo = container.read(assignmentRepositoryProvider);
      final nowIso = DateTime.now().toUtc().toIso8601String();

      // 1. Insert
      final id = await repo.create(
        AssignmentsCompanion.insert(
          id: 'asgn_test_1',
          userId: testUserId,
          subjectId: 'sub_math',
          title: 'Math Assignment 1',
          dueDate: nowIso,
          status: 'pending',
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );
      await pumpEventQueue();

      // 2. Update
      await repo.markCompleted(testUserId, id);
      await pumpEventQueue();

      // 3. Soft Delete
      await repo.delete(testUserId, id);
      await pumpEventQueue();

      subscription.close();

      // Verify states
      expect(emittedValues.length, greaterThanOrEqualTo(4));
      // First: []
      expect(emittedValues[0], isEmpty);
      // Second: [1 item, status pending]
      expect(emittedValues[1].length, 1);
      expect(emittedValues[1].first.title, 'Math Assignment 1');
      expect(emittedValues[1].first.status, 'pending');
      // Third: [1 item, status completed]
      expect(emittedValues[2].length, 1);
      expect(emittedValues[2].first.status, 'completed');
      // Fourth: [] after soft-delete
      expect(emittedValues.last, isEmpty);
    });

    test('safeBunkStreamProvider emits updated calculations on attendance insert, update, and soft-delete', () async {
      final emittedResults = <SafeBunkResult>[];
      final subscription = container.listen<AsyncValue<SafeBunkResult>>(
        safeBunkStreamProvider(testUserId),
        (_, next) {
          if (next.hasValue) {
            emittedResults.add(next.value!);
          }
        },
        fireImmediately: true,
      );

      await pumpEventQueue();

      final nowIso = DateTime.now().toUtc().toIso8601String();

      // 1. Insert 4 present records
      for (int i = 0; i < 4; i++) {
        await db.into(db.attendance).insert(
          AttendanceCompanion.insert(
            id: 'att_p_$i',
            userId: testUserId,
            subjectId: 'sub_1',
            date: nowIso,
            lectureType: 'theory',
            primaryStatus: 'present',
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );
        await pumpEventQueue();
      }

      // 2. Update record 0 to absent
      await (db.update(db.attendance)..where((t) => t.id.equals('att_p_0'))).write(
        AttendanceCompanion(
          primaryStatus: const Value('absent'),
          updatedAt: Value(nowIso),
        ),
      );
      await pumpEventQueue();

      // 3. Soft delete record 0
      await (db.update(db.attendance)..where((t) => t.id.equals('att_p_0'))).write(
        AttendanceCompanion(
          deletedAt: Value(nowIso),
        ),
      );
      await pumpEventQueue();

      subscription.close();

      expect(emittedResults.isNotEmpty, true);
      // Initial: 0 attended, 0 total
      expect(emittedResults.first.total, 0);
      
      // After 4 present: attended = 4, total = 4, pct = 100%
      final after4Present = emittedResults.firstWhere((r) => r.total == 4);
      expect(after4Present.attended, 4);
      expect(after4Present.currentPercentage, 100.0);

      // After updating record 0 to absent: total = 4, attended = 3, pct = 75%
      final afterUpdate = emittedResults.firstWhere((r) => r.total == 4 && r.attended == 3);
      expect(afterUpdate.currentPercentage, 75.0);

      // After soft deleting record 0: total = 3, attended = 3, pct = 100%
      final finalResult = emittedResults.last;
      expect(finalResult.total, 3);
      expect(finalResult.attended, 3);
    });

    test('calendarEventsStreamProvider emits on insert, update, and soft-delete', () async {
      final emittedValues = <List<CalendarEventEntity>>[];
      final subscription = container.listen<AsyncValue<List<CalendarEventEntity>>>(
        calendarEventsStreamProvider(testUserId),
        (_, next) {
          if (next.hasValue) {
            emittedValues.add(next.value!);
          }
        },
        fireImmediately: true,
      );

      await pumpEventQueue();

      final repo = container.read(calendarRepositoryProvider);
      final nowIso = DateTime.now().toUtc().toIso8601String();

      // 1. Insert
      final id = await repo.create(
        CalendarEventsCompanion.insert(
          id: 'evt_1',
          userId: testUserId,
          title: 'Physics Lab',
          startDate: nowIso,
          endDate: nowIso,
          eventType: 'lab',
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );
      await pumpEventQueue();

      // 2. Update
      await repo.update(
        testUserId,
        id,
        const CalendarEventsCompanion(
          title: Value('Advanced Physics Lab'),
        ),
      );
      await pumpEventQueue();

      // 3. Soft Delete
      await repo.delete(testUserId, id);
      await pumpEventQueue();

      subscription.close();

      expect(emittedValues.length, greaterThanOrEqualTo(4));
      expect(emittedValues[0], isEmpty);
      expect(emittedValues[1].first.title, 'Physics Lab');
      expect(emittedValues[2].first.title, 'Advanced Physics Lab');
      expect(emittedValues.last, isEmpty);
    });

    test('resourcesStreamProvider emits on insert, update, and soft-delete', () async {
      final emittedValues = <List<ResourceEntity>>[];
      final subscription = container.listen<AsyncValue<List<ResourceEntity>>>(
        resourcesStreamProvider(testUserId),
        (_, next) {
          if (next.hasValue) {
            emittedValues.add(next.value!);
          }
        },
        fireImmediately: true,
      );

      await pumpEventQueue();

      final repo = container.read(resourcesRepositoryProvider);
      final nowIso = DateTime.now().toUtc().toIso8601String();

      // 1. Insert
      final id = await repo.create(
        ResourcesCompanion.insert(
          id: 'res_1',
          userId: testUserId,
          title: 'Chapter 1 Notes',
          url: 'https://example.com/ch1.pdf',
          category: 'Notes',
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );
      await pumpEventQueue();

      // 2. Update
      await repo.update(
        testUserId,
        id,
        const ResourcesCompanion(
          title: Value('Updated Chapter 1 Notes'),
        ),
      );
      await pumpEventQueue();

      // 3. Soft Delete
      await repo.delete(testUserId, id);
      await pumpEventQueue();

      subscription.close();

      expect(emittedValues.length, greaterThanOrEqualTo(4));
      expect(emittedValues[0], isEmpty);
      expect(emittedValues[1].first.title, 'Chapter 1 Notes');
      expect(emittedValues[2].first.title, 'Updated Chapter 1 Notes');
      expect(emittedValues.last, isEmpty);
    });

    test('userSettingsStreamProvider emits on insert and update', () async {
      final emittedValues = <UserSettingsEntity?>[];
      final subscription = container.listen<AsyncValue<UserSettingsEntity?>>(
        userSettingsStreamProvider(testUserId),
        (_, next) {
          if (next.hasValue) {
            emittedValues.add(next.value);
          }
        },
        fireImmediately: true,
      );

      await pumpEventQueue();

      final repo = container.read(userSettingsRepositoryProvider);
      final nowIso = DateTime.now().toUtc().toIso8601String();

      // 1. Save initial settings
      await repo.saveSettings(
        UserSettingsCompanion.insert(
          id: 'sett_1',
          userId: testUserId,
          theme: const Value('dark'),
          notificationsEnabled: const Value(true),
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );
      await pumpEventQueue();

      // 2. Update theme
      await repo.updateTheme(testUserId, 'light');
      await pumpEventQueue();

      subscription.close();

      expect(emittedValues.length, greaterThanOrEqualTo(3));
      expect(emittedValues[0], isNull);
      expect(emittedValues[1]?.theme, 'dark');
      expect(emittedValues[2]?.theme, 'light');
    });

    test('dashboardSnapshotProvider automatically re-synthesizes state when streams emit changes', () async {
      // Listen to dashboardSnapshotProvider
      final snapshots = <DashboardSnapshot>[];
      final subscription = container.listen<AsyncValue<DashboardSnapshot>>(
        dashboardSnapshotProvider(testUserId),
        (_, next) {
          if (next.hasValue) {
            snapshots.add(next.value!);
          }
        },
        fireImmediately: true,
      );

      await pumpEventQueue();

      final assignmentsRepo = container.read(assignmentRepositoryProvider);
      final calendarRepo = container.read(calendarRepositoryProvider);
      final nowIso = DateTime.now().toUtc().toIso8601String();

      // Insert event today
      await calendarRepo.create(
        CalendarEventsCompanion.insert(
          id: 'evt_dash_1',
          userId: testUserId,
          title: 'Morning Lecture',
          startDate: nowIso,
          endDate: nowIso,
          eventType: 'lecture',
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );
      await pumpEventQueue();

      // Insert assignment
      await assignmentsRepo.create(
        AssignmentsCompanion.insert(
          id: 'asgn_dash_1',
          userId: testUserId,
          subjectId: 'sub_1',
          title: 'HW 1',
          dueDate: nowIso,
          status: 'pending',
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );
      await pumpEventQueue();

      subscription.close();

      expect(snapshots.isNotEmpty, true);
      final lastSnapshot = snapshots.last;
      expect(lastSnapshot.academicSnapshot, isNotNull);
      expect(lastSnapshot.academicSnapshot.deadlinesState, contains('Due Today'));
    });
  });

  group('Group 2: SafeBunkCalculator Mathematical Boundary & Stress Tests', () {
    test('Boundary 1: 0 total lectures', () {
      final res = SafeBunkCalculator.calculate(attended: 0, total: 0);
      expect(res.attended, 0);
      expect(res.total, 0);
      expect(res.currentPercentage, 0.0);
      expect(res.safeBunks, 0);
      expect(res.mustAttend, 0);

      // Negative total edge case
      final resNeg = SafeBunkCalculator.calculate(attended: 0, total: -5);
      expect(resNeg.currentPercentage, 0.0);
      expect(resNeg.safeBunks, 0);
      expect(resNeg.mustAttend, 0);
    });

    test('Boundary 2: 100% attendance across small and large counts', () {
      // 10 / 10 @ 75% target
      // maxBunks = floor((1000 - 750)/75) = floor(250/75) = 3
      final res10 = SafeBunkCalculator.calculate(attended: 10, total: 10);
      expect(res10.currentPercentage, 100.0);
      expect(res10.safeBunks, 3);
      expect(res10.mustAttend, 0);

      // 100 / 100 @ 75% target
      // maxBunks = floor((10000 - 7500)/75) = floor(2500/75) = 33
      final res100 = SafeBunkCalculator.calculate(attended: 100, total: 100);
      expect(res100.currentPercentage, 100.0);
      expect(res100.safeBunks, 33);
      expect(res100.mustAttend, 0);
    });

    test('Boundary 3: Exactly 75% target attendance', () {
      // 3 / 4 = 75%
      final res4 = SafeBunkCalculator.calculate(attended: 3, total: 4);
      expect(res4.currentPercentage, 75.0);
      expect(res4.safeBunks, 0);
      expect(res4.mustAttend, 0);

      // 75 / 100 = 75%
      final res100 = SafeBunkCalculator.calculate(attended: 75, total: 100);
      expect(res100.currentPercentage, 75.0);
      expect(res100.safeBunks, 0);
      expect(res100.mustAttend, 0);
    });

    test('Boundary 4: < 75% attendance needing mustAttend calculations', () {
      // 50 / 100 = 50%
      // needed = ceil((75*100 - 100*50) / (100 - 75)) = ceil((7500 - 5000)/25) = 100
      final res50 = SafeBunkCalculator.calculate(attended: 50, total: 100);
      expect(res50.currentPercentage, 50.0);
      expect(res50.safeBunks, 0);
      expect(res50.mustAttend, 100);

      // Verify mathematical check: (50 + 100) / (100 + 100) = 150 / 200 = 75%
      final verification = (50 + res50.mustAttend) / (100 + res50.mustAttend) * 100.0;
      expect(verification, 75.0);

      // 74 / 100 = 74%
      // needed = ceil((7500 - 7400)/25) = ceil(100/25) = 4
      final res74 = SafeBunkCalculator.calculate(attended: 74, total: 100);
      expect(res74.currentPercentage, 74.0);
      expect(res74.mustAttend, 4);

      // Verification: (74 + 4) / (100 + 4) = 78 / 104 = 75%
      expect((74 + 4) / (100 + 4) * 100.0, closeTo(75.0, 0.001));
    });

    test('Boundary 5: Custom target percentages', () {
      // 80 / 100 = 80%, target = 85%
      // needed = ceil((8500 - 8000)/(100 - 85)) = ceil(500/15) = 34
      final res85 = SafeBunkCalculator.calculate(
        attended: 80,
        total: 100,
        targetPercentage: 85.0,
      );
      expect(res85.currentPercentage, 80.0);
      expect(res85.targetPercentage, 85.0);
      expect(res85.mustAttend, 34);

      // 80 / 100 = 80%, target = 60%
      // maxBunks = floor((8000 - 6000)/60) = floor(2000/60) = 33
      final res60 = SafeBunkCalculator.calculate(
        attended: 80,
        total: 100,
        targetPercentage: 60.0,
      );
      expect(res60.safeBunks, 33);
      expect(res60.mustAttend, 0);
    });

    test('Boundary 6: Large lecture counts (10 million lectures)', () {
      const largeTotal = 10000000;
      const largeAttended = 8000000; // 80%
      
      final res = SafeBunkCalculator.calculate(
        attended: largeAttended,
        total: largeTotal,
        targetPercentage: 75.0,
      );

      expect(res.currentPercentage, 80.0);
      // maxBunks = floor((8M * 100 - 75 * 10M)/75) = floor((800M - 750M)/75) = floor(50M / 75) = 666,666
      expect(res.safeBunks, 666666);
      expect(res.mustAttend, 0);
    });
  });

  group('Group 3: Dashboard Synthesis Stress Tests', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('Synthesizes empty state correctly', () async {
      final snapshot = await container.read(dashboardSnapshotProvider(testUserId).future);

      expect(snapshot.greetingContext, '0 lectures today');
      expect(snapshot.nextAction, isNull);
      expect(snapshot.timelineEvents, isEmpty);
      expect(snapshot.academicSnapshot.deadlinesState, 'All clear');
      expect(snapshot.academicSnapshot.workloadState, 'Manageable');
      // FIX VERIFICATION: When total lectures = 0, dashboardSnapshotProvider reports 'No Data'.
      expect(snapshot.academicSnapshot.attendanceState, 'No Data');
    });

    test('Synthesizes heavy workload (> 3 pending assignments)', () async {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final assignmentsRepo = container.read(assignmentRepositoryProvider);

      for (int i = 1; i <= 5; i++) {
        await assignmentsRepo.create(
          AssignmentsCompanion.insert(
            id: 'asgn_heavy_$i',
            userId: testUserId,
            subjectId: 'sub_1',
            title: 'Assignment $i',
            dueDate: nowIso,
            status: 'pending',
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );
      }

      final snapshot = await container.read(dashboardSnapshotProvider(testUserId).future);
      expect(snapshot.academicSnapshot.workloadState, 'Heavy');
      expect(snapshot.academicSnapshot.deadlinesState, '5 Due Today');
    });

    test('Synthesizes critical attendance status (< 75%)', () async {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      // Insert 1 present, 3 absent -> 25%
      await db.into(db.attendance).insert(
        AttendanceCompanion.insert(
          id: 'att_crit_p',
          userId: testUserId,
          subjectId: 'sub_1',
          date: nowIso,
          lectureType: 'theory',
          primaryStatus: 'present',
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );
      for (int i = 0; i < 3; i++) {
        await db.into(db.attendance).insert(
          AttendanceCompanion.insert(
            id: 'att_crit_a_$i',
            userId: testUserId,
            subjectId: 'sub_1',
            date: nowIso,
            lectureType: 'theory',
            primaryStatus: 'absent',
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );
      }

      final snapshot = await container.read(dashboardSnapshotProvider(testUserId).future);
      expect(snapshot.academicSnapshot.attendanceState, 'Critical (25%)');
    });
  });

  group('Group 4: Rapid Concurrency Stress Tests', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('Performs 100 concurrent db operations across tables without deadlock or failure', () async {
      final assignmentsRepo = container.read(assignmentRepositoryProvider);
      final calendarRepo = container.read(calendarRepositoryProvider);
      final resourcesRepo = container.read(resourcesRepositoryProvider);
      final settingsRepo = container.read(userSettingsRepositoryProvider);
      final attendanceRepo = container.read(attendanceRepositoryProvider);

      final nowIso = DateTime.now().toUtc().toIso8601String();
      final futures = <Future<void>>[];

      // 20 rapid assignment creations
      for (int i = 0; i < 20; i++) {
        futures.add(
          assignmentsRepo.create(
            AssignmentsCompanion.insert(
              id: 'concurrent_asgn_$i',
              userId: testUserId,
              subjectId: 'sub_concurrent',
              title: 'Concurrent HW $i',
              dueDate: nowIso,
              status: 'pending',
              createdAt: nowIso,
              updatedAt: nowIso,
            ),
          ).then((_) => null),
        );
      }

      // 20 rapid calendar event creations
      for (int i = 0; i < 20; i++) {
        futures.add(
          calendarRepo.create(
            CalendarEventsCompanion.insert(
              id: 'concurrent_evt_$i',
              userId: testUserId,
              title: 'Concurrent Event $i',
              startDate: nowIso,
              endDate: nowIso,
              eventType: 'lecture',
              createdAt: nowIso,
              updatedAt: nowIso,
            ),
          ).then((_) => null),
        );
      }

      // 20 rapid resource creations
      for (int i = 0; i < 20; i++) {
        futures.add(
          resourcesRepo.create(
            ResourcesCompanion.insert(
              id: 'concurrent_res_$i',
              userId: testUserId,
              title: 'Concurrent Resource $i',
              url: 'https://example.com/res_$i',
              category: 'General',
              createdAt: nowIso,
              updatedAt: nowIso,
            ),
          ).then((_) => null),
        );
      }

      // 20 rapid attendance record insertions directly into DB
      for (int i = 0; i < 20; i++) {
        futures.add(
          db.into(db.attendance).insert(
            AttendanceCompanion.insert(
              id: 'concurrent_att_$i',
              userId: testUserId,
              subjectId: 'sub_concurrent',
              date: nowIso,
              lectureType: 'theory',
              primaryStatus: i % 2 == 0 ? 'present' : 'absent',
              createdAt: nowIso,
              updatedAt: nowIso,
            ),
          ).then((_) => null),
        );
      }

      // 20 rapid setting updates
      for (int i = 0; i < 20; i++) {
        futures.add(
          settingsRepo.saveSettings(
            UserSettingsCompanion.insert(
              id: 'sett_conc',
              userId: testUserId,
              theme: Value(i % 2 == 0 ? 'dark' : 'light'),
              createdAt: nowIso,
              updatedAt: nowIso,
            ),
          ),
        );
      }

      // Execute all 100 concurrent operations in parallel
      await expectLater(Future.wait(futures), completes);

      // Verify database integrity
      final assignments = await assignmentsRepo.watchAll(testUserId).first;
      final events = await calendarRepo.watchAll(testUserId).first;
      final resources = await resourcesRepo.watchAll(testUserId).first;
      final safeBunk = await attendanceRepo.watchAll(testUserId).first;

      expect(assignments.length, 20);
      expect(events.length, 20);
      expect(resources.length, 20);
      expect(safeBunk.length, 20);
    });
  });
}
