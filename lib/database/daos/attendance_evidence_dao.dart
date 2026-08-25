/// Attendance Evidence DAO
///
/// Owns queries and sync queue operations for the local evidence table (`lecture_evidence`).
/// Exposes reactive streams, insertion, and deletion with sync queue registration.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/sync_queue_dao.dart';
import 'package:college_companion/database/tables/lecture_evidence.dart';
import 'package:drift/drift.dart';

typedef AttendanceEvidenceCompanion = LectureEvidenceCompanion;
typedef AttendanceEvidenceEntity = LectureEvidenceEntity;
typedef AttendanceEvidence = LectureEvidence;

/// DAO for managing attendance & lecture evidence.
class AttendanceEvidenceDao {
  AttendanceEvidenceDao(this._database, [this._syncQueueDao]);

  final AppDatabase _database;
  final SyncQueueDao? _syncQueueDao;

  /// Watches all evidence attached to a record, ordered chronologically.
  Stream<List<LectureEvidenceEntity>> watchEvidenceForRecord(String recordId) {
    return (_database.select(_database.lectureEvidence)
          ..where((t) => t.lectureRecordId.equals(recordId))
          ..orderBy([(t) => OrderingTerm.desc(t.captureTimestamp)]))
        .watch();
  }

  /// Gets a single evidence entity by record ID.
  Future<LectureEvidenceEntity?> getByRecordId(String recordId) {
    return (_database.select(
      _database.lectureEvidence,
    )..where((t) => t.lectureRecordId.equals(recordId))).getSingleOrNull();
  }

  /// Gets an evidence entity by its primary key UUID.
  Future<LectureEvidenceEntity?> getById(String id) {
    return (_database.select(
      _database.lectureEvidence,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a new evidence row and returns the created evidence ID.
  Future<String> insertEvidence(LectureEvidenceCompanion evidence) async {
    final result = await _database
        .into(_database.lectureEvidence)
        .insertReturning(evidence);

    // Register insertion with sync queue if sync queue DAO is available
    if (_syncQueueDao != null) {
      await _syncQueueDao.enqueue(
        tableName: 'lecture_evidence',
        recordId: result.id,
        operation: 'INSERT',
      );
    }

    return result.id;
  }

  /// Creates a new evidence row (alias for insertEvidence).
  Future<String> create(LectureEvidenceCompanion data) => insertEvidence(data);

  /// Deletes an evidence row by [evidenceId] and registers a DELETE mutation with the sync queue.
  Future<void> deleteEvidence(String evidenceId) async {
    await (_database.delete(
      _database.lectureEvidence,
    )..where((t) => t.id.equals(evidenceId))).go();

    if (_syncQueueDao != null) {
      await _syncQueueDao.enqueue(
        tableName: 'lecture_evidence',
        recordId: evidenceId,
        operation: 'DELETE',
      );
    }
  }

  /// Updates the integrity `state` of an evidence row (e.g. `original`, `missing`, `integrity_failed`).
  Future<void> updateState(String id, String newState) {
    return (_database.update(_database.lectureEvidence)
          ..where((t) => t.id.equals(id)))
        .write(LectureEvidenceCompanion(state: Value(newState)));
  }

  /// Updates the stored relative path and SHA-256 hash.
  Future<void> updatePath(
    String id, {
    required String localPathRelative,
    required String sha256,
  }) {
    return (_database.update(
      _database.lectureEvidence,
    )..where((t) => t.id.equals(id))).write(
      LectureEvidenceCompanion(
        localPathRelative: Value(localPathRelative),
        sha256: Value(sha256),
      ),
    );
  }
}
