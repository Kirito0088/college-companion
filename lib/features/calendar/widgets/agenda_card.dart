import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

extension CalendarEventEntityColorX on CalendarEventEntity {
  Color get typeColor {
    switch (eventType.toLowerCase()) {
      case 'academic':
        return ColorTokens.primary;
      case 'assignment':
        return ColorTokens.secondary;
      case 'exam':
        return ColorTokens.error;
      case 'personal':
      default:
        return ColorTokens.tertiary;
    }
  }

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
    final typeColor = event.typeColor;

    final startDate = DateTime.tryParse(event.startDate);
    final timeStr = startDate != null
        ? '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiusTokens.borderRadiusMd,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusMd,
            border: Border.all(color: ColorTokens.surfaceVariant),
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
                            color: ColorTokens.onSurface,
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
                                  color: ColorTokens.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.sm),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: ColorTokens.onSurfaceVariant,
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
                            if (event.description != null && event.description!.isNotEmpty) ...[
                              const SizedBox(width: SpacingTokens.sm),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: ColorTokens.onSurfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.sm),
                              Flexible(
                                child: Text(
                                  event.description!,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: ColorTokens.onSurfaceVariant,
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
