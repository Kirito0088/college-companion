/// Environment Configuration
///
/// Loads and validates environment variables from the `.env` file.
/// All configuration values are read from the environment —
/// never hardcoded (per backend/security.md).
///
/// Never log sensitive values such as keys or URLs
/// (per backend/security.md).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads and provides access to environment configuration.
///
/// Must call [load] before accessing any values.
abstract final class EnvConfig {
  /// Loads the `.env` file from bundled assets.
  ///
  /// Throws [EnvConfigException] if the file cannot be loaded
  /// or required keys are missing.
  static Future<void> load() async {
    try {
      await dotenv.load();
    } on Exception catch (error) {
      throw EnvConfigException(
        'Failed to load environment configuration.',
        error,
      );
    }
    _validateRequiredKeys();
  }

  // ── App ────────────────────────────────────────────────────────────────

  /// The application display name.
  static String get appName => _optional('APP_NAME', 'College Companion');

  /// The current environment (e.g. `development`, `production`).
  static String get appEnv => _optional('APP_ENV', 'development');

  /// Whether the app is running in development mode.
  static bool get isDevelopment => appEnv == 'development';

  /// Whether the app is running in production mode.
  static bool get isProduction => appEnv == 'production';

  // ── Supabase ──────────────────────────────────────────────────────────

  /// The Supabase project URL.
  static String get supabaseUrl => _require('SUPABASE_URL');

  /// The Supabase publishable (anon) key.
  ///
  /// This is the public key — safe for client-side use.
  /// Never expose the Service Role Key (per backend/security.md).
  static String get supabasePublishableKey =>
      _require('SUPABASE_PUBLISHABLE_KEY');

  // ── Google OAuth ────────────────────────────────────────────────────────

  /// Google Web Client ID for native Google Sign-In.
  ///
  /// Required for Android Google Sign-In (per Supabase documentation).
  /// Created in Google Cloud Console as an "Web application" OAuth client.
  static String get googleWebClientId => _require('GOOGLE_WEB_CLIENT_ID');

  // ── Firebase ──────────────────────────────────────────────────────────

  /// Whether Firebase is enabled for Android.
  static bool get firebaseAndroidEnabled =>
      _optional('FIREBASE_ANDROID_ENABLED', 'true').toLowerCase() == 'true';

  // ── Logging ───────────────────────────────────────────────────────────

  /// The minimum log level (`debug`, `info`, `error`, `none`).
  ///
  /// Defaults to `debug` in debug mode, `none` in release mode.
  static String get logLevel =>
      _optional('LOG_LEVEL', kDebugMode ? 'debug' : 'none');

  /// Whether debug-level logging is enabled.
  static bool get isDebugLoggingEnabled => logLevel == 'debug';

  /// Whether info-level logging is enabled.
  static bool get isInfoLoggingEnabled =>
      logLevel == 'debug' || logLevel == 'info';

  /// Whether error-level logging is enabled.
  static bool get isErrorLoggingEnabled =>
      logLevel == 'debug' || logLevel == 'info' || logLevel == 'error';

  // ── Internals ──────────────────────────────────────────────────────────

  /// Keys that must be present for the app to function.
  static const List<String> _requiredKeys = [
    'SUPABASE_URL',
    'SUPABASE_PUBLISHABLE_KEY',
    'GOOGLE_WEB_CLIENT_ID',
  ];

  /// Returns the value for [key] or throws if missing/empty.
  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw EnvConfigException('Missing required environment key: $key');
    }
    return value;
  }

  /// Returns the value for [key] or [fallback] if missing.
  static String _optional(String key, String fallback) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) return fallback;
    return value;
  }

  /// Validates that all required keys are present in the environment.
  static void _validateRequiredKeys() {
    final missing = <String>[];
    for (final key in _requiredKeys) {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        missing.add(key);
      }
    }
    if (missing.isNotEmpty) {
      throw EnvConfigException(
        'Missing required environment keys: ${missing.join(', ')}. '
        'Check your .env file.',
      );
    }
  }
}

/// Exception thrown when environment configuration fails.
class EnvConfigException implements Exception {
  /// Creates an [EnvConfigException].
  const EnvConfigException(this.message, [this.cause]);

  /// A description of the configuration error.
  final String message;

  /// The underlying cause, if any.
  final Object? cause;

  @override
  String toString() {
    if (cause != null) return 'EnvConfigException: $message ($cause)';
    return 'EnvConfigException: $message';
  }
}
