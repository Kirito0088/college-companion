import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/internal_marks/repositories/internal_marks_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late InternalMarksRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    repository = InternalMarksRepository(database, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('create and getById internal mark with sync queue integration', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    final companion = InternalMarksCompanion(
      id: const Value('mark_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      examName: const Value('Mid Term 1'),
      marksObtained: const Value(18.5),
      maxMarks: const Value(20.0),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final id = await repository.create(companion);
    expect(id, 'mark_1');

    final result = await repository.getById('user_1', 'mark_1');
    expect(result, isNotNull);
    expect(result?.id, 'mark_1');
    expect(result?.examName, 'Mid Term 1');
    expect(result?.marksObtained, 18.5);
    expect(result?.maxMarks, 20.0);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.length, 1);
    expect(pendingSync.first.targetTable, 'internal_marks');
    expect(pendingSync.first.recordId, 'mark_1');
    expect(pendingSync.first.operation, 'INSERT');
  });

  test('update internal mark modifies score and enqueues sync UPDATE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(InternalMarksCompanion(
      id: const Value('mark_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      examName: const Value('UT-1'),
      marksObtained: const Value(15.0),
      maxMarks: const Value(20.0),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.update(
      'user_1',
      'mark_1',
      InternalMarksCompanion(
        marksObtained: const Value(19.0),
        updatedAt: Value(now),
      ),
    );

    final updated = await repository.getById('user_1', 'mark_1');
    expect(updated?.marksObtained, 19.0);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'UPDATE');
  });

  test('delete soft-deletes internal mark and enqueues sync DELETE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(InternalMarksCompanion(
      id: const Value('mark_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      examName: const Value('Quiz'),
      marksObtained: const Value(8.0),
      maxMarks: const Value(10.0),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.delete('user_1', 'mark_1');

    final result = await repository.getById('user_1', 'mark_1');
    expect(result, isNull);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'DELETE');
  });

  test('watchAll, watchBySubject, and watchById stream internal marks correctly', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(InternalMarksCompanion(
      id: const Value('mark_subA_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_A'),
      examName: const Value('Quiz 1'),
      marksObtained: const Value(9.0),
      maxMarks: const Value(10.0),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(InternalMarksCompanion(
      id: const Value('mark_subA_2'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_A'),
      examName: const Value('Quiz 2'),
      marksObtained: const Value(10.0),
      maxMarks: const Value(10.0),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(InternalMarksCompanion(
      id: const Value('mark_subB_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_B'),
      examName: const Value('Midterm'),
      marksObtained: const Value(45.0),
      maxMarks: const Value(50.0),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(InternalMarksCompanion(
      id: const Value('mark_deleted'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_A'),
      examName: const Value('Cancelled Exam'),
      marksObtained: const Value(0.0),
      maxMarks: const Value(10.0),
      deletedAt: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // watchAll: 3 active items
    final allList = await repository.watchAll('user_1').first;
    expect(allList.length, 3);

    // watchBySubject for sub_A: 2 active items
    final subAList = await repository.watchBySubject('user_1', 'sub_A').first;
    expect(subAList.length, 2);

    // watchById
    final single = await repository.watchById('user_1', 'mark_subA_1').first;
    expect(single, isNotNull);
    expect(single?.examName, 'Quiz 1');
  });

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.create(const InternalMarksCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });
}
