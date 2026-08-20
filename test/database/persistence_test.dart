/// Persistence across database close/reopen cycles.
library;

import 'dart:io';

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/shared/models/lecture_status.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_db.dart';

void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cc_persist_test');
    dbFile = File('${tempDir.path}/college_companion.db');
  });

  tearDown(() async {
    try {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  test('8. records and sync queue survive a close + reopen cycle', () async {
    // Session 1: create a record.
    final b1 = Backend(AppDatabase.forTesting(NativeDatabase(dbFile)));
    final g = await seedGraph(b1.db);
    final id = await b1.lectureRecords.create(
      userId: g.userId,
      timetableId: g.timetableId,
      subjectId: g.subjectId,
      semesterId: g.semesterId,
      status: const LectureStatus.absentWith('holiday'),
      note: 'persisted note',
      deviceTimezone: 'Asia/Kolkata',
      appVersion: '1.0.0',
    );
    await b1.syncRepository.setMetadata('cursor', 'v42');
    await b1.close();

    // Session 2: reopen the same file.
    final b2 = Backend(AppDatabase.forTesting(NativeDatabase(dbFile)));
    final rec = await b2.lectureRecords.getById(g.userId, id);

    expect(rec, isNotNull, reason: 'record must survive reopen');
    expect(rec!.statusText, 'absent|holiday');
    expect(rec.note, 'persisted note');
    expect(rec.syncStatus, 'pending');
    expect(rec.syncVersion, 1);

    // Sync queue entry persisted.
    final pending = await b2.syncRepository.fetchPending();
    expect(pending.any((p) => p.recordId == id), isTrue);

    // Metadata persisted.
    expect(await b2.syncRepository.getMetadata('cursor'), 'v42');

    await b2.close();
  });
}
