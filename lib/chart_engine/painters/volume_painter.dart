import 'package:flutter/material.dart';
import '../../domain/entities/candle.dart';
import '../core/chart_config.dart';
import '../core/chart_viewport.dart';

class VolumePainter extends CustomPainter {
  final List<Candle> candles;
  final ChartViewport viewport;
  final ChartTheme theme;

  VolumePainter({
    required this.candles,
    required this.viewport,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final visibleCandles = _getVisibleCandles();
    if (visibleCandles.isEmpty) return;

    final candleWidth = size.width / viewport.visibleCandleCount;
    final startOffset = (viewport.startIndex - viewport.startIndexInt) * candleWidth;

    for (int i = 0; i < visibleCandles.length; i++) {
      final candle = visibleCandles[i];
      final x = (i + 0.5) * candleWidth - startOffset;
      _drawVolumeBar(canvas, candle, x, candleWidth, size);
    }
  }

  List<Candle> _getVisibleCandles() {
    final start = viewport.startIndexInt;
    final end = viewport.endIndexInt;
    if (start >= candles.length) return [];
    return candles.sublist(start, end.clamp(0, candles.length));
  }

  void _drawVolumeBar(Canvas canvas, Candle candle, double x, double width, Size size) {
    final isUp = candle.isBullish;
    final color = isUp ? theme.volumeUpColor : theme.volumeDownColor;

    final barHeight = _volumeToHeight(candle.volume, size);
    final barWidth = (width * 0.6).clamp(2.0, 15.0);

    final rect = Rect.fromLTRB(
      x - barWidth / 2,
      size.height - barHeight,
      x + barWidth / 2,
      size.height,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  double _volumeToHeight(double volume, Size size) {
    final range = viewport.maxVolume - viewport.minVolume;
    if (range == 0) return 0;
    return size.height * (volume - viewport.minVolume) / range;
  }

  @override
  bool shouldRepaint(VolumePainter oldDelegate) {
    return candles != oldDelegate.candles ||
        viewport.startIndex != oldDelegate.viewport.startIndex ||
        viewport.endIndex != oldDelegate.viewport.endIndex;
  }
}
