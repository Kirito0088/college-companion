import 'package:college_companion/features/calendar/models/mock_event.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class AgendaCard extends StatelessWidget {
  const AgendaCard({super.key, required this.event, this.onTap});

  final MockEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = event.type.color;

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
                            if (event.time != null) ...[
                              Text(
                                event.time!,
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
                              event.type.label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (event.subject != null) ...[
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
                                  event.subject!,
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
