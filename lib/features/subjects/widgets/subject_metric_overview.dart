import 'package:college_companion/features/attendance/services/bunk_calculator.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/icon_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Renders the primary attendance and bunk calculator overview cards for a subject.
class SubjectMetricOverview extends StatelessWidget {
  const SubjectMetricOverview({
    super.key,
    required this.bunkMetrics,
    required this.presentCount,
    required this.absentCount,
    required this.cancelledCount,
  });

  final BunkCalculationResult bunkMetrics;
  final int presentCount;
  final int absentCount;
  final int cancelledCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (bunkMetrics.status) {
      case AttendanceStatus.onTrack:
        statusColor = cc.pri;
        statusLabel = 'On Track';
        statusIcon = Symbols.check_circle;
        break;
      case AttendanceStatus.warning:
        statusColor = cc.warn;
        statusLabel = 'Warning';
        statusIcon = Symbols.warning;
        break;
      case AttendanceStatus.critical:
        statusColor = cc.risk;
        statusLabel = 'Critical Deficit';
        statusIcon = Symbols.error;
        break;
    }

    final double pctValue = bunkMetrics.total > 0
        ? (bunkMetrics.attended / bunkMetrics.total).clamp(0.0, 1.0)
        : 0.0;
    final int pctInt = bunkMetrics.currentPercentage.round();

    return Column(
      children: [
        // Main Metric Card
        Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: BoxDecoration(
            color: cc.raise,
            borderRadius: RadiusTokens.borderRadiusXxl,
            border: Border.all(color: cc.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Percentage & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$pctInt%',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: cc.fg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      Text(
                        'Target: ${bunkMetrics.targetPercentage.round()}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cc.mut,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: RadiusTokens.borderRadiusPill,
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: IconSizeTokens.sm,
                          color: statusColor,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(
                          statusLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),

              // Progress Bar
              ClipRRect(
                borderRadius: RadiusTokens.borderRadiusPill,
                child: LinearProgressIndicator(
                  value: pctValue,
                  minHeight: 8,
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),

              // Quiet Confidence Status Message
              Text(
                bunkMetrics.statusMessage,
                style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
              ),
              const SizedBox(height: SpacingTokens.lg),

              // Secondary Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      label: 'Conducted',
                      value:
                          '${bunkMetrics.attended} / ${bunkMetrics.total} Classes',
                      icon: Symbols.school,
                      iconColor: cc.pri,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      label: bunkMetrics.safeBunks > 0
                          ? 'Safe Bunks'
                          : 'Must Attend',
                      value: bunkMetrics.safeBunks > 0
                          ? '${bunkMetrics.safeBunks} ${bunkMetrics.safeBunks == 1 ? 'Bunk' : 'Bunks'}'
                          : (bunkMetrics.classesToAttend > 0
                                ? '${bunkMetrics.classesToAttend} ${bunkMetrics.classesToAttend == 1 ? 'Class' : 'Classes'}'
                                : '0 Bunks'),
                      icon: bunkMetrics.safeBunks > 0
                          ? Symbols.airline_seat_recline_extra
                          : Symbols.event_repeat,
                      iconColor: bunkMetrics.safeBunks > 0
                          ? cc.pri
                          : (bunkMetrics.classesToAttend > 0
                                ? cc.warn
                                : cc.mut),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.md),

        // Breakdown stats row
        Row(
          children: [
            Expanded(
              child: _buildBreakdownCard(
                context,
                label: 'Present',
                count: presentCount,
                color: cc.pri,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: _buildBreakdownCard(
                context,
                label: 'Absent',
                count: absentCount,
                color: cc.risk,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: _buildBreakdownCard(
                context,
                label: 'Cancelled',
                count: cancelledCount,
                color: cc.mut,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: cc.raise2,
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(color: cc.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: IconSizeTokens.sm, color: iconColor),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(color: cc.mut),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: cc.fg,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.md,
        horizontal: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(color: cc.line),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: cc.mut),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            '$count',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
