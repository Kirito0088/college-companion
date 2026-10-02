/// v7 migration: repair assignments whose `subject_id` holds a subject's
/// name (#40).
///
/// Before #40 the add dialog stored the chosen subject's *name* in
/// `subject_id`. Every lookup by id missed those rows, and the cloud column
/// is a UUID foreign key, so they could never sync.
library;

import 'dart:io';

import 'package:college_companion/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

const _iso = '2026-09-01T00:00:00.000Z';

void main() {
  test('rewrites name-valued subject ids to real ids and queues the '
      'change for sync', () async {
    final tempDir = await Directory.systemTemp.createTemp('cc_v7');
    addTearDown(() => tempDir.delete(recursive: true));
    final file = File('${tempDir.path}/v6.db');

    // A database at the current schema, seeded with pre-#40 rows.
    final seed = AppDatabase.forTesting(NativeDatabase(file));
    await seed.customStatement('''
      INSERT INTO semesters (id, user_id, name, working_days, is_current,
        created_at, updated_at)
      VALUES ('sem-old', 'u1', 'Semester 4', '[]', 0, '$_iso', '$_iso'),
             ('sem-now', 'u1', 'Semester 5', '[]', 1, '$_iso', '$_iso')
    ''');
    await seed.customStatement('''
      INSERT INTO subjects (id, user_id, semester_id, name, type,
        created_at, updated_at)
      VALUES ('sub-dsa', 'u1', 'sem-now', 'Data Structures', 'theory',
               '$_iso', '$_iso'),
             ('sub-os-old', 'u1', 'sem-old', 'Operating Systems', 'theory',
               '$_iso', '$_iso'),
             ('sub-os-now', 'u1', 'sem-now', 'Operating Systems', 'theory',
               '$_iso', '$_iso'),
             ('sub-other', 'u2', 'sem-x', 'Data Structures', 'theory',
               '$_iso', '$_iso')
    ''');
    await seed.customStatement('''
      INSERT INTO assignments (id, user_id, subject_id, title, due_date,
        status, created_at, updated_at)
      VALUES ('a-name', 'u1', 'Data Structures', 'Lists', '2026-10-09',
               'pending', '$_iso', '$_iso'),
             ('a-dupe', 'u1', 'Operating Systems', 'Paging', '2026-10-09',
               'pending', '$_iso', '$_iso'),
             ('a-general', 'u1', 'General', 'Essay', '2026-10-09',
               'pending', '$_iso', '$_iso'),
             ('a-ok', 'u1', 'sub-dsa', 'Trees', '2026-10-09',
               'pending', '$_iso', '$_iso')
    ''');
    await seed.close();

    // Stamp it as v6, as an installed pre-#40 database would be.
    final raw = sqlite3.sqlite3.open(file.path);
    raw.execute('PRAGMA user_version = 6');
    raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final rows = {
      for (final a in await db.select(db.assignments).get()) a.id: a,
    };
    // Resolved within the owner's subjects only.
    expect(rows['a-name']!.subjectId, 'sub-dsa');
    // Two subjects share the name: the current semester's wins.
    expect(rows['a-dupe']!.subjectId, 'sub-os-now');
    // Nothing to point at: left alone, never guessed.
    expect(rows['a-general']!.subjectId, 'General');
    // Already an id: untouched.
    expect(rows['a-ok']!.subjectId, 'sub-dsa');
    expect(rows['a-ok']!.updatedAt, _iso);
    expect(rows['a-name']!.updatedAt, isNot(_iso));

    final queued = await db.select(db.syncQueueItems).get();
    expect(
      queued.map((q) => (q.targetTable, q.recordId, q.operation)).toSet(),
      {
        ('assignments', 'a-name', 'UPDATE'),
        ('assignments', 'a-dupe', 'UPDATE'),
      },
    );
  });
}
