/// Checklist 9: Riverpod — providers initialize, repositories resolve, and
/// the dependency graph is valid.
///
/// The database provider is overridden with an in-memory instance so the
/// graph resolves without touching path_provider / platform channels.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/lecture_evidence_dao.dart';
import 'package:college_companion/database/daos/lecture_record_dao.dart';
import 'package:college_companion/database/daos/sync_metadata_dao.dart';
import 'package:college_companion/database/daos/sync_queue_dao.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/attendance/repositories/lecture_record_repository.dart';
import 'package:college_companion/features/attendance/repositories/sync_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/shared/models/lecture_status.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('9. every DAO provider resolves to the right type', () {
    expect(container.read(lectureRecordDaoProvider), isA<LectureRecordDao>());
    expect(container.read(lectureEvidenceDaoProvider), isA<LectureEvidenceDao>());
    expect(container.read(syncQueueDaoProvider), isA<SyncQueueDao>());
    expect(container.read(syncMetadataDaoProvider), isA<SyncMetadataDao>());
  });

  test('9. every repository provider resolves through its dependency graph', () {
    expect(container.read(syncRepositoryProvider), isA<SyncRepository>());
    expect(
      container.read(lectureRecordRepositoryProvider),
      isA<LectureRecordRepository>(),
    );
    expect(container.read(attendanceRepositoryProvider), isA<AttendanceRepository>());
  });

  test('9. resolved repository is functional end-to-end via the container', () async {
    final repo = container.read(lectureRecordRepositoryProvider);
    final id = await repo.create(
      userId: 'u',
      timetableId: 'tt',
      subjectId: 's',
      semesterId: 'sem',
      status: const LectureStatus.present(),
      deviceTimezone: 'Asia/Kolkata',
      appVersion: '1.0.0',
    );
    final attendance = container.read(attendanceRepositoryProvider);
    final stats = await attendance.getSubjectStats('u', 's');
    expect(id, isNotEmpty);
    expect(stats.attended, 1);
  });
}
