import 'dart:math';
import '../../domain/entities/candle.dart';

class VolatilityAnalyzer {
  double analyze(List<Candle> candles) {
    if (candles.length < 20) return 50.0;

    final closes = candles.map((c) => c.close).toList();

    double score = 50.0;

    // 볼린저 밴드 분석
    final bb = _calculateBollingerBands(closes, 20, 2);
    if (bb != null) {
      final currentPrice = closes.last;
      final percentB = (currentPrice - bb.lower) / (bb.upper - bb.lower);

      if (percentB < 0.2) {
        score += 15; // 하단 밴드 근처 - 매수 기회
      } else if (percentB > 0.8) {
        score -= 15; // 상단 밴드 근처 - 매도 고려
      }

      // 밴드 폭 분석 (변동성 축소/확대)
      final bandWidth = (bb.upper - bb.lower) / bb.middle;
      if (bandWidth < 0.05) {
        score += 10; // 변동성 축소 - 돌파 가능성
      }
    }

    // ATR 기반 변동성
    final atr = _calculateATR(candles, 14);
    if (atr != null) {
      final atrPercent = atr / closes.last * 100;
      if (atrPercent < 2) {
        score += 5; // 낮은 변동성
      } else if (atrPercent > 5) {
        score -= 5; // 높은 변동성 (리스크)
      }
    }

    return score.clamp(0, 100);
  }

  BollingerBands? _calculateBollingerBands(List<double> prices, int period, double stdDevMultiplier) {
    if (prices.length < period) return null;

    final recentPrices = prices.sublist(prices.length - period);

    // SMA
    final sma = recentPrices.reduce((a, b) => a + b) / period;

    // 표준편차
    double sumSquaredDiff = 0;
    for (final price in recentPrices) {
      sumSquaredDiff += pow(price - sma, 2);
    }
    final stdDev = sqrt(sumSquaredDiff / period);

    return BollingerBands(
      upper: sma + (stdDevMultiplier * stdDev),
      middle: sma,
      lower: sma - (stdDevMultiplier * stdDev),
    );
  }

  double? _calculateATR(List<Candle> candles, int period) {
    if (candles.length < period + 1) return null;

    List<double> trueRanges = [];

    for (int i = 1; i < candles.length; i++) {
      final current = candles[i];
      final previous = candles[i - 1];

      final tr1 = current.high - current.low;
      final tr2 = (current.high - previous.close).abs();
      final tr3 = (current.low - previous.close).abs();

      trueRanges.add([tr1, tr2, tr3].reduce(max));
    }

    if (trueRanges.length < period) return null;

    // 최근 period개의 TR 평균
    final recentTR = trueRanges.sublist(trueRanges.length - period);
    return recentTR.reduce((a, b) => a + b) / period;
  }
}

class BollingerBands {
  final double upper;
  final double middle;
  final double lower;

  BollingerBands({
    required this.upper,
    required this.middle,
    required this.lower,
  });
}
