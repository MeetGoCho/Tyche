import '../../domain/entities/candle.dart';

class MomentumAnalyzer {
  double analyze(List<Candle> candles) {
    if (candles.length < 14) return 50.0;

    final closes = candles.map((c) => c.close).toList();

    double score = 50.0;

    // RSI 분석
    final rsi = _calculateRSI(closes, 14);
    if (rsi != null) {
      if (rsi < 30) {
        score += 20; // 과매도 -> 매수 기회
      } else if (rsi > 70) {
        score -= 20; // 과매수 -> 매도 고려
      } else if (rsi >= 40 && rsi <= 60) {
        score += 5; // 중립적
      }
    }

    // 모멘텀 (현재 가격 vs N일 전)
    if (closes.length >= 10) {
      final momentum = (closes.last - closes[closes.length - 10]) / closes[closes.length - 10];
      score += (momentum * 100).clamp(-15, 15);
    }

    // ROC (Rate of Change)
    if (closes.length >= 12) {
      final roc = ((closes.last - closes[closes.length - 12]) / closes[closes.length - 12]) * 100;
      if (roc > 0) {
        score += (roc / 2).clamp(0, 10);
      } else {
        score += (roc / 2).clamp(-10, 0);
      }
    }

    return score.clamp(0, 100);
  }

  double? _calculateRSI(List<double> prices, int period) {
    if (prices.length < period + 1) return null;

    List<double> gains = [];
    List<double> losses = [];

    for (int i = 1; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      if (change > 0) {
        gains.add(change);
        losses.add(0);
      } else {
        gains.add(0);
        losses.add(change.abs());
      }
    }

    if (gains.length < period) return null;

    double avgGain = 0;
    double avgLoss = 0;

    // 초기 평균 계산
    for (int i = 0; i < period; i++) {
      avgGain += gains[i];
      avgLoss += losses[i];
    }
    avgGain /= period;
    avgLoss /= period;

    // Smoothed RSI
    for (int i = period; i < gains.length; i++) {
      avgGain = (avgGain * (period - 1) + gains[i]) / period;
      avgLoss = (avgLoss * (period - 1) + losses[i]) / period;
    }

    if (avgLoss == 0) return 100;

    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }
}
