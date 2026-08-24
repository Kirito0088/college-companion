/// CCSection — Shared Titled Group Container
///
/// The "uppercase-ish label + rounded token container" wrapper repeated
/// across every settings/menu screen (ADR-011 redesign). Consolidates what
/// had been near-identical private `_buildSection`/`_buildSectionCard`
/// helpers in `settings_screen.dart`, `about_screen.dart`, and
/// `data_sync_screen.dart`.
library;

import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// A labeled group of [CCListRow]s (or any children) inside a rounded,
/// token-bordered container.
class CCSection extends StatelessWidget {
  const CCSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: cc.mut,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cc.raise,
            borderRadius: RadiusTokens.borderRadiusXxl,
            border: Border.all(color: cc.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}
