/// Checklist 3 & 6: Lecture Record repository (create/read/watch) and the
/// sync-queue enqueue behaviour that creation triggers.
library;

import 'package:college_companion/features/attendance/repositories/lecture_record_repository.dart';
import 'package:college_companion/shared/models/lecture_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_db.dart';

void main() {
  late Backend backend;
  late SeededGraph g;

  setUp(() async {
    backend = Backend.memory();
    g = await seedGraph(backend.db);
  });
  tearDown(() => backend.close());

  Future<String> createPresent({String? timetableId}) {
    return backend.lectureRecords.create(
      userId: g.userId,
      timetableId: timetableId ?? g.timetableId,
      subjectId: g.subjectId,
      semesterId: g.semesterId,
      status: const LectureStatus.present(),
      note: 'On time',
      deviceTimezone: 'Asia/Kolkata',
      appVersion: '1.0.0',
    );
  }

  group('3. create()', () {
    test('persists all business values correctly', () async {
      final id = await createPresent();
      final rec = await backend.lectureRecords.getById(g.userId, id);

      expect(rec, isNotNull);
      expect(rec!.id, id);
      expect(rec.userId, g.userId);
      expect(rec.timetableId, g.timetableId);
      expect(rec.subjectId, g.subjectId);
      expect(rec.semesterId, g.semesterId);
      expect(rec.statusText, 'present');
      expect(rec.note, 'On time');
      expect(rec.deviceTimezone, 'Asia/Kolkata');
      expect(rec.appVersion, '1.0.0');
    });

    test('initializes sync metadata correctly on creation', () async {
      final id = await createPresent();
      final rec = (await backend.lectureRecords.getById(g.userId, id))!;

      expect(rec.syncStatus, 'pending');
      expect(rec.syncVersion, 1);
      expect(rec.createdOffline, isTrue);
      expect(rec.lastSyncedAt, isNull);
    });

    test('timestamps are UTC and internally consistent', () async {
      final before = DateTime.now().toUtc();
      final id = await createPresent();
      final after = DateTime.now().toUtc();
      final rec = (await backend.lectureRecords.getById(g.userId, id))!;

      expect(rec.recordedAt.isUtc, isTrue);
      // recorded_at == created_at == updated_at at creation time.
      expect(rec.createdAt, rec.recordedAt);
      expect(rec.updatedAt, rec.recordedAt);
      expect(
        rec.recordedAt.isBefore(before.subtract(const Duration(seconds: 1))),
        isFalse,
      );
      expect(
        rec.recordedAt.isAfter(after.add(const Duration(seconds: 1))),
        isFalse,
      );
    });

    test('encodes secondary status (absent|holiday)', () async {
      final id = await backend.lectureRecords.create(
        userId: g.userId,
        timetableId: g.timetableId,
        subjectId: g.subjectId,
        semesterId: g.semesterId,
        status: const LectureStatus.absentWith('holiday'),
        deviceTimezone: 'Asia/Kolkata',
        appVersion: '1.0.0',
      );
      final rec = (await backend.lectureRecords.getById(g.userId, id))!;
      expect(rec.statusText, 'absent|holiday');
      expect(rec.note, isNull);
    });

    test('enforces 1:1 — duplicate timetable slot throws', () async {
      await createPresent();
      expect(
        () => createPresent(),
        throwsA(isA<LectureRecordExistsException>()),
      );
    });
  });

  group('3. read()', () {
    test('getByTimetableId returns the record for a slot', () async {
      final id = await createPresent();
      final rec = await backend.lectureRecords.getByTimetableId(
        g.userId,
        g.timetableId,
      );
      expect(rec?.id, id);
    });

    test('getAll returns all records for the user', () async {
      await createPresent(timetableId: 'tt-a');
      await createPresent(timetableId: 'tt-b');
      final all = await backend.lectureRecords.getAll(g.userId);
      expect(all.length, 2);
    });

    test('reads are user-scoped', () async {
      final id = await createPresent();
      final other = await backend.lectureRecords.getById('someone-else', id);
      expect(other, isNull);
    });
  });

  group('3. watch()', () {
    test('watchAll emits on new record', () async {
      final stream = backend.lectureRecords.watchAll(g.userId);
      final future = stream.firstWhere((rows) => rows.isNotEmpty);
      await createPresent();
      final rows = await future.timeout(const Duration(seconds: 5));
      expect(rows.single.statusText, 'present');
    });

    test('watchBySubject filters by subject', () async {
      final stream = backend.lectureRecords.watchBySubject(g.userId, g.subjectId);
      final future = stream.firstWhere((rows) => rows.isNotEmpty);
      await createPresent();
      final rows = await future.timeout(const Duration(seconds: 5));
      expect(rows.single.subjectId, g.subjectId);
    });
  });

  group('6. sync queue enqueue on create', () {
    test('create enqueues an INSERT op for lecture_records', () async {
      final id = await createPresent();
      final pending = await backend.syncRepository.fetchPending();
      expect(pending.length, 1);
      expect(pending.single.operation, 'INSERT');
      expect(pending.single.recordId, id);
      expect(pending.single.isSynced, isFalse);
      expect(pending.single.retryCount, 0);
    });

    test('multiple creates preserve FIFO ordering by createdAt', () async {
      final id1 = await createPresent(timetableId: 'tt-1');
      final id2 = await createPresent(timetableId: 'tt-2');
      final id3 = await createPresent(timetableId: 'tt-3');
      final pending = await backend.syncRepository.fetchPending();
      expect(
        pending.map((e) => e.recordId).toList(),
        [id1, id2, id3],
      );
    });

    test('duplicate enqueue for same record+op is merged', () async {
      final id = await createPresent();
      // Manually enqueue the same INSERT again — should be deduped.
      await backend.syncRepository.enqueue(
        tableName: 'lecture_records',
        recordId: id,
        operation: 'INSERT',
      );
      expect(await backend.queueDao.getPendingCount(), 1);
    });

    test('markEntireDayAbsent creates + enqueues per slot and is idempotent', () async {
      final created = await backend.lectureRecords.markEntireDayAbsent(
        userId: g.userId,
        slots: [
          MarkAbsentSlot(timetableId: 'd-1', subjectId: g.subjectId, semesterId: g.semesterId),
          MarkAbsentSlot(timetableId: 'd-2', subjectId: g.subjectId, semesterId: g.semesterId),
        ],
        deviceTimezone: 'Asia/Kolkata',
        appVersion: '1.0.0',
      );
      expect(created.length, 2);
      expect(await backend.queueDao.getPendingCount(), 2);

      // Re-running skips existing slots (no duplicates).
      final again = await backend.lectureRecords.markEntireDayAbsent(
        userId: g.userId,
        slots: [
          MarkAbsentSlot(timetableId: 'd-1', subjectId: g.subjectId, semesterId: g.semesterId),
        ],
        deviceTimezone: 'Asia/Kolkata',
        appVersion: '1.0.0',
      );
      expect(again, isEmpty);
    });
  });

  group('6. sync metadata store', () {
    test('set then get round-trips a bookkeeping value', () async {
      await backend.syncRepository.setMetadata('last_pull', '2026-07-07T00:00:00Z');
      expect(
        await backend.syncRepository.getMetadata('last_pull'),
        '2026-07-07T00:00:00Z',
      );
    });

    test('set replaces on conflict (upsert)', () async {
      await backend.syncRepository.setMetadata('k', 'v1');
      await backend.syncRepository.setMetadata('k', 'v2');
      expect(await backend.syncRepository.getMetadata('k'), 'v2');
    });
  });
}
