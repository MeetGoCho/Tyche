import '../../domain/entities/candle.dart';
import 'indicator_base.dart';

/// Momentum indicator
/// Measures the rate of change of price
class MomentumIndicator extends IndicatorBase {
  const MomentumIndicator({int period = 10})
      : super(name: 'MOM$period', period: period);

  @override
  List<double?> calculate(List<Candle> candles) {
    if (candles.length <= period) {
      return List.filled(candles.length, null);
    }

    final result = <double?>[];

    for (int i = 0; i < candles.length; i++) {
      if (i < period) {
        result.add(null);
      } else {
        // Momentum = Current Close - Close n periods ago
        result.add(candles[i].close - candles[i - period].close);
      }
    }

    return result;
  }
}

/// Rate of Change (ROC) indicator
/// Similar to momentum but expressed as a percentage
class ROCIndicator extends IndicatorBase {
  const ROCIndicator({int period = 10})
      : super(name: 'ROC$period', period: period);

  @override
  List<double?> calculate(List<Candle> candles) {
    if (candles.length <= period) {
      return List.filled(candles.length, null);
    }

    final result = <double?>[];

    for (int i = 0; i < candles.length; i++) {
      if (i < period) {
        result.add(null);
      } else {
        final previousClose = candles[i - period].close;
        if (previousClose == 0) {
          result.add(0);
        } else {
          // ROC = ((Current Close - Close n periods ago) / Close n periods ago) * 100
          result.add(((candles[i].close - previousClose) / previousClose) * 100);
        }
      }
    }

    return result;
  }
}

/// On Balance Volume (OBV) indicator
class OBVIndicator extends IndicatorBase {
  const OBVIndicator() : super(name: 'OBV', period: 1);

  @override
  List<double?> calculate(List<Candle> candles) {
    if (candles.isEmpty) {
      return [];
    }

    final result = <double?>[];
    double obv = 0;

    for (int i = 0; i < candles.length; i++) {
      if (i == 0) {
        obv = candles[i].volume;
      } else {
        if (candles[i].close > candles[i - 1].close) {
          obv += candles[i].volume;
        } else if (candles[i].close < candles[i - 1].close) {
          obv -= candles[i].volume;
        }
        // If close == previous close, OBV remains unchanged
      }
      result.add(obv);
    }

    return result;
  }
}

/// Average True Range (ATR) indicator
/// Measures market volatility
class ATRIndicator extends IndicatorBase {
  const ATRIndicator({int period = 14})
      : super(name: 'ATR$period', period: period);

  @override
  List<double?> calculate(List<Candle> candles) {
    if (candles.length < period) {
      return List.filled(candles.length, null);
    }

    final result = <double?>[];
    final trueRanges = <double>[];

    // Calculate True Range for each candle
    for (int i = 0; i < candles.length; i++) {
      double tr;
      if (i == 0) {
        tr = candles[i].high - candles[i].low;
      } else {
        final highLow = candles[i].high - candles[i].low;
        final highClose = (candles[i].high - candles[i - 1].close).abs();
        final lowClose = (candles[i].low - candles[i - 1].close).abs();
        tr = [highLow, highClose, lowClose].reduce((a, b) => a > b ? a : b);
      }
      trueRanges.add(tr);
    }

    // Calculate ATR using smoothed moving average
    for (int i = 0; i < candles.length; i++) {
      if (i < period - 1) {
        result.add(null);
      } else if (i == period - 1) {
        // First ATR is simple average
        double sum = 0;
        for (int j = 0; j < period; j++) {
          sum += trueRanges[j];
        }
        result.add(sum / period);
      } else {
        // Subsequent ATR uses smoothed average
        final prevAtr = result[i - 1]!;
        final atr = (prevAtr * (period - 1) + trueRanges[i]) / period;
        result.add(atr);
      }
    }

    return result;
  }
}
