/// Authentication Service
///
/// Encapsulates Supabase Google OAuth authentication using the native
/// google_sign_in package (per official Supabase Flutter documentation).
/// Never logs tokens, passwords, or authentication credentials
/// (per backend/security.md).
library;

import 'dart:async';

import 'package:college_companion/core/config/env_config.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service responsible for Supabase authentication.
class AuthService {
  /// Creates an [AuthService].
  AuthService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  static const String _tag = 'AuthService';

  final SupabaseClient _supabaseClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Web Client ID from Google Cloud Console (required for Android)
    serverClientId: EnvConfig.googleWebClientId,
  );

  /// Stream of Supabase authentication state changes.
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  /// Returns the currently signed-in [AppUser], or `null` if not signed in.
  AppUser? getCurrentUser() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;
    return _mapSupabaseUser(user);
  }

  /// Signs in with Google using native Google Sign-In and exchanges
  /// the ID token with Supabase.
  ///
  /// This is the officially recommended approach per Supabase Flutter docs:
  /// https://supabase.com/docs/guides/auth/social-login/auth-google
  Future<AppUser?> signInWithGoogle() async {
    AppLogger.info('Starting native Google Sign-In', tag: _tag);

    final existingUser = getCurrentUser();
    if (existingUser != null) return existingUser;

    try {
      // Step 1: Trigger native Google Sign-In
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        AppLogger.info('Google Sign-In cancelled by user', tag: _tag);
        return null;
      }

      // Step 2: Extract the authentication details
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('No ID token returned from Google Sign-In');
      }

      // Step 3: Exchange the ID token with Supabase
      await _supabaseClient.auth.signInWithIdToken(
        idToken: idToken,
        provider: OAuthProvider.google,
        accessToken: accessToken,
      );

      AppLogger.info('Native Google Sign-In successful', tag: _tag);

      // Step 4: Return the authenticated user
      final currentUser = getCurrentUser();
      return currentUser;
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Google Sign-In failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Signs out the current user from both Google and Supabase.
  Future<void> signOut() async {
    AppLogger.info('Signing out', tag: _tag);

    // Sign out from Supabase first
    await _supabaseClient.auth.signOut();

    // Then sign out from Google
    await _googleSignIn.signOut();

    AppLogger.info('Sign-out complete', tag: _tag);
  }

  /// Maps a Supabase [User] to an [AppUser].
  AppUser _mapSupabaseUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final displayName =
        _metadataString(metadata, 'full_name') ??
        _metadataString(metadata, 'name') ??
        user.email ??
        '';
    final photoUrl =
        _metadataString(metadata, 'avatar_url') ??
        _metadataString(metadata, 'picture');

    return AppUser(
      uid: user.id,
      displayName: displayName,
      email: user.email ?? '',
      photoUrl: photoUrl,
    );
  }

  String? _metadataString(Map<String, dynamic> metadata, String key) {
    final value = metadata[key];
    return value is String && value.isNotEmpty ? value : null;
  }
}
