/// Next Lecture Card
///
/// Displays the upcoming lecture for the authenticated user based on the DashboardSnapshot.
library;

import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A card highlighting the user's immediate next action.
class NextLectureCard extends ConsumerWidget {
  /// Creates a [NextLectureCard].
  const NextLectureCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dashboardSnapshotProvider);
    final theme = Theme.of(context);
    final nextAction = snapshot.nextAction;

    if (nextAction == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorTokens.surfaceContainerHigh.withValues(alpha: 0.6),
              ColorTokens.surfaceContainer,
            ],
          ),
          border: Border.all(
            color: ColorTokens.onSurface.withValues(alpha: 0.04),
            width: 1,
          ),
          borderRadius: RadiusTokens.borderRadiusLg,
        ),
        child: InkWell(
          onTap: () => context.push(RoutePaths.subjectDetails),
          borderRadius: RadiusTokens.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Next Action',
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
                      nextAction.urgencyString,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ColorTokens.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  nextAction.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
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
                      nextAction.timeString,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
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
                      nextAction.location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
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
