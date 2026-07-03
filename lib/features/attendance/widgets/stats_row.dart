import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            value: '148',
            label: 'Present',
            valueColor: ColorTokens.success,
          ),
        ),
        const SizedBox(width: SpacingTokens.base),
        Expanded(
          child: _buildStatCard(
            context,
            value: '32',
            label: 'Absent',
            valueColor: ColorTokens.error,
          ),
        ),
        const SizedBox(width: SpacingTokens.base),
        Expanded(
          child: _buildStatCard(
            context,
            value: '180',
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
          color: ColorTokens.outlineVariant.withValues(alpha: 0.1),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
