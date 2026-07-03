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

    return InkWell(
      onTap: () {
        context.push(RoutePaths.subjectOverview);
      },
      borderRadius: RadiusTokens.borderRadiusMd,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorTokens.primaryContainer, ColorTokens.surface],
          ),
          border: Border.all(color: ColorTokens.primary.withValues(alpha: 0.2)),
          borderRadius: RadiusTokens.borderRadiusMd,
        ),
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Lecture',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: ColorTokens.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '09:00 AM • Starts in 28m',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Statistics ML',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: ColorTokens.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dr. Kumar • Room 305',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorTokens.surface.withValues(alpha: 0.5),
                border: Border.all(
                  color: ColorTokens.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Symbols.calendar_today_rounded,
                color: ColorTokens.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
