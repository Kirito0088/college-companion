import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/calendar/widgets/agenda_card.dart';
import 'package:college_companion/theme/cc_tokens.dart';
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

  /// Map of day number (1-31) to a list of calendar events.
  final Map<int, List<CalendarEventEntity>> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final todayDay = now.day;

    // Calculate total days in current month and first weekday offset
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
    final offset = startingWeekday - 1; // Number of leading padding days

    final totalGridCells = ((offset + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: [
        // Days of week header
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
                      color: context.cc.mut,
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
            mainAxisSpacing: SpacingTokens.md,
            crossAxisSpacing: SpacingTokens.md,
            childAspectRatio: 1,
          ),
          itemCount: totalGridCells,
          itemBuilder: (context, index) {
            final dayNum = index - offset + 1;
            final isCurrentMonth = dayNum >= 1 && dayNum <= daysInMonth;

            final displayDate = isCurrentMonth
                ? dayNum
                : (dayNum < 1
                      ? DateTime(now.year, now.month, dayNum).day
                      : dayNum - daysInMonth);

            final isSelected = isCurrentMonth && displayDate == selectedDate;
            final isToday = isCurrentMonth && displayDate == todayDay;
            final dayEvents = isCurrentMonth
                ? (events[displayDate] ?? <CalendarEventEntity>[])
                : <CalendarEventEntity>[];

            return _CalendarDateCell(
              date: displayDate.toString(),
              isCurrentMonth: isCurrentMonth,
              isToday: isToday,
              isSelected: isSelected,
              events: dayEvents,
              onTap: () {
                if (isCurrentMonth) {
                  onDateSelected(displayDate);
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
  final List<CalendarEventEntity> events;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    Color textColor;
    if (isSelected) {
      textColor = cc.priFg;
    } else if (isCurrentMonth) {
      textColor = isToday ? cc.pri : cc.fg;
    } else {
      textColor = cc.dim;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      splashColor: cc.pri.withValues(alpha: 0.1),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected ? cc.pri : Colors.transparent,
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
                            ? cc.priFg.withValues(alpha: 0.8)
                            : event.typeColor(context),
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
