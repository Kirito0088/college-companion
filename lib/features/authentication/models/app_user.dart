/// App User Model
///
/// Represents the authenticated user's profile information.
/// Contains only the data documented in `backend/database.md` users table:
/// User ID, Name, Email, Profile Photo.
library;

/// Immutable representation of an authenticated user.
class AppUser {
  /// Creates an [AppUser].
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  /// The unique user identifier.
  final String uid;

  /// The user's display name from their Google account.
  final String displayName;

  /// The user's email address.
  final String email;

  /// The user's profile photo URL, if available.
  final String? photoUrl;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.uid == uid &&
        other.displayName == displayName &&
        other.email == email &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode => Object.hash(uid, displayName, email, photoUrl);

  @override
  String toString() => 'AppUser(uid: $uid, displayName: $displayName)';
}
