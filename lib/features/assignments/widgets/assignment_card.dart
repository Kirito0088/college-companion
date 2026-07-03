import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.timeLeft,
    super.key,
  });

  final String title;
  final String subject;
  final String dueDate;
  final String timeLeft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ColorTokens.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Symbols.description,
              color: ColorTokens.primary,
              fill: 1.0,
            ),
          ),
          const SizedBox(width: SpacingTokens.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: ColorTokens.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: SpacingTokens.xl,
                    ), // Gives 24dp breathing room
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, // Increased horizontal padding
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        timeLeft,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  subject,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.xs),
                Row(
                  children: [
                    Icon(
                      Symbols.schedule,
                      color: ColorTokens.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      size: 16,
                    ),
                    const SizedBox(width: SpacingTokens.xs),
                    Text(
                      'Due: $dueDate',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ColorTokens.onSurfaceVariant.withValues(
                          alpha: 0.9,
                        ),
                        fontWeight: FontWeight.w400,
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
