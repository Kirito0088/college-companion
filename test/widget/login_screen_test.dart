import 'package:college_companion/core/constants/app_constants.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/authentication/screens/login_screen.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders app identity and Google Sign-In button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.theme(Brightness.dark, Accent.jade),
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text(AppConstants.appDescription), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });
  });
}
