/// Logger Utility
///
/// Structured logging utility that respects the LOG_LEVEL
/// environment variable. Debug logs are disabled in production
/// (per backend/security.md).
///
/// Never log tokens, passwords, or sensitive user data
/// (per backend/security.md).
library;

import 'package:college_companion/core/config/env_config.dart';
import 'package:flutter/foundation.dart';

/// Structured logging utility.
///
/// Log output is controlled by the `LOG_LEVEL` environment variable.
/// Falls back to [kDebugMode] if environment is not yet loaded.
abstract final class AppLogger {
  /// Whether environment configuration has been loaded.
  ///
  /// Before [EnvConfig.load] completes, the logger falls back
  /// to [kDebugMode] for all log decisions.
  static bool _envLoaded = false;

  /// Marks the environment as loaded.
  ///
  /// Called from main.dart after [EnvConfig.load] succeeds.
  static void enableEnvBasedLogging() {
    _envLoaded = true;
  }

  /// Logs a debug message.
  static void debug(String message, {String? tag}) {
    final enabled = _envLoaded ? EnvConfig.isDebugLoggingEnabled : kDebugMode;
    if (enabled) {
      final prefix = tag != null ? '[$tag]' : '[DEBUG]';
      debugPrint('$prefix $message');
    }
  }

  /// Logs an info message.
  static void info(String message, {String? tag}) {
    final enabled = _envLoaded ? EnvConfig.isInfoLoggingEnabled : kDebugMode;
    if (enabled) {
      final prefix = tag != null ? '[$tag]' : '[INFO]';
      debugPrint('$prefix $message');
    }
  }

  /// Logs an error message.
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    final enabled = _envLoaded ? EnvConfig.isErrorLoggingEnabled : kDebugMode;
    if (enabled) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  Stack: $stackTrace');
    }
  }
}
