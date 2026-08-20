import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, this.safeBunk});

  final SafeBunkResult? safeBunk;

  @override
  Widget build(BuildContext context) {
    final presentStr = safeBunk != null ? '${safeBunk!.attended}' : '148';
    final absentStr = safeBunk != null ? '${safeBunk!.total - safeBunk!.attended}' : '32';
    final totalStr = safeBunk != null ? '${safeBunk!.total}' : '180';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            value: presentStr,
            label: 'Present',
            valueColor: ColorTokens.success,
          ),
        ),
        const SizedBox(width: SpacingTokens.base),
        Expanded(
          child: _buildStatCard(
            context,
            value: absentStr,
            label: 'Absent',
            valueColor: ColorTokens.error,
          ),
        ),
        const SizedBox(width: SpacingTokens.base),
        Expanded(
          child: _buildStatCard(
            context,
            value: totalStr,
            label: 'Total',
            valueColor: ColorTokens.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
    required Color valueColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.base),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
