import '../../domain/entities/candle.dart';
import 'indicator_base.dart';
import 'moving_average.dart';

/// Relative Strength Index (RSI) indicator
class RSIIndicator extends IndicatorBase {
  const RSIIndicator({int period = 14})
      : super(name: 'RSI$period', period: period);

  @override
  List<double?> calculate(List<Candle> candles) {
    if (candles.length < period + 1) {
      return List.filled(candles.length, null);
    }

    final result = <double?>[];
    final gains = <double>[];
    final losses = <double>[];

    // Calculate price changes
    for (int i = 1; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);
    }

    // First RSI value needs period candles
    result.add(null); // For first candle (no previous)

    // Calculate first average gain/loss
    double avgGain = 0;
    double avgLoss = 0;

    for (int i = 0; i < period; i++) {
      avgGain += gains[i];
      avgLoss += losses[i];
      result.add(null);
    }
    avgGain /= period;
    avgLoss /= period;

    // First RSI
    if (avgLoss == 0) {
      result[period] = 100;
    } else {
      final rs = avgGain / avgLoss;
      result[period] = 100 - (100 / (1 + rs));
    }

    // Subsequent RSI values using smoothed averages
    for (int i = period; i < gains.length; i++) {
      avgGain = (avgGain * (period - 1) + gains[i]) / period;
      avgLoss = (avgLoss * (period - 1) + losses[i]) / period;

      if (avgLoss == 0) {
        result.add(100);
      } else {
        final rs = avgGain / avgLoss;
        result.add(100 - (100 / (1 + rs)));
      }
    }

    return result;
  }

  /// Calculate RSI from a list of close prices
  static List<double?> calculateFromPrices(List<double> prices, int period) {
    if (prices.length < period + 1) {
      return List.filled(prices.length, null);
    }

    final result = <double?>[];
    final gains = <double>[];
    final losses = <double>[];

    for (int i = 1; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);
    }

    result.add(null);

    double avgGain = 0;
    double avgLoss = 0;

    for (int i = 0; i < period; i++) {
      avgGain += gains[i];
      avgLoss += losses[i];
      result.add(null);
    }
    avgGain /= period;
    avgLoss /= period;

    if (avgLoss == 0) {
      result[period] = 100;
    } else {
      final rs = avgGain / avgLoss;
      result[period] = 100 - (100 / (1 + rs));
    }

    for (int i = period; i < gains.length; i++) {
      avgGain = (avgGain * (period - 1) + gains[i]) / period;
      avgLoss = (avgLoss * (period - 1) + losses[i]) / period;

      if (avgLoss == 0) {
        result.add(100);
      } else {
        final rs = avgGain / avgLoss;
        result.add(100 - (100 / (1 + rs)));
      }
    }

    return result;
  }
}

/// Stochastic RSI indicator
class StochasticRSIIndicator extends IndicatorBase {
  final int kPeriod;
  final int dPeriod;

  const StochasticRSIIndicator({
    int period = 14,
    this.kPeriod = 14,
    this.dPeriod = 3,
  }) : super(name: 'StochRSI($period, $kPeriod, $dPeriod)', period: period);

  @override
  List<double?> calculate(List<Candle> candles) {
    // Returns %K line; use calculateAll for both lines
    return calculateAll(candles).k;
  }

  StochasticRSIResult calculateAll(List<Candle> candles) {
    final rsi = RSIIndicator(period: period).calculate(candles);

    // Calculate Stochastic of RSI
    final k = <double?>[];

    for (int i = 0; i < rsi.length; i++) {
      if (i < period + kPeriod - 1 || rsi[i] == null) {
        k.add(null);
        continue;
      }

      // Find min and max RSI in lookback period
      double minRsi = double.infinity;
      double maxRsi = double.negativeInfinity;

      bool hasNull = false;
      for (int j = i - kPeriod + 1; j <= i; j++) {
        if (rsi[j] == null) {
          hasNull = true;
          break;
        }
        minRsi = minRsi < rsi[j]! ? minRsi : rsi[j]!;
        maxRsi = maxRsi > rsi[j]! ? maxRsi : rsi[j]!;
      }

      if (hasNull) {
        k.add(null);
        continue;
      }

      final range = maxRsi - minRsi;
      if (range == 0) {
        k.add(50); // Middle value when range is 0
      } else {
        k.add(((rsi[i]! - minRsi) / range) * 100);
      }
    }

    // Calculate %D (SMA of %K)
    final kValues = k.whereType<double>().toList();
    final dValues = SMAIndicator.calculateFromValues(
      kValues.map((v) => v).toList(),
      dPeriod,
    );

    // Align %D with original length
    final d = <double?>[];
    int dIndex = 0;
    for (int i = 0; i < k.length; i++) {
      if (k[i] == null) {
        d.add(null);
      } else {
        d.add(dValues[dIndex]);
        dIndex++;
      }
    }

    return StochasticRSIResult(k: k, d: d);
  }
}

class StochasticRSIResult {
  final List<double?> k;
  final List<double?> d;

  const StochasticRSIResult({
    required this.k,
    required this.d,
  });
}
