/// Core Domain Exceptions
///
/// Defines domain-specific exception types for error mapping
/// across repositories and data sources.
library;

/// Base exception for all application errors.
abstract class AppException implements Exception {
  /// Creates an [AppException] with the given [message] and optional [cause].
  const AppException(this.message, [this.cause]);

  /// Error message describing the failure.
  final String message;

  /// Underlying cause or original exception, if available.
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Exception thrown when a database or Drift operation fails.
class DatabaseException extends AppException {
  /// Creates a [DatabaseException].
  const DatabaseException(super.message, [super.cause]);
}

/// Exception thrown when a requested resource/entity is not found.
class NotFoundException extends AppException {
  /// Creates a [NotFoundException].
  const NotFoundException(super.message, [super.cause]);
}

/// Exception thrown when input data validation fails.
class ValidationException extends AppException {
  /// Creates a [ValidationException].
  const ValidationException(super.message, [super.cause]);
}

/// General exception thrown by repository operations on unhandled errors.
class RepositoryException extends AppException {
  /// Creates a [RepositoryException].
  const RepositoryException(super.message, [super.cause]);
}
