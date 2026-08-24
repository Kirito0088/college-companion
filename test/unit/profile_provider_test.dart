import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/authentication/repositories/user_repository.dart';
import 'package:college_companion/features/profile/providers/profile_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _testUser = AppUser(
  uid: 'user_1',
  displayName: 'Alex Smith',
  email: 'alex@college.edu',
  photoUrl: 'https://example.com/photo.jpg',
);

/// A fixed-state stand-in for [AuthStateNotifier] so tests can drive
/// [authStateProvider] without touching Supabase.
class _FakeAuthStateNotifier extends AuthStateNotifier {
  _FakeAuthStateNotifier(this._initialState);

  final AuthState _initialState;

  @override
  AuthState build() => _initialState;
}

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  ProviderContainer buildContainer(AuthState authState) {
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        authStateProvider.overrideWith(() => _FakeAuthStateNotifier(authState)),
        userRepositoryProvider.overrideWithValue(
          UserRepository(database, null, SyncQueueRepository(database)),
        ),
      ],
    );
  }

  test(
    'userProfileProvider shows the authenticated Google identity with empty '
    'academic fields for a brand-new user, never synthesized fake data',
    () async {
      container = buildContainer(const AuthAuthenticated(_testUser));
      final repository = container.read(userRepositoryProvider);
      await repository.upsertUser(_testUser);

      final profile = container.read(userProfileProvider);
      expect(profile.displayName, 'Alex Smith');
      expect(profile.email, 'alex@college.edu');
      expect(profile.photoUrl, 'https://example.com/photo.jpg');
      expect(profile.collegeName, isEmpty);
      expect(profile.branch, isEmpty);
      expect(profile.university, isEmpty);
    },
  );

  test(
    'userProfileProvider shows empty profile when signed out, not fallback strings',
    () {
      container = buildContainer(const AuthUnauthenticated());
      final profile = container.read(userProfileProvider);
      expect(profile.displayName, isEmpty);
      expect(profile.email, isEmpty);
      expect(profile.collegeName, isEmpty);
    },
  );

  test(
    'updateProfile persists academic fields to Drift and they are readable back',
    () async {
      container = buildContainer(const AuthAuthenticated(_testUser));
      final repository = container.read(userRepositoryProvider);
      await repository.upsertUser(_testUser);

      final notifier = container.read(userProfileProvider.notifier);
      await notifier.updateProfile(
        const UserProfileDetails(
          collegeName: 'ABC College of Engineering',
          branch: 'Computer Science',
          semester: '6',
          studentId: '12345678',
          university: 'Mumbai University',
          course: 'Bachelor of Engineering',
          department: 'Computer Science (AI & ML)',
          gradYear: '2028',
        ),
      );

      final saved = await repository.getById('user_1');
      expect(saved?.collegeName, 'ABC College of Engineering');
      expect(saved?.branch, 'Computer Science');
      expect(saved?.semester, '6');
    },
  );

  test(
    'legacy SharedPreferences profile values are migrated into Drift once',
    () async {
      SharedPreferences.setMockInitialValues({
        'profile_collegeName': 'Legacy College',
        'profile_branch': 'Legacy Branch',
        'profile_university': 'Legacy University',
      });
      container = buildContainer(const AuthAuthenticated(_testUser));
      final repository = container.read(userRepositoryProvider);
      await repository.upsertUser(_testUser);
      // Ensure the Drift row is visible before the provider's first build.
      await repository.watchUser('user_1').first;

      // Reading the provider subscribes to the entity stream; keep listening
      // so the notifier rebuilds once that stream delivers, which is what
      // kicks off the fire-and-forget legacy migration.
      final sub = container.listen(userProfileProvider, (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final saved = await repository.getById('user_1');
      expect(saved?.collegeName, 'Legacy College');
      expect(saved?.branch, 'Legacy Branch');
      expect(saved?.university, 'Legacy University');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('profile_collegeName'), isFalse);
    },
  );
}
