/// Authentication Service
///
/// Encapsulates Google Sign-In and Firebase Authentication logic.
/// Never logs tokens, passwords, or authentication credentials
/// (per backend/security.md).
library;

import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service responsible for Google Sign-In and Firebase Authentication.
///
/// Authentication is handled by Firebase. Supabase handles data storage.
/// This service does not interact with Supabase.
class AuthService {
  /// Creates an [AuthService].
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  static const String _tag = 'AuthService';

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Returns the currently signed-in [AppUser], or `null` if not signed in.
  AppUser? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  /// Signs in with Google and returns the authenticated [AppUser].
  ///
  /// Returns `null` if the user cancels the sign-in flow.
  /// Throws on network failures or Firebase exceptions.
  Future<AppUser?> signInWithGoogle() async {
    AppLogger.info('Starting Google Sign-In', tag: _tag);

    // Trigger the Google Sign-In flow.
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // User cancelled the sign-in flow.
      AppLogger.info('Google Sign-In cancelled by user', tag: _tag);
      return null;
    }

    // Obtain the auth details from the Google Sign-In.
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a Firebase credential.
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential.
    final UserCredential userCredential = await _firebaseAuth
        .signInWithCredential(credential);

    final User? user = userCredential.user;
    if (user == null) {
      AppLogger.error('[$_tag] Firebase sign-in returned null user');
      return null;
    }

    AppLogger.info('Google Sign-In successful', tag: _tag);
    return _mapFirebaseUser(user);
  }

  /// Signs out from both Firebase and Google.
  Future<void> signOut() async {
    AppLogger.info('Signing out', tag: _tag);

    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();

    AppLogger.info('Sign-out complete', tag: _tag);
  }

  /// Maps a Firebase [User] to an [AppUser].
  AppUser _mapFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }
}
