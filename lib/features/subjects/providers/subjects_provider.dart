/// Subjects Providers
///
/// Riverpod providers for subject-related dependencies.
library;

import 'package:college_companion/features/subjects/repositories/subjects_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [SubjectRepository] instance.
final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return SubjectRepository(database);
});
