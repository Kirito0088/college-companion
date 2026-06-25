/// Supabase Service
///
/// Handles Supabase initialization and provides access to the client.
/// Credentials are read from environment configuration — never hardcoded
/// (per backend/security.md).
///
/// Never expose Service Role Keys (per backend/security.md).
library;

import 'package:college_companion/core/config/env_config.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service responsible for initializing and providing Supabase access.
abstract final class SupabaseService {
  static const String _tag = 'SupabaseService';

  /// Initializes the Supabase client using environment configuration.
  ///
  /// [EnvConfig.load] must be called before this method.
  /// Throws [SupabaseInitException] if initialization fails.
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        publishableKey: EnvConfig.supabasePublishableKey,
      );
      AppLogger.info('Supabase initialized', tag: _tag);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Supabase initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw SupabaseInitException(
        'Failed to initialize Supabase. Check your configuration.',
        error,
      );
    }
  }

  /// The Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;
}

/// Exception thrown when Supabase initialization fails.
class SupabaseInitException implements Exception {
  /// Creates a [SupabaseInitException].
  const SupabaseInitException(this.message, [this.cause]);

  /// A description of the initialization error.
  final String message;

  /// The underlying cause, if any.
  final Object? cause;

  @override
  String toString() {
    if (cause != null) return 'SupabaseInitException: $message ($cause)';
    return 'SupabaseInitException: $message';
  }
}
