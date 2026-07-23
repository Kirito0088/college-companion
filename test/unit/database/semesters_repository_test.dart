import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/internal_marks/repositories/internal_marks_repository.dart';
import 'package:college_companion/features/resources/repositories/resources_repository.dart';
import 'package:college_companion/features/semester/repositories/semesters_repository.dart';
import 'package:college_companion/features/subjects/repositories/subjects_repository.dart';
import 'package:college_companion/features/timetable/repositories/timetable_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late SemesterRepository repository;
  late SubjectRepository subjectRepository;
  late TimetableRepository timetableRepository;
  late AttendanceRepository attendanceRepository;
  late AssignmentRepository assignmentRepository;
  late InternalMarksRepository internalMarksRepository;
  late ResourcesRepository resourcesRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    repository = SemesterRepository(database, syncQueueRepository);
    subjectRepository = SubjectRepository(database, syncQueueRepository);
    timetableRepository = TimetableRepository(database, syncQueueRepository);
    attendanceRepository = AttendanceRepository(database, syncQueueRepository);
    assignmentRepository = AssignmentRepository(database, syncQueueRepository);
    internalMarksRepository = InternalMarksRepository(database, syncQueueRepository);
    resourcesRepository = ResourcesRepository(database, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('create and getById semester with sync queue integration', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    final id = await repository.create(SemestersCompanion(
      id: const Value('sem_1'),
      userId: const Value('user_1'),
      name: const Value('Semester 5'),
      workingDays: const Value('[0,1,2,3,4]'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    expect(id, 'sem_1');

    final result = await repository.getById('user_1', 'sem_1');
    expect(result, isNotNull);
    expect(result?.name, 'Semester 5');
    expect(result?.workingDays, '[0,1,2,3,4]');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.length, 1);
    expect(pendingSync.first.targetTable, 'semesters');
    expect(pendingSync.first.recordId, 'sem_1');
    expect(pendingSync.first.operation, 'INSERT');
  });

  test('update semester updates name and enqueues sync UPDATE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(SemestersCompanion(
      id: const Value('sem_1'),
      userId: const Value('user_1'),
      name: const Value('Old Name'),
      workingDays: const Value('[0,1,2,3,4]'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.update(
      'user_1',
      'sem_1',
      SemestersCompanion(
        name: const Value('New Name'),
        updatedAt: Value(now),
      ),
    );

    final updated = await repository.getById('user_1', 'sem_1');
    expect(updated?.name, 'New Name');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'UPDATE');
  });

  test('setCurrent transaction unsets active semester and sets target semester as current', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(SemestersCompanion(
      id: const Value('sem_1'),
      userId: const Value('user_1'),
      name: const Value('Semester 1'),
      workingDays: const Value('[0,1,2,3,4]'),
      isCurrent: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(SemestersCompanion(
      id: const Value('sem_2'),
      userId: const Value('user_1'),
      name: const Value('Semester 2'),
      workingDays: const Value('[0,1,2,3,4]'),
      isCurrent: const Value(false),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // Verify sem_1 is currently active
    var currentSem = await repository.watchCurrent('user_1').first;
    expect(currentSem?.id, 'sem_1');

    // Switch active semester to sem_2
    await repository.setCurrent('user_1', 'sem_2');

    final sem1After = await repository.getById('user_1', 'sem_1');
    final sem2After = await repository.getById('user_1', 'sem_2');

    expect(sem1After?.isCurrent, false);
    expect(sem2After?.isCurrent, true);

    currentSem = await repository.watchCurrent('user_1').first;
    expect(currentSem?.id, 'sem_2');
  });

  test('watchAll and watchById stream non-deleted semesters', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(SemestersCompanion(
      id: const Value('sem_active'),
      userId: const Value('user_1'),
      name: const Value('Active Semester'),
      workingDays: const Value('[0,1,2,3,4]'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(SemestersCompanion(
      id: const Value('sem_deleted'),
      userId: const Value('user_1'),
      name: const Value('Deleted Semester'),
      workingDays: const Value('[0,1,2,3,4]'),
      deletedAt: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    final list = await repository.watchAll('user_1').first;
    expect(list.length, 1);
    expect(list.first.id, 'sem_active');

    final single = await repository.watchById('user_1', 'sem_active').first;
    expect(single, isNotNull);
    expect(single?.name, 'Active Semester');
  });

  test('delete semester performs cascade soft-delete transaction on all child records', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    // 1. Create semester
    await repository.create(SemestersCompanion(
      id: const Value('sem_1'),
      userId: const Value('user_1'),
      name: const Value('Semester 1'),
      workingDays: const Value('[0,1,2,3,4]'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // 2. Create subject in semester
    await subjectRepository.create(SubjectsCompanion(
      id: const Value('sub_1'),
      userId: const Value('user_1'),
      semesterId: const Value('sem_1'),
      name: const Value('Physics'),
      type: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // 3. Create child records under subject
    await timetableRepository.create(TimetableCompanion(
      id: const Value('tt_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      dayOfWeek: const Value(1),
      startTime: const Value('09:00'),
      endTime: const Value('10:00'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await attendanceRepository.create(AttendanceCompanion(
      id: const Value('att_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      date: const Value('2026-08-01'),
      primaryStatus: const Value('present'),
      lectureType: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await assignmentRepository.create(AssignmentsCompanion(
      id: const Value('asgn_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Lab Homework'),
      dueDate: const Value('2026-08-05'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await internalMarksRepository.create(InternalMarksCompanion(
      id: const Value('mark_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      examName: const Value('Mid Term'),
      marksObtained: const Value(25.0),
      maxMarks: const Value(30.0),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await resourcesRepository.create(ResourcesCompanion(
      id: const Value('res_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Syllabus PDF'),
      url: const Value('https://example.com/syllabus.pdf'),
      category: const Value('syllabus'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // Verify all exist prior to deletion
    expect(await repository.getById('user_1', 'sem_1'), isNotNull);
    expect(await subjectRepository.getById('user_1', 'sub_1'), isNotNull);
    expect(await timetableRepository.getById('user_1', 'tt_1'), isNotNull);
    expect(await attendanceRepository.getById('user_1', 'att_1'), isNotNull);
    expect(await assignmentRepository.getById('user_1', 'asgn_1'), isNotNull);
    expect(await internalMarksRepository.getById('user_1', 'mark_1'), isNotNull);
    expect(await resourcesRepository.getById('user_1', 'res_1'), isNotNull);

    // Delete semester
    await repository.delete('user_1', 'sem_1');

    // Verify cascade soft-deletion across all tables
    expect(await repository.getById('user_1', 'sem_1'), isNull);
    expect(await subjectRepository.getById('user_1', 'sub_1'), isNull);
    expect(await timetableRepository.getById('user_1', 'tt_1'), isNull);
    expect(await attendanceRepository.getById('user_1', 'att_1'), isNull);
    expect(await assignmentRepository.getById('user_1', 'asgn_1'), isNull);
    expect(await internalMarksRepository.getById('user_1', 'mark_1'), isNull);
    expect(await resourcesRepository.getById('user_1', 'res_1'), isNull);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.targetTable, 'semesters');
    expect(pendingSync.last.operation, 'DELETE');
  });

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.create(const SemestersCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });
}
