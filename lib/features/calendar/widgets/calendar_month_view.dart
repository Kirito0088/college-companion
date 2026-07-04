import 'package:college_companion/features/calendar/models/mock_event.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class CalendarMonthView extends StatelessWidget {
  const CalendarMonthView({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.events = const {},
  });

  final int selectedDate;
  final ValueChanged<int> onDateSelected;

  /// Map of date (1-31) to a list of events.
  final Map<int, List<MockEvent>> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        // Days of week
        Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.md),
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
            mainAxisSpacing: SpacingTokens.md, // generous spacing
            crossAxisSpacing: SpacingTokens.md, // generous spacing
            childAspectRatio: 1,
          ),
          itemCount: 35, // 5 weeks (mock)
          itemBuilder: (context, index) {
            final isPrevMonth = index < 3;
            final isNextMonth = index >= 34;
            final isCurrentMonth = !isPrevMonth && !isNextMonth;

            final date = isPrevMonth
                ? 28 + index
                : isNextMonth
                ? index - 33
                : index - 2;

            final isSelected = date == selectedDate && isCurrentMonth;
            final isToday = date == 13 && isCurrentMonth; // Mock today is 13th
            final dayEvents = isCurrentMonth
                ? (events[date] ?? [])
                : <MockEvent>[];

            return _CalendarDateCell(
              date: date.toString(),
              isCurrentMonth: isCurrentMonth,
              isToday: isToday,
              isSelected: isSelected,
              events: dayEvents,
              onTap: () {
                if (isCurrentMonth) {
                  onDateSelected(date);
                }
              },
            );
          },
        ),
      ],
    );
  }
}

class _CalendarDateCell extends StatelessWidget {
  const _CalendarDateCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.onTap,
  });

  final String date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final List<MockEvent> events;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color textColor;
    if (isSelected) {
      textColor = ColorTokens.onPrimary;
    } else if (isCurrentMonth) {
      textColor = isToday ? ColorTokens.primary : ColorTokens.onSurface;
    } else {
      textColor = ColorTokens.surfaceContainerHighest;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      splashColor: ColorTokens.primary.withValues(alpha: 0.1),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected ? ColorTokens.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            width: isSelected ? 40 : 0,
            height: isSelected ? 40 : 0,
          ),
          Text(
            date,
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: isSelected || isToday
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
          if (events.isNotEmpty)
            Positioned(
              bottom: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events.take(3).map((event) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorTokens.onPrimary.withValues(alpha: 0.8)
                            : event.type.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
