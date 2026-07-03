import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class CurrentScoreCard extends StatelessWidget {
  const CurrentScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: ColorTokens.surfaceVariant),
        borderRadius: RadiusTokens.borderRadiusMd,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorTokens.primary.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Score',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '51',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: ColorTokens.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(
                          '/ 80',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ColorTokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '63.75%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: ColorTokens.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
