/// No location row when a block has no location (#42).
///
/// Lectures without a room and events without a description used to show
/// the placeholder "TBD"; they now carry an empty location, which must not
/// render as a lone pin icon.
library;

import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/features/dashboard/widgets/next_lecture_card.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

class _SignedIn extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(uid: 'u1', email: 'e@x.test', displayName: 'Test'),
  );
}

DashboardSnapshot _snapshot(String location) => DashboardSnapshot(
  greetingContext: '1 lecture today',
  nextAction: HeroAction(
    title: 'Compilers',
    timeString: '09:00 AM',
    location: location,
    urgencyString: 'Starts in 10m',
  ),
  timelineEvents: const [],
  academicSnapshot: DashboardSnapshot.empty().academicSnapshot,
  upcomingAssignments: const [],
);

Future<void> _pump(WidgetTester tester, String location) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(_SignedIn.new),
        dashboardSnapshotProvider.overrideWith(
          (ref, userId) => Future.value(_snapshot(location)),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.theme(Brightness.dark, Accent.jade),
        home: const Scaffold(body: NextLectureCard()),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('shows the room when there is one', (tester) async {
    await _pump(tester, 'Room 302');
    expect(find.text('Room 302'), findsOneWidget);
    expect(find.byIcon(Symbols.location_on), findsOneWidget);
  });

  testWidgets('shows no location row when there is none', (tester) async {
    await _pump(tester, '');
    expect(find.byIcon(Symbols.location_on), findsNothing);
  });
}
