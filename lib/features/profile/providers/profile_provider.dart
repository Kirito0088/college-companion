import 'dart:async';

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The active user's profile, combining Google-authenticated identity with
/// user-entered academic metadata stored in Drift SQLite.
///
/// Academic fields are empty strings — never a plausible-looking placeholder
/// — until the user fills them in on Account Information.
class UserProfileDetails {
  const UserProfileDetails({
    this.displayName = '',
    this.email = '',
    this.photoUrl,
    this.collegeName = '',
    this.branch = '',
    this.semester = '',
    this.studentId = '',
    this.university = '',
    this.course = '',
    this.department = '',
    this.gradYear = '',
    this.createdAt,
    this.updatedAt,
  });

  /// Builds a [UserProfileDetails] from the local Drift row (when it exists)
  /// and the current Google-authenticated identity.
  ///
  /// Name/email/photo prefer the live auth session, since that is always
  /// accurate; the Drift row is the fallback for the brief window between
  /// sign-in and the initial [entity] sync completing.
  factory UserProfileDetails.from({
    required UserEntity? entity,
    required AppUser? authUser,
  }) {
    return UserProfileDetails(
      displayName: authUser?.displayName ?? entity?.name ?? '',
      email: authUser?.email ?? entity?.email ?? '',
      photoUrl: authUser?.photoUrl ?? entity?.profilePhoto,
      collegeName: entity?.collegeName ?? '',
      branch: entity?.branch ?? '',
      semester: entity?.semester ?? '',
      studentId: entity?.studentId ?? '',
      university: entity?.university ?? '',
      course: entity?.course ?? '',
      department: entity?.department ?? '',
      gradYear: entity?.graduationYear ?? '',
      createdAt: entity?.createdAt,
      updatedAt: entity?.updatedAt,
    );
  }

  final String displayName;
  final String email;
  final String? photoUrl;
  final String collegeName;
  final String branch;
  final String semester;
  final String studentId;
  final String university;
  final String course;
  final String department;
  final String gradYear;

  /// ISO 8601 UTC timestamp the local Drift row was created, if known.
  final String? createdAt;

  /// ISO 8601 UTC timestamp the local Drift row was last saved/synced, if known.
  final String? updatedAt;

  UserProfileDetails copyWith({
    String? displayName,
    String? email,
    String? collegeName,
    String? branch,
    String? semester,
    String? studentId,
    String? university,
    String? course,
    String? department,
    String? gradYear,
  }) {
    return UserProfileDetails(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl,
      collegeName: collegeName ?? this.collegeName,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      studentId: studentId ?? this.studentId,
      university: university ?? this.university,
      course: course ?? this.course,
      department: department ?? this.department,
      gradYear: gradYear ?? this.gradYear,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// The active (signed-in) user's id, or null when unauthenticated.
final activeUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState is AuthAuthenticated ? authState.user.uid : null;
});

/// Watches the active user's Drift row. Emits `null` while signed out or
/// before the row has been created.
final activeUserEntityProvider = StreamProvider<UserEntity?>((ref) {
  final userId = ref.watch(activeUserIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchUser(userId);
});

/// Legacy SharedPreferences keys written by the old prefs-backed profile
/// provider. Migrated into Drift once, then cleared.
const _legacyProfileKeys = {
  'displayName': 'profile_displayName',
  'email': 'profile_email',
  'collegeName': 'profile_collegeName',
  'branch': 'profile_branch',
  'semester': 'profile_semester',
  'studentId': 'profile_studentId',
  'university': 'profile_university',
  'course': 'profile_course',
  'department': 'profile_department',
  'gradYear': 'profile_gradYear',
};

/// Exposes the active user's profile and the mutation to update it.
///
/// Sourced from Drift SQLite (`users` table) plus the live Supabase Auth
/// session — never hardcoded fallback data.
class UserProfileNotifier extends Notifier<UserProfileDetails> {
  static const String _tag = 'UserProfileNotifier';

  bool _legacyMigrationAttempted = false;

  @override
  UserProfileDetails build() {
    final authState = ref.watch(authStateProvider);
    final authUser = authState is AuthAuthenticated ? authState.user : null;
    final entityAsync = ref.watch(activeUserEntityProvider);
    final entity = entityAsync.valueOrNull;

    if (entity != null) {
      unawaited(_migrateLegacyPreferencesIfNeeded(entity));
    }

    return UserProfileDetails.from(entity: entity, authUser: authUser);
  }

  /// One-time migration of pre-Drift `SharedPreferences` values into the
  /// Drift `users` row, so data a user already entered isn't silently lost.
  ///
  /// Only runs when the Drift row's academic fields are still unset, and
  /// clears the legacy keys afterwards so it never re-runs.
  Future<void> _migrateLegacyPreferencesIfNeeded(UserEntity entity) async {
    if (_legacyMigrationAttempted) return;
    final alreadyMigrated =
        entity.collegeName != null ||
        entity.branch != null ||
        entity.semester != null ||
        entity.studentId != null ||
        entity.university != null ||
        entity.course != null ||
        entity.department != null ||
        entity.graduationYear != null;
    if (alreadyMigrated) {
      _legacyMigrationAttempted = true;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasLegacyData = _legacyProfileKeys.values.any(
      (key) => prefs.containsKey(key),
    );
    if (!hasLegacyData) {
      _legacyMigrationAttempted = true;
      return;
    }
    _legacyMigrationAttempted = true;

    try {
      final userId = ref.read(activeUserIdProvider);
      if (userId == null) return;
      final repository = ref.read(userRepositoryProvider);
      final now = DateTime.now().toUtc().toIso8601String();
      await repository.update(
        userId,
        UsersCompanion(
          collegeName: Value(
            prefs.getString(_legacyProfileKeys['collegeName']!),
          ),
          branch: Value(prefs.getString(_legacyProfileKeys['branch']!)),
          semester: Value(prefs.getString(_legacyProfileKeys['semester']!)),
          studentId: Value(prefs.getString(_legacyProfileKeys['studentId']!)),
          university: Value(prefs.getString(_legacyProfileKeys['university']!)),
          course: Value(prefs.getString(_legacyProfileKeys['course']!)),
          department: Value(prefs.getString(_legacyProfileKeys['department']!)),
          graduationYear: Value(
            prefs.getString(_legacyProfileKeys['gradYear']!),
          ),
          updatedAt: Value(now),
        ),
      );
      for (final key in _legacyProfileKeys.values) {
        await prefs.remove(key);
      }
      AppLogger.info(
        'Migrated legacy SharedPreferences profile into Drift',
        tag: _tag,
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Legacy profile migration failed (non-blocking)',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Persists academic profile edits to Drift SQLite and enqueues a sync.
  Future<void> updateProfile(UserProfileDetails details) async {
    final userId = ref.read(activeUserIdProvider);
    if (userId == null) return;

    final repository = ref.read(userRepositoryProvider);
    final now = DateTime.now().toUtc().toIso8601String();
    try {
      await repository.update(
        userId,
        UsersCompanion(
          name: Value(details.displayName),
          collegeName: Value(details.collegeName),
          branch: Value(details.branch),
          semester: Value(details.semester),
          studentId: Value(details.studentId),
          university: Value(details.university),
          course: Value(details.course),
          department: Value(details.department),
          graduationYear: Value(details.gradYear),
          updatedAt: Value(now),
        ),
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Failed to save account information',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileDetails>(
      UserProfileNotifier.new,
    );
