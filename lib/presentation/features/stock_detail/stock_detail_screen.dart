import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/strategy_type.dart';
import '../../../chart_engine/widgets/interactive_chart.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/error_widget.dart';
import 'stock_detail_provider.dart';

class StockDetailScreen extends ConsumerWidget {
  final String ticker;

  const StockDetailScreen({super.key, required this.ticker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockDetailProvider(ticker));

    return Scaffold(
      appBar: AppBar(
        title: Text(ticker),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () => context.push(RoutePaths.chart(ticker)),
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingWidget(message: 'Loading data...')
          : state.error != null
              ? AppErrorWidget(
                  message: state.error!,
                  onRetry: () => ref.read(stockDetailProvider(ticker).notifier).refresh(),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(stockDetailProvider(ticker).notifier).refresh(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StockHeader(
                          ticker: ticker,
                          candles: state.candles,
                        ),
                        const Divider(),
                        if (state.score != null)
                          _ScoreCard(
                            score: state.score!.overallScore,
                            strategy: state.selectedStrategy,
                          )
                        else
                          _NoScoreCard(),
                        const SizedBox(height: 16),
                        _StrategySelector(
                          selected: state.selectedStrategy,
                          onSelect: (strategy) {
                            ref.read(stockDetailProvider(ticker).notifier).selectStrategy(strategy);
                          },
                        ),
                        const SizedBox(height: 16),
                        _MiniChart(candles: state.candles),
                        const SizedBox(height: 16),
                        if (state.score != null)
                          _ScoreBreakdown(
                            trend: state.score!.breakdown.trend.round(),
                            momentum: state.score!.breakdown.momentum.round(),
                            volatility: state.score!.breakdown.volatility.round(),
                            volume: state.score!.breakdown.volume.round(),
                            pattern: state.score!.breakdown.pattern.round(),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _StockHeader extends StatelessWidget {
  final String ticker;
  final List candles;

  const _StockHeader({
    required this.ticker,
    required this.candles,
  });

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(ticker, style: AppTextStyles.h2),
      );
    }

    final lastCandle = candles.last;
    final prevCandle = candles.length > 1 ? candles[candles.length - 2] : lastCandle;
    final change = lastCandle.close - prevCandle.close;
    final changePercent = prevCandle.close != 0 ? (change / prevCandle.close) * 100 : 0.0;
    final isPositive = change >= 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ticker, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${lastCandle.close.toStringAsFixed(2)}',
                style: AppTextStyles.price,
              ),
              const SizedBox(width: 12),
              Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} (${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%)',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isPositive ? AppColors.bullish : AppColors.bearish,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final StrategyType strategy;

  const _ScoreCard({
    required this.score,
    required this.strategy,
  });

  @override
  Widget build(BuildContext context) {
    final signal = _getSignal(score);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.getScoreColor(score).withValues(alpha: 0.3),
            AppColors.getScoreColor(score).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.getScoreColor(score).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score',
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  strategy.displayName,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                score.toString(),
                style: AppTextStyles.score.copyWith(
                  color: AppColors.getScoreColor(score),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.getScoreColor(score),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  signal,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSignal(int score) {
    if (score >= 80) return 'Strong Buy';
    if (score >= 60) return 'Buy';
    if (score >= 40) return 'Neutral';
    if (score >= 20) return 'Sell';
    return 'Strong Sell';
  }
}

class _NoScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text(
          'Not enough data for score calculation',
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }
}

class _StrategySelector extends StatelessWidget {
  final StrategyType selected;
  final ValueChanged<StrategyType> onSelect;

  const _StrategySelector({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Strategy', style: AppTextStyles.h4),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: StrategyType.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final strategy = StrategyType.values[index];
              final isSelected = strategy == selected;

              return ChoiceChip(
                label: Text(strategy.displayName),
                selected: isSelected,
                onSelected: (_) => onSelect(strategy),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniChart extends StatelessWidget {
  final List candles;

  const _MiniChart({required this.candles});

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'No chart data',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveChart(
          candles: List.from(candles),
        ),
      ),
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  final int trend;
  final int momentum;
  final int volatility;
  final int volume;
  final int pattern;

  const _ScoreBreakdown({
    required this.trend,
    required this.momentum,
    required this.volatility,
    required this.volume,
    required this.pattern,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score Breakdown', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _ScoreBar(label: 'Trend', value: trend),
          _ScoreBar(label: 'Momentum', value: momentum),
          _ScoreBar(label: 'Volatility', value: volatility),
          _ScoreBar(label: 'Volume', value: volume),
          _ScoreBar(label: 'Pattern', value: pattern),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreBar({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.getScoreColor(value),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 32,
            child: Text(
              value.toString(),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.getScoreColor(value),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
