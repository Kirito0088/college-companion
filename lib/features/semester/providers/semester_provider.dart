/// Semester Providers
///
/// Riverpod providers for semester-related dependencies.
library;

import 'package:college_companion/features/semester/repositories/semesters_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [SemesterRepository] instance.
final semesterRepositoryProvider = Provider<SemesterRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return SemesterRepository(database, syncQueueRepository);
});
