import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class CalendarEventList extends StatelessWidget {
  const CalendarEventList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _EventCard(
          day: '14',
          month: 'MAY',
          title: 'AI Mini Project Report',
          subtitle: 'Due Tomorrow, 11:59 PM',
          indicatorColor: ColorTokens.error,
        ),
        _EventCard(
          day: '16',
          month: 'MAY',
          title: 'DevOps Lab Record',
          subtitle: 'Due in 2 days',
          indicatorColor: ColorTokens.warning,
        ),
        _EventCard(
          day: '20',
          month: 'MAY',
          title: 'Internal Test - CN',
          subtitle: '10:00 AM - 12:00 PM',
          indicatorColor: ColorTokens.info,
          isLast: true,
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.day,
    required this.month,
    required this.title,
    required this.subtitle,
    required this.indicatorColor,
    this.isLast = false,
  });

  final String day;
  final String month;
  final String title;
  final String subtitle;
  final Color indicatorColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs), // py-2
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date portion
          Container(
            constraints: const BoxConstraints(minWidth: 48), // min-w-[48px]
            padding: const EdgeInsets.only(top: SpacingTokens.xxs), // pt-1
            child: Column(
              children: [
                Text(
                  day,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ColorTokens.primary,
                    fontWeight: FontWeight.bold,
                    height: 1, // leading-none
                  ),
                ),
                const SizedBox(height: SpacingTokens.xxs), // mt-1
                Text(
                  month,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                    letterSpacing: 2, // tracking-widest
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.base), // gap-4
          // Content portion
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                bottom: SpacingTokens.base,
              ), // pb-4
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(
                          color: ColorTokens.surfaceVariant,
                          width: 1,
                        ),
                      ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: ColorTokens.onSurface,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xxs), // mt-1
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ColorTokens.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 12, // top-3
                    child: Container(
                      width: 8, // w-2
                      height: 8, // h-2
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: indicatorColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
