/// Supabase Service
///
/// Handles Supabase initialization and provides access to the client.
/// Project URL and anon key must be configured before use.
///
/// Never expose Service Role Keys (per backend/security.md).
library;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase project configuration.
///
/// Replace these placeholders with your actual Supabase project credentials.
/// Do not commit real credentials to version control.
abstract final class SupabaseConfig {
  // TODO(supabase): Replace with your Supabase project URL.
  static const String projectUrl = 'YOUR_SUPABASE_PROJECT_URL';

  // TODO(supabase): Replace with your Supabase publishable key.
  // This is the public anon/publishable key — safe for client-side use.
  static const String publishableKey = 'YOUR_SUPABASE_PUBLISHABLE_KEY';
}

/// Service responsible for initializing and providing Supabase access.
abstract final class SupabaseService {
  /// Initializes the Supabase client.
  ///
  /// Must be called before [client] is accessed.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.projectUrl,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  /// The Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;
}
