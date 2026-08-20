/// Semester Providers
///
/// Riverpod providers for semester-related dependencies.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/semester/repositories/semesters_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [SemesterRepository] instance.
final semesterRepositoryProvider = Provider<SemesterRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return SemesterRepository(database, syncQueueRepository);
});

/// Watches all active semesters for a user.
final semestersStreamProvider =
    StreamProvider.family<List<SemesterEntity>, String>((ref, userId) {
  final repo = ref.watch(semesterRepositoryProvider);
  return repo.watchAll(userId);
});

/// Watches a single semester by ID.
final semesterByIdStreamProvider =
    StreamProvider.family<SemesterEntity?, ({String userId, String semesterId})>((ref, params) {
  final repo = ref.watch(semesterRepositoryProvider);
  return repo.watchById(params.userId, params.semesterId);
});

/// Watches the current active semester for a user.
final currentSemesterStreamProvider =
    StreamProvider.family<SemesterEntity?, String>((ref, userId) {
  final repo = ref.watch(semesterRepositoryProvider);
  return repo.watchCurrent(userId);
});
