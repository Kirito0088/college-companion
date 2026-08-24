import 'dart:math';

import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OverallGauge extends StatelessWidget {
  const OverallGauge({super.key, this.safeBunk});

  final SafeBunkResult? safeBunk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final pct = safeBunk != null ? safeBunk!.currentPercentage : 0.0;
    final progress = (pct / 100.0).clamp(0.0, 1.0);
    final pctText = safeBunk != null ? '${pct.round()}%' : '–';
    final isSafe =
        safeBunk == null ||
        safeBunk!.total == 0 ||
        safeBunk!.currentPercentage >= safeBunk!.targetPercentage;
    final badgeColor = isSafe ? cc.pri : cc.risk;
    final badgeText = safeBunk != null
        ? (safeBunk!.safeBunks > 0
              ? 'You can miss ${safeBunk!.safeBunks} lectures'
              : (safeBunk!.mustAttend > 0
                    ? 'Must attend ${safeBunk!.mustAttend} lectures'
                    : 'On target (${safeBunk!.targetPercentage.round()}%)'))
        : 'Loading...';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xl),
      child: Center(
        child: GestureDetector(
          onTap: () {
            context.push(RoutePaths.safeBunk);
          },
          child: SizedBox(
            width: 192,
            height: 192,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GaugePainter(
                      progress: progress,
                      backgroundColor: cc.line,
                      progressColor: badgeColor,
                      strokeWidth: 12,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pctText,
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: cc.fg,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          letterSpacing: -2.0,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        'Overall Attendance',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: cc.mut,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
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
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
