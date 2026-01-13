import '../../domain/entities/candle.dart';
import 'indicator_base.dart';
import 'moving_average.dart';

/// MACD (Moving Average Convergence Divergence) indicator
class MACDIndicator extends IndicatorBase {
  final int fastPeriod;
  final int slowPeriod;
  final int signalPeriod;

  const MACDIndicator({
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
  }) : super(name: 'MACD($fastPeriod, $slowPeriod, $signalPeriod)', period: slowPeriod);

  @override
  List<double?> calculate(List<Candle> candles) {
    // Returns MACD line; use calculateAll for full result
    return calculateAll(candles).macd;
  }

  MACDResult calculateAll(List<Candle> candles) {
    if (candles.length < slowPeriod) {
      return MACDResult(
        macd: List.filled(candles.length, null),
        signal: List.filled(candles.length, null),
        histogram: List.filled(candles.length, null),
      );
    }

    // Calculate fast and slow EMAs
    final fastEma = EMAIndicator(period: fastPeriod).calculate(candles);
    final slowEma = EMAIndicator(period: slowPeriod).calculate(candles);

    // Calculate MACD line (fast EMA - slow EMA)
    final macd = <double?>[];
    for (int i = 0; i < candles.length; i++) {
      if (fastEma[i] == null || slowEma[i] == null) {
        macd.add(null);
      } else {
        macd.add(fastEma[i]! - slowEma[i]!);
      }
    }

    // Calculate signal line (EMA of MACD)
    final macdValues = <double>[];
    final macdStartIndex = <int>[];
    for (int i = 0; i < macd.length; i++) {
      if (macd[i] != null) {
        macdValues.add(macd[i]!);
        macdStartIndex.add(i);
      }
    }

    final signalValues = EMAIndicator.calculateFromValues(macdValues, signalPeriod);

    final signal = List<double?>.filled(candles.length, null);
    for (int i = 0; i < signalValues.length; i++) {
      signal[macdStartIndex[i]] = signalValues[i];
    }

    // Calculate histogram (MACD - Signal)
    final histogram = <double?>[];
    for (int i = 0; i < candles.length; i++) {
      if (macd[i] == null || signal[i] == null) {
        histogram.add(null);
      } else {
        histogram.add(macd[i]! - signal[i]!);
      }
    }

    return MACDResult(
      macd: macd,
      signal: signal,
      histogram: histogram,
    );
  }
}

class MACDResult {
  final List<double?> macd;
  final List<double?> signal;
  final List<double?> histogram;

  const MACDResult({
    required this.macd,
    required this.signal,
    required this.histogram,
  });

  /// Get all values at a specific index
  MACDPoint? getPoint(int index) {
    if (index < 0 ||
        index >= macd.length ||
        macd[index] == null ||
        signal[index] == null ||
        histogram[index] == null) {
      return null;
    }
    return MACDPoint(
      macd: macd[index]!,
      signal: signal[index]!,
      histogram: histogram[index]!,
    );
  }
}

class MACDPoint {
  final double macd;
  final double signal;
  final double histogram;

  const MACDPoint({
    required this.macd,
    required this.signal,
    required this.histogram,
  });

  bool get isBullish => histogram > 0;
  bool get isBearish => histogram < 0;
}
