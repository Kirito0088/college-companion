/// Recent Activity Section Widget
///
/// Displays a list of recent user activity once activity tracking
/// is implemented across the application.
library;

import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/shared/widgets/cc_empty_state.dart';
import 'package:college_companion/shared/widgets/section_header.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A section displaying recent activity.
///
/// Currently shows an empty state since activity tracking is not
/// yet implemented. Will display attendance entries, assignment
/// submissions, and grade updates once those features are built.
class RecentActivitySection extends StatelessWidget {
  /// Creates a [RecentActivitySection].
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Recent Activity'),
        SizedBox(height: SpacingTokens.md),
        CCCard(
          child: CCEmptyState(
            icon: Symbols.history_rounded,
            title: 'No recent activity',
            subtitle:
                'Your activity feed will show updates once you start using the app.',
          ),
        ),
      ],
    );
  }
}
