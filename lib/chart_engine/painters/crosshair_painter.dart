import 'package:flutter/material.dart';
import '../core/chart_config.dart';

class CrosshairPainter extends CustomPainter {
  final Offset position;
  final ChartTheme theme;
  final String? priceLabel;
  final String? timeLabel;

  CrosshairPainter({
    required this.position,
    required this.theme,
    this.priceLabel,
    this.timeLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.crosshairColor.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    // 수평선
    canvas.drawLine(
      Offset(0, position.dy),
      Offset(size.width, position.dy),
      paint,
    );

    // 수직선
    canvas.drawLine(
      Offset(position.dx, 0),
      Offset(position.dx, size.height),
      paint,
    );

    // 교차점 원
    final circlePaint = Paint()
      ..color = theme.crosshairColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 4, circlePaint);

    // 가격 라벨
    if (priceLabel != null) {
      _drawLabel(
        canvas,
        priceLabel!,
        Offset(size.width - 60, position.dy - 10),
        size,
      );
    }

    // 시간 라벨
    if (timeLabel != null) {
      _drawLabel(
        canvas,
        timeLabel!,
        Offset(position.dx - 30, size.height - 20),
        size,
      );
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset position, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: theme.textColor,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final bgRect = Rect.fromLTWH(
      position.dx - 2,
      position.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    final bgPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(2)),
      bgPaint,
    );

    textPainter.paint(canvas, Offset(position.dx + 2, position.dy));
  }

  @override
  bool shouldRepaint(CrosshairPainter oldDelegate) {
    return position != oldDelegate.position ||
        priceLabel != oldDelegate.priceLabel ||
        timeLabel != oldDelegate.timeLabel;
  }
}
