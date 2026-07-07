/// Lecture Record Repository
///
/// Owns persistence for the immutable `lecture_records` ledger.
/// (Phase 4 §3 — one immutable Lecture Record per Timetable Lecture, D1 / D2.)
///
/// Layer 1 of the three-layer immutability model (§4): exposes **no**
/// public `update()` or `delete()` methods — immutability is enforced at
/// compile-time. Sync-bookkeeping writes flow through the DAO's narrowly-
/// scoped internal `updateSyncState()` (Layer 2), and the SQLite BEFORE
/// UPDATE / BEFORE DELETE triggers are the runtime backstop (Layer 3).
///
/// Public API per the locked spec:
/// - `create()` — record attendance for one lecture (spec §3 1:1 UNIQUE)
/// - `getById()` / `watchById()` / `watchBySubject()` / `watchBySemester()` ...
/// - `markEntireDayAbsent()` — batch-create Absent records for a whole
///   day's timetable slots (spec §6)
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/lecture_record_dao.dart';
import 'package:college_companion/features/attendance/repositories/sync_repository.dart';
import 'package:college_companion/shared/models/lecture_status.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Repository for creating and reading immutable lecture records.
class LectureRecordRepository {
  LectureRecordRepository(this._database, this._syncRepository)
    : _dao = LectureRecordDao(_database);

  final AppDatabase _database;
  final SyncRepository _syncRepository;
  final LectureRecordDao _dao;

  static const _uuid = Uuid();

  // ── Creation ────────────────────────────────────────────────────────

  /// Creates an immutable lecture record for a specific timetable slot.
  ///
  /// Returns the new record's UUID.
  /// Throws [LectureRecordExistsException] if this timetable slot already
  /// has a record (1:1 UNIQUE constraint).
  Future<String> create({
    required String userId,
    required String timetableId,
    required String subjectId,
    required String semesterId,
    required LectureStatus status,
    String? note,
    required String deviceTimezone,
    required String appVersion,
  }) async {
    // Validate 1:1 — each timetable slot gets one record.
    final existing = await _dao.getByTimetableId(userId, timetableId);
    if (existing != null) {
      throw LectureRecordExistsException(timetableId);
    }

    final id = _uuid.v4();
    final now = DateTime.now().toUtc();

    await _database
        .into(_database.lectureRecords)
        .insert(
          LectureRecordsCompanion(
            id: Value(id),
            timetableId: Value(timetableId),
            subjectId: Value(subjectId),
            semesterId: Value(semesterId),
            userId: Value(userId),
            statusText: Value(status.encode()),
            note: note != null ? Value(note) : const Value.absent(),
            recordedAt: Value(now),
            deviceTimezone: Value(deviceTimezone),
            appVersion: Value(appVersion),
            // Sync columns — on creation, always:
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: const Value('pending'),
            syncVersion: const Value(1),
            createdOffline: const Value(true),
            lastSyncedAt: const Value.absent(),
          ),
        );

    // Phase 4 enqueue (Phase 5 engine executes the push).
    await _syncRepository.enqueue(
      tableName: 'lecture_records',
      recordId: id,
      operation: 'INSERT',
    );

    return id;
  }

  /// Batch-creates Absent records for every timetable slot on a given
  /// day (spec §6 "mark entire day absent"). Skips slots that already
  /// have a record.
  ///
  /// Returns the list of created record UUIDs.
  Future<List<String>> markEntireDayAbsent({
    required String userId,
    required List<MarkAbsentSlot> slots,
    required String deviceTimezone,
    required String appVersion,
  }) async {
    final created = <String>[];

    for (final slot in slots) {
      final existing = await _dao.getByTimetableId(userId, slot.timetableId);
      if (existing != null) continue;

      final id = await create(
        userId: userId,
        timetableId: slot.timetableId,
        subjectId: slot.subjectId,
        semesterId: slot.semesterId,
        status: const LectureStatus.absent(),
        deviceTimezone: deviceTimezone,
        appVersion: appVersion,
      );
      created.add(id);
    }
    return created;
  }

  // ── Reads (delegate to DAO) ─────────────────────────────────────────

  Stream<List<LectureRecordEntity>> watchAll(String userId) =>
      _dao.watchAll(userId);

  Stream<LectureRecordEntity?> watchById(String userId, String id) =>
      _dao.watchById(userId, id);

  Future<LectureRecordEntity?> getById(String userId, String id) =>
      _dao.getById(userId, id);

  Future<LectureRecordEntity?> getByTimetableId(
    String userId,
    String timetableId,
  ) => _dao.getByTimetableId(userId, timetableId);

  Stream<List<LectureRecordEntity>> watchBySubject(
    String userId,
    String subjectId,
  ) => _dao.watchBySubject(userId, subjectId);

  Stream<List<LectureRecordEntity>> watchBySemester(
    String userId,
    String semesterId,
  ) => _dao.watchBySemester(userId, semesterId);

  Future<List<LectureRecordEntity>> getByStatusPrefix(
    String userId,
    String subjectId,
    String statusPrefix,
  ) => _dao.getByStatusPrefix(userId, subjectId, statusPrefix);

  Future<List<LectureRecordEntity>> getAll(String userId) =>
      _dao.getAll(userId);
}

/// Thrown when attempting to create a duplicate lecture record for a
/// timetable slot that already has one.
class LectureRecordExistsException implements Exception {
  LectureRecordExistsException(this.timetableId);
  final String timetableId;

  @override
  String toString() =>
      'LectureRecordExistsException: timetable slot $timetableId already has a record.';
}

/// A timetable slot to mark absent in a batch operation (spec §6).
class MarkAbsentSlot {
  MarkAbsentSlot({
    required this.timetableId,
    required this.subjectId,
    required this.semesterId,
  });

  final String timetableId;
  final String subjectId;
  final String semesterId;
}
