/// Subjects Providers
///
/// Riverpod providers for subject-related dependencies.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/subjects/repositories/subjects_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [SubjectRepository] instance.
final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return SubjectRepository(database, syncQueueRepository);
});

/// Watches all active subjects for a user.
final subjectsStreamProvider =
    StreamProvider.family<List<SubjectEntity>, String>((ref, userId) {
  final repo = ref.watch(subjectRepositoryProvider);
  return repo.watchAll(userId);
});

/// Watches subjects for a specific semester.
/// Parameter format: 'userId:semesterId'
final subjectsBySemesterStreamProvider =
    StreamProvider.family<List<SubjectEntity>, ({String userId, String semesterId})>((ref, params) {
  final repo = ref.watch(subjectRepositoryProvider);
  return repo.watchBySemester(params.userId, params.semesterId);
});
