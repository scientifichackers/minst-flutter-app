import 'package:flutter/material.dart';
import 'package:mnist_app/src/constants.dart';

class DrawingPainter extends CustomPainter {
  final List<Offset> offsetPoints;

  DrawingPainter({@required this.offsetPoints});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < offsetPoints.length - 1; i++) {
      if (offsetPoints[i] != null && offsetPoints[i + 1] != null) {
        canvas.drawLine(offsetPoints[i], offsetPoints[i + 1], kDrawingPaint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
