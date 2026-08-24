/// Widget tests covering the Slice 4 (Attendance) redesign's real-data
/// wiring fix for the Safe Bunk screen.
///
/// `SafeBunkRing` and `SafeBunkStats` previously hardcoded '82%'/'180'/'148'/
/// '8' instead of reading from [safeBunkStreamProvider]. These tests
/// override that provider with a fixed [SafeBunkResult] (same
/// fake-stream-for-reads approach as
/// `test/widget/profile_settings_redesign_test.dart`, which avoids a Drift
/// watch-stream dispose-timer issue when a live `watch()` query runs inside
/// a widget test) and assert the rendered values match it, not the old
/// hardcoded literals — and that two different results render differently.
library;

import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/screens/safe_bunk_screen.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _TestAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(
      uid: 'test_user_id',
      email: 'test@example.com',
      displayName: 'Test Student',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SafeBunkScreen real-data wiring', () {
    Future<void> pumpSafeBunkScreen(
      WidgetTester tester,
      SafeBunkResult result,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_TestAuthStateNotifier.new),
            safeBunkStreamProvider.overrideWith(
              (ref, userId) => Stream.value(result),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SafeBunkScreen(),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'renders the provider-derived percentage and counts, not the old hardcoded values',
      (tester) async {
        final result = SafeBunkCalculator.calculate(attended: 40, total: 50);

        await pumpSafeBunkScreen(tester, result);

        expect(find.text('${result.currentPercentage.round()}%'), findsWidgets);
        expect(find.text('${result.total}'), findsOneWidget);
        expect(find.text('${result.attended}'), findsOneWidget);
        expect(find.text('${result.safeBunks}'), findsWidgets);

        // The old hardcoded literals must be gone now that real data flows.
        expect(find.text('82%'), findsNothing);
        expect(find.text('180'), findsNothing);
        expect(find.text('148'), findsNothing);
      },
    );

    testWidgets(
      'reflects a different provider result with different rendered numbers',
      (tester) async {
        // A different result must produce different on-screen numbers than
        // the previous test — proof the widget reads live state, not a
        // second hardcoded constant.
        final result = SafeBunkCalculator.calculate(attended: 15, total: 30);

        await pumpSafeBunkScreen(tester, result);

        expect(find.text('${result.currentPercentage.round()}%'), findsWidgets);
        expect(find.text('${result.total}'), findsOneWidget);
        expect(find.text('${result.attended}'), findsOneWidget);
      },
    );
  });
}
