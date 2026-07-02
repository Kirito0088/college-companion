/// Quick Stats Section Widget
///
/// Displays a grid of statistical summary cards.
/// Placeholder for future attendance, assignment, and grade integration.
library;

import 'package:college_companion/shared/widgets/section_header.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// A section displaying quick statistical summaries.
///
/// This widget is designed to be populated with actual data once
/// the attendance, assignments, and internal marks features are
/// implemented. The structure supports:
/// - Attendance percentage
/// - Pending assignments
/// - Average internal marks
/// - Total lectures attended
class QuickStatsSection extends StatelessWidget {
  /// Creates a [QuickStatsSection].
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Quick Stats'),
        SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.fact_check_rounded,
                title: 'Attendance',
                value: '--%',
                subtitle: 'Not available',
                color: ColorTokens.primary,
              ),
            ),
            SizedBox(width: SpacingTokens.md),
            Expanded(
              child: _StatCard(
                icon: Icons.assignment_rounded,
                title: 'Assignments',
                value: '--',
                subtitle: 'Pending tasks',
                color: ColorTokens.tertiary,
              ),
            ),
          ],
        ),
        SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.star_rounded,
                title: 'Average Marks',
                value: '--',
                subtitle: 'Internal assessment',
                color: ColorTokens.secondary,
              ),
            ),
            SizedBox(width: SpacingTokens.md),
            Expanded(
              child: _StatCard(
                icon: Icons.school_rounded,
                title: 'Lectures',
                value: '--',
                subtitle: 'Attended this term',
                color: ColorTokens.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A single statistics card widget.
class _StatCard extends StatelessWidget {
  /// Creates a [_StatCard].
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  /// The icon to display.
  final IconData icon;

  /// The card title.
  final String title;

  /// The main value to display.
  final String value;

  /// The subtitle text.
  final String subtitle;

  /// The accent color for this card.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.base),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                  vertical: SpacingTokens.xxs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: RadiusTokens.borderRadiusSm,
                ),
                child: Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
