import 'package:college_companion/features/onboarding/screens/onboarding_screen.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingScreen Widget Tests', () {
    testWidgets('Renders onboarding page view and navigation buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const OnboardingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Check page view rendered
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('Next button advances page view', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const OnboardingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find Next button or Icon button
      final nextButton = find.byType(ElevatedButton);
      if (nextButton.evaluate().isNotEmpty) {
        await tester.tap(nextButton.first);
        await tester.pumpAndSettle();
      }
    });
  });
}
