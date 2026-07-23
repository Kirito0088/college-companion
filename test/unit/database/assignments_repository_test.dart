import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late AssignmentRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    repository = AssignmentRepository(database, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('create and getById assignment with sync queue integration', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    final companion = AssignmentsCompanion(
      id: const Value('asgn_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Math Homework 1'),
      description: const Value('Calculus problems 1-10'),
      dueDate: const Value('2026-08-01'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final id = await repository.create(companion);
    expect(id, 'asgn_1');

    final result = await repository.getById('user_1', 'asgn_1');
    expect(result, isNotNull);
    expect(result?.title, 'Math Homework 1');
    expect(result?.description, 'Calculus problems 1-10');
    expect(result?.status, 'pending');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.length, 1);
    expect(pendingSync.first.targetTable, 'assignments');
    expect(pendingSync.first.recordId, 'asgn_1');
    expect(pendingSync.first.operation, 'INSERT');
  });

  test('update assignment modifies title and enqueues sync update', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Initial Title'),
      dueDate: const Value('2026-08-01'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.update(
      'user_1',
      'asgn_1',
      AssignmentsCompanion(
        title: const Value('Updated Title'),
        updatedAt: Value(now),
      ),
    );

    final updated = await repository.getById('user_1', 'asgn_1');
    expect(updated?.title, 'Updated Title');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.length, 2);
    expect(pendingSync.last.operation, 'UPDATE');
  });

  test('markCompleted sets status to completed and sets completedAt timestamp', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Physics Lab Report'),
      dueDate: const Value('2026-08-01'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.markCompleted('user_1', 'asgn_1');

    final completed = await repository.getById('user_1', 'asgn_1');
    expect(completed?.status, 'completed');
    expect(completed?.completedAt, isNotNull);
  });

  test('delete soft-deletes assignment and enqueues sync delete', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Essay'),
      dueDate: const Value('2026-08-01'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.delete('user_1', 'asgn_1');

    final result = await repository.getById('user_1', 'asgn_1');
    expect(result, isNull);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'DELETE');
  });

  test('watchAll filters by user and excludes soft-deleted assignments', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Task 1'),
      dueDate: const Value('2026-08-01'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_2'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Deleted Task'),
      dueDate: const Value('2026-08-02'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
      deletedAt: Value(now),
    ));

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_3'),
      userId: const Value('user_2'),
      subjectId: const Value('sub_1'),
      title: const Value('Other User Task'),
      dueDate: const Value('2026-08-01'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    final list = await repository.watchAll('user_1').first;
    expect(list.length, 1);
    expect(list.first.id, 'asgn_1');
  });

  test('watchPending and watchCompleted stream correct assignment statuses', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_pending'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Pending Assignment'),
      dueDate: const Value('2026-08-01'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_completed'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Completed Assignment'),
      dueDate: const Value('2026-07-20'),
      status: const Value('completed'),
      completedAt: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    final pendingList = await repository.watchPending('user_1').first;
    expect(pendingList.length, 1);
    expect(pendingList.first.id, 'asgn_pending');

    final completedList = await repository.watchCompleted('user_1').first;
    expect(completedList.length, 1);
    expect(completedList.first.id, 'asgn_completed');
  });

  test('watchDueOn and watchUpcoming filter by due date correctly', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_due_today'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Due Today'),
      dueDate: const Value('2026-08-10'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_due_later'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Due Later'),
      dueDate: const Value('2026-08-20'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    final targetDate = DateTime(2026, 8, 10);
    final dueOnList = await repository.watchDueOn('user_1', targetDate).first;
    expect(dueOnList.length, 1);
    expect(dueOnList.first.id, 'asgn_due_today');

    final upcomingCutoff = DateTime(2026, 8, 15);
    final upcomingList = await repository.watchUpcoming('user_1', upcomingCutoff).first;
    expect(upcomingList.length, 1);
    expect(upcomingList.first.id, 'asgn_due_today');
  });

  test('watchBySubject and watchById filter correctly', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_subj_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_A'),
      title: const Value('Sub A Assignment'),
      dueDate: const Value('2026-08-01'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(AssignmentsCompanion(
      id: const Value('asgn_subj_2'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_B'),
      title: const Value('Sub B Assignment'),
      dueDate: const Value('2026-08-01'),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    final subAList = await repository.watchBySubject('user_1', 'sub_A').first;
    expect(subAList.length, 1);
    expect(subAList.first.id, 'asgn_subj_1');

    final single = await repository.watchById('user_1', 'asgn_subj_1').first;
    expect(single, isNotNull);
    expect(single?.title, 'Sub A Assignment');
  });

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.create(const AssignmentsCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });
}
