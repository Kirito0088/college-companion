import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/internal_marks/repositories/internal_marks_repository.dart';
import 'package:college_companion/features/resources/repositories/resources_repository.dart';
import 'package:college_companion/features/subjects/repositories/subjects_repository.dart';
import 'package:college_companion/features/timetable/repositories/timetable_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late SubjectRepository repository;
  late AssignmentRepository assignmentRepository;
  late AttendanceRepository attendanceRepository;
  late TimetableRepository timetableRepository;
  late InternalMarksRepository internalMarksRepository;
  late ResourcesRepository resourcesRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    repository = SubjectRepository(database, syncQueueRepository);
    assignmentRepository = AssignmentRepository(database, syncQueueRepository);
    attendanceRepository = AttendanceRepository(database, syncQueueRepository);
    timetableRepository = TimetableRepository(database, syncQueueRepository);
    internalMarksRepository = InternalMarksRepository(database, syncQueueRepository);
    resourcesRepository = ResourcesRepository(database, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('create and getById subject with sync queue integration', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    final id = await repository.create(SubjectsCompanion(
      id: const Value('subj_1'),
      userId: const Value('user_1'),
      semesterId: const Value('sem_1'),
      name: const Value('Data Structures'),
      faculty: const Value('Dr. Smith'),
      type: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    expect(id, 'subj_1');

    final result = await repository.getById('user_1', 'subj_1');
    expect(result, isNotNull);
    expect(result?.name, 'Data Structures');
    expect(result?.faculty, 'Dr. Smith');
    expect(result?.type, 'theory');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.length, 1);
    expect(pendingSync.first.targetTable, 'subjects');
    expect(pendingSync.first.recordId, 'subj_1');
    expect(pendingSync.first.operation, 'INSERT');
  });

  test('update subject modifies fields and enqueues sync UPDATE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(SubjectsCompanion(
      id: const Value('subj_1'),
      userId: const Value('user_1'),
      semesterId: const Value('sem_1'),
      name: const Value('Initial Subject'),
      type: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.update(
      'user_1',
      'subj_1',
      SubjectsCompanion(
        name: const Value('Updated Subject'),
        faculty: const Value('Prof. Johnson'),
        updatedAt: Value(now),
      ),
    );

    final updated = await repository.getById('user_1', 'subj_1');
    expect(updated?.name, 'Updated Subject');
    expect(updated?.faculty, 'Prof. Johnson');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'UPDATE');
  });

  test('watchAll, watchBySemester, and getBySemester filter and order correctly', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(SubjectsCompanion(
      id: const Value('subj_b'),
      userId: const Value('user_1'),
      semesterId: const Value('sem_1'),
      name: const Value('B Science'),
      type: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(SubjectsCompanion(
      id: const Value('subj_a'),
      userId: const Value('user_1'),
      semesterId: const Value('sem_1'),
      name: const Value('A Math'),
      type: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(SubjectsCompanion(
      id: const Value('subj_other_sem'),
      userId: const Value('user_1'),
      semesterId: const Value('sem_2'),
      name: const Value('C English'),
      type: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // watchAll returns all user_1 subjects sorted by name ASC
    final allList = await repository.watchAll('user_1').first;
    expect(allList.length, 3);
    expect(allList[0].name, 'A Math');
    expect(allList[1].name, 'B Science');
    expect(allList[2].name, 'C English');

    // watchBySemester returns only sem_1 subjects sorted by name ASC
    final sem1List = await repository.watchBySemester('user_1', 'sem_1').first;
    expect(sem1List.length, 2);
    expect(sem1List[0].name, 'A Math');
    expect(sem1List[1].name, 'B Science');

    // getBySemester returns sem_1 list one-time
    final getSem1 = await repository.getBySemester('user_1', 'sem_1');
    expect(getSem1.length, 2);
    expect(getSem1.first.name, 'A Math');
  });

  test('watchById streams single subject', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(SubjectsCompanion(
      id: const Value('subj_1'),
      userId: const Value('user_1'),
      semesterId: const Value('sem_1'),
      name: const Value('Algorithms'),
      type: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    final stream = repository.watchById('user_1', 'subj_1');
    final entity = await stream.first;

    expect(entity, isNotNull);
    expect(entity?.name, 'Algorithms');
  });

  test('delete subject cascade soft-deletes assignments, attendance, timetable, marks, resources', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(SubjectsCompanion(
      id: const Value('subj_1'),
      userId: const Value('user_1'),
      semesterId: const Value('sem_1'),
      name: const Value('Algorithms'),
      type: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await assignmentRepository.create(AssignmentsCompanion(
      id: const Value('asgn_1'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_1'),
      title: const Value('Homework 1'),
      dueDate: const Value('2026-09-01'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await attendanceRepository.create(AttendanceCompanion(
      id: const Value('att_1'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_1'),
      date: const Value('2026-08-01'),
      primaryStatus: const Value('present'),
      lectureType: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await timetableRepository.create(TimetableCompanion(
      id: const Value('tt_1'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_1'),
      dayOfWeek: const Value(0),
      startTime: const Value('09:00:00'),
      endTime: const Value('10:00:00'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await internalMarksRepository.create(InternalMarksCompanion(
      id: const Value('mark_1'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_1'),
      examName: const Value('Quiz 1'),
      marksObtained: const Value(15.0),
      maxMarks: const Value(20.0),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await resourcesRepository.create(ResourcesCompanion(
      id: const Value('res_1'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_1'),
      title: const Value('Notes Chapter 1'),
      url: const Value('https://example.com/notes.pdf'),
      category: const Value('notes'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    expect(await repository.getById('user_1', 'subj_1'), isNotNull);
    expect(await assignmentRepository.getById('user_1', 'asgn_1'), isNotNull);
    expect(await attendanceRepository.getById('user_1', 'att_1'), isNotNull);
    expect(await timetableRepository.getById('user_1', 'tt_1'), isNotNull);
    expect(await internalMarksRepository.getById('user_1', 'mark_1'), isNotNull);
    expect(await resourcesRepository.getById('user_1', 'res_1'), isNotNull);

    await repository.delete('user_1', 'subj_1');

    expect(await repository.getById('user_1', 'subj_1'), isNull);
    expect(await assignmentRepository.getById('user_1', 'asgn_1'), isNull);
    expect(await attendanceRepository.getById('user_1', 'att_1'), isNull);
    expect(await timetableRepository.getById('user_1', 'tt_1'), isNull);
    expect(await internalMarksRepository.getById('user_1', 'mark_1'), isNull);
    expect(await resourcesRepository.getById('user_1', 'res_1'), isNull);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.targetTable, 'subjects');
    expect(pendingSync.last.operation, 'DELETE');
  });

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.create(const SubjectsCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });
}
