/// Dashboard Screen
///
/// The main dashboard screen displayed after authentication.
/// Composes all dashboard section widgets into a scrollable layout.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/features/dashboard/widgets/academic_snapshot_section.dart';
import 'package:college_companion/features/dashboard/widgets/next_lecture_card.dart';
import 'package:college_companion/features/dashboard/widgets/quick_actions_section.dart';
import 'package:college_companion/features/dashboard/widgets/today_overview_section.dart';
import 'package:college_companion/features/dashboard/widgets/upcoming_assignments_section.dart';
import 'package:college_companion/features/dashboard/widgets/welcome_section.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The main dashboard screen for authenticated users.
///
/// This is the default home screen that displays:
/// - Personalized welcome greeting
/// - Next action (Hero)
/// - Today's chronological flow
/// - Academic Snapshot
/// - Quick Actions
/// - Upcoming Assignments
class DashboardScreen extends ConsumerStatefulWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final snapshotAsync = ref.watch(dashboardSnapshotProvider(userId));

    return SafeArea(
      child: snapshotAsync.when(
        data: (_) {
          if (!_animController.isAnimating && _animController.value == 0) {
            _animController.forward();
          }
          return _buildSuccessContent();
        },
        loading: () => _buildLoadingState(),
        error: (err, stack) => NetworkErrorWidget(
          onRetry: () {
            ref.invalidate(dashboardSnapshotProvider(userId));
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
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
  }

  Widget _buildSuccessContent() {
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

          // Quick Actions
          FadeTransition(
            opacity: _snapshotOpacity, // Reusing snapshot animation timing
            child: SlideTransition(
              position: _snapshotSlide,
              child: QuickActionsSection(
                onTimetablePressed: () => context.push(RoutePaths.calendar),
                onAttendancePressed: () => context.push(RoutePaths.attendance),
                onAssignmentsPressed: () => context.push(RoutePaths.assignments),
                onFocusPressed: () => context.push(RoutePaths.focusMode),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xxl),
          
          // Upcoming Assignments
          FadeTransition(
            opacity: _snapshotOpacity, // Reusing snapshot animation timing
            child: SlideTransition(
              position: _snapshotSlide,
              child: const UpcomingAssignmentsSection(),
            ),
          ),
          const SizedBox(height: SpacingTokens.xxl),
        ],
      ),
    );
  }
}


