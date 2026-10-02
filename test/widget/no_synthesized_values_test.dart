/// Widget tests for issue #38: values that were literals rather than data.
///
/// Each test renders the empty case and asserts the screen makes no claim
/// it has no data for — no "SEM 5" without a semester, no "On target" or
/// "Eligible" without a single recorded lecture, no sync time for an
/// account that has never synced.
library;

import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/screens/attendance_screen.dart';
import 'package:college_companion/features/attendance/widgets/attendance_header.dart';
import 'package:college_companion/features/attendance/widgets/overall_gauge.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/profile/widgets/profile_menu_list.dart';
import 'package:college_companion/features/semester/providers/semester_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
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

const _noRecords = SafeBunkResult(
  attended: 0,
  total: 0,
  targetPercentage: 75,
  currentPercentage: 0,
  safeBunks: 0,
  mustAttend: 0,
);

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.theme(Brightness.dark, Accent.jade),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AttendanceHeader semester chip', () {
    testWidgets('is absent when there is no current semester', (tester) async {
      await tester.pumpWidget(_host(const AttendanceHeader()));

      expect(find.textContaining('SEM'), findsNothing);
    });

    testWidgets('shows the current semester name', (tester) async {
      await tester.pumpWidget(
        _host(const AttendanceHeader(semesterName: 'Fall 2026')),
      );

      expect(find.text('Fall 2026'), findsOneWidget);
      expect(find.text('SEM 5'), findsNothing);
    });
  });

  group('OverallGauge with no recorded lectures', () {
    testWidgets('does not claim the student is on target', (tester) async {
      await tester.pumpWidget(_host(const OverallGauge(safeBunk: _noRecords)));

      expect(find.textContaining('On target'), findsNothing);
      expect(find.text('0%'), findsNothing);
      expect(find.text('No lectures recorded yet'), findsOneWidget);
    });

    testWidgets('still reports a real on-target result', (tester) async {
      const onTarget = SafeBunkResult(
        attended: 3,
        total: 4,
        targetPercentage: 75,
        currentPercentage: 75,
        safeBunks: 0,
        mustAttend: 0,
      );
      await tester.pumpWidget(_host(const OverallGauge(safeBunk: onTarget)));

      expect(find.text('75%'), findsOneWidget);
      expect(find.text('On target (75%)'), findsOneWidget);
    });
  });

  group('ProfileMenuList', () {
    testWidgets('does not invent a last-synced time', (tester) async {
      await tester.pumpWidget(_host(const ProfileMenuList()));

      expect(find.textContaining('Last synced'), findsNothing);
      expect(find.textContaining('9:30 AM'), findsNothing);
    });
  });

  group('AttendanceScreen Overview with no recorded lectures', () {
    testWidgets('claims neither eligibility nor a safe margin', (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_TestAuthStateNotifier.new),
            safeBunkStreamProvider.overrideWith(
              (ref, userId) => Stream.value(_noRecords),
            ),
            subjectsStreamProvider.overrideWith(
              (ref, userId) => Stream.value(const []),
            ),
            attendanceRecordsStreamProvider.overrideWith(
              (ref, userId) => Stream.value(const []),
            ),
            currentSemesterStreamProvider.overrideWith(
              (ref, userId) => Stream.value(null),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.theme(Brightness.dark, Accent.jade),
            home: const AttendanceScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Eligible'), findsNothing);
      expect(find.text('Safe'), findsNothing);
      expect(find.textContaining('You can miss approximately'), findsNothing);
      expect(find.textContaining('SEM'), findsNothing);
    });
  });
}
