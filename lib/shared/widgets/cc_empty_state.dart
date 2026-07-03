/// CCEmptyState — Shared Empty State Component
///
/// Displayed when a feature contains no data (per DESIGN.md §9).
/// Every empty state includes an icon, a short explanation, and — when
/// practical — a suggested action, so users are never left staring at a
/// blank section.
///
/// Rules (per 03-ui-rules.md §14 / DESIGN.md):
/// - Never display a bare "No Data" message.
/// - Explain why the section is empty and what to do next.
/// - Never rely on color alone.
library;

import 'package:college_companion/theme/icon_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// A reusable empty-state widget.
///
/// Shows a [icon] above a [title] and optional [subtitle]. When [actionLabel]
/// and [onAction] are provided, a text button is rendered so the user can
/// take the suggested next step directly from the empty state.
class CCEmptyState extends StatelessWidget {
  /// Creates a [CCEmptyState].
  const CCEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// The illustration or icon cue.
  final IconData icon;

  /// The short explanation of why the section is empty.
  final String title;

  /// Optional supporting text describing what the user can do next.
  final String? subtitle;

  /// Optional label for the suggested action button.
  final String? actionLabel;

  /// Optional callback invoked when the action button is pressed.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: IconSizeTokens.xl,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: SpacingTokens.xxs),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: SpacingTokens.base),
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    );
  }
}
