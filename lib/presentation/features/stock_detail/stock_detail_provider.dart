import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../domain/entities/candle.dart';
import '../../../domain/entities/strategy_type.dart';
import '../../../domain/entities/time_frame.dart';
import '../../../scoring/core/score_calculator.dart';
import '../../../scoring/models/score_result.dart';

class StockDetailState {
  final String ticker;
  final List<Candle> candles;
  final ScoreResult? score;
  final StrategyType selectedStrategy;
  final TimeFrame selectedTimeFrame;
  final bool isLoading;
  final String? error;

  const StockDetailState({
    required this.ticker,
    this.candles = const [],
    this.score,
    this.selectedStrategy = StrategyType.movingAverage,
    this.selectedTimeFrame = TimeFrame.d1,
    this.isLoading = false,
    this.error,
  });

  StockDetailState copyWith({
    String? ticker,
    List<Candle>? candles,
    ScoreResult? score,
    StrategyType? selectedStrategy,
    TimeFrame? selectedTimeFrame,
    bool? isLoading,
    String? error,
  }) {
    return StockDetailState(
      ticker: ticker ?? this.ticker,
      candles: candles ?? this.candles,
      score: score ?? this.score,
      selectedStrategy: selectedStrategy ?? this.selectedStrategy,
      selectedTimeFrame: selectedTimeFrame ?? this.selectedTimeFrame,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StockDetailNotifier extends StateNotifier<StockDetailState> {
  final Ref _ref;
  final ScoreCalculator _scoreCalculator;

  StockDetailNotifier(this._ref, String ticker)
      : _scoreCalculator = ScoreCalculator(),
        super(StockDetailState(ticker: ticker, isLoading: true)) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    final repository = _ref.read(stockRepositoryProvider);
    final now = DateTime.now();
    final from = now.subtract(Duration(days: state.selectedTimeFrame.defaultLookbackDays));

    final result = await repository.getCandles(
      ticker: state.ticker,
      timeFrame: state.selectedTimeFrame,
      from: from,
      to: now,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (candles) {
        final score = candles.length >= 20
            ? _scoreCalculator.calculateScore(
                candles: candles,
                strategy: state.selectedStrategy,
              )
            : null;

        state = state.copyWith(
          candles: candles,
          score: score,
          isLoading: false,
        );
      },
    );
  }

  void selectStrategy(StrategyType strategy) {
    if (state.candles.length >= 20) {
      final score = _scoreCalculator.calculateScore(
        candles: state.candles,
        strategy: strategy,
      );
      state = state.copyWith(
        selectedStrategy: strategy,
        score: score,
      );
    } else {
      state = state.copyWith(selectedStrategy: strategy);
    }
  }

  void selectTimeFrame(TimeFrame timeFrame) {
    state = state.copyWith(selectedTimeFrame: timeFrame);
    _loadData();
  }

  Future<void> refresh() => _loadData();
}

final stockDetailProvider = StateNotifierProvider.family<StockDetailNotifier, StockDetailState, String>(
  (ref, ticker) => StockDetailNotifier(ref, ticker),
);
