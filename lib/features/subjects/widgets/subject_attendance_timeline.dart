import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/shared/widgets/cc_empty_state.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/icon_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Timeline list of past attendance sessions for a subject.
class SubjectAttendanceTimeline extends StatelessWidget {
  const SubjectAttendanceTimeline({
    super.key,
    required this.records,
    this.onEdit,
    this.onDelete,
  });

  final List<AttendanceEntity> records;
  final ValueChanged<AttendanceEntity>? onEdit;
  final ValueChanged<AttendanceEntity>? onDelete;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: SpacingTokens.xl),
        child: CcEmptyState(
          icon: Symbols.fact_check,
          title: 'No attendance records',
          subtitle:
              'Mark attendance using the action button below to start tracking sessions.',
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: SpacingTokens.sm),
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(context, record);
      },
    );
  }

  Widget _buildRecordCard(BuildContext context, AttendanceEntity record) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record.primaryStatus) {
      case 'present':
        statusColor = ColorTokens.success;
        statusIcon = Symbols.check_circle;
        statusText = 'Present';
        break;
      case 'absent':
        statusColor = ColorTokens.error;
        statusIcon = Symbols.cancel;
        statusText = 'Absent';
        break;
      case 'cancelled':
        statusColor = ColorTokens.onSurfaceVariant;
        statusIcon = Symbols.event_busy;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = ColorTokens.onSurfaceVariant;
        statusIcon = Symbols.help_outline;
        statusText = record.primaryStatus;
        break;
    }

    final hasNotes = record.notes != null && record.notes!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.base),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Icon Container
          Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: RadiusTokens.borderRadiusSm,
            ),
            child: Icon(
              statusIcon,
              size: IconSizeTokens.md,
              color: statusColor,
            ),
          ),
          const SizedBox(width: SpacingTokens.md),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.date,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: ColorTokens.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.sm,
                        vertical: SpacingTokens.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: RadiusTokens.borderRadiusSm,
                      ),
                      child: Text(
                        statusText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  record.lectureType.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                if (hasNotes) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    record.notes!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ColorTokens.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Edit/Delete menu if provided
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(width: SpacingTokens.xs),
            PopupMenuButton<String>(
              icon: const Icon(
                Symbols.more_vert,
                size: IconSizeTokens.sm,
                color: ColorTokens.onSurfaceVariant,
              ),
              color: ColorTokens.surfaceContainerHigh,
              onSelected: (action) {
                if (action == 'edit' && onEdit != null) {
                  onEdit!(record);
                } else if (action == 'delete' && onDelete != null) {
                  onDelete!(record);
                }
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Symbols.edit, size: IconSizeTokens.sm),
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
                          size: IconSizeTokens.sm,
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
        ],
      ),
    );
  }
}
