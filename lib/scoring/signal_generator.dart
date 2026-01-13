import '../domain/entities/candle.dart';
import '../domain/entities/signal_point.dart';
import '../domain/entities/strategy_type.dart';

/// Abstract interface for signal generators
/// This allows swapping between rule-based and AI-based generators
abstract class SignalGenerator {
  /// Generate trading signals from candle data
  SignalHistory generateSignals(List<Candle> candles);

  /// Strategy type this generator implements
  StrategyType get strategyType;
}

/// Factory to create appropriate signal generator for a strategy
class SignalGeneratorFactory {
  static SignalGenerator create(StrategyType strategy) {
    switch (strategy) {
      case StrategyType.movingAverage:
        return MASignalGenerator();
      case StrategyType.rsi:
        return RSISignalGenerator();
      case StrategyType.macd:
        return MACDSignalGenerator();
      case StrategyType.bollingerBands:
        return BollingerSignalGenerator();
      case StrategyType.volumeBreakout:
        return VolumeBreakoutSignalGenerator();
    }
  }
}

/// Moving Average crossover signal generator
class MASignalGenerator implements SignalGenerator {
  final int shortPeriod;
  final int longPeriod;

  MASignalGenerator({this.shortPeriod = 20, this.longPeriod = 50});

  @override
  StrategyType get strategyType => StrategyType.movingAverage;

  @override
  SignalHistory generateSignals(List<Candle> candles) {
    final signals = <SignalPoint>[];

    if (candles.length < longPeriod + 1) {
      return SignalHistory(
        signals: signals,
        strategyName: strategyType.displayName,
        calculatedAt: DateTime.now(),
      );
    }

    // Calculate SMAs
    final shortSma = _calculateSMA(candles, shortPeriod);
    final longSma = _calculateSMA(candles, longPeriod);

    // Find crossovers
    for (int i = longPeriod; i < candles.length; i++) {
      final prevShort = shortSma[i - 1];
      final prevLong = longSma[i - 1];
      final currShort = shortSma[i];
      final currLong = longSma[i];

      if (prevShort == null || prevLong == null ||
          currShort == null || currLong == null) continue;

      // Golden cross (short crosses above long) - Buy signal
      if (prevShort <= prevLong && currShort > currLong) {
        final confidence = _calculateCrossoverConfidence(
          currShort - currLong,
          currLong,
        );
        signals.add(SignalPoint(
          timestamp: candles[i].timestamp,
          candleIndex: i,
          type: SignalType.buy,
          confidence: confidence,
          reason: 'Golden Cross: SMA$shortPeriod crossed above SMA$longPeriod',
        ));
      }
      // Death cross (short crosses below long) - Sell signal
      else if (prevShort >= prevLong && currShort < currLong) {
        final confidence = _calculateCrossoverConfidence(
          currLong - currShort,
          currLong,
        );
        signals.add(SignalPoint(
          timestamp: candles[i].timestamp,
          candleIndex: i,
          type: SignalType.sell,
          confidence: confidence,
          reason: 'Death Cross: SMA$shortPeriod crossed below SMA$longPeriod',
        ));
      }
    }

    return SignalHistory(
      signals: signals,
      strategyName: strategyType.displayName,
      calculatedAt: DateTime.now(),
    );
  }

  List<double?> _calculateSMA(List<Candle> candles, int period) {
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

  double _calculateCrossoverConfidence(double diff, double base) {
    if (base == 0) return 50;
    final percentDiff = (diff / base).abs() * 100;
    // Scale to 50-100 range based on strength of crossover
    return (50 + percentDiff * 10).clamp(50, 100);
  }
}

/// RSI overbought/oversold signal generator
class RSISignalGenerator implements SignalGenerator {
  final int period;
  final double oversoldLevel;
  final double overboughtLevel;

  RSISignalGenerator({
    this.period = 14,
    this.oversoldLevel = 30,
    this.overboughtLevel = 70,
  });

  @override
  StrategyType get strategyType => StrategyType.rsi;

  @override
  SignalHistory generateSignals(List<Candle> candles) {
    final signals = <SignalPoint>[];

    if (candles.length < period + 2) {
      return SignalHistory(
        signals: signals,
        strategyName: strategyType.displayName,
        calculatedAt: DateTime.now(),
      );
    }

    final rsi = _calculateRSI(candles);

    for (int i = period + 1; i < candles.length; i++) {
      final prevRsi = rsi[i - 1];
      final currRsi = rsi[i];

      if (prevRsi == null || currRsi == null) continue;

      // RSI crossing up from oversold - Buy signal
      if (prevRsi <= oversoldLevel && currRsi > oversoldLevel) {
        final confidence = 50 + (oversoldLevel - prevRsi) * 1.5;
        signals.add(SignalPoint(
          timestamp: candles[i].timestamp,
          candleIndex: i,
          type: SignalType.buy,
          confidence: confidence.clamp(50, 100),
          reason: 'RSI exiting oversold zone (${prevRsi.toStringAsFixed(1)} → ${currRsi.toStringAsFixed(1)})',
        ));
      }
      // RSI crossing down from overbought - Sell signal
      else if (prevRsi >= overboughtLevel && currRsi < overboughtLevel) {
        final confidence = 50 + (prevRsi - overboughtLevel) * 1.5;
        signals.add(SignalPoint(
          timestamp: candles[i].timestamp,
          candleIndex: i,
          type: SignalType.sell,
          confidence: confidence.clamp(50, 100),
          reason: 'RSI exiting overbought zone (${prevRsi.toStringAsFixed(1)} → ${currRsi.toStringAsFixed(1)})',
        ));
      }
    }

    return SignalHistory(
      signals: signals,
      strategyName: strategyType.displayName,
      calculatedAt: DateTime.now(),
    );
  }

  List<double?> _calculateRSI(List<Candle> candles) {
    final result = <double?>[];
    if (candles.length < period + 1) {
      return List.filled(candles.length, null);
    }

    final gains = <double>[];
    final losses = <double>[];

    for (int i = 1; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
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

/// MACD crossover signal generator
class MACDSignalGenerator implements SignalGenerator {
  final int fastPeriod;
  final int slowPeriod;
  final int signalPeriod;

  MACDSignalGenerator({
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
  });

  @override
  StrategyType get strategyType => StrategyType.macd;

  @override
  SignalHistory generateSignals(List<Candle> candles) {
    final signals = <SignalPoint>[];

    if (candles.length < slowPeriod + signalPeriod) {
      return SignalHistory(
        signals: signals,
        strategyName: strategyType.displayName,
        calculatedAt: DateTime.now(),
      );
    }

    final macdResult = _calculateMACD(candles);
    final macd = macdResult['macd']!;
    final signal = macdResult['signal']!;

    for (int i = slowPeriod + signalPeriod; i < candles.length; i++) {
      final prevMacd = macd[i - 1];
      final prevSignal = signal[i - 1];
      final currMacd = macd[i];
      final currSignal = signal[i];

      if (prevMacd == null || prevSignal == null ||
          currMacd == null || currSignal == null) continue;

      // MACD crossing above signal line - Buy
      if (prevMacd <= prevSignal && currMacd > currSignal) {
        final confidence = 50 + (currMacd - currSignal).abs() * 5;
        signals.add(SignalPoint(
          timestamp: candles[i].timestamp,
          candleIndex: i,
          type: SignalType.buy,
          confidence: confidence.clamp(50, 100),
          reason: 'MACD crossed above signal line',
        ));
      }
      // MACD crossing below signal line - Sell
      else if (prevMacd >= prevSignal && currMacd < currSignal) {
        final confidence = 50 + (currSignal - currMacd).abs() * 5;
        signals.add(SignalPoint(
          timestamp: candles[i].timestamp,
          candleIndex: i,
          type: SignalType.sell,
          confidence: confidence.clamp(50, 100),
          reason: 'MACD crossed below signal line',
        ));
      }
    }

    return SignalHistory(
      signals: signals,
      strategyName: strategyType.displayName,
      calculatedAt: DateTime.now(),
    );
  }

  Map<String, List<double?>> _calculateMACD(List<Candle> candles) {
    final fastEma = _calculateEMA(candles, fastPeriod);
    final slowEma = _calculateEMA(candles, slowPeriod);

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
    final macdIndices = <int>[];
    for (int i = 0; i < macd.length; i++) {
      if (macd[i] != null) {
        macdValues.add(macd[i]!);
        macdIndices.add(i);
      }
    }

    final signalValues = _calculateEMAFromValues(macdValues, signalPeriod);
    final signal = List<double?>.filled(candles.length, null);
    for (int i = 0; i < signalValues.length; i++) {
      signal[macdIndices[i]] = signalValues[i];
    }

    return {'macd': macd, 'signal': signal};
  }

  List<double?> _calculateEMA(List<Candle> candles, int period) {
    if (candles.length < period) {
      return List.filled(candles.length, null);
    }

    final result = <double?>[];
    final multiplier = 2 / (period + 1);

    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += candles[i].close;
      result.add(null);
    }
    result[period - 1] = sum / period;

    for (int i = period; i < candles.length; i++) {
      final prevEma = result[i - 1]!;
      final ema = (candles[i].close - prevEma) * multiplier + prevEma;
      result.add(ema);
    }

    return result;
  }

  List<double?> _calculateEMAFromValues(List<double> values, int period) {
    if (values.length < period) {
      return List.filled(values.length, null);
    }

    final result = <double?>[];
    final multiplier = 2 / (period + 1);

    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += values[i];
      result.add(null);
    }
    result[period - 1] = sum / period;

    for (int i = period; i < values.length; i++) {
      final prevEma = result[i - 1]!;
      final ema = (values[i] - prevEma) * multiplier + prevEma;
      result.add(ema);
    }

    return result;
  }
}

/// Bollinger Bands breakout signal generator
class BollingerSignalGenerator implements SignalGenerator {
  final int period;
  final double stdDev;

  BollingerSignalGenerator({this.period = 20, this.stdDev = 2.0});

  @override
  StrategyType get strategyType => StrategyType.bollingerBands;

  @override
  SignalHistory generateSignals(List<Candle> candles) {
    final signals = <SignalPoint>[];

    if (candles.length < period + 1) {
      return SignalHistory(
        signals: signals,
        strategyName: strategyType.displayName,
        calculatedAt: DateTime.now(),
      );
    }

    final bands = _calculateBollingerBands(candles);
    final upper = bands['upper']!;
    final lower = bands['lower']!;

    for (int i = period; i < candles.length; i++) {
      final prevClose = candles[i - 1].close;
      final currClose = candles[i].close;
      final prevLower = lower[i - 1];
      final currLower = lower[i];
      final prevUpper = upper[i - 1];
      final currUpper = upper[i];

      if (prevLower == null || currLower == null ||
          prevUpper == null || currUpper == null) continue;

      // Price bouncing off lower band - Buy
      if (prevClose <= prevLower && currClose > currLower) {
        final confidence = 50 + ((currLower - prevClose) / prevClose).abs() * 500;
        signals.add(SignalPoint(
          timestamp: candles[i].timestamp,
          candleIndex: i,
          type: SignalType.buy,
          confidence: confidence.clamp(50, 100),
          reason: 'Price bounced off lower Bollinger Band',
        ));
      }
      // Price bouncing off upper band - Sell
      else if (prevClose >= prevUpper && currClose < currUpper) {
        final confidence = 50 + ((prevClose - currUpper) / currUpper).abs() * 500;
        signals.add(SignalPoint(
          timestamp: candles[i].timestamp,
          candleIndex: i,
          type: SignalType.sell,
          confidence: confidence.clamp(50, 100),
          reason: 'Price bounced off upper Bollinger Band',
        ));
      }
    }

    return SignalHistory(
      signals: signals,
      strategyName: strategyType.displayName,
      calculatedAt: DateTime.now(),
    );
  }

  Map<String, List<double?>> _calculateBollingerBands(List<Candle> candles) {
    final upper = <double?>[];
    final middle = <double?>[];
    final lower = <double?>[];

    for (int i = 0; i < candles.length; i++) {
      if (i < period - 1) {
        upper.add(null);
        middle.add(null);
        lower.add(null);
      } else {
        double sum = 0;
        for (int j = i - period + 1; j <= i; j++) {
          sum += candles[j].close;
        }
        final sma = sum / period;

        double variance = 0;
        for (int j = i - period + 1; j <= i; j++) {
          variance += (candles[j].close - sma) * (candles[j].close - sma);
        }
        final std = (variance / period).abs();
        final stdDevValue = std > 0 ? std * 0.5 + (std * 0.5).abs() : 0.0;
        final sqrtStd = _sqrt(stdDevValue);

        middle.add(sma);
        upper.add(sma + stdDev * sqrtStd);
        lower.add(sma - stdDev * sqrtStd);
      }
    }

    return {'upper': upper, 'middle': middle, 'lower': lower};
  }

  double _sqrt(double value) {
    if (value <= 0) return 0;
    double guess = value / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + value / guess) / 2;
    }
    return guess;
  }
}

/// Volume breakout signal generator
class VolumeBreakoutSignalGenerator implements SignalGenerator {
  final int period;
  final double volumeMultiplier;

  VolumeBreakoutSignalGenerator({
    this.period = 20,
    this.volumeMultiplier = 2.0,
  });

  @override
  StrategyType get strategyType => StrategyType.volumeBreakout;

  @override
  SignalHistory generateSignals(List<Candle> candles) {
    final signals = <SignalPoint>[];

    if (candles.length < period + 1) {
      return SignalHistory(
        signals: signals,
        strategyName: strategyType.displayName,
        calculatedAt: DateTime.now(),
      );
    }

    for (int i = period; i < candles.length; i++) {
      // Calculate average volume
      double avgVolume = 0;
      for (int j = i - period; j < i; j++) {
        avgVolume += candles[j].volume;
      }
      avgVolume /= period;

      final currentCandle = candles[i];
      final isVolumeSpike = currentCandle.volume > avgVolume * volumeMultiplier;

      if (!isVolumeSpike) continue;

      final volumeRatio = currentCandle.volume / avgVolume;
      final confidence = 50 + (volumeRatio - volumeMultiplier) * 15;

      // Volume spike with bullish candle - Buy
      if (currentCandle.isBullish) {
        signals.add(SignalPoint(
          timestamp: currentCandle.timestamp,
          candleIndex: i,
          type: SignalType.buy,
          confidence: confidence.clamp(50, 100),
          reason: 'Volume breakout (${volumeRatio.toStringAsFixed(1)}x avg) with bullish candle',
        ));
      }
      // Volume spike with bearish candle - Sell
      else {
        signals.add(SignalPoint(
          timestamp: currentCandle.timestamp,
          candleIndex: i,
          type: SignalType.sell,
          confidence: confidence.clamp(50, 100),
          reason: 'Volume breakout (${volumeRatio.toStringAsFixed(1)}x avg) with bearish candle',
        ));
      }
    }

    return SignalHistory(
      signals: signals,
      strategyName: strategyType.displayName,
      calculatedAt: DateTime.now(),
    );
  }
}
