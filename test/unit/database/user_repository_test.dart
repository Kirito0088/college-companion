import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/repositories/user_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late UserRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    repository = UserRepository(database, null, syncQueueRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('AppUser creation and properties', () {
    const user = AppUser(
      uid: 'user_1',
      displayName: 'Alex Smith',
      email: 'alex@college.edu',
      photoUrl: 'https://example.com/photo.jpg',
    );

    expect(user.uid, 'user_1');
    expect(user.displayName, 'Alex Smith');
    expect(user.email, 'alex@college.edu');
    expect(user.photoUrl, 'https://example.com/photo.jpg');
  });

  test('upsertUser saves user to offline SQLite and enqueues sync queue item', () async {
    const appUser = AppUser(
      uid: 'user_1',
      displayName: 'Alex Smith',
      email: 'alex@college.edu',
      photoUrl: 'https://example.com/photo.jpg',
    );

    await repository.upsertUser(appUser);

    final fetched = await repository.getById('user_1');
    expect(fetched, isNotNull);
    expect(fetched?.name, 'Alex Smith');
    expect(fetched?.email, 'alex@college.edu');
    expect(fetched?.profilePhoto, 'https://example.com/photo.jpg');

    final getUserResult = await repository.getUserById('user_1');
    expect(getUserResult, isNotNull);
    expect(getUserResult?.id, 'user_1');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.length, 1);
    expect(pendingSync.first.targetTable, 'users');
    expect(pendingSync.first.recordId, 'user_1');
    expect(pendingSync.first.operation, 'UPDATE');
  });

  test('create user companion inserts row and enqueues sync INSERT', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    final companion = UsersCompanion(
      id: const Value('user_new'),
      name: const Value('New User'),
      email: const Value('new@college.edu'),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final id = await repository.create(companion);
    expect(id, 'user_new');

    final fetched = await repository.getById('user_new');
    expect(fetched?.name, 'New User');

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.first.operation, 'INSERT');
  });

  test('update user modifies fields and enqueues sync UPDATE', () async {
    const appUser = AppUser(
      uid: 'user_1',
      displayName: 'Original Name',
      email: 'original@college.edu',
    );
    await repository.upsertUser(appUser);

    final now = DateTime.now().toUtc().toIso8601String();
    await repository.update(
      'user_1',
      UsersCompanion(
        name: const Value('Updated Name'),
        updatedAt: Value(now),
      ),
    );

    final updated = await repository.getById('user_1');
    expect(updated?.name, 'Updated Name');
  });

  test('watchUser, watchById, and watchAll stream user profile updates', () async {
    const appUser = AppUser(
      uid: 'user_1',
      displayName: 'Jane Doe',
      email: 'jane@college.edu',
    );

    await repository.upsertUser(appUser);

    final stream1 = repository.watchUser('user_1');
    final entity1 = await stream1.first;
    expect(entity1, isNotNull);
    expect(entity1?.name, 'Jane Doe');

    final stream2 = repository.watchById('user_1');
    final entity2 = await stream2.first;
    expect(entity2?.email, 'jane@college.edu');

    final allStream = repository.watchAll();
    final allUsers = await allStream.first;
    expect(allUsers.length, 1);
    expect(allUsers.first.id, 'user_1');
  });

  test('delete user removes record from SQLite and enqueues sync DELETE', () async {
    const appUser = AppUser(
      uid: 'user_to_delete',
      displayName: 'Delete Me',
      email: 'delete@college.edu',
    );

    await repository.upsertUser(appUser);
    expect(await repository.getById('user_to_delete'), isNotNull);

    await repository.delete('user_to_delete');
    expect(await repository.getById('user_to_delete'), isNull);

    final pendingSync = await syncQueueRepository.getPendingItems();
    expect(pendingSync.last.operation, 'DELETE');
  });

  test('wraps database errors in DatabaseException', () async {
    expect(
      () async => repository.create(const UsersCompanion()),
      throwsA(isA<DatabaseException>()),
    );
  });
}
