import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Strategy Market'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Store'),
            Tab(text: 'Ranking'),
            Tab(text: 'Influencer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStoreTab(),
          _buildRankingTab(),
          _buildInfluencerTab(),
        ],
      ),
    );
  }

  Widget _buildStoreTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _StrategyCard(
          name: _mockStrategies[index]['name']!,
          description: _mockStrategies[index]['description']!,
          winRate: _mockStrategies[index]['winRate']!,
          returns: _mockStrategies[index]['returns']!,
          price: _mockStrategies[index]['price']!,
        );
      },
    );
  }

  Widget _buildRankingTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _RankingItem(
          rank: index + 1,
          name: 'Strategy ${index + 1}',
          returns: '${(30 - index * 2).toStringAsFixed(1)}%',
          subscribers: '${1000 - index * 80}',
        );
      },
    );
  }

  Widget _buildInfluencerTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _InfluencerCard(
          name: _mockInfluencers[index]['name']!,
          followers: _mockInfluencers[index]['followers']!,
          strategies: _mockInfluencers[index]['strategies']!,
        );
      },
    );
  }

  static const List<Map<String, String>> _mockStrategies = [
    {
      'name': 'Golden Cross MA',
      'description': 'Moving average crossover strategy',
      'winRate': '68%',
      'returns': '+24.5%',
      'price': 'Free',
    },
    {
      'name': 'RSI Reversal',
      'description': 'Oversold/overbought reversal strategy',
      'winRate': '62%',
      'returns': '+18.2%',
      'price': '\$9.99',
    },
    {
      'name': 'MACD Momentum',
      'description': 'MACD signal line crossover',
      'winRate': '65%',
      'returns': '+21.8%',
      'price': '\$14.99',
    },
    {
      'name': 'Bollinger Squeeze',
      'description': 'Volatility breakout strategy',
      'winRate': '58%',
      'returns': '+15.6%',
      'price': '\$19.99',
    },
    {
      'name': 'Volume Breakout Pro',
      'description': 'Volume-based breakout signals',
      'winRate': '71%',
      'returns': '+28.3%',
      'price': '\$29.99',
    },
  ];

  static const List<Map<String, String>> _mockInfluencers = [
    {'name': 'TradeMaster', 'followers': '12.5K', 'strategies': '8'},
    {'name': 'AlgoTrader', 'followers': '8.2K', 'strategies': '5'},
    {'name': 'QuanTrader', 'followers': '6.8K', 'strategies': '12'},
    {'name': 'SwingKing', 'followers': '5.1K', 'strategies': '3'},
    {'name': 'DayTraderPro', 'followers': '4.3K', 'strategies': '6'},
  ];
}

class _StrategyCard extends StatelessWidget {
  final String name;
  final String description;
  final String winRate;
  final String returns;
  final String price;

  const _StrategyCard({
    required this.name,
    required this.description,
    required this.winRate,
    required this.returns,
    required this.price,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: price == 'Free'
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    price,
                    style: TextStyle(
                      color:
                          price == 'Free' ? AppColors.success : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(label: 'Win Rate', value: winRate),
                const SizedBox(width: 16),
                _StatChip(
                  label: '1Y Return',
                  value: returns,
                  valueColor: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _RankingItem extends StatelessWidget {
  final int rank;
  final String name;
  final String returns;
  final String subscribers;

  const _RankingItem({
    required this.rank,
    required this.name,
    required this.returns,
    required this.subscribers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.2),
          child: Text(
            '#$rank',
            style: TextStyle(
              color: rank <= 3 ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(name),
        subtitle: Text('$subscribers subscribers'),
        trailing: Text(
          returns,
          style: const TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _InfluencerCard extends StatelessWidget {
  final String name;
  final String followers;
  final String strategies;

  const _InfluencerCard({
    required this.name,
    required this.followers,
    required this.strategies,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            name[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$followers followers'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              strategies,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'strategies',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
