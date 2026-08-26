/// Issue #26 / #35 — the migrated widgets must repaint when the user changes
/// theme/accent at Settings -> Appearance.
///
/// The companion source-scan guard (`test/unit/theme_token_reactivity_test`)
/// proves the legacy `ColorTokens` statics are gone. These tests prove the
/// replacement actually tracks the accent, which a grep cannot show.
///
/// Every widget asserted here is mounted by `SubjectDetailsScreen`, so a
/// regression fails on a surface the user actually opens. The previous
/// revision pointed at two widgets that were unreachable from `lib/` and
/// rendered hardcoded attendance counts; both were removed in #35.
library;

import 'package:college_companion/features/attendance/services/bunk_calculator.dart';
import 'package:college_companion/features/subjects/providers/subject_detail_provider.dart';
import 'package:college_companion/features/subjects/widgets/subject_attendance_filter_bar.dart';
import 'package:college_companion/features/subjects/widgets/subject_metric_overview.dart';
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

  /// Colour the [FilterChip] labelled [data] resolved for its own label.
  ///
  /// Read off the widget rather than the painted paragraph: `RawChip` drives
  /// its label through an implicitly animated text style of its own, which a
  /// single pump would catch mid-flight even with theme animation disabled.
  Color? chipLabelColor(WidgetTester tester, String data) {
    return tester
        .widget<FilterChip>(find.widgetWithText(FilterChip, data))
        .labelStyle
        ?.color;
  }

  /// The filter bar as `SubjectDetailsScreen` mounts it, with `All` active.
  Widget filterBar() {
    return SubjectAttendanceFilterBar(
      selectedFilter: AttendanceFilter.all,
      onFilterSelected: (_) {},
      totalCount: 40,
      presentCount: 34,
      absentCount: 6,
      cancelledCount: 2,
    );
  }

  /// The metric overview as `SubjectDetailsScreen` mounts it, fed by the real
  /// calculator rather than hand-written percentages.
  Widget metricOverview() {
    return SubjectMetricOverview(
      bunkMetrics: BunkCalculator.calculate(attended: 34, total: 40),
      presentCount: 34,
      absentCount: 6,
      cancelledCount: 2,
    );
  }

  final jade = CCTokens.resolve(Brightness.dark, Accent.jade).pri;
  final azure = CCTokens.resolve(Brightness.dark, Accent.azure).pri;

  group('accent reactivity of migrated widgets (issue #26)', () {
    testWidgets(
      'SubjectAttendanceFilterBar paints the active chip in the selected accent',
      (tester) async {
        await tester.pumpWidget(host(Accent.jade, filterBar()));
        expect(chipLabelColor(tester, 'All (40)'), equals(jade));

        await tester.pumpWidget(host(Accent.azure, filterBar()));
        await tester.pump();
        expect(chipLabelColor(tester, 'All (40)'), equals(azure));
      },
    );

    testWidgets(
      'SubjectAttendanceFilterBar leaves inactive chips on the muted tone',
      (tester) async {
        await tester.pumpWidget(host(Accent.jade, filterBar()));
        final muted = CCTokens.resolve(Brightness.dark, Accent.jade).mut;

        expect(chipLabelColor(tester, 'Present (34)'), equals(muted));
        expect(chipLabelColor(tester, 'Present (34)'), isNot(equals(jade)));
      },
    );

    testWidgets('SubjectMetricOverview present-count follows the accent', (
      tester,
    ) async {
      await tester.pumpWidget(host(Accent.jade, metricOverview()));
      expect(textColor(tester, '34'), equals(jade));

      await tester.pumpWidget(host(Accent.azure, metricOverview()));
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
