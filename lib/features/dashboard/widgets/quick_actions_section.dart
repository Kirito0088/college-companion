/// Quick Actions Section Widget
///
/// Displays a grid of quick action buttons for common tasks.
library;

import 'package:college_companion/shared/widgets/section_header.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A section displaying quick action buttons.
///
/// Provides one-tap access to frequently used features:
/// - View Timetable
/// - Check Attendance
/// - View Assignments
/// - Start Focus Mode
class QuickActionsSection extends StatelessWidget {
  /// Creates a [QuickActionsSection].
  const QuickActionsSection({
    super.key,
    this.onTimetablePressed,
    this.onAttendancePressed,
    this.onAssignmentsPressed,
    this.onFocusPressed,
  });

  /// Callback when timetable action is pressed.
  final VoidCallback? onTimetablePressed;

  /// Callback when attendance action is pressed.
  final VoidCallback? onAttendancePressed;

  /// Callback when assignments action is pressed.
  final VoidCallback? onAssignmentsPressed;

  /// Callback when focus mode action is pressed.
  final VoidCallback? onFocusPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: SpacingTokens.md),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _QuickActionTile(
                    icon: Symbols.schedule_rounded,
                    label: 'Calendar',
                    color: colorScheme.primary,
                    onPressed: onTimetablePressed,
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: _QuickActionTile(
                    icon: Symbols.fact_check_rounded,
                    label: 'Attendance',
                    color: colorScheme.tertiary,
                    onPressed: onAttendancePressed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
            Row(
              children: [
                Expanded(
                  child: _QuickActionTile(
                    icon: Symbols.assignment_rounded,
                    label: 'Assignments',
                    color: colorScheme.secondary,
                    onPressed: onAssignmentsPressed,
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: _QuickActionTile(
                    icon: Symbols.timer_rounded,
                    label: 'Focus Mode',
                    color: colorScheme.error,
                    onPressed: onFocusPressed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// A single quick action tile widget.
class _QuickActionTile extends StatelessWidget {
  /// Creates a [_QuickActionTile].
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  /// The icon to display.
  final IconData icon;

  /// The action label.
  final String label;

  /// The accent color for this action.
  final Color color;

  /// Callback when the action is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: RadiusTokens.borderRadiusMd,
      child: InkWell(
        onTap: onPressed,
        borderRadius: RadiusTokens.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.md,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
