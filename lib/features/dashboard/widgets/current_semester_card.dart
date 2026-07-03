/// Current Semester Card Widget
///
/// Displays the active semester for the authenticated user (per
/// DESIGN.md §8 — Current Semester). Watches the semester repository
/// and shows an honest empty state when no semester is set up yet.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/semester/providers/semester_provider.dart';
import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/shared/widgets/cc_empty_state.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A card displaying the current semester information.
///
/// Watches the current semester via [semesterRepositoryProvider] and
/// displays its name. Shows an empty state if the user is unauthenticated
/// or has no current semester.
class CurrentSemesterCard extends ConsumerWidget {
  /// Creates a [CurrentSemesterCard].
  const CurrentSemesterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Watch the current semester only when the user is authenticated.
    final semesterStream = authState is AuthAuthenticated
        ? ref.watch(semesterRepositoryProvider).watchCurrent(authState.user.uid)
        : null;

    return StreamBuilder(
      stream: semesterStream,
      builder: (context, snapshot) {
        final semester = snapshot.data;
        final hasSemester = semester != null;

        return CCCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Semester',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              if (hasSemester)
                Text(
                  semester.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                const CCEmptyState(
                  icon: Symbols.school_rounded,
                  title: 'No semester set up yet',
                  subtitle: 'Create your first semester to get started.',
                ),
            ],
          ),
        );
      },
    );
  }
}
