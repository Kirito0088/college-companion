import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/theme/cc_tokens.dart';
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
              color: theme.colorScheme.onSurface,
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
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Target: 75%',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4), // rounded-full
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(
                  // Healthy attendance reads as the accent (ADR-011: success == pri),
                  // so the fill tracks the user's accent choice.
                  color: context.cc.pri,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(context, 'Present', '34', context.cc.pri),
              _buildStatItem(context, 'Absent', '6', context.cc.risk),
              _buildStatItem(
                context,
                'Total',
                '40',
                theme.colorScheme.onSurface,
              ),
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
            color: theme.colorScheme.onSurfaceVariant,
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
