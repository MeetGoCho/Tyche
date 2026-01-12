import 'package:flutter/material.dart';
import '../core/chart_config.dart';
import '../core/chart_viewport.dart';

class GridPainter extends CustomPainter {
  final ChartViewport viewport;
  final ChartTheme theme;
  final int horizontalLines;
  final int verticalLines;

  GridPainter({
    required this.viewport,
    required this.theme,
    this.horizontalLines = 5,
    this.verticalLines = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.gridColor
      ..strokeWidth = 0.5;

    // 수평선 (가격 레벨)
    for (int i = 0; i <= horizontalLines; i++) {
      final y = size.height * i / horizontalLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 수직선 (시간 레벨)
    for (int i = 0; i <= verticalLines; i++) {
      final x = size.width * i / verticalLines;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}
