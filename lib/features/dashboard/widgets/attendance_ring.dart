/// Attendance Ring Widget
///
/// A compact circular attendance-percentage indicator for the dashboard's
/// Academic Snapshot section. Shares its `CustomPainter` arc-drawing
/// approach with [OverallGauge] (attendance feature) at a smaller scale
/// suited to a stat-card slot rather than a full-screen hero gauge.
library;

import 'dart:math';

import 'package:college_companion/theme/cc_tokens.dart';
import 'package:flutter/material.dart';

/// A small ring showing the current attendance percentage.
///
/// [percentage] is the current attendance percentage (0-100). [isSafe]
/// determines whether the ring is drawn in the accent (on-track) or risk
/// (below target) color. When [hasData] is false (no attendance records
/// yet), the ring renders in a neutral muted tone with a "–" placeholder
/// instead of a risk-colored 0% — an empty history isn't the same as
/// failing attendance.
class AttendanceRing extends StatelessWidget {
  /// Creates an [AttendanceRing].
  const AttendanceRing({
    super.key,
    required this.percentage,
    required this.isSafe,
    this.hasData = true,
    this.size = 64,
  });

  /// Current attendance percentage (0-100).
  final double percentage;

  /// Whether the percentage is at or above the safe-bunk target.
  final bool isSafe;

  /// Whether any attendance records exist yet.
  final bool hasData;

  /// Diameter of the ring.
  final double size;

  @override
  Widget build(BuildContext context) {
    final cc = context.cc;
    final progress = hasData ? (percentage / 100.0).clamp(0.0, 1.0) : 0.0;
    final ringColor = !hasData ? cc.mut : (isSafe ? cc.pri : cc.risk);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                backgroundColor: cc.line,
                progressColor: ringColor,
                strokeWidth: size * 0.11,
              ),
            ),
          ),
          Text(
            hasData ? '${percentage.round()}%' : '–',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: ringColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
