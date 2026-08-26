import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SubjectIdentityCard extends StatelessWidget {
  const SubjectIdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CCCard(
      child: Row(
        children: [
          Container(
            width: 56, // w-14
            height: 56, // h-14
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: RadiusTokens.borderRadiusSm, // rounded-lg
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Icon(
              Symbols.psychology,
              color: theme.colorScheme.primary,
              size: 30, // text-3xl
              fill: 1, // icon-fill
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artificial Intelligence',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Prof. Sharma',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Row(
                  children: [
                    Text(
                      'Theory',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Text(
                      '4 Credits',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
