import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SubjectHeaderCard extends StatelessWidget {
  const SubjectHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: ColorTokens.surfaceVariant),
        borderRadius: RadiusTokens.borderRadiusMd,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: ColorTokens.surfaceVariant,
              borderRadius: RadiusTokens.borderRadiusSm,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Symbols.neurology,
              color: ColorTokens.primary,
              fill: 1.0,
              size: 24,
            ),
          ),
          const SizedBox(width: SpacingTokens.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artificial Intelligence',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ColorTokens.onSurface,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  'Prof. Sharma',
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
}
