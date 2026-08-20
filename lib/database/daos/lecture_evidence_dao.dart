/// Lecture Evidence DAO
///
/// Owns queries and operations for the local-only `lecture_evidence` table.
/// Exposes reactive streams, retrieval, insertion, deletion, and state updates.
library;

import 'package:college_companion/database/daos/attendance_evidence_dao.dart';

export 'package:college_companion/database/daos/attendance_evidence_dao.dart';

/// Queries for the local-only `lecture_evidence` table.
class LectureEvidenceDao extends AttendanceEvidenceDao {
  LectureEvidenceDao(super.database, [super.syncQueueDao]);
}
