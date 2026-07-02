/// Recent Activity Section Widget
///
/// Displays a list of recent user activity.
/// Placeholder for future activity feed integration.
library;

import 'package:college_companion/shared/widgets/section_header.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// A section displaying recent activity placeholders.
///
/// This widget is designed to be populated with actual activity
/// data once the relevant features are implemented. The structure
/// supports:
/// - Recent attendance entries
/// - Assignment submissions
/// - Grade updates
/// - Timetable changes
class RecentActivitySection extends StatelessWidget {
  /// Creates a [RecentActivitySection].
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recent Activity'),
        const SizedBox(height: SpacingTokens.md),
        Container(
          padding: const EdgeInsets.all(SpacingTokens.base),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusMd,
          ),
          child: Column(
            children: [
              _ActivityItem(
                icon: Icons.history_rounded,
                title: 'No recent activity',
                subtitle: 'Your activity feed will appear here',
                time: '',
                color: colorScheme.onSurfaceVariant,
              ),
              const Divider(color: ColorTokens.divider, height: 1),
              _ActivityItem(
                icon: Icons.info_outline_rounded,
                title: 'Setup your timetable',
                subtitle: 'Add classes to see activity updates',
                time: '',
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A single activity item widget.
class _ActivityItem extends StatelessWidget {
  /// Creates an [_ActivityItem].
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  /// The icon to display.
  final IconData icon;

  /// The activity title.
  final String title;

  /// The activity subtitle/description.
  final String subtitle;

  /// The time indicator (e.g., "2h ago").
  final String time;

  /// The icon color.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: RadiusTokens.borderRadiusSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (time.isNotEmpty)
            Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
