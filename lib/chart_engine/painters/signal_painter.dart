import 'package:flutter/material.dart';
import '../../domain/entities/signal_point.dart';
import '../../core/theme/app_colors.dart';
import '../core/chart_viewport.dart';

/// Painter for displaying trading signals on the chart
class SignalPainter extends CustomPainter {
  final ChartViewport viewport;
  final List<SignalPoint> signals;
  final int totalCandles;
  final int recentThreshold;

  SignalPainter({
    required this.viewport,
    required this.signals,
    required this.totalCandles,
    this.recentThreshold = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (signals.isEmpty) return;

    final chartWidth = size.width - 50; // Right margin for price axis
    final candleWidth = chartWidth / viewport.visibleCandleCount;
    final startIdx = viewport.startIndexInt;
    final endIdx = viewport.endIndexInt;

    for (final signal in signals) {
      // Only draw signals in visible range
      if (signal.candleIndex < startIdx || signal.candleIndex >= endIdx) {
        continue;
      }

      final x = (signal.candleIndex - startIdx + 0.5) * candleWidth;
      final isRecent = signal.isRecentFrom(totalCandles, threshold: recentThreshold);

      if (signal.isBuy) {
        if (isRecent) {
          _drawRecentBuySignal(canvas, x, size.height, signal.confidence);
        } else {
          _drawBuyArrow(canvas, x, size.height, signal.confidence);
        }
      } else {
        if (isRecent) {
          _drawRecentSellSignal(canvas, x, 0, signal.confidence);
        } else {
          _drawSellArrow(canvas, x, 0, signal.confidence);
        }
      }
    }
  }

  /// Draw buy arrow (pointing up) at bottom of chart
  void _drawBuyArrow(Canvas canvas, double x, double bottom, double confidence) {
    final opacity = _getOpacityFromConfidence(confidence);
    final paint = Paint()
      ..color = AppColors.bullish.withAlpha((opacity * 255).round())
      ..style = PaintingStyle.fill;

    final path = Path();
    final y = bottom - 25;
    const arrowSize = 12.0;

    // Arrow pointing up
    path.moveTo(x, y - arrowSize);
    path.lineTo(x - arrowSize / 2, y);
    path.lineTo(x - arrowSize / 4, y);
    path.lineTo(x - arrowSize / 4, y + arrowSize / 2);
    path.lineTo(x + arrowSize / 4, y + arrowSize / 2);
    path.lineTo(x + arrowSize / 4, y);
    path.lineTo(x + arrowSize / 2, y);
    path.close();

    canvas.drawPath(path, paint);
  }

  /// Draw sell arrow (pointing down) at top of chart
  void _drawSellArrow(Canvas canvas, double x, double top, double confidence) {
    final opacity = _getOpacityFromConfidence(confidence);
    final paint = Paint()
      ..color = AppColors.bearish.withAlpha((opacity * 255).round())
      ..style = PaintingStyle.fill;

    final path = Path();
    final y = top + 25;
    const arrowSize = 12.0;

    // Arrow pointing down
    path.moveTo(x, y + arrowSize);
    path.lineTo(x - arrowSize / 2, y);
    path.lineTo(x - arrowSize / 4, y);
    path.lineTo(x - arrowSize / 4, y - arrowSize / 2);
    path.lineTo(x + arrowSize / 4, y - arrowSize / 2);
    path.lineTo(x + arrowSize / 4, y);
    path.lineTo(x + arrowSize / 2, y);
    path.close();

    canvas.drawPath(path, paint);
  }

  /// Draw recent buy signal (circle) at bottom of chart
  void _drawRecentBuySignal(Canvas canvas, double x, double bottom, double confidence) {
    final y = bottom - 30;
    const radius = 10.0;

    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.bullish.withAlpha(50)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), radius + 4, glowPaint);

    // Main circle
    final paint = Paint()
      ..color = AppColors.bullish
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), radius, paint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(100)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x - 2, y - 2), radius / 3, highlightPaint);

    // Confidence text
    _drawConfidenceText(canvas, x, y, confidence.round());
  }

  /// Draw recent sell signal (circle) at top of chart
  void _drawRecentSellSignal(Canvas canvas, double x, double top, double confidence) {
    final y = top + 30;
    const radius = 10.0;

    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.bearish.withAlpha(50)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), radius + 4, glowPaint);

    // Main circle
    final paint = Paint()
      ..color = AppColors.bearish
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), radius, paint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(100)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x - 2, y - 2), radius / 3, highlightPaint);

    // Confidence text
    _drawConfidenceText(canvas, x, y, confidence.round());
  }

  void _drawConfidenceText(Canvas canvas, double x, double y, int confidence) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$confidence',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  double _getOpacityFromConfidence(double confidence) {
    // Map confidence 50-100 to opacity 0.5-1.0
    return 0.5 + (confidence - 50) / 100;
  }

  @override
  bool shouldRepaint(covariant SignalPainter oldDelegate) {
    return viewport != oldDelegate.viewport ||
        signals != oldDelegate.signals ||
        totalCandles != oldDelegate.totalCandles;
  }
}
