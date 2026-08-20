import 'package:college_companion/features/subjects/providers/subject_detail_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
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
    return Wrap(
      spacing: SpacingTokens.sm,
      runSpacing: SpacingTokens.xs,
      children: [
        _buildChip(
          label: 'All',
          count: totalCount,
          filter: AttendanceFilter.all,
        ),
        _buildChip(
          label: 'Present',
          count: presentCount,
          filter: AttendanceFilter.present,
          color: ColorTokens.success,
        ),
        _buildChip(
          label: 'Absent',
          count: absentCount,
          filter: AttendanceFilter.absent,
          color: ColorTokens.error,
        ),
        _buildChip(
          label: 'Cancelled',
          count: cancelledCount,
          filter: AttendanceFilter.cancelled,
          color: ColorTokens.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required int count,
    required AttendanceFilter filter,
    Color? color,
  }) {
    final isSelected = selectedFilter == filter;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => onFilterSelected(filter),
      selectedColor: (color ?? ColorTokens.primary).withValues(alpha: 0.2),
      backgroundColor: ColorTokens.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.borderRadiusPill,
        side: BorderSide(
          color: isSelected
              ? (color ?? ColorTokens.primary)
              : ColorTokens.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      labelStyle: TextStyle(
        color: isSelected
            ? (color ?? ColorTokens.primary)
            : ColorTokens.onSurfaceVariant,
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
