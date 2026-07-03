import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class SubjectAttendanceStats extends StatelessWidget {
  const SubjectAttendanceStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CCCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '85%',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: ColorTokens.onSurface,
                ),
              ),
              Text(
                'Target: 75%',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Progress bar
          Container(
            height: 8, // h-2
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorTokens.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4), // rounded-full
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981), // attendance-chart-fill
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                'Present',
                '34',
                SemanticColorTokens.present,
              ),
              _buildStatItem(
                context,
                'Absent',
                '6',
                SemanticColorTokens.absent,
              ),
              _buildStatItem(context, 'Total', '40', ColorTokens.onSurface),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
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
          style: theme.textTheme.labelLarge?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
