import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late AttendanceRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    repository = AttendanceRepository(database, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('create and getById attendance record with sync queue integration', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    final companion = AttendanceCompanion(
      id: const Value('att_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      date: const Value('2026-07-23'),
      primaryStatus: const Value('present'),
      lectureType: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final id = await repository.create(companion);
    expect(id, 'att_1');

    final result = await repository.getById('user_1', 'att_1');
    expect(result, isNotNull);
    expect(result?.id, 'att_1');
    expect(result?.primaryStatus, 'present');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.length, 1);
    expect(pendingSync.first.targetTable, 'attendance');
    expect(pendingSync.first.recordId, 'att_1');
    expect(pendingSync.first.operation, 'INSERT');
  });

  test('update attendance modifies fields and enqueues sync UPDATE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AttendanceCompanion(
      id: const Value('att_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      date: const Value('2026-07-23'),
      primaryStatus: const Value('present'),
      lectureType: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.update(
      'user_1',
      'att_1',
      AttendanceCompanion(
        primaryStatus: const Value('absent'),
        notes: const Value('Sick leave'),
        updatedAt: Value(now),
      ),
    );

    final updated = await repository.getById('user_1', 'att_1');
    expect(updated?.primaryStatus, 'absent');
    expect(updated?.notes, 'Sick leave');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'UPDATE');
  });

  test('delete soft-deletes attendance record and enqueues sync DELETE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AttendanceCompanion(
      id: const Value('att_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      date: const Value('2026-07-23'),
      primaryStatus: const Value('present'),
      lectureType: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.delete('user_1', 'att_1');

    final result = await repository.getById('user_1', 'att_1');
    expect(result, isNull);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'DELETE');
  });

  test('watchAll filters by user and soft deletes', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AttendanceCompanion(
      id: const Value('id_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      date: const Value('2026-07-23'),
      primaryStatus: const Value('present'),
      lectureType: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(AttendanceCompanion(
      id: const Value('id_2'),
      userId: const Value('user_2'),
      subjectId: const Value('sub_1'),
      date: const Value('2026-07-23'),
      primaryStatus: const Value('absent'),
      lectureType: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(AttendanceCompanion(
      id: const Value('id_3'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      date: const Value('2026-07-23'),
      primaryStatus: const Value('cancelled'),
      lectureType: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
      deletedAt: Value(now),
    ));

    final results = await repository.watchAll('user_1').first;
    expect(results.length, 1);
    expect(results.first.id, 'id_1');
  });

  test('watchBySubject, watchOnDate, watchByDateRange, and watchById filter properly', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(AttendanceCompanion(
      id: const Value('att_day1_subA'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_A'),
      date: const Value('2026-07-20'),
      primaryStatus: const Value('present'),
      lectureType: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(AttendanceCompanion(
      id: const Value('att_day2_subA'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_A'),
      date: const Value('2026-07-22'),
      primaryStatus: const Value('present'),
      lectureType: const Value('theory'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(AttendanceCompanion(
      id: const Value('att_day2_subB'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_B'),
      date: const Value('2026-07-22'),
      primaryStatus: const Value('absent'),
      lectureType: const Value('practical'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // watchBySubject
    final subAList = await repository.watchBySubject('user_1', 'sub_A').first;
    expect(subAList.length, 2);

    // watchOnDate
    final dateList = await repository.watchOnDate('user_1', DateTime(2026, 7, 22)).first;
    expect(dateList.length, 2);

    // watchByDateRange
    final rangeList = await repository.watchByDateRange(
      'user_1',
      DateTime(2026, 7, 21),
      DateTime(2026, 7, 25),
    ).first;
    expect(rangeList.length, 2);

    // watchById
    final single = await repository.watchById('user_1', 'att_day1_subA').first;
    expect(single, isNotNull);
    expect(single?.subjectId, 'sub_A');
  });

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.create(const AttendanceCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });
}
