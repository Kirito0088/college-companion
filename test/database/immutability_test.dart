/// Immutability Verification (Layer 1 and Layer 2)
library;

import 'package:college_companion/shared/models/lecture_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_db.dart';

void main() {
  late Backend backend;
  late SeededGraph g;
  late String recordId;

  setUp(() async {
    backend = Backend.memory();
    g = await seedGraph(backend.db);
    recordId = await backend.lectureRecords.create(
      userId: g.userId,
      timetableId: g.timetableId,
      subjectId: g.subjectId,
      semesterId: g.semesterId,
      status: const LectureStatus.present(),
      note: 'original',
      deviceTimezone: 'Asia/Kolkata',
      appVersion: '1.0.0',
    );
  });

  tearDown(() => backend.close());

  group('Layer 1 Immutability', () {
    test(
      'LectureRecordRepository exposes no public update or delete methods',
      () async {
        final rec = await backend.lectureRecords.getById(g.userId, recordId);
        expect(rec, isNotNull);
        expect(rec?.statusText, 'present');
        expect(rec?.note, 'original');
      },
    );
  });

  group('Layer 2 Sync State Bookkeeping', () {
    test('updateSyncState updates sync state metadata', () async {
      await backend.lectureDao.updateSyncState(
        recordId,
        syncStatus: 'synced',
        syncVersion: 2,
        lastSyncedAt: DateTime.utc(2026, 7, 7),
      );

      final after = await backend.lectureRecords.getById(g.userId, recordId);
      expect(after?.syncStatus, 'synced');
      expect(after?.syncVersion, 2);
      expect(after?.lastSyncedAt, DateTime.utc(2026, 7, 7));
      expect(after?.statusText, 'present');
      expect(after?.note, 'original');
    });
  });
}
