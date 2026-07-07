import 'package:college_companion/features/attendance/widgets/attendance_header.dart';
import 'package:college_companion/features/attendance/widgets/attendance_trend_card.dart';
import 'package:college_companion/features/attendance/widgets/overall_gauge.dart';
import 'package:college_companion/features/attendance/widgets/segmented_control.dart';
import 'package:college_companion/features/attendance/widgets/stats_row.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AttendanceHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: LayoutTokens.screenPadding,
                  right: LayoutTokens.screenPadding,
                  top: SpacingTokens.md,
                  bottom:
                      LayoutTokens.bottomNavigationHeight + SpacingTokens.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedControl(
                      selectedIndex: _selectedIndex,
                      onChanged: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: LayoutTokens.sectionGap),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position:
                                    Tween<Offset>(
                                      begin: const Offset(0.0, 0.05),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: child,
                              ),
                            );
                          },
                      child: KeyedSubtree(
                        key: ValueKey<int>(_selectedIndex),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _selectedIndex == 0
                              ? _buildOverviewTab(context)
                              : _buildSubjectsTab(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOverviewTab(BuildContext context) {
    return [
      const OverallGauge(),
      const SizedBox(height: LayoutTokens.sectionGap),
      const StatsRow(),
      const SizedBox(height: LayoutTokens.sectionGap),
      const AttendanceTrendCard(),
      const SizedBox(height: LayoutTokens.sectionGap),
      _buildHealthCard(context),
      const SizedBox(height: LayoutTokens.sectionGap),
      _buildInsightsCard(context),
      const SizedBox(height: LayoutTokens.sectionGap),
      _buildRequirementCard(context),
      const SizedBox(height: LayoutTokens.sectionGap),
      _buildQuickActions(context),
    ];
  }

  List<Widget> _buildSubjectsTab(BuildContext context) {
    return [
      _buildSearchPlaceholder(context),
      const SizedBox(height: LayoutTokens.sectionGap),
      _buildSubjectCard(context, 'Operating Systems', '84%', 42, 50, 0.84),
      const SizedBox(height: SpacingTokens.md),
      _buildSubjectCard(context, 'Database Management', '96%', 48, 50, 0.96),
      const SizedBox(height: SpacingTokens.md),
      _buildSubjectCard(context, 'Computer Networks', '71%', 35, 49, 0.71),
    ];
  }

  Widget _buildHealthCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: ColorTokens.success.withValues(alpha: 0.1),
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(
          color: ColorTokens.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: const BoxDecoration(
              color: ColorTokens.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Symbols.check,
              color: ColorTokens.onSuccess,
              size: 24,
            ),
          ),
          const SizedBox(width: SpacingTokens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safe',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  'You can miss approximately 8 more lectures before reaching 75%.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            'Attendance Insights',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
            border: Border.all(
              color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInsightStat(
                      context,
                      'Highest Attendance',
                      'DBMS (96%)',
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: _buildInsightStat(
                      context,
                      'Lowest Attendance',
                      'CN (71%)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.lg),
              Row(
                children: [
                  Expanded(
                    child: _buildInsightStat(
                      context,
                      'Subjects Below Target',
                      '1 Subject',
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: _buildInsightStat(
                      context,
                      'Average Attendance',
                      '82%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.xxs),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRequirementCard(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            'Attendance Requirement',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
            border: Border.all(
              color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRequirementStat(
                context,
                'Minimum Required',
                '75%',
                ColorTokens.onSurface,
              ),
              _buildRequirementStat(
                context,
                'Current',
                '82%',
                ColorTokens.onSurface,
              ),
              _buildRequirementStat(
                context,
                'Status',
                'Eligible',
                ColorTokens.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementStat(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildActionCard(context, 'Attendance History', Symbols.history),
        const SizedBox(height: SpacingTokens.md),
        _buildActionCard(context, 'Attendance Calculator', Symbols.calculate),
        const SizedBox(height: SpacingTokens.md),
        _buildActionCard(context, 'Attendance Settings', Symbols.settings),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Material(
      color: ColorTokens.surfaceContainer,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.borderRadiusLg,
        side: BorderSide(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {}, // TODO: Navigate
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: ColorTokens.primary, size: 24),
              const SizedBox(width: SpacingTokens.lg),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Symbols.chevron_right,
                color: ColorTokens.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Symbols.search, color: ColorTokens.onSurfaceVariant),
          const SizedBox(width: SpacingTokens.md),
          Text(
            'Search subjects...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    String name,
    String percentage,
    int present,
    int total,
    double progress,
  ) {
    final theme = Theme.of(context);

    Color progressColor;
    if (progress >= 0.75) {
      progressColor = ColorTokens.success;
    } else {
      progressColor = ColorTokens.error;
    }

    return Material(
      color: ColorTokens.surfaceContainer,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.borderRadiusXl,
        side: BorderSide(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {}, // TODO: Navigate to Subject Attendance screen
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorTokens.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    percentage,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: progressColor.withValues(alpha: 0.2),
                color: progressColor,
                minHeight: 6,
                borderRadius: BorderRadius.circular(100),
              ),
              const SizedBox(height: SpacingTokens.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$present / $total Lectures Attended',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                    ),
                  ),
                  const Icon(
                    Symbols.chevron_right,
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
