import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tyche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _MarketOverview(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
            SliverToBoxAdapter(
              child: _WatchlistHeader(),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _WatchlistItem(
                  ticker: _demoWatchlist[index]['ticker']!,
                  name: _demoWatchlist[index]['name']!,
                  price: _demoWatchlist[index]['price']!,
                  change: _demoWatchlist[index]['change']!,
                  score: int.parse(_demoWatchlist[index]['score']!),
                ),
                childCount: _demoWatchlist.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Overview',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MarketCard(
                  name: 'S&P 500',
                  value: '4,783.45',
                  change: '+0.58%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MarketCard(
                  name: 'NASDAQ',
                  value: '15,003.22',
                  change: '+0.82%',
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MarketCard(
                  name: 'DOW',
                  value: '37,545.33',
                  change: '-0.12%',
                  isPositive: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MarketCard(
                  name: 'VIX',
                  value: '13.45',
                  change: '-2.31%',
                  isPositive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final String name;
  final String value;
  final String change;
  final bool isPositive;

  const _MarketCard({
    required this.name,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: AppTextStyles.bodySmall.copyWith(
              color: isPositive ? AppColors.bullish : AppColors.bearish,
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Watchlist',
            style: AppTextStyles.h3,
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

class _WatchlistItem extends StatelessWidget {
  final String ticker;
  final String name;
  final String price;
  final String change;
  final int score;

  const _WatchlistItem({
    required this.ticker,
    required this.name,
    required this.price,
    required this.change,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = !change.startsWith('-');

    return InkWell(
      onTap: () => context.push(RoutePaths.stockDetail(ticker)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticker, style: AppTextStyles.h4),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _ScoreBadge(score: score),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: AppTextStyles.priceSmall),
                  const SizedBox(height: 2),
                  Text(
                    change,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isPositive ? AppColors.bullish : AppColors.bearish,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getScoreColor(score).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        score.toString(),
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.getScoreColor(score),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

final _demoWatchlist = [
  {'ticker': 'AAPL', 'name': 'Apple Inc.', 'price': '\$185.92', 'change': '+1.23%', 'score': '72'},
  {'ticker': 'GOOGL', 'name': 'Alphabet Inc.', 'price': '\$141.80', 'change': '+0.85%', 'score': '65'},
  {'ticker': 'MSFT', 'name': 'Microsoft Corp.', 'price': '\$378.91', 'change': '-0.42%', 'score': '58'},
  {'ticker': 'TSLA', 'name': 'Tesla Inc.', 'price': '\$248.48', 'change': '+2.15%', 'score': '45'},
  {'ticker': 'NVDA', 'name': 'NVIDIA Corp.', 'price': '\$495.22', 'change': '+3.21%', 'score': '81'},
];
