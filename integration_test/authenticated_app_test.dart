import 'package:college_companion/app.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class _MockAuthenticatedNotifier extends AuthStateNotifier {
  @override
  AuthState build() {
    return const AuthAuthenticated(
      AppUser(
        uid: 'test-student-123',
        displayName: 'Alex TestStudent',
        email: 'alex.student@college.edu',
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Automated Authenticated App Integration Test', () {
    testWidgets('Bypasses login and navigates authenticated screens on virtual device', (
      WidgetTester tester,
    ) async {
      // Launch app with authenticated state override
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_MockAuthenticatedNotifier.new),
          ],
          child: const CollegeCompanionApp(),
        ),
      );

      // Wait for router navigation and animations to settle
      await tester.pumpAndSettle();

      // 1. Verify we bypassed login and landed on DashboardScreen
      expect(find.byType(DashboardScreen), findsOneWidget);

      // 2. Verify Bottom Navigation Bar is present
      expect(find.byType(NavigationBar), findsOneWidget);

      // 3. Test tapping Attendance navigation tab
      final attendanceTab = find.byIcon(Icons.calendar_today_rounded);
      if (attendanceTab.evaluate().isNotEmpty) {
        await tester.tap(attendanceTab.first);
        await tester.pumpAndSettle();
      }

      // 4. Test tapping Profile navigation tab
      final profileTab = find.byIcon(Icons.person_rounded);
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab.first);
        await tester.pumpAndSettle();
      }
    });
  });
}
