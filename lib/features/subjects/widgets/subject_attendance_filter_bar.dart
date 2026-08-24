import 'package:college_companion/features/subjects/providers/subject_detail_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// Bar containing filter chips for attendance record list.
class SubjectAttendanceFilterBar extends StatelessWidget {
  const SubjectAttendanceFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.totalCount,
    required this.presentCount,
    required this.absentCount,
    required this.cancelledCount,
  });

  final AttendanceFilter selectedFilter;
  final ValueChanged<AttendanceFilter> onFilterSelected;
  final int totalCount;
  final int presentCount;
  final int absentCount;
  final int cancelledCount;

  @override
  Widget build(BuildContext context) {
    final cc = context.cc;
    return Wrap(
      spacing: SpacingTokens.sm,
      runSpacing: SpacingTokens.xs,
      children: [
        _buildChip(
          context,
          label: 'All',
          count: totalCount,
          filter: AttendanceFilter.all,
        ),
        _buildChip(
          context,
          label: 'Present',
          count: presentCount,
          filter: AttendanceFilter.present,
          color: cc.pri,
        ),
        _buildChip(
          context,
          label: 'Absent',
          count: absentCount,
          filter: AttendanceFilter.absent,
          color: cc.risk,
        ),
        _buildChip(
          context,
          label: 'Cancelled',
          count: cancelledCount,
          filter: AttendanceFilter.cancelled,
          color: cc.mut,
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required int count,
    required AttendanceFilter filter,
    Color? color,
  }) {
    final cc = context.cc;
    final isSelected = selectedFilter == filter;
    final chipColor = color ?? cc.pri;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => onFilterSelected(filter),
      selectedColor: chipColor.withValues(alpha: 0.2),
      backgroundColor: cc.raise,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.borderRadiusPill,
        side: BorderSide(color: isSelected ? chipColor : cc.line),
      ),
      labelStyle: TextStyle(
        color: isSelected ? chipColor : cc.mut,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
    );
  }
}
