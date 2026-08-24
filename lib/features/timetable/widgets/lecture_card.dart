/// Lecture Card
///
/// Displays a single lecture slot in the timetable with subject name, timing,
/// room, faculty, type tag, and active lecture highlight indicator.
library;

import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/theme/cc_tokens.dart';
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
    final cc = context.cc;
    final isCurrent = lecture.isCurrent;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: isCurrent ? cc.raise2 : cc.raise,
          borderRadius: RadiusTokens.borderRadiusXxl,
          border: Border.all(
            color: isCurrent ? cc.pri : cc.line,
            width: isCurrent ? 1.5 : 1.0,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: RadiusTokens.borderRadiusXxl,
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
                            decoration: BoxDecoration(
                              color: cc.pri,
                              borderRadius: RadiusTokens.borderRadiusPill,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: cc.priFg,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: SpacingTokens.xs),
                                Text(
                                  'NOW',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cc.priFg,
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
                        icon: Icon(Symbols.more_vert, size: 20, color: cc.mut),
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
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.delete,
                                    size: 18,
                                    color: cc.risk,
                                  ),
                                  const SizedBox(width: SpacingTokens.sm),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: cc.risk),
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
                    color: cc.fg,
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
                          color: isCurrent ? cc.pri : cc.mut,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(
                          lecture.formattedTimeRange,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isCurrent ? cc.pri : cc.mut,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    // Room
                    if (lecture.room != null && lecture.room!.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Symbols.location_on, size: 16, color: cc.mut),
                            const SizedBox(width: SpacingTokens.xs),
                            Flexible(
                              child: Text(
                                lecture.room!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cc.mut,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Faculty
                    if (lecture.faculty != null && lecture.faculty!.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Symbols.person, size: 16, color: cc.mut),
                            const SizedBox(width: SpacingTokens.xs),
                            Flexible(
                              child: Text(
                                lecture.faculty!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cc.mut,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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

class _LectureTypeChip extends StatelessWidget {
  const _LectureTypeChip({required this.lectureType});

  final String lectureType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final colorScheme = Theme.of(context).colorScheme;
    final isPractical = lectureType.toLowerCase() == 'practical';
    final isTutorial = lectureType.toLowerCase() == 'tutorial';

    Color chipBg = cc.raise2;
    Color chipFg = cc.mut;

    if (isPractical) {
      chipBg = colorScheme.secondaryContainer;
      chipFg = colorScheme.onSecondaryContainer;
    } else if (isTutorial) {
      chipBg = colorScheme.tertiaryContainer;
      chipFg = colorScheme.onTertiaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: RadiusTokens.borderRadiusSm,
        border: Border.all(color: cc.line, width: 1),
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
