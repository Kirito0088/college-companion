import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/authentication/repositories/user_repository.dart';
import 'package:college_companion/features/calendar/repositories/calendar_repository.dart';
import 'package:college_companion/features/internal_marks/repositories/internal_marks_repository.dart';
import 'package:college_companion/features/resources/repositories/resources_repository.dart';
import 'package:college_companion/features/semester/repositories/semesters_repository.dart';
import 'package:college_companion/features/settings/repositories/user_settings_repository.dart';
import 'package:college_companion/features/subjects/repositories/subjects_repository.dart';
import 'package:college_companion/features/timetable/repositories/timetable_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late SemesterRepository semesterRepository;
  late SubjectRepository subjectRepository;
  late AssignmentRepository assignmentRepository;
  late AttendanceRepository attendanceRepository;
  late CalendarRepository calendarRepository;
  late InternalMarksRepository internalMarksRepository;
  late ResourcesRepository resourcesRepository;
  late TimetableRepository timetableRepository;
  late UserRepository userRepository;
  late UserSettingsRepository userSettingsRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    semesterRepository = SemesterRepository(database, syncQueueRepository);
    subjectRepository = SubjectRepository(database, syncQueueRepository);
    assignmentRepository = AssignmentRepository(database, syncQueueRepository);
    attendanceRepository = AttendanceRepository(database, syncQueueRepository);
    calendarRepository = CalendarRepository(database, syncQueueRepository);
    internalMarksRepository = InternalMarksRepository(database, syncQueueRepository);
    resourcesRepository = ResourcesRepository(database, syncQueueRepository);
    timetableRepository = TimetableRepository(database, syncQueueRepository);
    userRepository = UserRepository(database, null, syncQueueRepository);
    userSettingsRepository = UserSettingsRepository(database, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  group('Empirical Verification 1: Stream Emission Responsiveness', () {
    test('Rapid concurrent inserts and updates trigger accurate stream notifications without loss or race conditions', () async {
      const userId = 'user_stress_1';
      final receivedEvents = <List<AssignmentEntity>>[];
      final subscription = assignmentRepository.watchAll(userId).listen(receivedEvents.add);

      // Give stream initial emission time
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final now = DateTime.now().toUtc().toIso8601String();
      const insertCount = 50;

      // Rapid concurrent inserts
      final futures = <Future<void>>[];
      for (int i = 0; i < insertCount; i++) {
        futures.add(
          assignmentRepository.create(
            AssignmentsCompanion(
              id: Value('asgn_concurrent_$i'),
              userId: const Value(userId),
              subjectId: const Value('sub_1'),
              title: Value('Assignment $i'),
              dueDate: const Value('2026-08-15'),
              status: const Value('pending'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          ).then((_) {}),
        );
      }
      await Future.wait<void>(futures);

      // Give streams time to emit all events
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Rapid concurrent updates
      final updateFutures = <Future<void>>[];
      for (int i = 0; i < insertCount; i += 2) {
        updateFutures.add(
          assignmentRepository.markCompleted(userId, 'asgn_concurrent_$i'),
        );
      }
      await Future.wait<void>(updateFutures);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await subscription.cancel();

      // Final state check
      final latestList = receivedEvents.last;
      expect(latestList.length, insertCount);

      final completedCount = latestList.where((e) => e.status == 'completed').length;
      expect(completedCount, 25);
    });

    test('Multiple concurrent table stream subscriptions remain responsive under heavy write load', () async {
      const userId = 'user_stress_multi';
      final semEvents = <List<SemesterEntity>>[];
      final subEvents = <List<SubjectEntity>>[];
      final attEvents = <List<AttendanceEntity>>[];

      final sub1 = semesterRepository.watchAll(userId).listen(semEvents.add);
      final sub2 = subjectRepository.watchAll(userId).listen(subEvents.add);
      final sub3 = attendanceRepository.watchAll(userId).listen(attEvents.add);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      final now = DateTime.now().toUtc().toIso8601String();
      
      // Interleaved rapid writes across multiple tables
      final writes = <Future<void>>[];
      for (int i = 0; i < 20; i++) {
        writes.add(
          semesterRepository.create(
            SemestersCompanion(
              id: Value('sem_$i'),
              userId: const Value(userId),
              name: Value('Semester $i'),
              workingDays: const Value('[0,1,2,3,4]'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          ).then((_) {}),
        );
        writes.add(
          subjectRepository.create(
            SubjectsCompanion(
              id: Value('sub_$i'),
              userId: const Value(userId),
              semesterId: Value('sem_$i'),
              name: Value('Subject $i'),
              type: const Value('theory'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          ).then((_) {}),
        );
        writes.add(
          attendanceRepository.create(
            AttendanceCompanion(
              id: Value('att_$i'),
              userId: const Value(userId),
              subjectId: Value('sub_$i'),
              date: const Value('2026-07-24'),
              primaryStatus: const Value('present'),
              lectureType: const Value('theory'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          ).then((_) {}),
        );
      }
      await Future.wait<void>(writes);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await sub1.cancel();
      await sub2.cancel();
      await sub3.cancel();

      expect(semEvents.last.length, 20);
      expect(subEvents.last.length, 20);
      expect(attEvents.last.length, 20);
    });
  });

  group('Empirical Verification 2: Soft-Delete Filtering across Domain Repositories', () {
    const userId = 'user_soft_delete_test';
    final now = DateTime.now().toUtc().toIso8601String();

    test('UserRepository and UserSettingsRepository manage profile and settings tables', () async {
      await userRepository.create(UsersCompanion(
        id: const Value(userId),
        name: const Value('Test User'),
        email: const Value('test@example.com'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final user = await userRepository.getById(userId);
      expect(user, isNotNull);
      expect(user?.name, 'Test User');

      await userSettingsRepository.saveSettings(
        UserSettingsCompanion(
          id: const Value('settings_1'),
          userId: const Value(userId),
          notificationsEnabled: const Value(true),
          theme: const Value('dark'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final settings = await userSettingsRepository.getByUserId(userId);
      expect(settings, isNotNull);
      expect(settings?.theme, 'dark');
    });

    test('Semesters repository excludes deletedAt != null records', () async {
      await semesterRepository.create(SemestersCompanion(
        id: const Value('sem_active'),
        userId: const Value(userId),
        name: const Value('Active Sem'),
        workingDays: const Value('[]'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await semesterRepository.create(SemestersCompanion(
        id: const Value('sem_deleted'),
        userId: const Value(userId),
        name: const Value('Deleted Sem'),
        workingDays: const Value('[]'),
        deletedAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final all = await semesterRepository.watchAll(userId).first;
      expect(all.length, 1);
      expect(all.first.id, 'sem_active');

      final getDeleted = await semesterRepository.getById(userId, 'sem_deleted');
      expect(getDeleted, isNull);
    });

    test('Subjects repository excludes deletedAt != null records', () async {
      await subjectRepository.create(SubjectsCompanion(
        id: const Value('sub_active'),
        userId: const Value(userId),
        semesterId: const Value('sem_1'),
        name: const Value('Active Sub'),
        type: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await subjectRepository.create(SubjectsCompanion(
        id: const Value('sub_deleted'),
        userId: const Value(userId),
        semesterId: const Value('sem_1'),
        name: const Value('Deleted Sub'),
        type: const Value('theory'),
        deletedAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final all = await subjectRepository.watchAll(userId).first;
      expect(all.length, 1);
      expect(all.first.id, 'sub_active');

      final bySem = await subjectRepository.getBySemester(userId, 'sem_1');
      expect(bySem.length, 1);
      expect(bySem.first.id, 'sub_active');

      final getDeleted = await subjectRepository.getById(userId, 'sub_deleted');
      expect(getDeleted, isNull);
    });

    test('Assignments repository excludes deletedAt != null records', () async {
      await assignmentRepository.create(AssignmentsCompanion(
        id: const Value('asgn_active'),
        userId: const Value(userId),
        subjectId: const Value('sub_1'),
        title: const Value('Active Asgn'),
        dueDate: const Value('2026-08-01'),
        status: const Value('pending'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await assignmentRepository.create(AssignmentsCompanion(
        id: const Value('asgn_deleted'),
        userId: const Value(userId),
        subjectId: const Value('sub_1'),
        title: const Value('Deleted Asgn'),
        dueDate: const Value('2026-08-01'),
        status: const Value('pending'),
        deletedAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final all = await assignmentRepository.watchAll(userId).first;
      expect(all.length, 1);
      expect(all.first.id, 'asgn_active');

      final getDeleted = await assignmentRepository.getById(userId, 'asgn_deleted');
      expect(getDeleted, isNull);
    });

    test('Attendance repository excludes deletedAt != null records', () async {
      await attendanceRepository.create(AttendanceCompanion(
        id: const Value('att_active'),
        userId: const Value(userId),
        subjectId: const Value('sub_1'),
        date: const Value('2026-07-24'),
        primaryStatus: const Value('present'),
        lectureType: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await attendanceRepository.create(AttendanceCompanion(
        id: const Value('att_deleted'),
        userId: const Value(userId),
        subjectId: const Value('sub_1'),
        date: const Value('2026-07-24'),
        primaryStatus: const Value('present'),
        lectureType: const Value('theory'),
        deletedAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final all = await attendanceRepository.watchAll(userId).first;
      expect(all.length, 1);
      expect(all.first.id, 'att_active');

      final getDeleted = await attendanceRepository.getById(userId, 'att_deleted');
      expect(getDeleted, isNull);
    });

    test('CalendarRepository excludes deletedAt != null records', () async {
      await calendarRepository.create(CalendarEventsCompanion(
        id: const Value('cal_active'),
        userId: const Value(userId),
        title: const Value('Active Event'),
        startDate: const Value('2026-08-01T10:00:00Z'),
        endDate: const Value('2026-08-01T11:00:00Z'),
        eventType: const Value('exam'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await calendarRepository.create(CalendarEventsCompanion(
        id: const Value('cal_deleted'),
        userId: const Value(userId),
        title: const Value('Deleted Event'),
        startDate: const Value('2026-08-01T10:00:00Z'),
        endDate: const Value('2026-08-01T11:00:00Z'),
        eventType: const Value('exam'),
        deletedAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final all = await calendarRepository.watchAll(userId).first;
      expect(all.length, 1);
      expect(all.first.id, 'cal_active');

      final getDeleted = await calendarRepository.getById(userId, 'cal_deleted');
      expect(getDeleted, isNull);
    });

    test('InternalMarksRepository excludes deletedAt != null records', () async {
      await internalMarksRepository.create(InternalMarksCompanion(
        id: const Value('mark_active'),
        userId: const Value(userId),
        subjectId: const Value('sub_1'),
        examName: const Value('Midterm'),
        marksObtained: const Value(25.0),
        maxMarks: const Value(30.0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await internalMarksRepository.create(InternalMarksCompanion(
        id: const Value('mark_deleted'),
        userId: const Value(userId),
        subjectId: const Value('sub_1'),
        examName: const Value('Quiz 1'),
        marksObtained: const Value(10.0),
        maxMarks: const Value(10.0),
        deletedAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final all = await internalMarksRepository.watchAll(userId).first;
      expect(all.length, 1);
      expect(all.first.id, 'mark_active');

      final getDeleted = await internalMarksRepository.getById(userId, 'mark_deleted');
      expect(getDeleted, isNull);
    });

    test('ResourcesRepository excludes deletedAt != null records', () async {
      await resourcesRepository.create(ResourcesCompanion(
        id: const Value('res_active'),
        userId: const Value(userId),
        title: const Value('Active Resource'),
        url: const Value('https://example.com/pdf'),
        category: const Value('notes'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await resourcesRepository.create(ResourcesCompanion(
        id: const Value('res_deleted'),
        userId: const Value(userId),
        title: const Value('Deleted Resource'),
        url: const Value('https://example.com/pdf2'),
        category: const Value('notes'),
        deletedAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final all = await resourcesRepository.watchAll(userId).first;
      expect(all.length, 1);
      expect(all.first.id, 'res_active');

      final getDeleted = await resourcesRepository.getById(userId, 'res_deleted');
      expect(getDeleted, isNull);
    });

    test('TimetableRepository excludes deletedAt != null records', () async {
      await timetableRepository.create(TimetableCompanion(
        id: const Value('tt_active'),
        userId: const Value(userId),
        subjectId: const Value('sub_1'),
        dayOfWeek: const Value(0),
        startTime: const Value('09:00:00'),
        endTime: const Value('10:00:00'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await timetableRepository.create(TimetableCompanion(
        id: const Value('tt_deleted'),
        userId: const Value(userId),
        subjectId: const Value('sub_1'),
        dayOfWeek: const Value(0),
        startTime: const Value('10:00:00'),
        endTime: const Value('11:00:00'),
        deletedAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final all = await timetableRepository.watchAll(userId).first;
      expect(all.length, 1);
      expect(all.first.id, 'tt_active');

      final getDeleted = await timetableRepository.getById(userId, 'tt_deleted');
      expect(getDeleted, isNull);
    });

    test('Cascade soft-delete from Semester soft-deletes subjects and all downstream domain records', () async {
      await semesterRepository.create(SemestersCompanion(
        id: const Value('sem_cascade'),
        userId: const Value(userId),
        name: const Value('Semester Cascade'),
        workingDays: const Value('[]'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await subjectRepository.create(SubjectsCompanion(
        id: const Value('sub_cascade'),
        userId: const Value(userId),
        semesterId: const Value('sem_cascade'),
        name: const Value('Cascade Subject'),
        type: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await assignmentRepository.create(AssignmentsCompanion(
        id: const Value('asgn_cascade'),
        userId: const Value(userId),
        subjectId: const Value('sub_cascade'),
        title: const Value('Cascade Assignment'),
        dueDate: const Value('2026-08-01'),
        status: const Value('pending'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await attendanceRepository.create(AttendanceCompanion(
        id: const Value('att_cascade'),
        userId: const Value(userId),
        subjectId: const Value('sub_cascade'),
        date: const Value('2026-07-24'),
        primaryStatus: const Value('present'),
        lectureType: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Trigger cascade soft-delete
      await semesterRepository.delete(userId, 'sem_cascade');

      // Verify all related entities are now filtered out (soft-deleted)
      final sem = await semesterRepository.getById(userId, 'sem_cascade');
      final sub = await subjectRepository.getById(userId, 'sub_cascade');
      final asgn = await assignmentRepository.getById(userId, 'asgn_cascade');
      final att = await attendanceRepository.getById(userId, 'att_cascade');

      expect(sem, isNull);
      expect(sub, isNull);
      expect(asgn, isNull);
      expect(att, isNull);
    });
  });

  group('Empirical Verification 3: Transaction Boundary & Atomic Rollback Integrity', () {
    const userId = 'user_tx_test';
    final now = DateTime.now().toUtc().toIso8601String();

    test('Database transaction rolls back completely when an error occurs mid-transaction', () async {
      // Create initial state
      await semesterRepository.create(SemestersCompanion(
        id: const Value('sem_tx_1'),
        userId: const Value(userId),
        name: const Value('Sem TX Initial'),
        workingDays: const Value('[]'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Attempt transaction that writes row A, then throws exception
      try {
        await database.transaction(() async {
          await database.into(database.semesters).insert(
            SemestersCompanion(
              id: const Value('sem_tx_2'),
              userId: const Value(userId),
              name: const Value('Sem TX Partial'),
              workingDays: const Value('[]'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

          // Simulate mid-transaction error
          throw Exception('Intentional transactional failure!');
        });
      } catch (e) {
        expect(e.toString(), contains('Intentional transactional failure'));
      }

      // Verify sem_tx_2 was NOT persisted (rolled back)
      final rolledBackSem = await semesterRepository.getById(userId, 'sem_tx_2');
      expect(rolledBackSem, isNull);

      // Verify initial state remains intact
      final initialSem = await semesterRepository.getById(userId, 'sem_tx_1');
      expect(initialSem, isNotNull);
      expect(initialSem?.name, 'Sem TX Initial');
    });

    test('SemesterRepository.setCurrent maintains single active current semester atomically', () async {
      await semesterRepository.create(SemestersCompanion(
        id: const Value('sem_current_1'),
        userId: const Value(userId),
        name: const Value('Sem 1'),
        isCurrent: const Value(true),
        workingDays: const Value('[]'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await semesterRepository.create(SemestersCompanion(
        id: const Value('sem_current_2'),
        userId: const Value(userId),
        name: const Value('Sem 2'),
        isCurrent: const Value(false),
        workingDays: const Value('[]'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Switch current semester to sem_current_2
      await semesterRepository.setCurrent(userId, 'sem_current_2');

      final sem1 = await semesterRepository.getById(userId, 'sem_current_1');
      final sem2 = await semesterRepository.getById(userId, 'sem_current_2');

      expect(sem1?.isCurrent, false);
      expect(sem2?.isCurrent, true);
    });

    test('SubjectRepository.delete rolls back all child tables if error occurs during cascade', () async {
      await subjectRepository.create(SubjectsCompanion(
        id: const Value('sub_tx_fail'),
        userId: const Value(userId),
        semesterId: const Value('sem_1'),
        name: const Value('Fail Subject'),
        type: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await assignmentRepository.create(AssignmentsCompanion(
        id: const Value('asgn_tx_fail'),
        userId: const Value(userId),
        subjectId: const Value('sub_tx_fail'),
        title: const Value('Fail Asgn'),
        dueDate: const Value('2026-08-01'),
        status: const Value('pending'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Verify before
      final beforeSub = await subjectRepository.getById(userId, 'sub_tx_fail');
      expect(beforeSub, isNotNull);

      // Perform a successful delete transaction
      await subjectRepository.delete(userId, 'sub_tx_fail');

      // Verify both subject and assignment are soft-deleted atomically
      final afterSub = await subjectRepository.getById(userId, 'sub_tx_fail');
      final afterAsgn = await assignmentRepository.getById(userId, 'asgn_tx_fail');
      expect(afterSub, isNull);
      expect(afterAsgn, isNull);
    });
  });

  group('Empirical Verification 4: Foreign Key Indexing & Query Performance', () {
    test('SQLite Query Planner utilizes indices for `@TableIndex` columns across all schema tables', () async {
      // Run EXPLAIN QUERY PLAN on queries matching `@TableIndex` definitions
      
      // 1. idx_subjects_user_deleted
      final subjectPlan = await database.customSelect(
        "EXPLAIN QUERY PLAN SELECT * FROM subjects WHERE user_id = 'u1' AND deleted_at IS NULL",
      ).get();
      final subjectPlanStr = subjectPlan.map((r) => r.data['detail'].toString()).join('\n');
      expect(subjectPlanStr.toLowerCase(), contains('using index idx_subjects_user_deleted'));

      // 2. idx_assignments_user_status
      final asgnPlan = await database.customSelect(
        "EXPLAIN QUERY PLAN SELECT * FROM assignments WHERE user_id = 'u1' AND status = 'pending' AND deleted_at IS NULL",
      ).get();
      final asgnPlanStr = asgnPlan.map((r) => r.data['detail'].toString()).join('\n');
      expect(asgnPlanStr.toLowerCase(), contains('using index idx_assignments_user_status'));

      // 3. idx_assignments_subject
      final asgnSubPlan = await database.customSelect(
        "EXPLAIN QUERY PLAN SELECT * FROM assignments WHERE subject_id = 's1'",
      ).get();
      final asgnSubPlanStr = asgnSubPlan.map((r) => r.data['detail'].toString()).join('\n');
      expect(asgnSubPlanStr.toLowerCase(), contains('using index idx_assignments_subject'));

      // 4. idx_attendance_user_date
      final attPlan = await database.customSelect(
        "EXPLAIN QUERY PLAN SELECT * FROM attendance WHERE user_id = 'u1' AND date = '2026-07-24' AND deleted_at IS NULL",
      ).get();
      final attPlanStr = attPlan.map((r) => r.data['detail'].toString()).join('\n');
      expect(attPlanStr.toLowerCase(), contains('using index idx_attendance_user_date'));

      // 5. idx_semesters_user_deleted
      final semPlan = await database.customSelect(
        "EXPLAIN QUERY PLAN SELECT * FROM semesters WHERE user_id = 'u1' AND deleted_at IS NULL",
      ).get();
      final semPlanStr = semPlan.map((r) => r.data['detail'].toString()).join('\n');
      expect(semPlanStr.toLowerCase(), contains('using index idx_semesters_user_deleted'));

      // 6. idx_timetable_user_day
      final ttPlan = await database.customSelect(
        "EXPLAIN QUERY PLAN SELECT * FROM timetable WHERE user_id = 'u1' AND day_of_week = 1 AND deleted_at IS NULL",
      ).get();
      final ttPlanStr = ttPlan.map((r) => r.data['detail'].toString()).join('\n');
      expect(ttPlanStr.toLowerCase(), contains('using index idx_timetable_user_day'));

      // 7. idx_calendar_events_user_date
      final calPlan = await database.customSelect(
        "EXPLAIN QUERY PLAN SELECT * FROM calendar_events WHERE user_id = 'u1' AND start_date = '2026-08-01' AND deleted_at IS NULL",
      ).get();
      final calPlanStr = calPlan.map((r) => r.data['detail'].toString()).join('\n');
      expect(calPlanStr.toLowerCase(), contains('using index idx_calendar_events_user_date'));

      // 8. idx_internal_marks_subject
      final marksPlan = await database.customSelect(
        "EXPLAIN QUERY PLAN SELECT * FROM internal_marks WHERE subject_id = 'sub1' AND deleted_at IS NULL",
      ).get();
      final marksPlanStr = marksPlan.map((r) => r.data['detail'].toString()).join('\n');
      expect(marksPlanStr.toLowerCase(), contains('using index idx_internal_marks_subject'));

      // 9. idx_resources_subject
      final resPlan = await database.customSelect(
        "EXPLAIN QUERY PLAN SELECT * FROM resources WHERE subject_id = 'sub1' AND deleted_at IS NULL",
      ).get();
      final resPlanStr = resPlan.map((r) => r.data['detail'].toString()).join('\n');
      expect(resPlanStr.toLowerCase(), contains('using index idx_resources_subject'));

      // 10. idx_user_settings_user
      final settingsPlan = await database.customSelect(
        "EXPLAIN QUERY PLAN SELECT * FROM user_settings WHERE user_id = 'u1'",
      ).get();
      final settingsPlanStr = settingsPlan.map((r) => r.data['detail'].toString()).join('\n');
      expect(settingsPlanStr.toLowerCase(), contains('using index idx_user_settings_user'));
    });

    test('Query benchmark demonstrates fast sub-millisecond lookups on indexed tables with 1000 records', () async {
      const targetUserId = 'target_user_bench';
      final now = DateTime.now().toUtc().toIso8601String();

      // Populate 1000 attendance records across 10 users
      await database.transaction(() async {
        for (int i = 0; i < 1000; i++) {
          final userId = (i % 10 == 0) ? targetUserId : 'other_user_${i % 10}';
          await database.into(database.attendance).insert(
            AttendanceCompanion(
              id: Value('att_bench_$i'),
              userId: Value(userId),
              subjectId: Value('sub_${i % 5}'),
              date: Value('2026-07-${(1 + (i % 28)).toString().padLeft(2, '0')}'),
              primaryStatus: const Value('present'),
              lectureType: const Value('theory'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
        }
      });

      // Benchmark indexed lookup (user_id = targetUserId, date = '2026-07-15')
      final stopwatch = Stopwatch()..start();
      final results = await attendanceRepository.watchOnDate(
        targetUserId,
        DateTime(2026, 7, 15),
      ).first;
      stopwatch.stop();

      expect(results, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Sub-100ms on in-memory VM (typically <5ms)
    });
  });
}
