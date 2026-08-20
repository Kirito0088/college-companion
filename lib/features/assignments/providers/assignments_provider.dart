/// Assignments Providers
///
/// Riverpod providers for assignment-related dependencies.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [AssignmentRepository] instance.
final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return AssignmentRepository(database, syncQueueRepository);
});

/// Watches all non-deleted assignments for a user.
final assignmentsStreamProvider =
    StreamProvider.family<List<AssignmentEntity>, String>((ref, userId) {
      final repo = ref.watch(assignmentRepositoryProvider);
      return repo.watchAll(userId);
    });

/// Watches pending assignments for a user.
final pendingAssignmentsStreamProvider =
    StreamProvider.family<List<AssignmentEntity>, String>((ref, userId) {
      final repo = ref.watch(assignmentRepositoryProvider);
      return repo.watchPending(userId);
    });
