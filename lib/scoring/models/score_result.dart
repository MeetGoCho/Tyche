import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/strategy_type.dart';

class ScoreResult extends Equatable {
  final int overallScore;
  final ScoreBreakdown breakdown;
  final Signal signal;
  final StrategyType strategy;
  final DateTime calculatedAt;

  const ScoreResult({
    required this.overallScore,
    required this.breakdown,
    required this.signal,
    required this.strategy,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [overallScore, breakdown, signal, strategy, calculatedAt];
}

class ScoreBreakdown extends Equatable {
  final double trend;
  final double momentum;
  final double volatility;
  final double volume;
  final double pattern;

  const ScoreBreakdown({
    required this.trend,
    required this.momentum,
    required this.volatility,
    required this.volume,
    required this.pattern,
  });

  @override
  List<Object?> get props => [trend, momentum, volatility, volume, pattern];
}

enum Signal {
  strongBuy('Strong Buy', Color(0xFF4CAF50)),
  buy('Buy', Color(0xFF8BC34A)),
  neutral('Neutral', Color(0xFF9E9E9E)),
  sell('Sell', Color(0xFFFF9800)),
  strongSell('Strong Sell', Color(0xFFF44336));

  final String label;
  final Color color;

  const Signal(this.label, this.color);

  static Signal fromScore(int score) {
    if (score >= 80) return strongBuy;
    if (score >= 60) return buy;
    if (score >= 40) return neutral;
    if (score >= 20) return sell;
    return strongSell;
  }
}
