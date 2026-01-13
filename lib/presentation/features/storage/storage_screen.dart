import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/strategy_type.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Watchlist'),
            Tab(text: 'My Strategies'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWatchlistTab(),
          _buildMyStrategiesTab(),
        ],
      ),
    );
  }

  Widget _buildWatchlistTab() {
    if (_mockWatchlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No stocks in watchlist',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search and add stocks to track them here',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockWatchlist.length,
      itemBuilder: (context, index) {
        final stock = _mockWatchlist[index];
        return _WatchlistItem(
          ticker: stock['ticker']!,
          name: stock['name']!,
          price: stock['price']!,
          change: stock['change']!,
          changePercent: stock['changePercent']!,
          onTap: () {
            context.push(RoutePaths.stockDetail(stock['ticker']!));
          },
        );
      },
    );
  }

  Widget _buildMyStrategiesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: StrategyType.values.length,
      itemBuilder: (context, index) {
        final strategy = StrategyType.values[index];
        return _StrategyItem(
          strategy: strategy,
          isOwned: true,
        );
      },
    );
  }

  static const List<Map<String, String>> _mockWatchlist = [
    {
      'ticker': 'AAPL',
      'name': 'Apple Inc.',
      'price': '\$178.52',
      'change': '+2.34',
      'changePercent': '+1.33%',
    },
    {
      'ticker': 'NVDA',
      'name': 'NVIDIA Corporation',
      'price': '\$875.28',
      'change': '+12.45',
      'changePercent': '+1.44%',
    },
    {
      'ticker': 'TSLA',
      'name': 'Tesla, Inc.',
      'price': '\$245.67',
      'change': '-3.21',
      'changePercent': '-1.29%',
    },
    {
      'ticker': 'MSFT',
      'name': 'Microsoft Corporation',
      'price': '\$415.32',
      'change': '+5.67',
      'changePercent': '+1.38%',
    },
  ];
}

class _WatchlistItem extends StatelessWidget {
  final String ticker;
  final String name;
  final String price;
  final String change;
  final String changePercent;
  final VoidCallback onTap;

  const _WatchlistItem({
    required this.ticker,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change.startsWith('+');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            ticker[0],
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          ticker,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          name,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '$change ($changePercent)',
              style: TextStyle(
                color: isPositive ? AppColors.success : AppColors.error,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StrategyItem extends StatelessWidget {
  final StrategyType strategy;
  final bool isOwned;

  const _StrategyItem({
    required this.strategy,
    required this.isOwned,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStrategyIcon(),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strategy.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _getStrategyDescription(),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Owned',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  label: 'Win Rate',
                  value: _getMockWinRate(),
                ),
                _StatColumn(
                  label: '1Y Return',
                  value: _getMockReturn(),
                  valueColor: AppColors.success,
                ),
                _StatColumn(
                  label: 'Max DD',
                  value: _getMockDrawdown(),
                  valueColor: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStrategyIcon() {
    switch (strategy) {
      case StrategyType.movingAverage:
        return Icons.trending_up;
      case StrategyType.rsi:
        return Icons.speed;
      case StrategyType.macd:
        return Icons.show_chart;
      case StrategyType.bollingerBands:
        return Icons.stacked_line_chart;
      case StrategyType.volumeBreakout:
        return Icons.bar_chart;
    }
  }

  String _getStrategyDescription() {
    switch (strategy) {
      case StrategyType.movingAverage:
        return 'Trend following using moving average crossovers';
      case StrategyType.rsi:
        return 'Momentum based on relative strength index';
      case StrategyType.macd:
        return 'Trend momentum using MACD histogram';
      case StrategyType.bollingerBands:
        return 'Volatility-based support and resistance';
      case StrategyType.volumeBreakout:
        return 'Volume-confirmed price breakouts';
    }
  }

  String _getMockWinRate() {
    switch (strategy) {
      case StrategyType.movingAverage:
        return '68%';
      case StrategyType.rsi:
        return '62%';
      case StrategyType.macd:
        return '65%';
      case StrategyType.bollingerBands:
        return '58%';
      case StrategyType.volumeBreakout:
        return '71%';
    }
  }

  String _getMockReturn() {
    switch (strategy) {
      case StrategyType.movingAverage:
        return '+24.5%';
      case StrategyType.rsi:
        return '+18.2%';
      case StrategyType.macd:
        return '+21.8%';
      case StrategyType.bollingerBands:
        return '+15.6%';
      case StrategyType.volumeBreakout:
        return '+28.3%';
    }
  }

  String _getMockDrawdown() {
    switch (strategy) {
      case StrategyType.movingAverage:
        return '-12.3%';
      case StrategyType.rsi:
        return '-15.8%';
      case StrategyType.macd:
        return '-14.2%';
      case StrategyType.bollingerBands:
        return '-18.5%';
      case StrategyType.volumeBreakout:
        return '-10.7%';
    }
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
