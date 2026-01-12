import 'package:flutter/material.dart';
import '../../domain/entities/candle.dart';
import '../core/chart_config.dart';
import '../core/chart_viewport.dart';

class CandlestickPainter extends CustomPainter {
  final List<Candle> candles;
  final ChartViewport viewport;
  final ChartTheme theme;

  CandlestickPainter({
    required this.candles,
    required this.viewport,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final visibleCandles = _getVisibleCandles();
    if (visibleCandles.isEmpty) return;

    final candleWidth = _calculateCandleWidth(size, visibleCandles.length);
    final startOffset = (viewport.startIndex - viewport.startIndexInt) * candleWidth;

    for (int i = 0; i < visibleCandles.length; i++) {
      final candle = visibleCandles[i];
      final x = (i + 0.5) * candleWidth - startOffset;
      _drawCandle(canvas, candle, x, candleWidth, size);
    }
  }

  List<Candle> _getVisibleCandles() {
    final start = viewport.startIndexInt;
    final end = viewport.endIndexInt;
    if (start >= candles.length) return [];
    return candles.sublist(start, end.clamp(0, candles.length));
  }

  double _calculateCandleWidth(Size size, int count) {
    if (count == 0) return 0;
    return size.width / viewport.visibleCandleCount;
  }

  void _drawCandle(Canvas canvas, Candle candle, double x, double width, Size size) {
    final isUp = candle.isBullish;
    final color = isUp ? theme.upColor : theme.downColor;

    final bodyTop = _priceToY(isUp ? candle.close : candle.open, size);
    final bodyBottom = _priceToY(isUp ? candle.open : candle.close, size);
    final wickTop = _priceToY(candle.high, size);
    final wickBottom = _priceToY(candle.low, size);

    // 심지 (Wick)
    final wickPaint = Paint()
      ..color = color
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(x, wickTop),
      Offset(x, wickBottom),
      wickPaint,
    );

    // 몸통 (Body)
    final bodyWidth = (width * 0.8).clamp(2.0, 20.0);
    final bodyRect = Rect.fromLTRB(
      x - bodyWidth / 2,
      bodyTop,
      x + bodyWidth / 2,
      bodyBottom.clamp(bodyTop + 1, size.height),
    );

    final bodyPaint = Paint()
      ..color = color
      ..style = isUp ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 1;

    canvas.drawRect(bodyRect, bodyPaint);
  }

  double _priceToY(double price, Size size) {
    final range = viewport.maxPrice - viewport.minPrice;
    if (range == 0) return size.height / 2;
    return size.height * (1 - (price - viewport.minPrice) / range);
  }

  @override
  bool shouldRepaint(CandlestickPainter oldDelegate) {
    return candles != oldDelegate.candles ||
        viewport.startIndex != oldDelegate.viewport.startIndex ||
        viewport.endIndex != oldDelegate.viewport.endIndex;
  }
}
