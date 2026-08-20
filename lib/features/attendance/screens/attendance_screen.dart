import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/attendance/widgets/attendance_header.dart';
import 'package:college_companion/features/attendance/widgets/attendance_trend_card.dart';
import 'package:college_companion/features/attendance/widgets/overall_gauge.dart';
import 'package:college_companion/features/attendance/widgets/segmented_control.dart';
import 'package:college_companion/features/attendance/widgets/stats_row.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  int _selectedIndex = 0;
  String _subjectSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final safeBunkAsync = ref.watch(safeBunkStreamProvider(userId));
    final safeBunk = safeBunkAsync.valueOrNull;
    
    final insightsAsync = ref.watch(attendanceInsightsProvider(userId));
    final insights = insightsAsync.valueOrNull;

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
                              ? _buildOverviewTab(context, safeBunk, insights)
                              : _buildSubjectsTab(context, userId),
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

  List<Widget> _buildOverviewTab(BuildContext context, SafeBunkResult? safeBunk, AttendanceInsights? insights) {
    return [
      OverallGauge(safeBunk: safeBunk),
      const SizedBox(height: LayoutTokens.sectionGap),
      StatsRow(safeBunk: safeBunk),
      const SizedBox(height: LayoutTokens.sectionGap),
      const AttendanceTrendCard(),
      const SizedBox(height: LayoutTokens.sectionGap),
      _buildHealthCard(context, safeBunk),
      const SizedBox(height: LayoutTokens.sectionGap),
      _buildInsightsCard(context, insights),
      const SizedBox(height: LayoutTokens.sectionGap),
      _buildRequirementCard(context, safeBunk),
      const SizedBox(height: LayoutTokens.sectionGap),
      _buildQuickActions(context),
    ];
  }

  List<Widget> _buildSubjectsTab(BuildContext context, String userId) {
    final subjectsAsync = ref.watch(subjectsStreamProvider(userId));
    final repo = ref.watch(attendanceRepositoryProvider);
    final recordsStream = repo.watchAll(userId);

    return [
      _buildSearchPlaceholder(context),
      const SizedBox(height: LayoutTokens.sectionGap),
      subjectsAsync.when(
        data: (subjects) {
          final filteredSubjects = subjects.where((s) {
            if (_subjectSearchQuery.isEmpty) return true;
            return s.name.toLowerCase().contains(_subjectSearchQuery.toLowerCase());
          }).toList();

          return StreamBuilder<List<AttendanceEntity>>(
            stream: recordsStream,
            builder: (context, snapshot) {
              final records = snapshot.data ?? [];

              if (filteredSubjects.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.xl),
                    child: Text(
                      _subjectSearchQuery.isEmpty 
                        ? 'No subjects added yet.' 
                        : 'No subjects found matching query.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              final cards = filteredSubjects.map((subject) {
                final subjRecords = records.where((r) => r.subjectId == subject.id).toList();
                final present = subjRecords.where((x) => x.primaryStatus == 'present').length;
                final total = subjRecords.length;
                final pct = total > 0 ? (present / total) : 0.0;
                final pctStr = '${(pct * 100).round()}%';

                return Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                  child: _buildSubjectCard(
                    context,
                    subject.id,
                    subject.name,
                    pctStr,
                    present,
                    total > 0 ? total : 0,
                    pct,
                    repo,
                    userId,
                  ),
                );
              }).toList();

              return Column(children: cards);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error loading subjects: $err',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ColorTokens.error,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildHealthCard(BuildContext context, SafeBunkResult? safeBunk) {
    final theme = Theme.of(context);
    final isSafe = safeBunk == null || safeBunk.currentPercentage >= safeBunk.targetPercentage;
    final title = isSafe ? 'Safe' : 'Action Required';
    final color = isSafe ? ColorTokens.success : ColorTokens.error;
    final message = safeBunk != null
        ? (isSafe
            ? 'You can miss approximately ${safeBunk.safeBunks} more lectures before reaching ${safeBunk.targetPercentage.round()}%.'
            : 'You must attend ${safeBunk.mustAttend} more lectures to reach ${safeBunk.targetPercentage.round()}%.')
        : 'Loading...';

    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSafe ? Symbols.check : Symbols.warning,
              color: isSafe ? ColorTokens.onSuccess : ColorTokens.onError,
              size: 24,
            ),
          ),
          const SizedBox(width: SpacingTokens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  message,
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

  Widget _buildInsightsCard(BuildContext context, AttendanceInsights? insights) {
    final theme = Theme.of(context);
    final avgPctStr = insights != null ? '${insights.averagePercentage.round()}%' : '--%';

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
                      insights != null ? '${insights.highestSubject} (${insights.highestPercentage.round()}%)' : '--',
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: _buildInsightStat(
                      context,
                      'Lowest Attendance',
                      insights != null ? '${insights.lowestSubject} (${insights.lowestPercentage.round()}%)' : '--',
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
                      insights != null ? '${insights.subjectsBelowTarget} Subject(s)' : '--',
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: _buildInsightStat(
                      context,
                      'Average Attendance',
                      avgPctStr,
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

  Widget _buildRequirementCard(BuildContext context, SafeBunkResult? safeBunk) {
    final theme = Theme.of(context);
    final targetStr = safeBunk != null ? '${safeBunk.targetPercentage.round()}%' : '--%';
    final currentStr = safeBunk != null ? '${safeBunk.currentPercentage.round()}%' : '--%';
    final statusStr = safeBunk != null
        ? (safeBunk.currentPercentage >= safeBunk.targetPercentage ? 'Eligible' : 'Ineligible')
        : '--';
    final statusColor = statusStr == 'Eligible' ? ColorTokens.success : (statusStr == '--' ? ColorTokens.onSurfaceVariant : ColorTokens.error);

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
                targetStr,
                ColorTokens.onSurface,
              ),
              _buildRequirementStat(
                context,
                'Current',
                currentStr,
                ColorTokens.onSurface,
              ),
              _buildRequirementStat(
                context,
                'Status',
                statusStr,
                statusColor,
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
        onTap: () {},
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
    return TextField(
      onChanged: (val) {
        setState(() {
          _subjectSearchQuery = val;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search subjects...',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: ColorTokens.onSurfaceVariant,
        ),
        prefixIcon: const Icon(Symbols.search, color: ColorTokens.onSurfaceVariant),
        filled: true,
        fillColor: ColorTokens.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusXl,
          borderSide: BorderSide(
            color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusXl,
          borderSide: BorderSide(
            color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusXl,
          borderSide: BorderSide(color: ColorTokens.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    String subjectId,
    String name,
    String percentage,
    int present,
    int total,
    double progress,
    AttendanceRepository repo,
    String userId,
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
        onTap: () => context.push(RoutePaths.subjectDetails),
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Symbols.check_circle, color: ColorTokens.success),
                        tooltip: 'Mark Present',
                        onPressed: () async {
                           await repo.create(
                             AttendanceCompanion.insert(
                               id: const Uuid().v4(),
                               userId: userId,
                               subjectId: subjectId,
                               date: DateTime.now().toUtc().toIso8601String().split('T').first,
                               primaryStatus: 'present',
                               lectureType: 'theory',
                               createdAt: DateTime.now().toUtc().toIso8601String(),
                               updatedAt: DateTime.now().toUtc().toIso8601String(),
                             )
                           );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Symbols.cancel, color: ColorTokens.error),
                        tooltip: 'Mark Absent',
                        onPressed: () async {
                           await repo.create(
                             AttendanceCompanion.insert(
                               id: const Uuid().v4(),
                               userId: userId,
                               subjectId: subjectId,
                               date: DateTime.now().toUtc().toIso8601String().split('T').first,
                               primaryStatus: 'absent',
                               lectureType: 'theory',
                               createdAt: DateTime.now().toUtc().toIso8601String(),
                               updatedAt: DateTime.now().toUtc().toIso8601String(),
                             )
                           );
                        },
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      const Icon(
                        Symbols.chevron_right,
                        color: ColorTokens.onSurfaceVariant,
                      ),
                    ],
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

