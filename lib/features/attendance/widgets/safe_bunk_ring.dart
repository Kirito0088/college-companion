import 'dart:math';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class SafeBunkRing extends StatelessWidget {
  const SafeBunkRing({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(
        top: SpacingTokens.xxxl,
        bottom: SpacingTokens.xl,
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 250, // max-height 250px in HTML
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular Ring Painter
            SizedBox.expand(
              child: CustomPaint(
                painter: _BunkRingPainter(
                  progress: 0.82, // mapped to stroke-dasharray roughly
                  ringColor: const Color(0xFF8B5CF6), // primary variant purple
                  backgroundColor: ColorTokens.outlineVariant, // #1E293B
                ),
              ),
            ),
            // Inner Content
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
                      color: ColorTokens.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    '8',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: ColorTokens.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 72, // text-7xl
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'lectures',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'to stay above 75%',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ColorTokens.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
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
    // Matches the SVG stroke width scaling. HTML has stroke-width 3.8 on 40x40 viewBox.
    // 3.8 / 40 * 250 = ~23.75
    final strokeWidth = size.width * 0.095;
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * pi * progress;

    // Glow paint
    final glowPaint = Paint()
      ..color = ringColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // Draw glow once with reduced opacity for a softer, more premium look
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start at top
      sweepAngle,
      false,
      glowPaint,
    );

    // Foreground arc
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
