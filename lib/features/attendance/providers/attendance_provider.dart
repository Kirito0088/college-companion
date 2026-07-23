/// Attendance Providers
///
/// Riverpod providers for attendance-related dependencies.
library;

import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [AttendanceRepository] instance.
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return AttendanceRepository(database, syncQueueRepository);
});
