import 'package:college_companion/database/daos/attendance_evidence_dao.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_db.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Backend backend;
  late AttendanceEvidenceDao evidenceDao;

  setUp(() {
    backend = Backend.memory();
    evidenceDao = AttendanceEvidenceDao(backend.db, backend.queueDao);
  });

  tearDown(() => backend.close());

  group('AttendanceEvidenceDao - CRUD & Reactive Streams', () {
    test('insertEvidence creates a new row and allows retrieval', () async {
      await seedGraph(backend.db);
      const recordId = 'rec-101';
      final now = DateTime.now().toUtc();

      final companion = AttendanceEvidenceCompanion(
        id: const Value('ev-1'),
        lectureRecordId: const Value(recordId),
        localPathRelative: const Value('evidence/photo1.jpg'),
        sha256: const Value('abcdef1234567890'),
        width: const Value(1920),
        height: const Value(1080),
        captureTimestamp: Value(now),
        appVersion: const Value('1.0.0'),
        timezone: const Value('UTC'),
        state: const Value('original'),
      );

      final insertedId = await evidenceDao.insertEvidence(companion);
      expect(insertedId, 'ev-1');

      final fetched = await evidenceDao.getById('ev-1');
      expect(fetched, isNotNull);
      expect(fetched!.id, 'ev-1');
      expect(fetched.lectureRecordId, recordId);
      expect(fetched.localPathRelative, 'evidence/photo1.jpg');
      expect(fetched.sha256, 'abcdef1234567890');
    });

    test(
      'watchEvidenceForRecord emits updates reactively when evidence is inserted and deleted',
      () async {
        await seedGraph(backend.db);
        const recordId = 'rec-stream-1';
        final now = DateTime.now().toUtc();

        final stream = evidenceDao.watchEvidenceForRecord(recordId);

        expect(stream, emitsInOrder([isEmpty, hasLength(1), isEmpty]));

        // Insert
        final companion = AttendanceEvidenceCompanion(
          id: const Value('ev-stream-1'),
          lectureRecordId: const Value(recordId),
          localPathRelative: const Value('evidence/stream.jpg'),
          sha256: const Value('hash123'),
          width: const Value(800),
          height: const Value(600),
          captureTimestamp: Value(now),
          appVersion: const Value('1.0.0'),
          timezone: const Value('UTC'),
          state: const Value('original'),
        );
        await evidenceDao.insertEvidence(companion);

        // Delete
        await evidenceDao.deleteEvidence('ev-stream-1');
      },
    );

    test(
      'deleteEvidence removes record and registers with SyncQueue',
      () async {
        await seedGraph(backend.db);
        const recordId = 'rec-del-1';
        final now = DateTime.now().toUtc();

        await evidenceDao.insertEvidence(
          AttendanceEvidenceCompanion(
            id: const Value('ev-del-1'),
            lectureRecordId: const Value(recordId),
            localPathRelative: const Value('evidence/del.jpg'),
            sha256: const Value('delhash'),
            width: const Value(100),
            height: const Value(100),
            captureTimestamp: Value(now),
            appVersion: const Value('1.0.0'),
            timezone: const Value('UTC'),
            state: const Value('original'),
          ),
        );

        final beforeDelete = await evidenceDao.getById('ev-del-1');
        expect(beforeDelete, isNotNull);

        // Delete
        await evidenceDao.deleteEvidence('ev-del-1');

        final afterDelete = await evidenceDao.getById('ev-del-1');
        expect(afterDelete, isNull);

        // Verify sync queue has registered DELETE operation
        final pendingQueue = await backend.queueDao.fetchPending();
        final deleteItem = pendingQueue.firstWhere(
          (item) => item.recordId == 'ev-del-1' && item.operation == 'DELETE',
        );
        expect(deleteItem, isNotNull);
        expect(
          deleteItem.targetTable,
          isIn(['lecture_evidence', 'attendance_evidence']),
        );
      },
    );
  });
}
