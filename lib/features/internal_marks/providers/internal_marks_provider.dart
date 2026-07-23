import 'package:college_companion/features/internal_marks/repositories/internal_marks_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final internalMarksRepositoryProvider = Provider<InternalMarksRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return InternalMarksRepository(database, syncQueueRepository);
});
