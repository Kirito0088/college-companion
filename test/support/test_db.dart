/// Shared test harness for backend QA (Phase 4.5).
///
/// Builds the full local backend stack over an in-memory SQLite database so
/// tests exercise the *real* Drift schema, migrations, triggers, DAOs, and
/// repositories — not mocks.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/lecture_record_dao.dart';
import 'package:college_companion/database/daos/sync_metadata_dao.dart';
import 'package:college_companion/database/daos/sync_queue_dao.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/attendance/repositories/lecture_record_repository.dart';
import 'package:college_companion/features/attendance/repositories/sync_repository.dart';
import 'package:drift/native.dart';

/// The full backend stack wired over a single [AppDatabase] instance.
class Backend {
  Backend(this.db)
    : lectureDao = LectureRecordDao(db),
      queueDao = SyncQueueDao(db),
      metadataDao = SyncMetadataDao(db) {
    syncRepository = SyncRepository(queueDao, metadataDao);
    lectureRecords = LectureRecordRepository(db, syncRepository);
    attendance = AttendanceRepository(lectureDao);
  }

  /// Builds a backend over a fresh in-memory database.
  factory Backend.memory() => Backend(AppDatabase.forTesting(NativeDatabase.memory()));

  final AppDatabase db;
  final LectureRecordDao lectureDao;
  final SyncQueueDao queueDao;
  final SyncMetadataDao metadataDao;
  late final SyncRepository syncRepository;
  late final LectureRecordRepository lectureRecords;
  late final AttendanceRepository attendance;

  Future<void> close() => db.close();
}

const testUserId = 'user-1';

/// Seeds a minimal but valid parent graph: user → semester → subject →
/// timetable slot. Returns the created IDs for use in lecture records.
///
/// Because the local schema is denormalized (no FK enforcement), lecture
/// records can technically be created without these — but seeding keeps
/// tests realistic and exercises the parent tables' constraints too.
Future<SeededGraph> seedGraph(
  AppDatabase db, {
  String userId = testUserId,
  String subjectId = 'subject-1',
  String semesterId = 'semester-1',
  String timetableId = 'timetable-1',
}) async {
  await db.into(db.users).insert(
    UsersCompanion.insert(
      id: userId,
      name: 'Test Student',
      email: 'test@example.com',
    ),
  );
  await db.into(db.semesters).insert(
    SemestersCompanion.insert(
      id: semesterId,
      userId: userId,
      name: 'Semester 5',
      workingDays: '[0,1,2,3,4]',
    ),
  );
  await db.into(db.subjects).insert(
    SubjectsCompanion.insert(
      id: subjectId,
      userId: userId,
      semesterId: semesterId,
      name: 'Data Structures',
    ),
  );
  await db.into(db.timetable).insert(
    TimetableCompanion.insert(
      id: timetableId,
      userId: userId,
      subjectId: subjectId,
      dayOfWeek: 0,
      startTime: '09:00',
      endTime: '10:00',
    ),
  );
  return SeededGraph(
    userId: userId,
    semesterId: semesterId,
    subjectId: subjectId,
    timetableId: timetableId,
  );
}

/// IDs from [seedGraph].
class SeededGraph {
  SeededGraph({
    required this.userId,
    required this.semesterId,
    required this.subjectId,
    required this.timetableId,
  });

  final String userId;
  final String semesterId;
  final String subjectId;
  final String timetableId;
}
