import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock dates representing May 2025 like in Stitch design
    final daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        // Days of week
        Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.base), // mb-4
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Dates grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: SpacingTokens.base, // gap-y-4
            crossAxisSpacing: SpacingTokens.xs, // gap-x-2
            childAspectRatio: 1,
          ),
          itemCount: 35, // 3 + 31 + 1
          itemBuilder: (context, index) {
            // Determine date status
            final isPrevMonth = index < 3;
            final isNextMonth = index >= 34;
            final isCurrentMonth = !isPrevMonth && !isNextMonth;

            final date = isPrevMonth
                ? 28 + index
                : isNextMonth
                ? index - 33
                : index - 2; // 1 to 31

            final isToday = date == 13 && isCurrentMonth;

            // Events
            final isRedEvent = date == 14 && isCurrentMonth;
            final isYellowEvent = date == 16 && isCurrentMonth;
            final isBlueEvent = date == 20 && isCurrentMonth;
            final isVioletEvent = date == 28 && isCurrentMonth;
            final isVioletEventFaded = date == 31 && isCurrentMonth;

            return _CalendarDateCell(
              date: date.toString(),
              isCurrentMonth: isCurrentMonth,
              isToday: isToday,
              eventColor: isRedEvent
                  ? ColorTokens.error
                  : isYellowEvent
                  ? ColorTokens.warning
                  : isBlueEvent
                  ? ColorTokens.info
                  : isVioletEvent
                  ? ColorTokens.primary
                  : isVioletEventFaded
                  ? ColorTokens.primary.withValues(alpha: 0.5)
                  : null,
            );
          },
        ),
        // Decorative dashed line
        Padding(
          padding: const EdgeInsets.only(
            top: SpacingTokens.sm,
            left: SpacingTokens.huge,
            right: SpacingTokens.huge,
          ),
          child: Divider(
            color: ColorTokens.primary.withValues(alpha: 0.15),
            thickness: 0.5,
          ),
        ),
      ],
    );
  }
}

class _CalendarDateCell extends StatelessWidget {
  const _CalendarDateCell({
    required this.date,
    required this.isCurrentMonth,
    this.isToday = false,
    this.eventColor,
  });

  final String date;
  final bool isCurrentMonth;
  final bool isToday;
  final Color? eventColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20), // makes ripple circular
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isToday)
            Container(
              width: 32, // w-8
              height: 32, // h-8
              decoration: BoxDecoration(
                color: ColorTokens.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorTokens.primary.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          Text(
            date,
            style: isToday
                ? theme.textTheme.titleMedium?.copyWith(
                    color: ColorTokens.onPrimary,
                    fontWeight: FontWeight.bold,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    color: isCurrentMonth
                        ? ColorTokens.onSurface
                        : ColorTokens.surfaceContainerHighest,
                  ),
          ),
          if (eventColor != null)
            Positioned(
              bottom: 4, // bottom-1
              child: Container(
                width: 4, // w-1
                height: 4, // h-1
                decoration: BoxDecoration(
                  color: eventColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
