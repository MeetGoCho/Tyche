import '../../domain/entities/candle.dart';
import 'indicator_base.dart';

/// Simple Moving Average (SMA) indicator
class SMAIndicator extends IndicatorBase {
  const SMAIndicator({int period = 20})
      : super(name: 'SMA$period', period: period);

  @override
  List<double?> calculate(List<Candle> candles) {
    if (candles.length < period) {
      return List.filled(candles.length, null);
    }

    final result = <double?>[];

    for (int i = 0; i < candles.length; i++) {
      if (i < period - 1) {
        result.add(null);
      } else {
        double sum = 0;
        for (int j = i - period + 1; j <= i; j++) {
          sum += candles[j].close;
        }
        result.add(sum / period);
      }
    }

    return result;
  }

  /// Static helper to calculate SMA from a list of values
  static List<double?> calculateFromValues(List<double> values, int period) {
    if (values.length < period) {
      return List.filled(values.length, null);
    }

    final result = <double?>[];

    for (int i = 0; i < values.length; i++) {
      if (i < period - 1) {
        result.add(null);
      } else {
        double sum = 0;
        for (int j = i - period + 1; j <= i; j++) {
          sum += values[j];
        }
        result.add(sum / period);
      }
    }

    return result;
  }
}

/// Exponential Moving Average (EMA) indicator
class EMAIndicator extends IndicatorBase {
  const EMAIndicator({int period = 20})
      : super(name: 'EMA$period', period: period);

  @override
  List<double?> calculate(List<Candle> candles) {
    if (candles.length < period) {
      return List.filled(candles.length, null);
    }

    final result = <double?>[];
    final multiplier = 2 / (period + 1);

    // First EMA is SMA
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += candles[i].close;
      result.add(null);
    }
    result[period - 1] = sum / period;

    // Calculate EMA for remaining candles
    for (int i = period; i < candles.length; i++) {
      final prevEma = result[i - 1]!;
      final ema = (candles[i].close - prevEma) * multiplier + prevEma;
      result.add(ema);
    }

    return result;
  }

  /// Static helper to calculate EMA from a list of values
  static List<double?> calculateFromValues(List<double> values, int period) {
    if (values.length < period) {
      return List.filled(values.length, null);
    }

    final result = <double?>[];
    final multiplier = 2 / (period + 1);

    // First EMA is SMA
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += values[i];
      result.add(null);
    }
    result[period - 1] = sum / period;

    // Calculate EMA for remaining values
    for (int i = period; i < values.length; i++) {
      final prevEma = result[i - 1]!;
      final ema = (values[i] - prevEma) * multiplier + prevEma;
      result.add(ema);
    }

    return result;
  }
}

/// Helper class to calculate multiple moving averages at once
class MovingAverageCalculator {
  final List<Candle> candles;

  MovingAverageCalculator(this.candles);

  Map<String, List<double?>> calculateSMAs(List<int> periods) {
    final result = <String, List<double?>>{};

    for (final period in periods) {
      final sma = SMAIndicator(period: period);
      result['SMA$period'] = sma.calculate(candles);
    }

    return result;
  }

  Map<String, List<double?>> calculateEMAs(List<int> periods) {
    final result = <String, List<double?>>{};

    for (final period in periods) {
      final ema = EMAIndicator(period: period);
      result['EMA$period'] = ema.calculate(candles);
    }

    return result;
  }
}
