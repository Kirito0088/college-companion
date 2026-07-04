import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SubjectDetailsScreen extends StatelessWidget {
  const SubjectDetailsScreen({super.key});

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
            _buildQuickActions(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildUpcoming(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildResourcesPreview(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildFacultyCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSubjectInformation(context),
            const SizedBox(height: SpacingTokens.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operating Systems',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: ColorTokens.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                'CS501',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ColorTokens.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SpacingTokens.xxs),
              Text(
                'Semester 5',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: SpacingTokens.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.xs,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.primaryContainer.withValues(alpha: 0.5),
            borderRadius: RadiusTokens.borderRadiusSm,
          ),
          child: Text(
            'CORE SUBJECT',
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
    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: const BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(
                  context,
                  'Attendance',
                  '84%',
                  Symbols.fact_check,
                  ColorTokens.success,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: _buildOverviewStat(
                  context,
                  'Classes',
                  '42 / 50',
                  Symbols.school,
                  ColorTokens.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(
                  context,
                  'Assignments',
                  '2 Pending',
                  Symbols.assignment,
                  ColorTokens.warning,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: _buildOverviewStat(
                  context,
                  'Faculty',
                  'Dr. A. Sharma',
                  Symbols.person,
                  ColorTokens.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: RadiusTokens.borderRadiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Attendance',
                Symbols.fact_check,
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: _buildActionCard(
                context,
                'Assignments',
                Symbols.assignment,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Resources',
                Symbols.menu_book,
                onTap: () => context.push('/resources'),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: _buildActionCard(context, 'Faculty', Symbols.person),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: ColorTokens.surfaceContainer,
      borderRadius: RadiusTokens.borderRadiusLg,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () {}, // TODO: Navigate
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: SpacingTokens.lg,
            horizontal: SpacingTokens.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: ColorTokens.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: ColorTokens.primary, size: 20),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcoming(BuildContext context) {
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
            'Upcoming',
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
              _buildUpcomingRow(
                context,
                'Assignment 3',
                'Due Tomorrow',
                Symbols.assignment,
                ColorTokens.warning,
                true,
              ),
              _buildUpcomingRow(
                context,
                'Lab Practical',
                'Friday',
                Symbols.science,
                ColorTokens.primary,
                true,
              ),
              _buildUpcomingRow(
                context,
                'Internal Assessment',
                '15 Aug',
                Symbols.edit_document,
                ColorTokens.error,
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingRow(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool showBorder,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.cardPadding,
        vertical: SpacingTokens.lg,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: RadiusTokens.borderRadiusSm,
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: SpacingTokens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  subtitle,
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

  Widget _buildResourcesPreview(BuildContext context) {
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
            'Resources Preview',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: const BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          child: Column(
            children: [
              _buildResourceRow(
                context,
                'Lecture Notes',
                '5 PDFs',
                Symbols.description,
              ),
              const SizedBox(height: SpacingTokens.md),
              _buildResourceRow(
                context,
                'Lab Manual',
                '2 PDFs',
                Symbols.science,
              ),
              const SizedBox(height: SpacingTokens.md),
              _buildResourceRow(
                context,
                'Reference Books',
                '3 Books',
                Symbols.menu_book,
              ),
              const SizedBox(height: SpacingTokens.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {}, // TODO: Navigate
                  style: FilledButton.styleFrom(
                    backgroundColor: ColorTokens.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    foregroundColor: ColorTokens.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.md,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: RadiusTokens.borderRadiusLg,
                    ),
                  ),
                  child: const Text('View All Resources'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourceRow(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: ColorTokens.onSurfaceVariant),
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
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFacultyCard(BuildContext context) {
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
            'Faculty',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: const BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: ColorTokens.primaryContainer,
                child: Text(
                  'AS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ColorTokens.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // NOTE: Professor information is local to the user and
                    // should NOT be synced to the shared backend database.
                    // These fields must eventually be loaded from the local SQLite DB.
                    Text(
                      'Dr. A. Sharma',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorTokens.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Symbols.call,
                          size: 16,
                          color: ColorTokens.onSurfaceVariant,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(
                          '+91 98765 43210',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ColorTokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectInformation(BuildContext context) {
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
            'Subject Information',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: const BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          child: Column(
            children: [
              _buildInfoRow(context, 'Subject Code', 'CS501', Symbols.code),
              const SizedBox(height: SpacingTokens.md),
              _buildInfoRow(context, 'Credits', '4', Symbols.military_tech),
              const SizedBox(height: SpacingTokens.md),
              _buildInfoRow(context, 'Type', 'Core', Symbols.category),
              const SizedBox(height: SpacingTokens.md),
              _buildInfoRow(context, 'Semester', '5', Symbols.layers),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: ColorTokens.onSurfaceVariant),
        const SizedBox(width: SpacingTokens.lg),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
