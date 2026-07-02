/// Dashboard Screen
///
/// The main dashboard screen displayed after authentication.
/// Composes all dashboard section widgets into a scrollable layout.
library;

import 'package:college_companion/features/dashboard/widgets/current_semester_card.dart';
import 'package:college_companion/features/dashboard/widgets/quick_actions_section.dart';
import 'package:college_companion/features/dashboard/widgets/quick_stats_section.dart';
import 'package:college_companion/features/dashboard/widgets/recent_activity_section.dart';
import 'package:college_companion/features/dashboard/widgets/today_overview_section.dart';
import 'package:college_companion/features/dashboard/widgets/welcome_section.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// The main dashboard screen for authenticated users.
///
/// This is the default home screen that displays:
/// - Personalized welcome greeting
/// - Current semester information
/// - Today's schedule overview
/// - Quick statistics
/// - Recent activity
/// - Quick action buttons
class DashboardScreen extends StatelessWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(SpacingTokens.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SpacingTokens.base),
            // Welcome section with user greeting
            WelcomeSection(),
            SizedBox(height: SpacingTokens.xl),

            // Current semester card
            CurrentSemesterCard(),
            SizedBox(height: SpacingTokens.xl),

            // Today's overview
            TodayOverviewSection(),
            SizedBox(height: SpacingTokens.xl),

            // Quick statistics grid
            QuickStatsSection(),
            SizedBox(height: SpacingTokens.xl),

            // Recent activity
            RecentActivitySection(),
            SizedBox(height: SpacingTokens.xl),

            // Quick action buttons
            QuickActionsSection(),
            SizedBox(height: SpacingTokens.xl),
          ],
        ),
      ),
    );
  }
}
