/// Authentication Providers
///
/// Riverpod providers for authentication state management.
/// Feature-specific providers live inside the feature directory
/// (per references/Architecture.md).
library;

import 'dart:async';

import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/repositories/user_repository.dart';
import 'package:college_companion/features/authentication/services/auth_service.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [AuthService] instance.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provides the [UserRepository] instance.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final client = ref.watch(supabaseClientProvider);
  return UserRepository(database, client);
});

/// Manages authentication state across the application.
///
/// On initialization: checks Supabase Auth for an existing session.
/// Exposes [signIn] and [signOut] methods.
final authStateProvider = NotifierProvider<AuthStateNotifier, AuthState>(
  AuthStateNotifier.new,
);

/// Notifier that manages the [AuthState] lifecycle.
class AuthStateNotifier extends Notifier<AuthState> {
  static const String _tag = 'AuthStateNotifier';

  @override
  AuthState build() {
    // Check for an existing Supabase Auth session on initialization.
    unawaited(Future<void>.microtask(_restoreSession));
    return const AuthInitial();
  }

  /// Attempts to restore an existing Supabase Auth session.
  Future<void> _restoreSession() async {
    state = const AuthLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final existingUser = authService.getCurrentUser();

      if (existingUser != null) {
        AppLogger.info('Existing session restored', tag: _tag);
        state = AuthAuthenticated(existingUser);

        // Sync user profile to Supabase in the background.
        _syncUserProfile(existingUser);
      } else {
        AppLogger.info('No existing session found', tag: _tag);
        state = const AuthUnauthenticated();
      }
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Session restoration failed',
        error: error,
        stackTrace: stackTrace,
      );
      state = const AuthUnauthenticated();
    }
  }

  /// Signs in with Google.
  ///
  /// On success: syncs user profile to Supabase and transitions
  /// to [AuthAuthenticated].
  Future<void> signIn() async {
    state = const AuthLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();

      if (user == null) {
        // User cancelled the sign-in flow.
        state = const AuthUnauthenticated();
        return;
      }

      state = AuthAuthenticated(user);

      // Sync user profile to Supabase in the background.
      _syncUserProfile(user);
    } on Exception catch (error, stackTrace) {
      AppLogger.error('Sign-in failed', error: error, stackTrace: stackTrace);
      state = const AuthError('Couldn\'t sign in right now. Please try again.');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    state = const AuthLoading();

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      state = const AuthUnauthenticated();
    } on Exception catch (error, stackTrace) {
      AppLogger.error('Sign-out failed', error: error, stackTrace: stackTrace);
      // Even if sign-out fails, treat as unauthenticated
      // to avoid trapping the user.
      state = const AuthUnauthenticated();
    }
  }

  /// Syncs the user profile to Supabase in the background.
  ///
  /// Failure is non-blocking — the app is offline-first.
  Future<void> _syncUserProfile(AppUser user) async {
    try {
      final userRepository = ref.read(userRepositoryProvider);
      await userRepository.upsertUser(user);
    } on Exception catch (error) {
      // Non-blocking: the app is offline-first.
      // Sync will be retried on next app launch or state change.
      AppLogger.error(
        'User profile sync to Supabase failed (non-blocking)',
        error: error,
      );
    }
  }
}
