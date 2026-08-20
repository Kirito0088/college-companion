import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/features/resources/providers/resources_provider.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SafeBunkCalculator Unit Tests', () {
    test('calculate returns 0% when total is 0 or negative', () {
      final result = SafeBunkCalculator.calculate(attended: 0, total: 0);
      expect(result.attended, 0);
      expect(result.total, 0);
      expect(result.currentPercentage, 0.0);
      expect(result.safeBunks, 0);
      expect(result.mustAttend, 0);
    });

    test(
      'calculate calculates safe bunks when above target percentage (75%)',
      () {
        // 9 attended out of 10 total = 90%
        // maxBunks = floor((9*100 - 75*10)/75) = floor((900 - 750)/75) = 2
        final result = SafeBunkCalculator.calculate(attended: 9, total: 10);
        expect(result.currentPercentage, 90.0);
        expect(result.targetPercentage, 75.0);
        expect(result.safeBunks, 2);
        expect(result.mustAttend, 0);
      },
    );

    test('calculate calculates zero safe bunks when exactly at 75%', () {
      // 3 attended out of 4 total = 75%
      // maxBunks = floor((300 - 300)/75) = 0
      final result = SafeBunkCalculator.calculate(attended: 3, total: 4);
      expect(result.currentPercentage, 75.0);
      expect(result.safeBunks, 0);
      expect(result.mustAttend, 0);
    });

    test(
      'calculate calculates mustAttend when below target percentage (75%)',
      () {
        // 6 attended out of 10 total = 60%
        // needed = ceil((75*10 - 100*6)/(100 - 75)) = ceil((750 - 600)/25) = 6
        final result = SafeBunkCalculator.calculate(attended: 6, total: 10);
        expect(result.currentPercentage, 60.0);
        expect(result.safeBunks, 0);
        expect(result.mustAttend, 6);
      },
    );

    test('calculate supports custom target percentage', () {
      // 8 attended out of 10 total = 80%, target 80%
      final result = SafeBunkCalculator.calculate(
        attended: 8,
        total: 10,
        targetPercentage: 80.0,
      );
      expect(result.currentPercentage, 80.0);
      expect(result.targetPercentage, 80.0);
      expect(result.safeBunks, 0);
      expect(result.mustAttend, 0);
    });
  });

  group('Restored StreamProviders Unit Tests', () {
    late AppDatabase db;
    late ProviderContainer container;
    const testUserId = 'user_test_123';

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test(
      'assignmentsStreamProvider emits list of assignments for user',
      () async {
        final now = DateTime.now().toUtc().toIso8601String();
        await db
            .into(db.assignments)
            .insert(
              AssignmentsCompanion.insert(
                id: 'asgn_1',
                userId: testUserId,
                subjectId: 'sub_1',
                title: 'Math Homework',
                dueDate: now,
                status: 'pending',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final assignments = await container.read(
          assignmentsStreamProvider(testUserId).future,
        );
        expect(assignments.length, 1);
        expect(assignments.first.title, 'Math Homework');
        expect(assignments.first.userId, testUserId);
      },
    );

    test(
      'safeBunkStreamProvider calculates safe bunks from database attendance records',
      () async {
        final now = DateTime.now().toUtc().toIso8601String();
        // Insert 8 present records and 2 absent records -> 8/10 = 80%
        for (int i = 0; i < 8; i++) {
          await db
              .into(db.attendance)
              .insert(
                AttendanceCompanion.insert(
                  id: 'att_p_$i',
                  userId: testUserId,
                  subjectId: 'sub_1',
                  date: now,
                  lectureType: 'theory',
                  primaryStatus: 'present',
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }
        for (int i = 0; i < 2; i++) {
          await db
              .into(db.attendance)
              .insert(
                AttendanceCompanion.insert(
                  id: 'att_a_$i',
                  userId: testUserId,
                  subjectId: 'sub_1',
                  date: now,
                  lectureType: 'theory',
                  primaryStatus: 'absent',
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }

        final safeBunkResult = await container.read(
          safeBunkStreamProvider(testUserId).future,
        );
        expect(safeBunkResult.attended, 8);
        expect(safeBunkResult.total, 10);
        expect(safeBunkResult.currentPercentage, 80.0);
      },
    );

    test(
      'calendarEventsStreamProvider emits list of events for user',
      () async {
        final now = DateTime.now().toUtc().toIso8601String();
        await db
            .into(db.calendarEvents)
            .insert(
              CalendarEventsCompanion.insert(
                id: 'evt_1',
                userId: testUserId,
                title: 'Midterm Exam',
                startDate: now,
                endDate: now,
                eventType: 'exam',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final events = await container.read(
          calendarEventsStreamProvider(testUserId).future,
        );
        expect(events.length, 1);
        expect(events.first.title, 'Midterm Exam');
        expect(events.first.eventType, 'exam');
      },
    );

    test('resourcesStreamProvider emits list of resources for user', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      await db
          .into(db.resources)
          .insert(
            ResourcesCompanion.insert(
              id: 'res_1',
              userId: testUserId,
              title: 'Data Structures PDF',
              url: 'https://example.com/ds.pdf',
              category: 'Notes',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final resources = await container.read(
        resourcesStreamProvider(testUserId).future,
      );
      expect(resources.length, 1);
      expect(resources.first.title, 'Data Structures PDF');
    });

    test('userSettingsStreamProvider emits user settings for user', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      await db
          .into(db.userSettings)
          .insert(
            UserSettingsCompanion.insert(
              id: 'sett_1',
              userId: testUserId,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final settings = await container.read(
        userSettingsStreamProvider(testUserId).future,
      );
      expect(settings, isNotNull);
      expect(settings?.userId, testUserId);
    });

    test(
      'dashboardSnapshotProvider produces fallback mock snapshot when userId is empty',
      () async {
        final snapshot = await container.read(
          dashboardSnapshotProvider('').future,
        );
        expect(snapshot, isA<DashboardSnapshot>());
        expect(snapshot.academicSnapshot, isNotNull);
      },
    );

    test(
      'dashboardSnapshotProvider synthesizes real dashboard data for valid userId',
      () async {
        final now = DateTime.now();
        final nowIso = now.toUtc().toIso8601String();

        // Seed calendar event today
        await db
            .into(db.calendarEvents)
            .insert(
              CalendarEventsCompanion.insert(
                id: 'evt_today',
                userId: testUserId,
                title: 'Algorithms Lecture',
                startDate: nowIso,
                endDate: now
                    .add(const Duration(hours: 1))
                    .toUtc()
                    .toIso8601String(),
                eventType: 'academic',
                createdAt: nowIso,
                updatedAt: nowIso,
              ),
            );

        // Seed pending assignment due today
        await db
            .into(db.assignments)
            .insert(
              AssignmentsCompanion.insert(
                id: 'asgn_today',
                userId: testUserId,
                subjectId: 'sub_algo',
                title: 'Assignment 1',
                dueDate: nowIso,
                status: 'pending',
                createdAt: nowIso,
                updatedAt: nowIso,
              ),
            );

        final snapshot = await container.read(
          dashboardSnapshotProvider(testUserId).future,
        );
        expect(snapshot, isA<DashboardSnapshot>());
        expect(snapshot.academicSnapshot, isNotNull);
        expect(snapshot.academicSnapshot.attendanceState, 'No Data');
      },
    );
  });
}
