import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class SafeBunkStats extends StatelessWidget {
  const SafeBunkStats({super.key, this.safeBunk});

  final SafeBunkResult? safeBunk;

  @override
  Widget build(BuildContext context) {
    final cc = context.cc;
    final currentStr = safeBunk != null
        ? '${safeBunk!.currentPercentage.round()}%'
        : '–';
    final totalStr = safeBunk != null ? '${safeBunk!.total}' : '–';
    final attendedStr = safeBunk != null ? '${safeBunk!.attended}' : '–';
    final safeBunksStr = safeBunk != null ? '${safeBunk!.safeBunks}' : '–';

    return Container(
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusXxl,
        border: Border.all(color: cc.line),
      ),
      child: Column(
        children: [
          _StatRow(
            label: 'Current Attendance',
            value: currentStr,
            showBorder: true,
            isImportant: false,
          ),
          _StatRow(
            label: 'Total Lectures',
            value: totalStr,
            showBorder: true,
            isImportant: false,
          ),
          _StatRow(
            label: 'Lectures Attended',
            value: attendedStr,
            showBorder: true,
            isImportant: false,
          ),
          _StatRow(
            label: 'Lectures You Can Bunk',
            value: safeBunksStr,
            showBorder: false,
            isImportant: true,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.showBorder,
    required this.isImportant,
  });

  final String label;
  final String value;
  final bool showBorder;
  final bool isImportant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.md,
        horizontal: SpacingTokens.base,
      ),
      decoration: BoxDecoration(
        border: showBorder ? Border(bottom: BorderSide(color: cc.line)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isImportant || label == 'Current Attendance'
                    ? cc.fg
                    : cc.mut,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          SizedBox(
            width: 60,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isImportant ? cc.pri : cc.fg,
                fontWeight: isImportant ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
