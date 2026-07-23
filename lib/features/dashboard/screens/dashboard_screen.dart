/// Dashboard Screen
///
/// The main dashboard screen displayed after authentication.
/// Composes all dashboard section widgets into a scrollable layout.
library;

import 'package:college_companion/features/dashboard/widgets/academic_snapshot_section.dart';
import 'package:college_companion/features/dashboard/widgets/next_lecture_card.dart';
import 'package:college_companion/features/dashboard/widgets/today_overview_section.dart';
import 'package:college_companion/features/dashboard/widgets/welcome_section.dart';
import 'package:college_companion/shared/models/mock_ui_state.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// The main dashboard screen for authenticated users.
///
/// This is the default home screen that displays:
/// - Personalized welcome greeting
/// - Next action (Hero)
/// - Today's chronological flow
/// - Academic Snapshot
class DashboardScreen extends StatefulWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  MockUiState _uiState = MockUiState.loading;
  late final AnimationController _animController;
  late final Animation<double> _heroOpacity;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _timelineOpacity;
  late final Animation<Offset> _timelineSlide;
  late final Animation<double> _snapshotOpacity;
  late final Animation<Offset> _snapshotSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Staggered animations:
    // Hero: 0.0 -> 0.4
    // Timeline: 0.3 -> 0.7
    // Snapshot: 0.6 -> 1.0

    _heroOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
          ),
        );

    _timelineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _timelineSlide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _snapshotOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _snapshotSlide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Simulate initial network fetch
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _uiState = MockUiState.success);
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorTokens.background,
        gradient: RadialGradient(
          center: const Alignment(0.0, -0.8),
          radius: 1.2,
          colors: [ColorTokens.primary.withValues(alpha: 0.06), Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
      child: SafeArea(child: _buildBody()),
    );
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
              SizedBox(height: SpacingTokens.xxl),
              SkeletonCard(),
              SizedBox(height: SpacingTokens.xxl),
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
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() => _uiState = MockUiState.success);
                  _animController.forward(from: 0.0);
                }
              });
            });
          },
        );
      case MockUiState.success:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutTokens.screenPadding,
            vertical: SpacingTokens.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: SpacingTokens.md),
              // Greeting is un-animated (static orienting anchor)
              const WelcomeSection(),
              const SizedBox(height: SpacingTokens.xxl),

              // Hero
              FadeTransition(
                opacity: _heroOpacity,
                child: SlideTransition(
                  position: _heroSlide,
                  child: const NextLectureCard(),
                ),
              ),
              const SizedBox(height: SpacingTokens.xxl),

              // Timeline
              FadeTransition(
                opacity: _timelineOpacity,
                child: SlideTransition(
                  position: _timelineSlide,
                  child: const TodayOverviewSection(),
                ),
              ),
              const SizedBox(height: SpacingTokens.xxl),

              // Academic Snapshot
              FadeTransition(
                opacity: _snapshotOpacity,
                child: SlideTransition(
                  position: _snapshotSlide,
                  child: const AcademicSnapshotSection(),
                ),
              ),
              const SizedBox(height: SpacingTokens.xxl),
            ],
          ),
        );
    }
  }
}
