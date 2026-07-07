/// Attendance Providers
///
/// Riverpod providers for attendance-related dependencies.
///
/// Phase 4: expanded with DAO providers for lecture_records,
/// lecture_evidence, sync_queue, sync_metadata, plus
/// LectureRecordRepository, SyncRepository, and the updated
/// AttendanceRepository read-model.
library;

import 'package:college_companion/database/daos/lecture_evidence_dao.dart';
import 'package:college_companion/database/daos/lecture_record_dao.dart';
import 'package:college_companion/database/daos/sync_metadata_dao.dart';
import 'package:college_companion/database/daos/sync_queue_dao.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/attendance/repositories/lecture_record_repository.dart';
import 'package:college_companion/features/attendance/repositories/sync_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── DAOs ────────────────────────────────────────────────────────────────

final lectureRecordDaoProvider = Provider<LectureRecordDao>((ref) {
  final database = ref.watch(databaseProvider);
  return LectureRecordDao(database);
});

final lectureEvidenceDaoProvider = Provider<LectureEvidenceDao>((ref) {
  final database = ref.watch(databaseProvider);
  return LectureEvidenceDao(database);
});

final syncQueueDaoProvider = Provider<SyncQueueDao>((ref) {
  final database = ref.watch(databaseProvider);
  return SyncQueueDao(database);
});

final syncMetadataDaoProvider = Provider<SyncMetadataDao>((ref) {
  final database = ref.watch(databaseProvider);
  return SyncMetadataDao(database);
});

// ── Repositories ────────────────────────────────────────────────────────

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final queueDao = ref.watch(syncQueueDaoProvider);
  final metadataDao = ref.watch(syncMetadataDaoProvider);
  return SyncRepository(queueDao, metadataDao);
});

final lectureRecordRepositoryProvider = Provider<LectureRecordRepository>((
  ref,
) {
  final database = ref.watch(databaseProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  return LectureRecordRepository(database, syncRepo);
});

/// Provides the [AttendanceRepository] read-model.
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final dao = ref.watch(lectureRecordDaoProvider);
  return AttendanceRepository(dao);
});
