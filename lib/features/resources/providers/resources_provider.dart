import 'package:college_companion/features/resources/repositories/resources_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resourcesRepositoryProvider = Provider<ResourcesRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return ResourcesRepository(database, syncQueueRepository);
});
