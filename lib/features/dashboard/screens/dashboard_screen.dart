/// Dashboard Screen
///
/// The main dashboard screen displayed after authentication.
/// Composes all dashboard section widgets into a scrollable layout.
library;

import 'package:college_companion/features/dashboard/widgets/next_lecture_card.dart';
import 'package:college_companion/features/dashboard/widgets/quick_stats_section.dart';
import 'package:college_companion/features/dashboard/widgets/today_overview_section.dart';
import 'package:college_companion/features/dashboard/widgets/welcome_section.dart';
import 'package:college_companion/shared/models/mock_ui_state.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// The main dashboard screen for authenticated users.
///
/// This is the default home screen that displays:
/// - Personalized welcome greeting
/// - Next lecture
/// - Quick statistics
/// - Today's schedule
class DashboardScreen extends StatefulWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  MockUiState _uiState = MockUiState.success;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: _buildBody());
  }

  Widget _buildBody() {
    switch (_uiState) {
      case MockUiState.loading:
        return const SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: LayoutTokens.screenPadding,
            vertical: SpacingTokens.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SpacingTokens.md),
              SkeletonCard(),
              SizedBox(height: SpacingTokens.xl),
              SkeletonCard(),
              SizedBox(height: SpacingTokens.xl),
              SkeletonCard(),
            ],
          ),
        );
      case MockUiState.empty:
      case MockUiState.error:
        return NetworkErrorWidget(
          onRetry: () {
            setState(() {
              _uiState = MockUiState.loading;
              Future.delayed(
                const Duration(seconds: 1),
                () => setState(() => _uiState = MockUiState.success),
              );
            });
          },
        );
      case MockUiState.success:
        return const SingleChildScrollView(
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
        );
    }
  }
}
