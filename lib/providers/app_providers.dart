/// Global Riverpod Providers
///
/// Core application-level providers. Feature-specific providers
/// will live inside their respective feature directories.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/services/connectivity_service.dart';
import 'package:college_companion/services/supabase_service.dart';
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
