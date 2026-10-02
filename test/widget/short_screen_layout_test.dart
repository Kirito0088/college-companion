/// Height-axis layout checks on a short screen (#39).
///
/// #32's harness exercises device *widths*; the designated QA device
/// (emulator-5554) is 320×640 dp, and two failures only showed on its
/// height: onboarding copy drawn under the bottom controls, and the
/// Calendar FAB over the agenda.
library;

import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/calendar/screens/calendar_screen.dart';
import 'package:college_companion/features/onboarding/screens/onboarding_screen.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _TestAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(uid: 'u1', email: 'e@x.test', displayName: 'Test'),
  );
}

const _shortScreen = Size(320, 640);

void _useShortScreen(WidgetTester tester) {
  tester.view.physicalSize = _shortScreen;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('OnboardingScreen at 320×640', () {
    for (final scale in [1.0, 1.5]) {
      testWidgets('no page draws under the bottom controls '
          '(text scale $scale)', (tester) async {
        _useShortScreen(tester);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.theme(Brightness.light, Accent.jade),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const OnboardingScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final controls = find.byKey(OnboardingScreen.controlsKey);
        for (var page = 0; page < 5; page++) {
          expect(tester.takeException(), isNull, reason: 'page $page');
          expect(
            tester.getRect(find.byType(PageView)).bottom,
            lessThanOrEqualTo(tester.getRect(controls).top),
            reason: 'page $page content extends under the controls',
          );
          if (page < 4) {
            await tester.drag(find.byType(PageView), const Offset(-400, 0));
            await tester.pumpAndSettle();
          }
        }
      });
    }
  });

  group('CalendarScreen at 320×640', () {
    testWidgets('the agenda can be scrolled clear of the FAB', (tester) async {
      _useShortScreen(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_TestAuthStateNotifier.new),
            calendarEventsStreamProvider.overrideWith(
              (ref, userId) => Stream.value(const []),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.theme(Brightness.light, Accent.jade),
            home: const CalendarScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();

      final empty = tester.getRect(find.byType(EmptyCalendar));
      final fab = tester.getRect(find.byType(FloatingActionButton));
      expect(empty.overlaps(fab), isFalse);
    });
  });
}
