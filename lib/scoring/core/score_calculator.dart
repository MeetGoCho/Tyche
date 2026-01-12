import '../../domain/entities/candle.dart';
import '../../domain/entities/strategy_type.dart';
import '../analyzers/trend_analyzer.dart';
import '../analyzers/momentum_analyzer.dart';
import '../analyzers/volatility_analyzer.dart';
import '../analyzers/volume_analyzer.dart';
import '../analyzers/pattern_analyzer.dart';
import '../models/score_result.dart';

class ScoreCalculator {
  final TrendAnalyzer _trendAnalyzer;
  final MomentumAnalyzer _momentumAnalyzer;
  final VolatilityAnalyzer _volatilityAnalyzer;
  final VolumeAnalyzer _volumeAnalyzer;
  final PatternAnalyzer _patternAnalyzer;

  ScoreCalculator({
    TrendAnalyzer? trendAnalyzer,
    MomentumAnalyzer? momentumAnalyzer,
    VolatilityAnalyzer? volatilityAnalyzer,
    VolumeAnalyzer? volumeAnalyzer,
    PatternAnalyzer? patternAnalyzer,
  })  : _trendAnalyzer = trendAnalyzer ?? TrendAnalyzer(),
        _momentumAnalyzer = momentumAnalyzer ?? MomentumAnalyzer(),
        _volatilityAnalyzer = volatilityAnalyzer ?? VolatilityAnalyzer(),
        _volumeAnalyzer = volumeAnalyzer ?? VolumeAnalyzer(),
        _patternAnalyzer = patternAnalyzer ?? PatternAnalyzer();

  ScoreResult calculateScore({
    required List<Candle> candles,
    required StrategyType strategy,
  }) {
    // 각 분석기로부터 점수 획득
    final trendScore = _trendAnalyzer.analyze(candles);
    final momentumScore = _momentumAnalyzer.analyze(candles);
    final volatilityScore = _volatilityAnalyzer.analyze(candles);
    final volumeScore = _volumeAnalyzer.analyze(candles);
    final patternScore = _patternAnalyzer.analyze(candles);

    // 전략별 가중치 적용
    final weights = _getWeightsForStrategy(strategy);

    final rawScore = trendScore * weights.trend +
        momentumScore * weights.momentum +
        volatilityScore * weights.volatility +
        volumeScore * weights.volume +
        patternScore * weights.pattern;

    final normalizedScore = rawScore.round().clamp(0, 100);

    return ScoreResult(
      overallScore: normalizedScore,
      breakdown: ScoreBreakdown(
        trend: trendScore,
        momentum: momentumScore,
        volatility: volatilityScore,
        volume: volumeScore,
        pattern: patternScore,
      ),
      signal: Signal.fromScore(normalizedScore),
      strategy: strategy,
      calculatedAt: DateTime.now(),
    );
  }

  _StrategyWeights _getWeightsForStrategy(StrategyType strategy) {
    switch (strategy) {
      case StrategyType.movingAverage:
        return const _StrategyWeights(
          trend: 0.40,
          momentum: 0.20,
          volatility: 0.15,
          volume: 0.15,
          pattern: 0.10,
        );
      case StrategyType.rsi:
        return const _StrategyWeights(
          trend: 0.15,
          momentum: 0.45,
          volatility: 0.15,
          volume: 0.15,
          pattern: 0.10,
        );
      case StrategyType.macd:
        return const _StrategyWeights(
          trend: 0.30,
          momentum: 0.35,
          volatility: 0.10,
          volume: 0.15,
          pattern: 0.10,
        );
      case StrategyType.bollingerBands:
        return const _StrategyWeights(
          trend: 0.15,
          momentum: 0.20,
          volatility: 0.40,
          volume: 0.15,
          pattern: 0.10,
        );
      case StrategyType.volumeBreakout:
        return const _StrategyWeights(
          trend: 0.20,
          momentum: 0.15,
          volatility: 0.15,
          volume: 0.40,
          pattern: 0.10,
        );
    }
  }
}

class _StrategyWeights {
  final double trend;
  final double momentum;
  final double volatility;
  final double volume;
  final double pattern;

  const _StrategyWeights({
    required this.trend,
    required this.momentum,
    required this.volatility,
    required this.volume,
    required this.pattern,
  });
}
