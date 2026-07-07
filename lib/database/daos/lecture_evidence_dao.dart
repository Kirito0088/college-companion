/// Lecture Evidence DAO
///
/// Owns **queries only** for the local-only `lecture_evidence` table.
/// Never imported by UI/feature code.
///
/// Evidence is never synced (Phase 4 D7); this DAO has no sync methods.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Queries for the local-only `lecture_evidence` table.
class LectureEvidenceDao {
  LectureEvidenceDao(this._database);

  final AppDatabase _database;

  /// Gets the evidence row for a lecture record (1:1), if any.
  Future<LectureEvidenceEntity?> getByRecordId(String lectureRecordId) {
    return (_database.select(_database.lectureEvidence)
          ..where((t) => t.lectureRecordId.equals(lectureRecordId)))
        .getSingleOrNull();
  }

  /// Gets an evidence row by its own UUID.
  Future<LectureEvidenceEntity?> getById(String id) {
    return (_database.select(
      _database.lectureEvidence,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Creates a new evidence row. Returns the new row's UUID.
  Future<String> create(LectureEvidenceCompanion data) async {
    final result = await _database
        .into(_database.lectureEvidence)
        .insertReturning(data);
    return result.id;
  }

  /// Updates the integrity `state` of an evidence row (e.g. when
  /// re-verification finds the file missing or hash mismatched).
  Future<void> updateState(String id, String newState) {
    return (_database.update(_database.lectureEvidence)
          ..where((t) => t.id.equals(id)))
        .write(LectureEvidenceCompanion(state: Value(newState)));
  }

  /// Updates the stored relative path and SHA-256 (e.g. after a file move
  /// or re-hash).
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
