import 'dart:math';

import 'package:flutter/material.dart';
class IntradayChart extends StatelessWidget {
  final List<double> points;
  const IntradayChart({required this.points});


  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Theme.of(context).cardColor),
        child: CustomPaint(
          painter: _LineChartPainter(points),
          child: Container(),
        ),
      ),
    );
  }
}


class _LineChartPainter extends CustomPainter {
  final List<double> points;
  _LineChartPainter(this.points);


  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;


    final minP = points.reduce(min);
    final maxP = points.reduce(max);
    final scale = (maxP - minP) == 0 ? 1.0 : (maxP - minP);


    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - ((points[i] - minP) / scale) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }


// choose color based on trend
    paintLine.color = points.last >= points.first ? Colors.green : Colors.red;
    canvas.drawPath(path, paintLine);
  }


  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.points != points;
}