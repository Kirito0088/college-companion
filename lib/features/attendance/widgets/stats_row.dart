import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, this.safeBunk});

  final SafeBunkResult? safeBunk;

  @override
  Widget build(BuildContext context) {
    final cc = context.cc;
    final presentStr = safeBunk != null ? '${safeBunk!.attended}' : '–';
    final absentStr = safeBunk != null
        ? '${safeBunk!.total - safeBunk!.attended}'
        : '–';
    final totalStr = safeBunk != null ? '${safeBunk!.total}' : '–';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            cc: cc,
            value: presentStr,
            label: 'Present',
            valueColor: cc.pri,
          ),
        ),
        const SizedBox(width: SpacingTokens.base),
        Expanded(
          child: _buildStatCard(
            context,
            cc: cc,
            value: absentStr,
            label: 'Absent',
            valueColor: cc.risk,
          ),
        ),
        const SizedBox(width: SpacingTokens.base),
        Expanded(
          child: _buildStatCard(
            context,
            cc: cc,
            value: totalStr,
            label: 'Total',
            valueColor: cc.fg,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required CCTokens cc,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.base),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusXxl,
        border: Border.all(color: cc.line),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cc.mut,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
