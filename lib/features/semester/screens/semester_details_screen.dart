import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SemesterDetailsScreen extends StatelessWidget {
  const SemesterDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          color: ColorTokens.onSurface,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Semester 5',
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutTokens.screenPadding,
          vertical: SpacingTokens.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildOverviewCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSubjectsSection(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildWeeklySummary(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildImportantDates(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildResources(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSemesterTimeline(context),
            const SizedBox(height: SpacingTokens.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Semester',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ColorTokens.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                'July 2026 – November 2026',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.xs,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.primaryContainer.withValues(alpha: 0.5),
            borderRadius: RadiusTokens.borderRadiusSm,
          ),
          child: Text(
            'ACTIVE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: ColorTokens.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: const BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semester Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ColorTokens.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '68%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ColorTokens.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          LinearProgressIndicator(
            value: 0.68,
            backgroundColor: ColorTokens.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            color: ColorTokens.primary,
            minHeight: 10,
            borderRadius: BorderRadius.circular(100),
          ),
          const SizedBox(height: SpacingTokens.xl),
          Row(
            children: [
              Expanded(child: _buildOverviewStat(context, '7', 'Subjects')),
              Expanded(child: _buildOverviewStat(context, '24', 'Credits')),
              Expanded(child: _buildOverviewStat(context, '82%', 'Attendance')),
              Expanded(child: _buildOverviewStat(context, '68%', 'Complete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubjectsSection(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = [
      {
        'title': 'Operating Systems',
        'code': 'CS501',
        'attendance': '84%',
        'assignments': '2 Pending',
      },
      {
        'title': 'Database Management Systems',
        'code': 'CS502',
        'attendance': '90%',
        'assignments': 'Completed',
      },
      {
        'title': 'Computer Networks',
        'code': 'CS503',
        'attendance': '79%',
        'assignments': '1 Pending',
      },
      {
        'title': 'Artificial Intelligence',
        'code': 'CS504',
        'attendance': '88%',
        'assignments': 'Completed',
      },
      {
        'title': 'Software Engineering',
        'code': 'CS505',
        'attendance': '92%',
        'assignments': '1 Pending',
      },
      {
        'title': 'Web Technology',
        'code': 'CS506',
        'attendance': '76%',
        'assignments': '3 Pending',
      },
      {
        'title': 'Mini Project',
        'code': 'CS507',
        'attendance': '100%',
        'assignments': 'Completed',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            'Subjects',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...subjects.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.md),
            child: _buildSubjectCard(context, s),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, Map<String, String> data) {
    final theme = Theme.of(context);
    final bool isCompleted = data['assignments'] == 'Completed';

    return Material(
      color: ColorTokens.surfaceContainer,
      borderRadius: RadiusTokens.borderRadiusLg,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RoutePaths.subjectDetails),
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title']!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorTokens.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      data['code']!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ColorTokens.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Row(
                      children: [
                        _buildSubjectStat(
                          context,
                          'Attendance',
                          data['attendance']!,
                        ),
                        const SizedBox(width: SpacingTokens.xl),
                        _buildSubjectStat(
                          context,
                          'Assignments',
                          data['assignments']!,
                          valueColor: isCompleted
                              ? ColorTokens.primary
                              : ColorTokens.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
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

  Widget _buildSubjectStat(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? ColorTokens.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySummary(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: const BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: _buildWeeklyStat(
                  context,
                  '18',
                  'Classes',
                  Symbols.calendar_today,
                  ColorTokens.primary,
                ),
              ),
              Expanded(
                child: _buildWeeklyStat(
                  context,
                  '12',
                  'Completed',
                  Symbols.check_circle,
                  ColorTokens.tertiary,
                ),
              ),
              Expanded(
                child: _buildWeeklyStat(
                  context,
                  '6',
                  'Remaining',
                  Symbols.pending,
                  ColorTokens.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildImportantDates(BuildContext context) {
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
            'Important Dates',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildDateRow(
                context,
                'Mid Semester Exam',
                '15 Aug',
                Symbols.edit_document,
                true,
              ),
              _buildDateRow(
                context,
                'Practical Submission',
                '28 Aug',
                Symbols.assignment,
                true,
              ),
              _buildDateRow(
                context,
                'Viva Examination',
                '3 Sept',
                Symbols.record_voice_over,
                true,
              ),
              _buildDateRow(
                context,
                'End Semester Exam',
                '21 Oct',
                Symbols.school,
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    String title,
    String date,
    IconData icon,
    bool showBorder,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.cardPadding,
        vertical: LayoutTokens.cardPadding,
      ),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: const BoxDecoration(
              color: ColorTokens.surfaceContainerHigh,
              borderRadius: RadiusTokens.borderRadiusSm,
            ),
            child: Icon(icon, size: 20, color: ColorTokens.primary),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: ColorTokens.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            date,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResources(BuildContext context) {
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
            'Resources',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildResourceRow(
                context,
                'Academic Calendar',
                Symbols.calendar_month,
                true,
              ),
              _buildResourceRow(context, 'Timetable', Symbols.view_week, true),
              _buildResourceRow(context, 'Syllabus', Symbols.menu_book, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourceRow(
    BuildContext context,
    String title,
    IconData icon,
    bool showBorder,
  ) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: BoxDecoration(
            border: showBorder
                ? Border(
                    bottom: BorderSide(
                      color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: ColorTokens.onSurfaceVariant),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
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

  Widget _buildSemesterTimeline(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: const BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semester Started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
              Text(
                '45 days ago',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: SpacingTokens.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expected Completion',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
              Text(
                '62 days remaining',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
