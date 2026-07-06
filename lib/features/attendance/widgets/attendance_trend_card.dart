import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AttendanceTrendCard extends StatelessWidget {
  const AttendanceTrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.base),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Trend',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.onSurface,
                ),
              ),
              Row(
                children: [
                  Text(
                    'This Week',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Symbols.expand_more_rounded,
                    color: ColorTokens.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xl),
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 24,
                  width: 32,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildYLabel(context, '100%'),
                      _buildYLabel(context, '75%'),
                      _buildYLabel(context, '50%'),
                      _buildYLabel(context, '25%'),
                      _buildYLabel(context, '0%'),
                    ],
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
                            return Container(
                              height: 1,
                              color: ColorTokens.outlineVariant.withValues(
                                alpha: 0.1,
                              ),
                            );
                          }),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 24,
                        child: CustomPaint(painter: _TrendChartPainter()),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildXLabel(context, 'Mon'),
                            _buildXLabel(context, 'Tue'),
                            _buildXLabel(context, 'Wed'),
                            _buildXLabel(context, 'Thu'),
                            _buildXLabel(context, 'Fri'),
                            _buildXLabel(context, 'Sat'),
                            _buildXLabel(context, 'Sun'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: ColorTokens.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildXLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: ColorTokens.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const points = [
      Offset(0, 0.5),
      Offset(0.16, 0.6),
      Offset(0.33, 0.55),
      Offset(0.50, 0.65),
      Offset(0.66, 0.40),
      Offset(0.83, 0.45),
      Offset(1.0, 0.45),
    ];

    final paint = Paint()
      ..color = ColorTokens.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final x = p.dx * size.width;
      final y = p.dy * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = ColorTokens.primary
      ..style = PaintingStyle.fill;

    for (final p in points) {
      final x = p.dx * size.width;
      final y = p.dy * size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
