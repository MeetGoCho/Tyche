import '../../domain/entities/candle.dart';

class TrendAnalyzer {
  double analyze(List<Candle> candles) {
    if (candles.length < 50) return 50.0;

    final closes = candles.map((c) => c.close).toList();

    final sma20 = _calculateSMA(closes, 20);
    final sma50 = _calculateSMA(closes, 50);

    if (sma20.isEmpty || sma50.isEmpty) return 50.0;

    double score = 50.0;

    // 단기 MA > 장기 MA = 상승 추세
    if (sma20.last > sma50.last) {
      score += 15;
    } else {
      score -= 15;
    }

    // 가격이 MA 위에 있으면 가점
    if (closes.last > sma20.last) score += 10;
    if (closes.last > sma50.last) score += 10;

    // 추세 기울기 분석
    if (sma20.length >= 10) {
      final slope = _calculateSlope(sma20.sublist(sma20.length - 10));
      score += (slope * 1000).clamp(-15, 15);
    }

    return score.clamp(0, 100);
  }

  List<double> _calculateSMA(List<double> data, int period) {
    if (data.length < period) return [];

    final result = <double>[];
    for (int i = period - 1; i < data.length; i++) {
      double sum = 0;
      for (int j = i - period + 1; j <= i; j++) {
        sum += data[j];
      }
      result.add(sum / period);
    }
    return result;
  }

  double _calculateSlope(List<double> data) {
    if (data.length < 2) return 0;

    final n = data.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += data[i];
      sumXY += i * data[i];
      sumX2 += i * i;
    }

    final denominator = n * sumX2 - sumX * sumX;
    if (denominator == 0) return 0;

    return (n * sumXY - sumX * sumY) / denominator;
  }
}
