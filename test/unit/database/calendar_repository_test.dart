import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/calendar/repositories/calendar_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late CalendarRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    repository = CalendarRepository(database, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('create and getById calendar event with sync queue integration', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    final companion = CalendarEventsCompanion(
      id: const Value('event_1'),
      userId: const Value('user_1'),
      title: const Value('Midterm Exam'),
      description: const Value('Calculus midterm'),
      startDate: const Value('2026-08-01T09:00:00Z'),
      endDate: const Value('2026-08-01T12:00:00Z'),
      isAllDay: const Value(false),
      eventType: const Value('exam'),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final id = await repository.create(companion);
    expect(id, 'event_1');

    final result = await repository.getById('user_1', 'event_1');
    expect(result, isNotNull);
    expect(result?.title, 'Midterm Exam');
    expect(result?.description, 'Calculus midterm');
    expect(result?.eventType, 'exam');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.length, 1);
    expect(pendingSync.first.targetTable, 'calendar_events');
    expect(pendingSync.first.recordId, 'event_1');
    expect(pendingSync.first.operation, 'INSERT');
  });

  test('update calendar event modifies title and enqueues sync UPDATE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(CalendarEventsCompanion(
      id: const Value('event_1'),
      userId: const Value('user_1'),
      title: const Value('Initial Event'),
      startDate: const Value('2026-08-01T09:00:00Z'),
      endDate: const Value('2026-08-01T12:00:00Z'),
      eventType: const Value('general'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.update(
      'user_1',
      'event_1',
      CalendarEventsCompanion(
        title: const Value('Rescheduled Event'),
        updatedAt: Value(now),
      ),
    );

    final updated = await repository.getById('user_1', 'event_1');
    expect(updated?.title, 'Rescheduled Event');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'UPDATE');
  });

  test('soft delete calendar event enqueues sync DELETE and filters out event', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(CalendarEventsCompanion(
      id: const Value('event_1'),
      userId: const Value('user_1'),
      title: const Value('To be deleted'),
      startDate: const Value('2026-08-01T09:00:00Z'),
      endDate: const Value('2026-08-01T12:00:00Z'),
      eventType: const Value('personal'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    var results = await repository.watchAll('user_1').first;
    expect(results.length, 1);

    await repository.delete('user_1', 'event_1');

    results = await repository.watchAll('user_1').first;
    expect(results.length, 0);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'DELETE');
  });

  test('watchByDateRange, watchUpcoming, and watchById filter calendar events correctly', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(CalendarEventsCompanion(
      id: const Value('ev_early'),
      userId: const Value('user_1'),
      title: const Value('Early Event'),
      startDate: const Value('2026-08-05T09:00:00Z'),
      endDate: const Value('2026-08-05T10:00:00Z'),
      eventType: const Value('exam'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(CalendarEventsCompanion(
      id: const Value('ev_late'),
      userId: const Value('user_1'),
      title: const Value('Late Event'),
      startDate: const Value('2026-08-25T09:00:00Z'),
      endDate: const Value('2026-08-25T10:00:00Z'),
      eventType: const Value('holiday'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // watchByDateRange (Aug 1 to Aug 10)
    final rangeList = await repository.watchByDateRange(
      'user_1',
      DateTime.utc(2026, 8, 1),
      DateTime.utc(2026, 8, 10),
    ).first;
    expect(rangeList.length, 1);
    expect(rangeList.first.id, 'ev_early');

    // watchUpcoming (up to Aug 15)
    final upcomingList = await repository.watchUpcoming(
      'user_1',
      DateTime.utc(2026, 8, 15),
    ).first;
    expect(upcomingList.length, 1);
    expect(upcomingList.first.id, 'ev_early');

    // watchById
    final single = await repository.watchById('user_1', 'ev_early').first;
    expect(single, isNotNull);
    expect(single?.title, 'Early Event');
  });

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.create(const CalendarEventsCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });
}
