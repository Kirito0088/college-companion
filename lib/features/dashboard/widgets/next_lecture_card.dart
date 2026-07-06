/// Next Lecture Card
///
/// Displays the upcoming lecture for the authenticated user.
library;

import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A card highlighting the user's next lecture.
class NextLectureCard extends StatelessWidget {
  /// Creates a [NextLectureCard].
  const NextLectureCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: ColorTokens.surfaceContainerLow,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(
            color: ColorTokens.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: InkWell(
          onTap: () => context.push(RoutePaths.subjectDetails),
          borderRadius: RadiusTokens.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Next Lecture',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: ColorTokens.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        const Icon(
                          Symbols.arrow_forward_rounded,
                          size: 14,
                          color: ColorTokens.onSurfaceVariant,
                        ),
                      ],
                    ),
                    Text(
                      'Starts in 28m',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'Statistics ML',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.xs),
                Row(
                  children: [
                    const Icon(
                      Symbols.schedule,
                      size: 16,
                      color: ColorTokens.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '09:00 AM',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    const Icon(
                      Symbols.location_on,
                      size: 16,
                      color: ColorTokens.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Room 305',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
