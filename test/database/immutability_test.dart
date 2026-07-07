/// Checklist 5: Immutability — the three protection layers.
///
///   Layer 1 (Repository): no public update()/delete() — compile-time.
///   Layer 2 (DAO): updateSyncState writes ONLY sync-bookkeeping columns.
///   Layer 3 (SQLite trigger): BEFORE UPDATE/DELETE RAISE(ABORT).
///
/// Layer 1 is verified by the absence of the API (the repository has no
/// update/delete methods to call). Layers 2 and 3 are verified at runtime.
library;

import 'package:college_companion/shared/models/lecture_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/common.dart' show SqliteException;

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

  group('Layer 3 — SQLite trigger blocks business-field mutation', () {
    test('changing status_text is rejected by the trigger', () async {
      expect(
        () => backend.db.customStatement(
          "UPDATE lecture_records SET status_text = 'absent' WHERE id = ?",
          [recordId],
        ),
        throwsA(
          isA<SqliteException>().having(
            (e) => e.message,
            'message',
            contains('immutable'),
          ),
        ),
      );
    });

    test('changing note is rejected', () async {
      expect(
        () => backend.db.customStatement(
          "UPDATE lecture_records SET note = 'tampered' WHERE id = ?",
          [recordId],
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('changing recorded_at / timetable_id / created_at is rejected', () async {
      for (final col in ['recorded_at', 'timetable_id', 'created_at']) {
        expect(
          () => backend.db.customStatement(
            "UPDATE lecture_records SET $col = 'x' WHERE id = ?",
            [recordId],
          ),
          throwsA(isA<SqliteException>()),
          reason: 'mutating $col must abort',
        );
      }
    });

    test('business fields are unchanged after a rejected update', () async {
      try {
        await backend.db.customStatement(
          "UPDATE lecture_records SET status_text = 'absent' WHERE id = ?",
          [recordId],
        );
      } catch (_) {}
      final rec = (await backend.lectureRecords.getById(g.userId, recordId))!;
      expect(rec.statusText, 'present');
      expect(rec.note, 'original');
    });
  });

  group('Layer 3 — delete protection', () {
    test('DELETE on lecture_records is rejected by the trigger', () async {
      expect(
        () => backend.db.customStatement(
          'DELETE FROM lecture_records WHERE id = ?',
          [recordId],
        ),
        throwsA(
          isA<SqliteException>().having(
            (e) => e.message,
            'message',
            contains('cannot be deleted'),
          ),
        ),
      );
    });

    test('record still present after a rejected delete', () async {
      try {
        await backend.db.customStatement(
          'DELETE FROM lecture_records WHERE id = ?',
          [recordId],
        );
      } catch (_) {}
      expect(await backend.lectureRecords.getById(g.userId, recordId), isNotNull);
    });
  });

  group('Layer 2 — sync-bookkeeping columns remain writable', () {
    test('updateSyncState succeeds and updates only sync columns', () async {
      final before = (await backend.lectureRecords.getById(g.userId, recordId))!;

      await backend.lectureDao.updateSyncState(
        recordId,
        syncStatus: 'synced',
        syncVersion: 2,
        lastSyncedAt: DateTime.utc(2026, 7, 7),
      );

      final after = (await backend.lectureRecords.getById(g.userId, recordId))!;
      // Sync columns changed.
      expect(after.syncStatus, 'synced');
      expect(after.syncVersion, 2);
      expect(after.lastSyncedAt, DateTime.utc(2026, 7, 7));
      // Business columns untouched.
      expect(after.statusText, before.statusText);
      expect(after.note, before.note);
      expect(after.recordedAt, before.recordedAt);
      expect(after.timetableId, before.timetableId);
      expect(after.createdAt, before.createdAt);
    });

    test('a bare sync-only UPDATE via SQL is allowed by the trigger', () async {
      // The trigger WHEN clause excludes sync columns, so this must NOT abort.
      await backend.db.customStatement(
        "UPDATE lecture_records SET sync_status = 'failed' WHERE id = ?",
        [recordId],
      );
      final rec = (await backend.lectureRecords.getById(g.userId, recordId))!;
      expect(rec.syncStatus, 'failed');
    });
  });
}
