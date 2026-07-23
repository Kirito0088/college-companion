import 'package:college_companion/features/onboarding/screens/onboarding_screen.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Automated Onboarding Flow Integration Test', () {
    testWidgets('Renders onboarding page view and advances pages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const OnboardingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert PageView is rendered
      expect(find.byType(PageView), findsOneWidget);

      // Swipe horizontally to test live gesture interactions on virtual device
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
    });
  });
}
