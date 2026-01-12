import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ChartScreen extends ConsumerStatefulWidget {
  final String ticker;

  const ChartScreen({super.key, required this.ticker});

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  String _selectedTimeFrame = '1D';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.ticker),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _TimeFrameSelector(
            selected: _selectedTimeFrame,
            onSelect: (tf) => setState(() => _selectedTimeFrame = tf),
          ),
          Expanded(
            child: _ChartArea(
              ticker: widget.ticker,
              timeFrame: _selectedTimeFrame,
            ),
          ),
          _IndicatorPanel(),
        ],
      ),
    );
  }
}

class _TimeFrameSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _TimeFrameSelector({
    required this.selected,
    required this.onSelect,
  });

  static const _timeFrames = ['1m', '5m', '15m', '1h', '4h', '1D', '1W'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _timeFrames.map((tf) {
          final isSelected = tf == selected;
          return GestureDetector(
            onTap: () => onSelect(tf),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tf,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChartArea extends StatelessWidget {
  final String ticker;
  final String timeFrame;

  const _ChartArea({
    required this.ticker,
    required this.timeFrame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.candlestick_chart,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Candlestick Chart',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 8),
            Text(
              '$ticker - $timeFrame',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chart engine will be implemented here',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Indicators', style: AppTextStyles.labelMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _IndicatorChip(label: 'MA 20', isActive: true),
              _IndicatorChip(label: 'MA 50', isActive: true),
              _IndicatorChip(label: 'RSI', isActive: false),
              _IndicatorChip(label: 'MACD', isActive: false),
              _IndicatorChip(label: 'Bollinger', isActive: false),
              _IndicatorChip(label: 'Volume', isActive: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndicatorChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _IndicatorChip({
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (value) {},
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isActive ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}
