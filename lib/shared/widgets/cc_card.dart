/// CCCard — Shared Card Component
///
/// The base container used throughout College Companion (per DESIGN.md §9).
/// Provides consistent padding, border radius, and surface color for every
/// card-style section. Presentation-only; contains no business logic.
///
/// Rules (per DESIGN.md / 03-ui-rules.md §7):
/// - Consistent padding, radius, and elevation.
/// - Never nest cards inside cards.
/// - Avoid hardcoded spacing/radius/colors — use design tokens.
library;

import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// A reusable card container following the College Companion design system.
///
/// Wraps its [child] in a tonal surface with the standard card padding
/// and a medium border radius. Pass [padding] to override the default
/// [SpacingTokens.base] padding when a section needs a tighter or looser
/// internal layout (e.g. dense grids).
class CCCard extends StatelessWidget {
  /// Creates a [CCCard].
  const CCCard({super.key, required this.child, this.padding});

  /// The card content.
  final Widget child;

  /// Internal padding. Defaults to [SpacingTokens.base] when null.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(SpacingTokens.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusMd,
      ),
      child: child,
    );
  }
}
