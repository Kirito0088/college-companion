/// Quick Stats Section Widget
///
/// Displays a row of statistical summaries.
library;

import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A section displaying quick statistical summaries in a row of 4 cards.
class QuickStatsSection extends StatelessWidget {
  /// Creates a [QuickStatsSection].
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today at a glance',
              style: theme.textTheme.titleMedium?.copyWith(
                color: ColorTokens.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'View All',
              style: theme.textTheme.labelLarge?.copyWith(
                color: ColorTokens.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatCard(
                context: context,
                icon: Symbols.school_rounded,
                iconColor: ColorTokens.primary,
                value: '3',
                label: 'Lectures',
              ),
              const SizedBox(width: SpacingTokens.xs),
              _buildStatCard(
                context: context,
                icon: Symbols.assignment_rounded,
                iconColor: ColorTokens.warning,
                value: '1',
                label: 'Assignment\nDue',
              ),
              const SizedBox(width: SpacingTokens.xs),
              _buildStatCard(
                context: context,
                icon: Symbols.fact_check_rounded,
                iconColor: ColorTokens.success,
                value: '82%',
                label: 'Attendance\n(Target: 75%)',
                valueColor: ColorTokens.success,
              ),
              const SizedBox(width: SpacingTokens.xs),
              _buildStatCard(
                context: context,
                icon: Symbols.timer_rounded,
                iconColor: ColorTokens.primary,
                value: '8',
                label: 'Hours\nFocus Goal',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.sm,
          horizontal: SpacingTokens.xxs,
        ),
        decoration: BoxDecoration(
          color: ColorTokens.surface,
          borderRadius: RadiusTokens.borderRadiusMd,
          border: Border.all(color: ColorTokens.surfaceVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24, fill: 1.0),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? ColorTokens.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: ColorTokens.onSurfaceVariant,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}
