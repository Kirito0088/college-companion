import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// Semantic color for a calendar event [type] label (e.g. `'academic'`,
/// `'assignment'`), sourced from the ADR-011 reactive tokens.
///
/// Centralized here so every calendar surface — the agenda card, the month
/// grid, event details, and the "New Event" type picker — renders the same
/// event type consistently. Previously each of those hand-rolled its own
/// switch statement and disagreed (e.g. 'assignment' was `secondary` in one
/// place and `warning` in another).
Color calendarEventTypeColor(BuildContext context, String type) {
  final cc = context.cc;
  switch (type.toLowerCase()) {
    case 'academic':
    case 'lecture':
    case 'holiday':
      return cc.pri;
    case 'assignment':
      return cc.warn;
    case 'exam':
      return cc.risk;
    case 'personal':
    default:
      return Theme.of(context).colorScheme.tertiary;
  }
}

extension CalendarEventEntityColorX on CalendarEventEntity {
  /// Semantic color for this event's [eventType]. See
  /// [calendarEventTypeColor].
  Color typeColor(BuildContext context) =>
      calendarEventTypeColor(context, eventType);

  String get typeLabel {
    if (eventType.isEmpty) return 'Event';
    return '${eventType[0].toUpperCase()}${eventType.substring(1)}';
  }
}

class AgendaCard extends StatelessWidget {
  const AgendaCard({super.key, required this.event, this.onTap});

  final CalendarEventEntity event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final typeColor = event.typeColor(context);

    final startDate = DateTime.tryParse(event.startDate);
    final timeStr = startDate != null
        ? '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiusTokens.borderRadiusXxl,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: cc.raise,
            borderRadius: RadiusTokens.borderRadiusXxl,
            border: Border.all(color: cc.line),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Event Type Indicator Bar
                Container(width: 4, color: typeColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cc.fg,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (timeStr != null) ...[
                              Text(
                                timeStr,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cc.mut,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.sm),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: cc.mut,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.sm),
                            ],
                            Text(
                              event.typeLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (event.description != null &&
                                event.description!.isNotEmpty) ...[
                              const SizedBox(width: SpacingTokens.sm),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: cc.mut,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.sm),
                              Flexible(
                                child: Text(
                                  event.description!,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: cc.mut,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
