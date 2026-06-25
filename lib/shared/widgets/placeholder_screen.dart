/// Placeholder Screen
///
/// Reusable placeholder widget displayed for routes that have not
/// yet been implemented. Shows the feature name so developers can
/// easily identify which route they are viewing.
library;

import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// A simple placeholder screen for unimplemented features.
class PlaceholderScreen extends StatelessWidget {
  /// Creates a [PlaceholderScreen] with the given [title].
  const PlaceholderScreen({
    required this.title,
    super.key,
  });

  /// The name of the feature or screen to display.
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: SpacingTokens.base),
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'This feature is coming soon.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
