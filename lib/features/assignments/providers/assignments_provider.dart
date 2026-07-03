/// Assignments Providers
///
/// Riverpod providers for assignment-related dependencies.
library;

import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [AssignmentRepository] instance.
final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return AssignmentRepository(database);
});
