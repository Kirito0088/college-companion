/// Next Lecture Card
///
/// Displays the upcoming lecture for the authenticated user based on the DashboardSnapshot.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:college_companion/theme/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A card highlighting the user's immediate next action.
class NextLectureCard extends ConsumerWidget {
  /// Creates a [NextLectureCard].
  const NextLectureCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated ? authState.user.uid : '';
    final snapshot =
        ref.watch(dashboardSnapshotProvider(userId)).valueOrNull ??
        DashboardSnapshot.empty();
    final theme = Theme.of(context);
    final cc = context.cc;
    final nextAction = snapshot.nextAction;

    if (nextAction == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cc.raise2, cc.raise],
          ),
          border: Border.all(color: cc.line, width: 1),
          borderRadius: RadiusTokens.borderRadiusXxl,
          boxShadow: cc.shadow,
        ),
        child: InkWell(
          onTap: () => context.push(RoutePaths.subjectDetails),
          borderRadius: RadiusTokens.borderRadiusXxl,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'NEXT ACTION',
                              style:
                                  TypographyTokens.mono(
                                    theme.textTheme.labelMedium,
                                  ).copyWith(
                                    color: cc.mut,
                                    letterSpacing:
                                        TypographyTokens.monoLabelSpacing,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: SpacingTokens.xs),
                          Icon(
                            Symbols.arrow_forward_rounded,
                            size: 14,
                            color: cc.mut,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Flexible(
                      child: Text(
                        nextAction.urgencyString,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cc.pri,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  nextAction.title,
                  style: TypographyTokens.serifTextTheme.headlineSmall
                      ?.copyWith(color: cc.fg, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.xs),
                Row(
                  children: [
                    Icon(Symbols.schedule, size: 16, color: cc.mut),
                    const SizedBox(width: 4),
                    Text(
                      nextAction.timeString,
                      style: TypographyTokens.mono(
                        theme.textTheme.bodyMedium,
                      ).copyWith(color: cc.mut),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    Icon(Symbols.location_on, size: 16, color: cc.mut),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        nextAction.location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cc.mut,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
