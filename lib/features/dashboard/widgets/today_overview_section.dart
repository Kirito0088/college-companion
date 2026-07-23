/// Today Schedule Section Widget
///
/// Displays a chronological flow of today's events from the DashboardSnapshot.
library;

import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A section displaying today's chronological flow.
class TodayOverviewSection extends ConsumerWidget {
  /// Creates a [TodayOverviewSection].
  const TodayOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dashboardSnapshotProvider);
    final theme = Theme.of(context);
    final events = snapshot.timelineEvents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Flow",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Icon(
              Symbols.tune_rounded,
              color: ColorTokens.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        ...events.map(
          (event) => Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
            child: _buildClassItem(
              context,
              timeText: event.timeString,
              meridiem: event.meridiem,
              className: event.title,
              room: event.location,
              isNow: event.isNow,
              isPast: event.isPast,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassItem(
    BuildContext context, {
    required String timeText,
    required String meridiem,
    required String className,
    required String room,
    required bool isNow,
    required bool isPast,
  }) {
    final theme = Theme.of(context);
    // Visual fading for past events (Cognitive Relief)
    final opacity = isPast ? 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 12),
                Text(
                  timeText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isNow
                        ? ColorTokens.onSurface
                        : ColorTokens.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  meridiem,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Container(
              decoration: isNow
                  ? BoxDecoration(
                      color: ColorTokens.surfaceContainer,
                      borderRadius: RadiusTokens.borderRadiusMd,
                      border: Border.all(
                        color: ColorTokens.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    )
                  : const BoxDecoration(
                      borderRadius: RadiusTokens.borderRadiusMd,
                    ),
              child: ClipRRect(
                borderRadius: RadiusTokens.borderRadiusMd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              className,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: ColorTokens.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              room,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: ColorTokens.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (isNow)
                            Text(
                              'NOW',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: ColorTokens.success,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                          const SizedBox(width: SpacingTokens.xs),
                          Icon(
                            Symbols.chevron_right_rounded,
                            color: isNow
                                ? ColorTokens.success
                                : ColorTokens.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
