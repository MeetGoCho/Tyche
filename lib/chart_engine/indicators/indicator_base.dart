import '../../domain/entities/candle.dart';

/// Base class for all technical indicators
abstract class IndicatorBase {
  final String name;
  final int period;

  const IndicatorBase({
    required this.name,
    required this.period,
  });

  /// Calculate indicator values from candles
  List<double?> calculate(List<Candle> candles);
}

/// Result of indicator calculation with multiple lines
class IndicatorResult {
  final String name;
  final Map<String, List<double?>> lines;

  const IndicatorResult({
    required this.name,
    required this.lines,
  });
}

/// Configuration for overlay indicators (drawn on main chart)
enum OverlayIndicatorType {
  sma,
  ema,
  bollingerBands,
  ichimoku,
  parabolicSar,
}

/// Configuration for sub-indicators (drawn in separate panel)
enum SubIndicatorType {
  rsi,
  stochasticRsi,
  macd,
  momentum,
}

/// Active indicators configuration
class IndicatorConfig {
  final Set<OverlayIndicatorType> overlayIndicators;
  final Set<SubIndicatorType> subIndicators;
  final Map<String, int> periods;

  const IndicatorConfig({
    this.overlayIndicators = const {},
    this.subIndicators = const {},
    this.periods = const {
      'sma_short': 20,
      'sma_long': 50,
      'sma_trend': 200,
      'ema': 20,
      'bb_period': 20,
      'bb_std': 2,
      'rsi': 14,
      'stoch_k': 14,
      'stoch_d': 3,
      'macd_fast': 12,
      'macd_slow': 26,
      'macd_signal': 9,
      'momentum': 10,
    },
  });

  IndicatorConfig copyWith({
    Set<OverlayIndicatorType>? overlayIndicators,
    Set<SubIndicatorType>? subIndicators,
    Map<String, int>? periods,
  }) {
    return IndicatorConfig(
      overlayIndicators: overlayIndicators ?? this.overlayIndicators,
      subIndicators: subIndicators ?? this.subIndicators,
      periods: periods ?? this.periods,
    );
  }

  int getPeriod(String key) => periods[key] ?? 14;
}
