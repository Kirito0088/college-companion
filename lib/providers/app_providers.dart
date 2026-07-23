/// Global Riverpod Providers
///
/// Core application-level providers. Feature-specific providers
/// will live inside their respective feature directories.
library;

import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/settings/repositories/user_settings_repository.dart';
import 'package:college_companion/services/connectivity_service.dart';
import 'package:college_companion/services/supabase_service.dart';
import 'package:college_companion/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the application's local database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// Provides the connectivity monitoring service.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Provides the Supabase client instance.
///
/// [SupabaseService.initialize] must be called before this provider
/// is read (handled in main.dart).
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});

/// Provides the sync queue repository.
final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return SyncQueueRepository(database);
});

/// Provides the user settings repository.
final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return UserSettingsRepository(database, syncQueueRepository);
});

/// Provides the sync service background worker instance.
final syncServiceProvider = Provider<SyncService>((ref) {
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  final database = ref.watch(databaseProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final supabaseClient = ref.watch(supabaseClientProvider);

  final service = SyncService(
    syncQueueRepository: syncQueueRepository,
    database: database,
    supabaseClient: supabaseClient,
    connectivityService: connectivityService,
  );

  ref.onDispose(service.dispose);
  return service;
});
