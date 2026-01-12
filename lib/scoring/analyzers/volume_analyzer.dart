import '../../domain/entities/candle.dart';

class VolumeAnalyzer {
  double analyze(List<Candle> candles) {
    if (candles.length < 20) return 50.0;

    double score = 50.0;

    // 거래량 이동평균 분석
    final volumes = candles.map((c) => c.volume).toList();
    final volumeMA = _calculateSMA(volumes, 20);

    if (volumeMA.isNotEmpty) {
      final currentVolume = volumes.last;
      final avgVolume = volumeMA.last;

      // 현재 거래량이 평균보다 높으면 신호 강화
      final volumeRatio = currentVolume / avgVolume;

      if (volumeRatio > 2) {
        // 거래량 급증
        final lastCandle = candles.last;
        if (lastCandle.isBullish) {
          score += 20; // 상승 + 거래량 급증
        } else {
          score -= 10; // 하락 + 거래량 급증
        }
      } else if (volumeRatio > 1.5) {
        final lastCandle = candles.last;
        if (lastCandle.isBullish) {
          score += 10;
        } else {
          score -= 5;
        }
      } else if (volumeRatio < 0.5) {
        score -= 5; // 거래량 부족
      }
    }

    // OBV (On Balance Volume) 추세
    final obv = _calculateOBV(candles);
    if (obv.length >= 20) {
      final obvMA = _calculateSMA(obv, 20);
      if (obvMA.isNotEmpty && obv.last > obvMA.last) {
        score += 10; // OBV 상승 추세
      } else if (obvMA.isNotEmpty && obv.last < obvMA.last) {
        score -= 10; // OBV 하락 추세
      }
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

  List<double> _calculateOBV(List<Candle> candles) {
    if (candles.isEmpty) return [];

    List<double> obv = [0];

    for (int i = 1; i < candles.length; i++) {
      final current = candles[i];
      final previous = candles[i - 1];

      if (current.close > previous.close) {
        obv.add(obv.last + current.volume);
      } else if (current.close < previous.close) {
        obv.add(obv.last - current.volume);
      } else {
        obv.add(obv.last);
      }
    }

    return obv;
  }
}
