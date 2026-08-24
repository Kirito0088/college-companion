/// Today Schedule Section Widget
///
/// Displays today's chronological flow as a single vertical "spine"
/// timeline (ADR-011 canvas) — a continuous line connecting each event's
/// node, echoing the login screen's `_DaySpine` motif.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:college_companion/theme/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A section displaying today's chronological flow as a spine timeline.
class TodayOverviewSection extends ConsumerWidget {
  /// Creates a [TodayOverviewSection].
  const TodayOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated ? authState.user.uid : '';
    final snapshot =
        ref.watch(dashboardSnapshotProvider(userId)).valueOrNull ??
        DashboardSnapshot.empty();
    final theme = Theme.of(context);
    final cc = context.cc;
    final events = snapshot.timelineEvents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Today's Flow",
                style: TypographyTokens.serifTextTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cc.fg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Icon(Symbols.tune_rounded, color: cc.mut, size: 24),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        if (events.isEmpty)
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
                Icon(Symbols.event_available_rounded, size: 48, color: cc.pri),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'No classes scheduled for today',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cc.fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  'Take a break or catch up on assignments!',
                  style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < events.length; i++)
                _SpineRow(
                  event: events[i],
                  isFirst: i == 0,
                  isLast: i == events.length - 1,
                ),
            ],
          ),
      ],
    );
  }
}

/// A single row of the spine timeline: a time label, a node on the
/// continuous vertical spine, and the event's content card.
class _SpineRow extends StatelessWidget {
  const _SpineRow({
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  final TimelineEvent event;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final opacity = event.isPast ? 0.4 : 1.0;
    final nodeColor = event.isNow ? cc.pri : cc.line2;

    return Opacity(
      opacity: opacity,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      event.timeString,
                      style: TypographyTokens.mono(theme.textTheme.labelLarge)
                          .copyWith(
                            color: event.isNow ? cc.fg : cc.mut,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      event.meridiem,
                      style: TypographyTokens.mono(
                        theme.textTheme.labelSmall,
                      ).copyWith(color: cc.dim),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            // ── The spine: a continuous vertical line with a node per event ──
            SizedBox(
              width: 16,
              child: Column(
                children: [
                  Container(
                    width: 1.5,
                    height: 12,
                    color: isFirst ? Colors.transparent : cc.line,
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: nodeColor,
                      border: event.isNow
                          ? null
                          : Border.all(color: cc.line2, width: 1.5),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: isLast ? Colors.transparent : cc.line,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: event.isNow ? cc.raise2 : Colors.transparent,
                    borderRadius: RadiusTokens.borderRadiusMd,
                    border: event.isNow
                        ? Border.all(
                            color: cc.pri.withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: cc.fg,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.location,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cc.mut,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (event.isNow)
                            Text(
                              'NOW',
                              style:
                                  TypographyTokens.mono(
                                    theme.textTheme.labelSmall,
                                  ).copyWith(
                                    color: cc.pri,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing:
                                        TypographyTokens.monoLabelSpacing,
                                  ),
                            ),
                          const SizedBox(width: SpacingTokens.xs),
                          Icon(
                            Symbols.chevron_right_rounded,
                            color: event.isNow ? cc.pri : cc.mut,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
