import 'dart:math';
import '../../domain/entities/candle.dart';
import 'indicator_base.dart';

/// Bollinger Bands indicator
/// Consists of middle band (SMA), upper band (SMA + k*σ), lower band (SMA - k*σ)
class BollingerBandsIndicator extends IndicatorBase {
  final double standardDeviations;

  const BollingerBandsIndicator({
    int period = 20,
    this.standardDeviations = 2.0,
  }) : super(name: 'BB($period, $standardDeviations)', period: period);

  @override
  List<double?> calculate(List<Candle> candles) {
    // This returns middle band only; use calculateAll for full result
    return calculateAll(candles).middle;
  }

  BollingerBandsResult calculateAll(List<Candle> candles) {
    if (candles.length < period) {
      return BollingerBandsResult(
        upper: List.filled(candles.length, null),
        middle: List.filled(candles.length, null),
        lower: List.filled(candles.length, null),
      );
    }

    final upper = <double?>[];
    final middle = <double?>[];
    final lower = <double?>[];

    for (int i = 0; i < candles.length; i++) {
      if (i < period - 1) {
        upper.add(null);
        middle.add(null);
        lower.add(null);
      } else {
        // Calculate SMA
        double sum = 0;
        for (int j = i - period + 1; j <= i; j++) {
          sum += candles[j].close;
        }
        final sma = sum / period;

        // Calculate standard deviation
        double variance = 0;
        for (int j = i - period + 1; j <= i; j++) {
          variance += pow(candles[j].close - sma, 2);
        }
        final stdDev = sqrt(variance / period);

        middle.add(sma);
        upper.add(sma + standardDeviations * stdDev);
        lower.add(sma - standardDeviations * stdDev);
      }
    }

    return BollingerBandsResult(
      upper: upper,
      middle: middle,
      lower: lower,
    );
  }

  /// Calculate %B (position within bands, 0-1 scale)
  List<double?> calculatePercentB(List<Candle> candles) {
    final bands = calculateAll(candles);
    final result = <double?>[];

    for (int i = 0; i < candles.length; i++) {
      if (bands.upper[i] == null || bands.lower[i] == null) {
        result.add(null);
      } else {
        final bandwidth = bands.upper[i]! - bands.lower[i]!;
        if (bandwidth == 0) {
          result.add(0.5);
        } else {
          result.add((candles[i].close - bands.lower[i]!) / bandwidth);
        }
      }
    }

    return result;
  }

  /// Calculate bandwidth (volatility measure)
  List<double?> calculateBandwidth(List<Candle> candles) {
    final bands = calculateAll(candles);
    final result = <double?>[];

    for (int i = 0; i < candles.length; i++) {
      if (bands.upper[i] == null ||
          bands.lower[i] == null ||
          bands.middle[i] == null ||
          bands.middle[i] == 0) {
        result.add(null);
      } else {
        result.add((bands.upper[i]! - bands.lower[i]!) / bands.middle[i]!);
      }
    }

    return result;
  }
}

class BollingerBandsResult {
  final List<double?> upper;
  final List<double?> middle;
  final List<double?> lower;

  const BollingerBandsResult({
    required this.upper,
    required this.middle,
    required this.lower,
  });

  /// Get all values at a specific index
  BollingerBandsPoint? getPoint(int index) {
    if (index < 0 ||
        index >= upper.length ||
        upper[index] == null ||
        middle[index] == null ||
        lower[index] == null) {
      return null;
    }
    return BollingerBandsPoint(
      upper: upper[index]!,
      middle: middle[index]!,
      lower: lower[index]!,
    );
  }
}

class BollingerBandsPoint {
  final double upper;
  final double middle;
  final double lower;

  const BollingerBandsPoint({
    required this.upper,
    required this.middle,
    required this.lower,
  });

  double get bandwidth => upper - lower;
}
