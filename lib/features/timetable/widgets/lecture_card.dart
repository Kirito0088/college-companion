/// Lecture Card
///
/// Displays a single lecture slot in the timetable with subject name, timing,
/// room, faculty, type tag, and active lecture highlight indicator.
library;

import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Card widget for a scheduled lecture slot.
class LectureCard extends StatelessWidget {
  /// Creates a [LectureCard].
  const LectureCard({
    super.key,
    required this.lecture,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  /// The lecture slot presentation data.
  final LectureScheduleItem lecture;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Optional edit callback.
  final VoidCallback? onEdit;

  /// Optional delete callback.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = lecture.isCurrent;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: isCurrent
              ? ColorTokens.surfaceContainerHigh
              : ColorTokens.surfaceContainer,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(
            color: isCurrent ? ColorTokens.primary : ColorTokens.outlineVariant,
            width: isCurrent ? 1.5 : 1.0,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: RadiusTokens.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Type chip & Active badge & More menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _LectureTypeChip(lectureType: lecture.lectureType),
                        if (isCurrent) ...[
                          const SizedBox(width: SpacingTokens.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpacingTokens.sm,
                              vertical: SpacingTokens.xxs,
                            ),
                            decoration: const BoxDecoration(
                              color: ColorTokens.primary,
                              borderRadius: RadiusTokens.borderRadiusPill,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: ColorTokens.onPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: SpacingTokens.xs),
                                Text(
                                  'NOW',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: ColorTokens.onPrimary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Symbols.more_vert,
                          size: 20,
                          color: ColorTokens.onSurfaceVariant,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') onEdit?.call();
                          if (value == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Symbols.edit, size: 18),
                                  SizedBox(width: SpacingTokens.sm),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.delete,
                                    size: 18,
                                    color: ColorTokens.error,
                                  ),
                                  SizedBox(width: SpacingTokens.sm),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: ColorTokens.error),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.sm),

                // Subject Name
                Text(
                  lecture.subjectName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ColorTokens.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.sm),

                // Metadata row: Time & Room & Faculty
                Wrap(
                  spacing: SpacingTokens.md,
                  runSpacing: SpacingTokens.xs,
                  children: [
                    // Time range
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.schedule,
                          size: 16,
                          color: isCurrent
                              ? ColorTokens.primary
                              : ColorTokens.onSurfaceVariant,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(
                          lecture.formattedTimeRange,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isCurrent
                                ? ColorTokens.primary
                                : ColorTokens.onSurfaceVariant,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    // Room
                    if (lecture.room != null && lecture.room!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Symbols.location_on,
                            size: 16,
                            color: ColorTokens.onSurfaceVariant,
                          ),
                          const SizedBox(width: SpacingTokens.xs),
                          Text(
                            lecture.room!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ColorTokens.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                    // Faculty
                    if (lecture.faculty != null && lecture.faculty!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Symbols.person,
                            size: 16,
                            color: ColorTokens.onSurfaceVariant,
                          ),
                          const SizedBox(width: SpacingTokens.xs),
                          Text(
                            lecture.faculty!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ColorTokens.onSurfaceVariant,
                            ),
                          ),
                        ],
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

class _LectureTypeChip extends StatelessWidget {
  const _LectureTypeChip({required this.lectureType});

  final String lectureType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPractical = lectureType.toLowerCase() == 'practical';
    final isTutorial = lectureType.toLowerCase() == 'tutorial';

    Color chipBg = ColorTokens.surfaceContainerHighest;
    Color chipFg = ColorTokens.onSurfaceVariant;

    if (isPractical) {
      chipBg = ColorTokens.secondaryContainer;
      chipFg = ColorTokens.onSecondaryContainer;
    } else if (isTutorial) {
      chipBg = ColorTokens.tertiaryContainer;
      chipFg = ColorTokens.onTertiaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: RadiusTokens.borderRadiusSm,
        border: Border.all(color: ColorTokens.outlineVariant, width: 1),
      ),
      child: Text(
        lectureType.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipFg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
