/// Lecture Record DAO
///
/// Owns **queries only** for the `lecture_records` table (Phase 4 §4).
/// Never imported by UI/feature code (enforced by `lib/database/daos/`
/// placement and code review).
///
/// Layer 2 of the three-layer immutability model: exposes a narrowly-scoped
/// internal `updateSyncState()` method reserved exclusively for the
/// synchronization engine, migrations, and repair tooling — it writes
/// **only** sync-bookkeeping columns (`syncStatus`, `syncVersion`,
/// `lastSyncedAt`, `updatedAt`). The DAO must never become a general
/// mutation API (no broad `update()`/`delete()`).
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Queries and narrowly-scoped sync operations for `lecture_records`.
class LectureRecordDao {
  LectureRecordDao(this._database);

  final AppDatabase _database;

  // ── Read queries ────────────────────────────────────────────────────

  /// Watches all lecture records for a user, most recent first.
  Stream<List<LectureRecordEntity>> watchAll(String userId) {
    return (_database.select(_database.lectureRecords)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
        .watch();
  }

  /// Watches a single record by ID.
  Stream<LectureRecordEntity?> watchById(String userId, String id) {
    return (_database.select(_database.lectureRecords)
          ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Gets a single record by ID (one-time fetch).
  Future<LectureRecordEntity?> getById(String userId, String id) {
    return (_database.select(_database.lectureRecords)
          ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets the record for a specific timetable slot, if any.
  Future<LectureRecordEntity?> getByTimetableId(
    String userId,
    String timetableId,
  ) {
    return (_database.select(_database.lectureRecords)..where(
          (t) => t.userId.equals(userId) & t.timetableId.equals(timetableId),
        ))
        .getSingleOrNull();
  }

  /// Watches records for a subject, most recent first.
  Stream<List<LectureRecordEntity>> watchBySubject(
    String userId,
    String subjectId,
  ) {
    return (_database.select(_database.lectureRecords)
          ..where(
            (t) => t.userId.equals(userId) & t.subjectId.equals(subjectId),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
        .watch();
  }

  /// Watches records for a semester, most recent first.
  Stream<List<LectureRecordEntity>> watchBySemester(
    String userId,
    String semesterId,
  ) {
    return (_database.select(_database.lectureRecords)
          ..where(
            (t) => t.userId.equals(userId) & t.semesterId.equals(semesterId),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
        .watch();
  }

  /// Gets all records for a user as a one-time fetch.
  Future<List<LectureRecordEntity>> getAll(String userId) {
    return (_database.select(_database.lectureRecords)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
        .get();
  }

  /// Gets all records matching a given status prefix (e.g. "present", "absent").
  /// The attendance read-model aggregates/filters from the result in Dart.
  Future<List<LectureRecordEntity>> getByStatusPrefix(
    String userId,
    String subjectId,
    String statusPrefix,
  ) {
    return (_database.select(_database.lectureRecords)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.subjectId.equals(subjectId) &
                t.statusText.like('$statusPrefix|%'),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
        .get();
  }

  // ── Internal sync method (narrowly scoped — Layer 2) ────────────────

  /// Updates **only** sync-bookkeeping columns on an existing record.
  ///
  /// Reserved for the sync engine, migrations, and repair tooling.
  /// Never called by feature/UI code.
  ///
  /// Writes only: `syncStatus`, `syncVersion`, `lastSyncedAt`, `updatedAt`.
  Future<void> updateSyncState(
    String id, {
    required String syncStatus,
    int? syncVersion,
    DateTime? lastSyncedAt,
  }) {
    return (_database.update(
      _database.lectureRecords,
    )..where((t) => t.id.equals(id))).write(
      LectureRecordsCompanion(
        syncStatus: Value(syncStatus),
        syncVersion: syncVersion != null
            ? Value(syncVersion)
            : const Value.absent(),
        lastSyncedAt: lastSyncedAt != null
            ? Value(lastSyncedAt)
            : const Value.absent(),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}
