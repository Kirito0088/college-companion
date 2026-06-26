/// Authentication State
///
/// Sealed class representing the possible states of authentication.
/// Used by the auth provider to communicate state to the UI.
library;

import 'package:college_companion/features/authentication/models/app_user.dart';

/// The current authentication state.
sealed class AuthState {
  const AuthState();
}

/// Initial state before authentication status has been determined.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Authentication is in progress (sign-in or session restoration).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The user is authenticated.
class AuthAuthenticated extends AuthState {
  /// Creates an [AuthAuthenticated] state with the given [user].
  const AuthAuthenticated(this.user);

  /// The authenticated user.
  final AppUser user;
}

/// The user is not authenticated.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An authentication error occurred.
class AuthError extends AuthState {
  /// Creates an [AuthError] state with the given [message].
  const AuthError(this.message);

  /// A user-friendly error message.
  final String message;
}
