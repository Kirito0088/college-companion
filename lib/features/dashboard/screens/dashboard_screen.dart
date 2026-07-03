/// Dashboard Screen
///
/// The main dashboard screen displayed after authentication.
/// Composes all dashboard section widgets into a scrollable layout.
library;

import 'package:college_companion/features/dashboard/widgets/next_lecture_card.dart';
import 'package:college_companion/features/dashboard/widgets/quick_stats_section.dart';
import 'package:college_companion/features/dashboard/widgets/today_overview_section.dart';
import 'package:college_companion/features/dashboard/widgets/welcome_section.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// The main dashboard screen for authenticated users.
///
/// This is the default home screen that displays:
/// - Personalized welcome greeting
/// - Next lecture
/// - Quick statistics
/// - Today's schedule
class DashboardScreen extends StatelessWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: LayoutTokens.screenPadding,
          vertical: SpacingTokens.base,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SpacingTokens.md),
            // Welcome section with user greeting
            WelcomeSection(),
            SizedBox(height: SpacingTokens.xl),

            // Next lecture card
            NextLectureCard(),
            SizedBox(height: SpacingTokens.xl),

            // Quick statistics grid
            QuickStatsSection(),
            SizedBox(height: SpacingTokens.xl),

            // Today's schedule
            TodayOverviewSection(),
            SizedBox(height: SpacingTokens.xl),
          ],
        ),
      ),
    );
  }
}
