import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/lectures_dao.dart';
import 'package:college_companion/features/timetable/repositories/timetable_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late TimetableRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    repository = TimetableRepository(database, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> seedDatabase() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();

    // Insert user
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

    // Insert semester
    await database
        .into(database.semesters)
        .insert(
          SemestersCompanion.insert(
            id: 'sem_1',
            userId: 'user_1',
            name: 'Semester 5',
            workingDays: '[0,1,2,3,4]',
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );

    // Insert subjects
    await database
        .into(database.subjects)
        .insert(
          SubjectsCompanion.insert(
            id: 'subj_cs101',
            userId: 'user_1',
            semesterId: 'sem_1',
            name: 'Algorithms & Data Structures',
            faculty: const Value('Prof. Alan Turing'),
            type: const Value('theory'),
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );

    await database
        .into(database.subjects)
        .insert(
          SubjectsCompanion.insert(
            id: 'subj_ee201',
            userId: 'user_1',
            semesterId: 'sem_1',
            name: 'Digital Electronics Lab',
            faculty: const Value('Dr. Claude Shannon'),
            type: const Value('practical'),
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );
  }

  group('TimetableRepository with LecturesDao Joins', () {
    test(
      'watchLecturesForDay joins timetable with subject and orders by start time',
      () async {
        await seedDatabase();
        final nowIso = DateTime.now().toUtc().toIso8601String();

        // Monday (day 0) slots
        await repository.create(
          TimetableCompanion.insert(
            id: 'tt_mon_2',
            userId: 'user_1',
            subjectId: 'subj_ee201',
            dayOfWeek: 0,
            startTime: '11:00:00',
            endTime: '13:00:00',
            room: const Value('Hardware Lab 2'),
            lectureType: const Value('practical'),
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );

        await repository.create(
          TimetableCompanion.insert(
            id: 'tt_mon_1',
            userId: 'user_1',
            subjectId: 'subj_cs101',
            dayOfWeek: 0,
            startTime: '09:00:00',
            endTime: '10:00:00',
            room: const Value('Hall 101'),
            lectureType: const Value('theory'),
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );

        // Tuesday (day 1) slot
        await repository.create(
          TimetableCompanion.insert(
            id: 'tt_tue_1',
            userId: 'user_1',
            subjectId: 'subj_cs101',
            dayOfWeek: 1,
            startTime: '10:00:00',
            endTime: '11:00:00',
            room: const Value('Hall 102'),
            lectureType: const Value('theory'),
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );

        final mondayLectures = await repository
            .watchLecturesForDay('user_1', 0)
            .first;

        expect(mondayLectures.length, 2);
        // Chronological ordering
        expect(mondayLectures[0].id, 'tt_mon_1');
        expect(mondayLectures[0].subjectName, 'Algorithms & Data Structures');
        expect(mondayLectures[0].faculty, 'Prof. Alan Turing');
        expect(mondayLectures[0].room, 'Hall 101');
        expect(mondayLectures[0].startTime, '09:00:00');
        expect(mondayLectures[0].endTime, '10:00:00');
        expect(mondayLectures[0].lectureType, 'theory');

        expect(mondayLectures[1].id, 'tt_mon_2');
        expect(mondayLectures[1].subjectName, 'Digital Electronics Lab');
        expect(mondayLectures[1].faculty, 'Dr. Claude Shannon');
        expect(mondayLectures[1].room, 'Hardware Lab 2');
        expect(mondayLectures[1].startTime, '11:00:00');
        expect(mondayLectures[1].endTime, '13:00:00');
        expect(mondayLectures[1].lectureType, 'practical');

        // Check empty day
        final sundayLectures = await repository
            .watchLecturesForDay('user_1', 6)
            .first;
        expect(sundayLectures, isEmpty);
      },
    );

    test(
      'watchAllWeeklyLectures returns all days ordered by dayOfWeek then startTime',
      () async {
        await seedDatabase();
        final nowIso = DateTime.now().toUtc().toIso8601String();

        await repository.create(
          TimetableCompanion.insert(
            id: 'tt_wed_1',
            userId: 'user_1',
            subjectId: 'subj_cs101',
            dayOfWeek: 2,
            startTime: '09:00:00',
            endTime: '10:00:00',
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );

        await repository.create(
          TimetableCompanion.insert(
            id: 'tt_mon_1',
            userId: 'user_1',
            subjectId: 'subj_cs101',
            dayOfWeek: 0,
            startTime: '09:00:00',
            endTime: '10:00:00',
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );

        final weeklyLectures = await repository
            .watchAllWeeklyLectures('user_1')
            .first;
        expect(weeklyLectures.length, 2);
        expect(weeklyLectures[0].id, 'tt_mon_1');
        expect(weeklyLectures[1].id, 'tt_wed_1');
      },
    );

    test('isCurrent is computed correctly for active lecture slot', () async {
      await seedDatabase();
      final nowIso = DateTime.now().toUtc().toIso8601String();

      await repository.create(
        TimetableCompanion.insert(
          id: 'tt_1',
          userId: 'user_1',
          subjectId: 'subj_cs101',
          dayOfWeek: 0,
          startTime: '09:00:00',
          endTime: '10:00:00',
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );

      final lecturesDao = LecturesDao(database);
      // Monday 09:30 UTC/local
      final simulatedTime = DateTime(
        2026,
        8,
        17,
        9,
        30,
      ); // 2026-08-17 is Monday
      final mondayLectures = await lecturesDao
          .watchLecturesForDay('user_1', 0, simulatedTime)
          .first;

      expect(mondayLectures.first.isCurrent, isTrue);

      // Outside the time slot (10:30)
      final outsideTime = DateTime(2026, 8, 17, 10, 30);
      final outsideLectures = await lecturesDao
          .watchLecturesForDay('user_1', 0, outsideTime)
          .first;

      expect(outsideLectures.first.isCurrent, isFalse);
    });
  });
}
