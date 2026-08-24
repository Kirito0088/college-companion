/// Upcoming Assignments Section Widget
///
/// Displays a list of upcoming assignments from the DashboardSnapshot.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/section_header.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A section displaying upcoming assignments.
class UpcomingAssignmentsSection extends ConsumerWidget {
  /// Creates an [UpcomingAssignmentsSection].
  const UpcomingAssignmentsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated ? authState.user.uid : '';
    final snapshot =
        ref.watch(dashboardSnapshotProvider(userId)).valueOrNull ??
        DashboardSnapshot.empty();
    final theme = Theme.of(context);
    final cc = context.cc;
    final assignments = snapshot.upcomingAssignments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Upcoming Assignments',
          onSeeAllPressed: () => context.push(RoutePaths.assignments),
        ),
        const SizedBox(height: SpacingTokens.md),
        if (assignments.isEmpty)
          Container(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            decoration: BoxDecoration(
              color: cc.raise,
              borderRadius: RadiusTokens.borderRadiusXxl,
              border: Border.all(color: cc.line),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Symbols.assignment_turned_in_rounded,
                  size: 48,
                  color: cc.pri,
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'No upcoming assignments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cc.fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  "You're all caught up!",
                  style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
                ),
              ],
            ),
          )
        else
          ...assignments.map(
            (assignment) => Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
              child: _buildAssignmentCard(
                context,
                title: assignment.title,
                subject: assignment.subject,
                dueDate: assignment.dueDateString,
                daysLeft: assignment.daysLeft,
                onTap: () => context.push(
                  RoutePaths.assignmentDetails.replaceFirst(
                    ':id',
                    assignment.id,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context, {
    required String title,
    required String subject,
    required String dueDate,
    required int daysLeft,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cc = context.cc;

    // Determine color based on urgency
    Color indicatorColor = cc.pri;
    if (daysLeft <= 1) {
      indicatorColor = cc.risk;
    } else if (daysLeft <= 3) {
      indicatorColor = cc.warn;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: RadiusTokens.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: cc.raise2,
          borderRadius: RadiusTokens.borderRadiusMd,
          border: Border.all(color: cc.line),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cc.fg,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        subject,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cc.mut,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      Icon(Symbols.circle, size: 4, color: cc.mut),
                      const SizedBox(width: SpacingTokens.sm),
                      Text(
                        dueDate,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cc.mut,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: indicatorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                daysLeft == 0 ? 'Today' : '${daysLeft}d left',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: indicatorColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
