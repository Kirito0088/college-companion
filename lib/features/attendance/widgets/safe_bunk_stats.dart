import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class SafeBunkStats extends StatelessWidget {
  const SafeBunkStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens
            .surfaceContainer, // surface-container-lowest mapped to surfaceContainer
        borderRadius: RadiusTokens.borderRadiusXl,
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: const Column(
        children: [
          _StatRow(
            label: 'Current Attendance',
            value: '82%',
            showBorder: true,
            isImportant: false,
          ),
          _StatRow(
            label: 'Total Lectures',
            value: '180',
            showBorder: true,
            isImportant: false,
          ),
          _StatRow(
            label: 'Lectures Attended',
            value: '148',
            showBorder: true,
            isImportant: false,
          ),
          _StatRow(
            label: 'Lectures You Can Bunk',
            value: '8',
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

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.md, // py-4
        horizontal: SpacingTokens.base, // px-card-padding -> 16px
      ),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: ColorTokens.outlineVariant.withValues(alpha: 0.3),
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isImportant || label == 'Current Attendance'
                    ? ColorTokens.onSurface
                    : ColorTokens.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          SizedBox(
            width: 60, // w-[60px]
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isImportant
                    ? ColorTokens.success
                    : ColorTokens.onSurface,
                fontWeight: isImportant ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
