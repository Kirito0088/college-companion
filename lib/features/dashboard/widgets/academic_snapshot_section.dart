/// Academic Snapshot Section Widget
///
/// Displays a synthesized summary of macro-level academic status.
library;

import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A section displaying interpreted academic states to provide reassurance.
class AcademicSnapshotSection extends ConsumerWidget {
  /// Creates a [AcademicSnapshotSection].
  const AcademicSnapshotSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dashboardSnapshotProvider);
    final theme = Theme.of(context);
    final stats = snapshot.academicSnapshot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Academic Snapshot',
              style: theme.textTheme.titleLarge?.copyWith(
                color: ColorTokens.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: SpacingTokens.md,
            horizontal: SpacingTokens.sm,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.surfaceContainerLow,
            borderRadius: RadiusTokens.borderRadiusLg,
            border: Border.all(
              color: ColorTokens.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(
                context: context,
                icon: Symbols.fact_check_rounded,
                iconColor: ColorTokens.success,
                value: stats.attendanceState,
                label: 'Attendance',
                valueColor: ColorTokens.success,
              ),
              _buildStatCard(
                context: context,
                icon: Symbols.school_rounded,
                iconColor: ColorTokens.warning, // Indicating heavy workload
                value: stats.workloadState,
                label: 'Workload',
                valueColor: ColorTokens.warning,
              ),
              _buildStatCard(
                context: context,
                icon: Symbols.assignment_rounded,
                iconColor: ColorTokens.primary,
                value: stats.deadlinesState,
                label: 'Deadlines',
              ),
              _buildStatCard(
                context: context,
                icon: Symbols
                    .coffee_rounded, // Replaced timer with coffee for break
                iconColor: ColorTokens.primary,
                value: stats.nextBreakState,
                label: 'Next Break',
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24, fill: 1.0),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              // Reduced from titleLarge to fit text like '1 Due Tonight'
              fontWeight: FontWeight.w700,
              color: valueColor ?? ColorTokens.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.xxs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: ColorTokens.onSurfaceVariant,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
