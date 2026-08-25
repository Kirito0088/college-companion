import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// This week's attendance trend, plotted from real records.
///
/// Takes its data as a parameter rather than watching a provider itself so
/// the chart stays trivially testable and the screen keeps a single point of
/// user id resolution.
class AttendanceTrendCard extends StatelessWidget {
  const AttendanceTrendCard({required this.trend, super.key});

  /// This week's per-weekday percentages, Monday-first.
  ///
  /// Deliberately the whole [AsyncValue] rather than a nullable trend: the
  /// card has four genuinely distinct things to say — still loading, failed
  /// to read, read successfully but the week had no lectures, and here is
  /// your curve. Device QA caught this card reporting a hard
  /// `no such table: attendance` failure as "Loading…" forever, because a
  /// nullable trend cannot tell a pending read apart from a failed one.
  final AsyncValue<AttendanceTrend> trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.base),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusXxl,
        border: Border.all(color: cc.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attendance Trend',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cc.fg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This Week',
                    style: theme.textTheme.labelLarge?.copyWith(color: cc.mut),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 4),
                  Icon(Symbols.expand_more_rounded, color: cc.mut, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xl),
          SizedBox(
            height: 160,
            child: switch (trend) {
              AsyncError() => _buildPlaceholder(
                context,
                cc,
                'Couldn’t load your trend',
                'Pull down to refresh and try again.',
              ),
              AsyncData(value: final t) when !t.hasData => _buildPlaceholder(
                context,
                cc,
                'Not enough data yet',
                'Mark attendance this week to see your trend.',
              ),
              AsyncData(value: final t) => _buildChart(context, cc, t),
              _ => _buildPlaceholder(context, cc, 'Loading…', null),
            },
          ),
        ],
      ),
    );
  }

  IconData get _placeholderIcon => switch (trend) {
    AsyncError() => Symbols.error_outline_rounded,
    _ => Symbols.timeline_rounded,
  };

  Widget _buildPlaceholder(
    BuildContext context,
    CCTokens cc,
    String title,
    String? subtitle,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_placeholderIcon, color: cc.mut, size: 32),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(color: cc.mut),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, CCTokens cc, AttendanceTrend trend) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 24,
          width: 32,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildYLabel(context, cc, '100%'),
                _buildYLabel(context, cc, '75%'),
                _buildYLabel(context, cc, '50%'),
                _buildYLabel(context, cc, '25%'),
                _buildYLabel(context, cc, '0%'),
              ],
            ),
          ),
        ),
        Positioned(
          left: 40,
          right: 0,
          top: 0,
          bottom: 0,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 24,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (_) {
                    return Container(height: 1, color: cc.line);
                  }),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 24,
                child: CustomPaint(
                  painter: TrendChartPainter(
                    lineColor: cc.pri,
                    percentages: trend.dailyPercentages,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final day in const [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ])
                      Flexible(child: _buildXLabel(context, cc, day)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYLabel(BuildContext context, CCTokens cc, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: cc.mut,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildXLabel(BuildContext context, CCTokens cc, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: cc.mut,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Plots one point per weekday from real attendance percentages.
///
/// Public (rather than library-private) so widget tests can assert the
/// painted data actually changes with the underlying records — see
/// `test/features/attendance/attendance_trend_test.dart`.
@visibleForTesting
class TrendChartPainter extends CustomPainter {
  TrendChartPainter({required this.lineColor, required this.percentages});

  final Color lineColor;

  /// Exactly 7 entries, Monday-first. `null` days are skipped, not plotted
  /// at 0% — a day with no lectures is not a day with no attendance.
  final List<double?> percentages;

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[];
    for (var i = 0; i < percentages.length; i++) {
      final pct = percentages[i];
      if (pct == null) continue;
      final x = percentages.length == 1
          ? 0.0
          : (i / (percentages.length - 1)) * size.width;
      final y = (1 - (pct.clamp(0.0, 100.0) / 100.0)) * size.height;
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (final p in points) {
      canvas.drawCircle(p, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TrendChartPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      !listEquals(oldDelegate.percentages, percentages);
}
