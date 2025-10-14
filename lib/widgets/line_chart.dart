import 'package:flutter/material.dart';
import 'dart:math';

class LineChart extends StatelessWidget {
  final List<double> points;
  final Color lineColor;

  const LineChart({super.key, required this.points, this.lineColor = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(points, lineColor),
      size: const Size(double.infinity, 80),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;

  _LineChartPainter(this.points, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    final minY = points.reduce(min);
    final maxY = points.reduce(max);
    final range = (maxY - minY).abs() < 1 ? 1.0 : maxY - minY;

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - ((points[i] - minY) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.lineColor != lineColor;
}
