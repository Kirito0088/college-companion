/// Today Schedule Section Widget
///
/// Displays a summary of today's schedule and activities.
library;

import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A section displaying today's overview.
class TodayOverviewSection extends StatelessWidget {
  /// Creates a [TodayOverviewSection].
  const TodayOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Schedule",
              style: theme.textTheme.titleMedium?.copyWith(
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
        _buildClassItem(
          context,
          timeText: '08:00',
          meridiem: 'AM',
          className: 'Statistics ML',
          room: 'Room 305',
          isNow: true,
        ),
        const SizedBox(height: SpacingTokens.sm),
        _buildClassItem(
          context,
          timeText: '10:00',
          meridiem: 'AM',
          className: 'Artificial Intelligence',
          room: 'Room 302',
          isNow: false,
        ),
        const SizedBox(height: SpacingTokens.sm),
        _buildClassItem(
          context,
          timeText: '12:00',
          meridiem: 'PM',
          className: 'DevOps',
          room: 'Lab 1',
          isNow: false,
        ),
        const SizedBox(height: SpacingTokens.md),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Text(
              '+1 more',
              style: theme.textTheme.labelLarge?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
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
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Container(
            decoration: isNow
                ? BoxDecoration(
                    color: ColorTokens.surface,
                    border: Border.all(color: ColorTokens.surfaceVariant),
                    borderRadius: RadiusTokens.borderRadiusMd,
                  )
                : const BoxDecoration(borderRadius: RadiusTokens.borderRadiusMd),
            child: ClipRRect(
              borderRadius: RadiusTokens.borderRadiusMd,
              child: Stack(
                children: [
                  if (isNow)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 4,
                      child: Container(color: ColorTokens.primary),
                    ),
                  Padding(
                    padding: isNow
                        ? const EdgeInsets.fromLTRB(16, 12, 12, 12)
                        : const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
