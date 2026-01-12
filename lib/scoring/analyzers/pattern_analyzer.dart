import '../../domain/entities/candle.dart';

class PatternAnalyzer {
  double analyze(List<Candle> candles) {
    if (candles.length < 10) return 50.0;

    double score = 50.0;

    // 최근 캔들 패턴 분석
    final recentCandles = candles.sublist(candles.length - 5);

    // 연속 상승/하락 분석
    int consecutiveBullish = 0;
    int consecutiveBearish = 0;

    for (final candle in recentCandles.reversed) {
      if (candle.isBullish) {
        if (consecutiveBearish == 0) {
          consecutiveBullish++;
        } else {
          break;
        }
      } else {
        if (consecutiveBullish == 0) {
          consecutiveBearish++;
        } else {
          break;
        }
      }
    }

    if (consecutiveBullish >= 3) {
      score += 10;
    } else if (consecutiveBearish >= 3) {
      score -= 10;
    }

    // 도지 패턴 (반전 신호)
    final lastCandle = candles.last;
    if (_isDoji(lastCandle)) {
      // 이전 추세에 따라 반전 신호
      final prevCandle = candles[candles.length - 2];
      if (prevCandle.isBearish) {
        score += 5; // 하락 후 도지 - 반전 가능
      } else {
        score -= 5; // 상승 후 도지 - 조정 가능
      }
    }

    // 망치형/역망치형 패턴
    if (_isHammer(lastCandle)) {
      score += 10;
    } else if (_isInvertedHammer(lastCandle)) {
      score += 5;
    }

    // 장악형 패턴
    if (candles.length >= 2) {
      final prev = candles[candles.length - 2];
      final curr = candles.last;

      if (_isBullishEngulfing(prev, curr)) {
        score += 15;
      } else if (_isBearishEngulfing(prev, curr)) {
        score -= 15;
      }
    }

    return score.clamp(0, 100);
  }

  bool _isDoji(Candle candle) {
    final bodySize = candle.bodySize;
    final range = candle.range;
    if (range == 0) return false;
    return bodySize / range < 0.1;
  }

  bool _isHammer(Candle candle) {
    final bodySize = candle.bodySize;
    final range = candle.range;
    if (range == 0 || bodySize == 0) return false;

    final lowerWick = candle.lowerWick;
    final upperWick = candle.upperWick;

    return lowerWick > bodySize * 2 && upperWick < bodySize * 0.5;
  }

  bool _isInvertedHammer(Candle candle) {
    final bodySize = candle.bodySize;
    final range = candle.range;
    if (range == 0 || bodySize == 0) return false;

    final lowerWick = candle.lowerWick;
    final upperWick = candle.upperWick;

    return upperWick > bodySize * 2 && lowerWick < bodySize * 0.5;
  }

  bool _isBullishEngulfing(Candle prev, Candle curr) {
    return prev.isBearish &&
        curr.isBullish &&
        curr.open < prev.close &&
        curr.close > prev.open;
  }

  bool _isBearishEngulfing(Candle prev, Candle curr) {
    return prev.isBullish &&
        curr.isBearish &&
        curr.open > prev.close &&
        curr.close < prev.open;
  }
}
