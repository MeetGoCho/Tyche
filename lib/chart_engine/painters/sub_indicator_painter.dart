import 'package:flutter/material.dart';
import '../core/chart_config.dart';
import '../core/chart_viewport.dart';

/// Painter for sub-indicators (RSI, MACD, etc.) in separate panel
class SubIndicatorPainter extends CustomPainter {
  final ChartViewport viewport;
  final ChartTheme theme;
  final SubIndicatorType type;
  final Map<String, List<double?>> data;
  final double minValue;
  final double maxValue;

  SubIndicatorPainter({
    required this.viewport,
    required this.theme,
    required this.type,
    required this.data,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);

    switch (type) {
      case SubIndicatorType.rsi:
        _drawRSI(canvas, size);
        break;
      case SubIndicatorType.macd:
        _drawMACD(canvas, size);
        break;
      case SubIndicatorType.stochRsi:
        _drawStochasticRSI(canvas, size);
        break;
      case SubIndicatorType.momentum:
        _drawMomentum(canvas, size);
        break;
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Draw horizontal grid lines
    final paint = Paint()
      ..color = theme.gridColor
      ..strokeWidth = 0.5;

    final levels = _getLevels();
    final range = maxValue - minValue;
    if (range == 0) return;

    for (final level in levels) {
      final y = size.height * (1 - (level - minValue) / range);
      canvas.drawLine(Offset(0, y), Offset(size.width - 50, y), paint);

      // Draw level label
      final textPainter = TextPainter(
        text: TextSpan(
          text: level.toStringAsFixed(0),
          style: TextStyle(
            color: theme.textColor,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - 48, y - 6));
    }
  }

  List<double> _getLevels() {
    switch (type) {
      case SubIndicatorType.rsi:
      case SubIndicatorType.stochRsi:
        return [0, 30, 50, 70, 100];
      case SubIndicatorType.macd:
        return [minValue, 0, maxValue];
      case SubIndicatorType.momentum:
        return [minValue, 0, maxValue];
    }
  }

  void _drawRSI(Canvas canvas, Size size) {
    final rsi = data['rsi'];
    if (rsi == null) return;

    // Draw overbought/oversold zones
    _drawZone(canvas, size, 70, 100, Colors.red.withAlpha(30));
    _drawZone(canvas, size, 0, 30, Colors.green.withAlpha(30));

    // Draw RSI line
    _drawLine(canvas, size, rsi, const Color(0xFF9C27B0));
  }

  void _drawStochasticRSI(Canvas canvas, Size size) {
    final k = data['k'];
    final d = data['d'];

    // Draw overbought/oversold zones
    _drawZone(canvas, size, 80, 100, Colors.red.withAlpha(30));
    _drawZone(canvas, size, 0, 20, Colors.green.withAlpha(30));

    // Draw %K and %D lines
    if (k != null) _drawLine(canvas, size, k, const Color(0xFF2196F3));
    if (d != null) _drawLine(canvas, size, d, const Color(0xFFFF9800));
  }

  void _drawMACD(Canvas canvas, Size size) {
    final macd = data['macd'];
    final signal = data['signal'];
    final histogram = data['histogram'];

    // Draw histogram bars
    if (histogram != null) {
      _drawHistogram(canvas, size, histogram);
    }

    // Draw MACD and signal lines
    if (macd != null) _drawLine(canvas, size, macd, const Color(0xFF2196F3));
    if (signal != null) _drawLine(canvas, size, signal, const Color(0xFFFF9800));
  }

  void _drawMomentum(Canvas canvas, Size size) {
    final momentum = data['momentum'];
    if (momentum == null) return;

    // Draw zero line
    final range = maxValue - minValue;
    if (range > 0) {
      final zeroY = size.height * (1 - (0 - minValue) / range);
      final paint = Paint()
        ..color = theme.gridColor
        ..strokeWidth = 1;
      canvas.drawLine(Offset(0, zeroY), Offset(size.width - 50, zeroY), paint);
    }

    _drawLine(canvas, size, momentum, const Color(0xFF4CAF50));
  }

  void _drawZone(
    Canvas canvas,
    Size size,
    double low,
    double high,
    Color color,
  ) {
    final range = maxValue - minValue;
    if (range == 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTRB(
      0,
      size.height * (1 - (high - minValue) / range),
      size.width - 50,
      size.height * (1 - (low - minValue) / range),
    );

    canvas.drawRect(rect, paint);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double?> values,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool pathStarted = false;

    final chartWidth = size.width - 50;
    final candleWidth = chartWidth / viewport.visibleCandleCount;
    final startIdx = viewport.startIndexInt;
    final endIdx = viewport.endIndexInt;
    final range = maxValue - minValue;

    if (range == 0) return;

    for (int i = startIdx; i < endIdx && i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        pathStarted = false;
        continue;
      }

      final x = (i - startIdx + 0.5) * candleWidth;
      final y = size.height * (1 - (value - minValue) / range);

      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawHistogram(
    Canvas canvas,
    Size size,
    List<double?> values,
  ) {
    final chartWidth = size.width - 50;
    final candleWidth = chartWidth / viewport.visibleCandleCount;
    final startIdx = viewport.startIndexInt;
    final endIdx = viewport.endIndexInt;
    final range = maxValue - minValue;

    if (range == 0) return;

    final zeroY = size.height * (1 - (0 - minValue) / range);

    for (int i = startIdx; i < endIdx && i < values.length; i++) {
      final value = values[i];
      if (value == null) continue;

      final x = (i - startIdx) * candleWidth + candleWidth * 0.2;
      final barWidth = candleWidth * 0.6;
      final y = size.height * (1 - (value - minValue) / range);

      final paint = Paint()
        ..color = value >= 0 ? theme.upColor.withAlpha(180) : theme.downColor.withAlpha(180)
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTRB(
        x,
        value >= 0 ? y : zeroY,
        x + barWidth,
        value >= 0 ? zeroY : y,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SubIndicatorPainter oldDelegate) {
    return viewport != oldDelegate.viewport ||
        data != oldDelegate.data ||
        type != oldDelegate.type;
  }
}

enum SubIndicatorType {
  rsi,
  macd,
  stochRsi,
  momentum,
}
