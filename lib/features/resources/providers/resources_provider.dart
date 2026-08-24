/// Resources Providers
///
/// Riverpod providers for resource-related dependencies and reactive streams.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/resources/repositories/resources_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/services/resource_file_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [ResourcesRepository] instance.
final resourcesRepositoryProvider = Provider<ResourcesRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return ResourcesRepository(database, syncQueueRepository);
});

/// Provides the [ResourceFileService] used to stat and open local files.
final resourceFileServiceProvider = Provider<ResourceFileService>((ref) {
  return ResourceFileService();
});

/// Watches all non-deleted resources for a user.
final resourcesStreamProvider =
    StreamProvider.family<List<ResourceEntity>, String>((ref, userId) {
      final repo = ref.watch(resourcesRepositoryProvider);
      return repo.watchAll(userId);
    });
