import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/resources/repositories/resources_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late ResourcesRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    repository = ResourcesRepository(database, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('create and getById resource with sync queue integration', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    final companion = ResourcesCompanion(
      id: const Value('res_1'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_1'),
      title: const Value('Physics Notes'),
      description: const Value('Chapter 1 notes'),
      url: const Value('https://example.com/physics.pdf'),
      category: const Value('notes'),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final id = await repository.create(companion);
    expect(id, 'res_1');

    final result = await repository.getById('user_1', 'res_1');
    expect(result, isNotNull);
    expect(result?.title, 'Physics Notes');
    expect(result?.description, 'Chapter 1 notes');
    expect(result?.url, 'https://example.com/physics.pdf');
    expect(result?.category, 'notes');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.length, 1);
    expect(pendingSync.first.targetTable, 'resources');
    expect(pendingSync.first.recordId, 'res_1');
    expect(pendingSync.first.operation, 'INSERT');
  });

  test('update resource modifies title and enqueues sync UPDATE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(ResourcesCompanion(
      id: const Value('res_1'),
      userId: const Value('user_1'),
      title: const Value('Initial Title'),
      url: const Value('https://example.com/link'),
      category: const Value('notes'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.update(
      'user_1',
      'res_1',
      ResourcesCompanion(
        title: const Value('Updated Title'),
        url: const Value('https://example.com/updated_link'),
        updatedAt: Value(now),
      ),
    );

    final updated = await repository.getById('user_1', 'res_1');
    expect(updated?.title, 'Updated Title');
    expect(updated?.url, 'https://example.com/updated_link');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'UPDATE');
  });

  test('delete soft-deletes resource and enqueues sync DELETE', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(ResourcesCompanion(
      id: const Value('res_1'),
      userId: const Value('user_1'),
      title: const Value('Old Paper'),
      url: const Value('https://example.com/old.pdf'),
      category: const Value('past_papers'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.delete('user_1', 'res_1');

    final result = await repository.getById('user_1', 'res_1');
    expect(result, isNull);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'DELETE');
  });

  test('watchAll, watchBySubject, watchByCategory, and watchById stream resources properly', () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await repository.create(ResourcesCompanion(
      id: const Value('res_notes_subA'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_A'),
      title: const Value('Sub A Notes'),
      url: const Value('https://example.com/subA.pdf'),
      category: const Value('notes'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(ResourcesCompanion(
      id: const Value('res_papers_subA'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_A'),
      title: const Value('Sub A Past Papers'),
      url: const Value('https://example.com/papers.pdf'),
      category: const Value('past_papers'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    await repository.create(ResourcesCompanion(
      id: const Value('res_deleted'),
      userId: const Value('user_1'),
      subjectId: const Value('sub_A'),
      title: const Value('Deleted Link'),
      url: const Value('https://example.com/del.pdf'),
      category: const Value('notes'),
      deletedAt: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // watchAll: 2 active resources
    final allList = await repository.watchAll('user_1').first;
    expect(allList.length, 2);

    // watchBySubject for sub_A: 2 active resources
    final subAList = await repository.watchBySubject('user_1', 'sub_A').first;
    expect(subAList.length, 2);

    // watchByCategory for past_papers: 1 resource
    final categoryList = await repository.watchByCategory('user_1', 'past_papers').first;
    expect(categoryList.length, 1);
    expect(categoryList.first.id, 'res_papers_subA');

    // watchById
    final single = await repository.watchById('user_1', 'res_notes_subA').first;
    expect(single, isNotNull);
    expect(single?.title, 'Sub A Notes');
  });

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.create(const ResourcesCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });
}
