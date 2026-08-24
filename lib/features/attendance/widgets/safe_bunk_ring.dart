import 'dart:math';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class SafeBunkRing extends StatelessWidget {
  const SafeBunkRing({super.key, this.safeBunk});

  final SafeBunkResult? safeBunk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    final hasData = safeBunk != null;
    final isSafe = !hasData || safeBunk!.safeBunks > 0;
    final ringColor = isSafe ? cc.pri : cc.risk;
    // Ring visualizes how much of the safe-bunk margin remains, not raw
    // attendance percentage — 0 margin (must-attend state) draws an empty ring.
    final progress = hasData
        ? (safeBunk!.safeBunks / (safeBunk!.safeBunks + 1)).clamp(0.0, 1.0)
        : 0.0;
    final safeBunksText = hasData ? '${safeBunk!.safeBunks}' : '–';

    return Container(
      padding: const EdgeInsets.only(
        top: SpacingTokens.xxxl,
        bottom: SpacingTokens.xl,
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CustomPaint(
                painter: _BunkRingPainter(
                  progress: progress,
                  ringColor: ringColor,
                  backgroundColor: cc.line,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'can bunk',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cc.mut,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    safeBunksText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: cc.fg,
                      fontWeight: FontWeight.bold,
                      fontSize: 72,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'lectures',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(color: cc.mut),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    hasData
                        ? 'to stay above ${safeBunk!.targetPercentage.round()}%'
                        : 'Loading...',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cc.mut.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BunkRingPainter extends CustomPainter {
  _BunkRingPainter({
    required this.progress,
    required this.ringColor,
    required this.backgroundColor,
  });

  final double progress;
  final Color ringColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.095;
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * pi * progress;

    final glowPaint = Paint()
      ..color = ringColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    final fgPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BunkRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
