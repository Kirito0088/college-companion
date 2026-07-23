import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
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

  test('create and getById timetable slot with sync queue integration', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    final id = await repository.create(TimetableCompanion(
      id: const Value('tt_1'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_1'),
      dayOfWeek: const Value(1),
      startTime: const Value('09:00:00'),
      endTime: const Value('10:00:00'),
      room: const Value('Lab 101'),
      lectureType: const Value('practical'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    expect(id, 'tt_1');

    final result = await repository.getById('user_1', 'tt_1');
    expect(result, isNotNull);
    expect(result?.dayOfWeek, 1);
    expect(result?.startTime, '09:00:00');
    expect(result?.endTime, '10:00:00');
    expect(result?.room, 'Lab 101');
    expect(result?.lectureType, 'practical');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.length, 1);
    expect(pendingSync.first.targetTable, 'timetable');
    expect(pendingSync.first.recordId, 'tt_1');
    expect(pendingSync.first.operation, 'INSERT');
  });

  test('update timetable slot modifies fields and enqueues sync UPDATE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(TimetableCompanion(
      id: const Value('tt_1'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_1'),
      dayOfWeek: const Value(1),
      startTime: const Value('09:00:00'),
      endTime: const Value('10:00:00'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.update(
      'user_1',
      'tt_1',
      TimetableCompanion(
        startTime: const Value('09:30:00'),
        endTime: const Value('10:30:00'),
        room: const Value('Room 302'),
        updatedAt: Value(now),
      ),
    );

    final updated = await repository.getById('user_1', 'tt_1');
    expect(updated?.startTime, '09:30:00');
    expect(updated?.endTime, '10:30:00');
    expect(updated?.room, 'Room 302');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'UPDATE');
  });

  test('delete soft-deletes timetable slot and enqueues sync DELETE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(TimetableCompanion(
      id: const Value('tt_1'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_1'),
      dayOfWeek: const Value(1),
      startTime: const Value('09:00:00'),
      endTime: const Value('10:00:00'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.delete('user_1', 'tt_1');

    final result = await repository.getById('user_1', 'tt_1');
    expect(result, isNull);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'DELETE');
  });

  test('watchAll, watchByDay, watchBySubject, watchById streams filter and order correctly', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(TimetableCompanion(
      id: const Value('tt_mon_early'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_math'),
      dayOfWeek: const Value(0),
      startTime: const Value('08:00:00'),
      endTime: const Value('09:00:00'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(TimetableCompanion(
      id: const Value('tt_mon_late'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_physics'),
      dayOfWeek: const Value(0),
      startTime: const Value('11:00:00'),
      endTime: const Value('12:00:00'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(TimetableCompanion(
      id: const Value('tt_tue'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_math'),
      dayOfWeek: const Value(1),
      startTime: const Value('09:00:00'),
      endTime: const Value('10:00:00'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(TimetableCompanion(
      id: const Value('tt_deleted'),
      userId: const Value('user_1'),
      subjectId: const Value('subj_math'),
      dayOfWeek: const Value(0),
      startTime: const Value('10:00:00'),
      endTime: const Value('11:00:00'),
      deletedAt: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // watchAll: 3 active entries sorted by dayOfWeek then startTime
    final allList = await repository.watchAll('user_1').first;
    expect(allList.length, 3);
    expect(allList[0].id, 'tt_mon_early');
    expect(allList[1].id, 'tt_mon_late');
    expect(allList[2].id, 'tt_tue');

    // watchByDay for Monday (day 0): 2 entries sorted by startTime
    final monList = await repository.watchByDay('user_1', 0).first;
    expect(monList.length, 2);
    expect(monList[0].id, 'tt_mon_early');
    expect(monList[1].id, 'tt_mon_late');

    // watchBySubject for Math: 2 active entries (Mon early & Tue)
    final mathList = await repository.watchBySubject('user_1', 'subj_math').first;
    expect(mathList.length, 2);

    // watchById
    final single = await repository.watchById('user_1', 'tt_mon_early').first;
    expect(single, isNotNull);
    expect(single?.subjectId, 'subj_math');
  });

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.create(const TimetableCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });
}
