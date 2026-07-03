import 'package:college_companion/features/attendance/widgets/at_risk_card.dart';
import 'package:college_companion/features/attendance/widgets/attendance_header.dart';
import 'package:college_companion/features/attendance/widgets/attendance_trend_card.dart';
import 'package:college_companion/features/attendance/widgets/overall_gauge.dart';
import 'package:college_companion/features/attendance/widgets/segmented_control.dart';
import 'package:college_companion/features/attendance/widgets/stats_row.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SafeArea(
        child: Column(
          children: [
            AttendanceHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: LayoutTokens.screenPadding,
                  right: LayoutTokens.screenPadding,
                  top: SpacingTokens.md,
                  bottom:
                      LayoutTokens.bottomNavigationHeight + SpacingTokens.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedControl(),
                    SizedBox(height: LayoutTokens.sectionGap),
                    OverallGauge(),
                    SizedBox(height: LayoutTokens.sectionGap),
                    StatsRow(),
                    SizedBox(height: LayoutTokens.sectionGap),
                    AttendanceTrendCard(),
                    SizedBox(height: SpacingTokens.sm),
                    AtRiskCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
