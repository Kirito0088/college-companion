import 'package:college_companion/core/constants/app_constants.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/authentication/screens/login_screen.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class _FakeAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Automated Virtual Device Integration Test', () {
    testWidgets('App renders on virtual device and displays login UI', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app identity on live virtual device screen
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text(AppConstants.appDescription), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);

      // Interact with the button on live device
      final googleButton = find.text('Continue with Google');
      await tester.tap(googleButton);
      await tester.pumpAndSettle();
    });
  });
}
