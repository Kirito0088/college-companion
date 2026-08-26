/// Issue #26 — the migrated widgets must repaint when the user changes
/// theme/accent at Settings -> Appearance.
///
/// The companion source-scan guard (`test/unit/theme_token_reactivity_test`)
/// proves the legacy `ColorTokens` statics are gone. These tests prove the
/// replacement actually tracks the accent, which a grep cannot show.
library;

import 'package:college_companion/features/subjects/widgets/subject_attendance_stats.dart';
import 'package:college_companion/features/subjects/widgets/subject_tabs.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(Accent accent, Widget child) {
    return MaterialApp(
      theme: AppTheme.theme(Brightness.dark, accent),
      // MaterialApp lerps theme changes through an implicit AnimatedTheme,
      // so without this a single pump lands mid-interpolation and reads a
      // blend of the old and new accent.
      themeAnimationDuration: Duration.zero,
      home: Scaffold(body: child),
    );
  }

  /// Colour of the [Text] whose content is [data].
  Color? textColor(WidgetTester tester, String data) {
    return tester.widget<Text>(find.text(data)).style?.color;
  }

  final jade = CCTokens.resolve(Brightness.dark, Accent.jade).pri;
  final azure = CCTokens.resolve(Brightness.dark, Accent.azure).pri;

  group('accent reactivity of migrated widgets (issue #26)', () {
    testWidgets('SubjectTabs paints the active tab in the selected accent', (
      tester,
    ) async {
      await tester.pumpWidget(host(Accent.jade, const SubjectTabs()));
      expect(textColor(tester, 'Overview'), equals(jade));

      await tester.pumpWidget(host(Accent.azure, const SubjectTabs()));
      await tester.pump();
      expect(textColor(tester, 'Overview'), equals(azure));
    });

    testWidgets('SubjectTabs leaves inactive tabs on the muted tone', (
      tester,
    ) async {
      await tester.pumpWidget(host(Accent.jade, const SubjectTabs()));
      final muted = CCTokens.resolve(Brightness.dark, Accent.jade).mut;
      expect(textColor(tester, 'Lectures'), equals(muted));
      expect(textColor(tester, 'Lectures'), isNot(equals(jade)));
    });

    testWidgets('SubjectAttendanceStats present-count follows the accent', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(Accent.jade, const SubjectAttendanceStats()),
      );
      expect(textColor(tester, '34'), equals(jade));

      await tester.pumpWidget(
        host(Accent.azure, const SubjectAttendanceStats()),
      );
      await tester.pump();
      expect(textColor(tester, '34'), equals(azure));
    });

    testWidgets('CCDialogs.showSuccessDialog tints its icon with the accent', (
      tester,
    ) async {
      for (final (accent, expected) in [
        (Accent.jade, jade),
        (Accent.azure, azure),
      ]) {
        await tester.pumpWidget(
          host(
            accent,
            Builder(
              builder: (context) => TextButton(
                onPressed: () => CCDialogs.showSuccessDialog(
                  context,
                  title: 'Saved',
                  message: 'All good.',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
        expect(icon.color, equals(expected));

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }
    });
  });
}
