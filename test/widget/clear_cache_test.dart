/// Clear Cache clears cache, not the student's data (#41).
///
/// It used to delete every SharedPreferences key except one, which sent
/// the student back through onboarding, erased their Focus history, and
/// reset the "asked once" notification-permission guard, despite its own
/// promise that it "will not delete your account data".
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/features/settings/screens/settings_screen.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SignedIn extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(uid: 'u1', email: 'e@x.test', displayName: 'Test'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('keeps onboarding state, Focus history and the permission '
      'guard', (tester) async {
    const history = [
      '{"id":"1759222800000","subject":"DSA","durationMinutes":25,'
          '"completedAt":"2026-10-01T10:00:00.000"}',
    ];
    SharedPreferences.setMockInitialValues({
      'has_completed_onboarding': true,
      'focus_session_history': history,
      'focus_dnd_enabled': false,
      'notification_permission_requested': true,
    });
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_SignedIn.new),
          userSettingsStreamProvider.overrideWith(
            (ref, userId) => Stream<UserSettingsEntity?>.value(null),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.theme(Brightness.dark, Accent.jade),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Clear Cache'));
    await tester.tap(find.text('Clear Cache'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('has_completed_onboarding'), isTrue);
    expect(prefs.getStringList('focus_session_history'), history);
    expect(prefs.getBool('focus_dnd_enabled'), isFalse);
    expect(prefs.getBool('notification_permission_requested'), isTrue);
  });
}
