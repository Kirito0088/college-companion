import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AttendanceTrendCard extends StatelessWidget {
  const AttendanceTrendCard({super.key});

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
            child: Stack(
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
                          painter: _TrendChartPainter(lineColor: cc.pri),
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
            ),
          ),
        ],
      ),
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

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({required this.lineColor});

  final Color lineColor;

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
      ..color = lineColor
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
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (final p in points) {
      final x = p.dx * size.width;
      final y = p.dy * size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}
