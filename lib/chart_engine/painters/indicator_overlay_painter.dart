import 'package:flutter/material.dart';
import '../core/chart_config.dart';
import '../core/chart_viewport.dart';

/// Painter for overlay indicators (MA, Bollinger Bands, etc.)
class IndicatorOverlayPainter extends CustomPainter {
  final ChartViewport viewport;
  final ChartTheme theme;
  final Map<String, List<double?>> indicators;
  final Map<String, Color> colors;

  IndicatorOverlayPainter({
    required this.viewport,
    required this.theme,
    required this.indicators,
    Map<String, Color>? colors,
  }) : colors = colors ?? _defaultColors;

  static const Map<String, Color> _defaultColors = {
    'SMA20': Color(0xFFFFEB3B),    // Yellow
    'SMA50': Color(0xFFFF9800),    // Orange
    'SMA200': Color(0xFF9C27B0),   // Purple
    'EMA20': Color(0xFF00BCD4),    // Cyan
    'BB_upper': Color(0xFF2196F3), // Blue
    'BB_middle': Color(0xFF2196F3),
    'BB_lower': Color(0xFF2196F3),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - 50; // Right margin for price axis
    final candleWidth = chartWidth / viewport.visibleCandleCount;

    for (final entry in indicators.entries) {
      final name = entry.key;
      final values = entry.value;
      final color = colors[name] ?? Colors.white;

      _drawIndicatorLine(
        canvas,
        size,
        values,
        color,
        candleWidth,
        isBand: name.startsWith('BB_'),
      );
    }

    // Draw Bollinger Bands fill if all three are present
    if (indicators.containsKey('BB_upper') &&
        indicators.containsKey('BB_middle') &&
        indicators.containsKey('BB_lower')) {
      _drawBollingerBandsFill(
        canvas,
        size,
        indicators['BB_upper']!,
        indicators['BB_lower']!,
        candleWidth,
      );
    }
  }

  void _drawIndicatorLine(
    Canvas canvas,
    Size size,
    List<double?> values,
    Color color,
    double candleWidth, {
    bool isBand = false,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = isBand ? 1.0 : 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool pathStarted = false;

    final startIdx = viewport.startIndexInt;
    final endIdx = viewport.endIndexInt;
    final priceRange = viewport.maxPrice - viewport.minPrice;

    if (priceRange == 0) return;

    for (int i = startIdx; i < endIdx && i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        pathStarted = false;
        continue;
      }

      final x = (i - startIdx + 0.5) * candleWidth;
      final y = size.height * (1 - (value - viewport.minPrice) / priceRange);

      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawBollingerBandsFill(
    Canvas canvas,
    Size size,
    List<double?> upper,
    List<double?> lower,
    double candleWidth,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF2196F3).withAlpha(25)
      ..style = PaintingStyle.fill;

    final path = Path();
    final startIdx = viewport.startIndexInt;
    final endIdx = viewport.endIndexInt;
    final priceRange = viewport.maxPrice - viewport.minPrice;

    if (priceRange == 0) return;

    // Find first valid point
    int firstValidIdx = -1;
    for (int i = startIdx; i < endIdx && i < upper.length; i++) {
      if (upper[i] != null && lower[i] != null) {
        firstValidIdx = i;
        break;
      }
    }

    if (firstValidIdx == -1) return;

    // Draw upper line forward
    final upperPoints = <Offset>[];
    final lowerPoints = <Offset>[];

    for (int i = firstValidIdx; i < endIdx && i < upper.length; i++) {
      if (upper[i] == null || lower[i] == null) continue;

      final x = (i - startIdx + 0.5) * candleWidth;
      final upperY = size.height * (1 - (upper[i]! - viewport.minPrice) / priceRange);
      final lowerY = size.height * (1 - (lower[i]! - viewport.minPrice) / priceRange);

      upperPoints.add(Offset(x, upperY));
      lowerPoints.add(Offset(x, lowerY));
    }

    if (upperPoints.isEmpty) return;

    // Create path: upper forward, lower backward
    path.moveTo(upperPoints.first.dx, upperPoints.first.dy);
    for (final point in upperPoints) {
      path.lineTo(point.dx, point.dy);
    }
    for (final point in lowerPoints.reversed) {
      path.lineTo(point.dx, point.dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IndicatorOverlayPainter oldDelegate) {
    return viewport != oldDelegate.viewport ||
        indicators != oldDelegate.indicators;
  }
}
