/// Today Overview Section Widget
///
/// Displays a summary of today's schedule and activities.
/// Placeholder for future timetable integration.
library;

import 'package:college_companion/shared/widgets/section_header.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// A section displaying today's overview placeholder.
///
/// This widget is designed to be replaced with actual timetable
/// data once the timetable feature is implemented. The structure
/// allows for easy integration of:
/// - Today's lectures
/// - Upcoming practicals
/// - Break times
/// - Room locations
class TodayOverviewSection extends StatelessWidget {
  /// Creates a [TodayOverviewSection].
  const TodayOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Today's Overview", onSeeAllPressed: null),
        const SizedBox(height: SpacingTokens.md),
        Container(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusMd,
          ),
          child: Column(
            children: [
              Icon(
                Icons.event_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 32,
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'No classes scheduled today',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SpacingTokens.xxs),
              Text(
                'Your timetable will appear here',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
