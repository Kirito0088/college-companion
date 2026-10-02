import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dev auth bypass', () {
    // Supabase is deliberately not initialised here: with the bypass on, the
    // notifier must not touch AuthService (which reads Supabase.instance).
    test('starts authenticated as the dev user without touching Supabase', () {
      final container = ProviderContainer(
        overrides: [devAuthBypassProvider.overrideWithValue(true)],
      );
      addTearDown(container.dispose);

      final state = container.read(authStateProvider);

      expect(state, isA<AuthAuthenticated>());
      expect(
        (state as AuthAuthenticated).user.uid,
        AuthStateNotifier.devUser.uid,
      );
      expect(state.user.uid, isNotEmpty);
    });

    test(
      'signOut keeps the dev session so a driver cannot get trapped',
      () async {
        final container = ProviderContainer(
          overrides: [devAuthBypassProvider.overrideWithValue(true)],
        );
        addTearDown(container.dispose);

        await container.read(authStateProvider.notifier).signOut();

        expect(container.read(authStateProvider), isA<AuthAuthenticated>());
      },
    );

    test('is off by default (no --dart-define)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(devAuthBypassProvider), isFalse);
    });
  });
}
