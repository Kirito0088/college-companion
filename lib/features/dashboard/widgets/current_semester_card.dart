/// Current Semester Card Widget
///
/// Displays the current active semester information.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/semester/providers/semester_provider.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card displaying the current semester information.
///
/// Watches the current semester via Riverpod's [semesterRepositoryProvider]
/// and displays relevant information. Shows a placeholder
/// if no semester exists yet.
class CurrentSemesterCard extends ConsumerWidget {
  /// Creates a [CurrentSemesterCard].
  const CurrentSemesterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get the current semester if user is authenticated
    final semesterStream = authState is AuthAuthenticated
        ? ref.watch(semesterRepositoryProvider).watchCurrent(authState.user.uid)
        : null;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: RadiusTokens.borderRadiusMd,
      ),
      child: semesterStream != null
          ? StreamBuilder(
              stream: semesterStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final semester = snapshot.data!;
                  return _buildSemesterContent(context, semester.name);
                }
                return _buildPlaceholder(context);
              },
            )
          : _buildPlaceholder(context),
    );
  }

  /// Builds the semester content when data is available.
  Widget _buildSemesterContent(BuildContext context, String name) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Semester',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          name,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Builds the placeholder UI when no semester exists.
  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Semester',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            Icon(
              Icons.school_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                'No semester set up yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ],
    );
  }
}
