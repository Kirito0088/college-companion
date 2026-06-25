/// Logger Utility
///
/// Debug logging utility. Debug logs should be disabled in production
/// (per backend/security.md).
library;

import 'package:flutter/foundation.dart';

/// Simple logging utility.
///
/// Only logs in debug mode. Never logs tokens, passwords,
/// or sensitive user data (per backend/security.md).
abstract final class AppLogger {
  /// Logs a debug message. Only prints in debug mode.
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[DEBUG]';
      debugPrint('$prefix $message');
    }
  }

  /// Logs an info message. Only prints in debug mode.
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[INFO]';
      debugPrint('$prefix $message');
    }
  }

  /// Logs an error message. Only prints in debug mode.
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  Stack: $stackTrace');
    }
  }
}
