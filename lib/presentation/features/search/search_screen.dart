import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // 데모용 검색 결과 (추후 API 연동)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchResults = _demoStocks
            .where((stock) =>
                stock['ticker']!.toLowerCase().contains(query.toLowerCase()) ||
                stock['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search stocks by ticker or name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchController.text.isEmpty) {
      return _PopularStocks();
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different keyword',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final stock = _searchResults[index];
        return _SearchResultItem(
          ticker: stock['ticker']!,
          name: stock['name']!,
          exchange: stock['exchange']!,
          onTap: () => context.push(RoutePaths.stockDetail(stock['ticker']!)),
        );
      },
    );
  }
}

class _PopularStocks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Popular Stocks',
              style: AppTextStyles.h4,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final stock = _popularStocks[index];
              return _SearchResultItem(
                ticker: stock['ticker']!,
                name: stock['name']!,
                exchange: stock['exchange']!,
                onTap: () => context.push(RoutePaths.stockDetail(stock['ticker']!)),
              );
            },
            childCount: _popularStocks.length,
          ),
        ),
      ],
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final String ticker;
  final String name;
  final String exchange;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.ticker,
    required this.name,
    required this.exchange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceLight,
        child: Text(
          ticker[0],
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
        ),
      ),
      title: Text(ticker, style: AppTextStyles.labelLarge),
      subtitle: Text(
        name,
        style: AppTextStyles.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          exchange,
          style: AppTextStyles.bodySmall,
        ),
      ),
    );
  }
}

final _demoStocks = [
  {'ticker': 'AAPL', 'name': 'Apple Inc.', 'exchange': 'NASDAQ'},
  {'ticker': 'GOOGL', 'name': 'Alphabet Inc.', 'exchange': 'NASDAQ'},
  {'ticker': 'MSFT', 'name': 'Microsoft Corporation', 'exchange': 'NASDAQ'},
  {'ticker': 'AMZN', 'name': 'Amazon.com Inc.', 'exchange': 'NASDAQ'},
  {'ticker': 'TSLA', 'name': 'Tesla Inc.', 'exchange': 'NASDAQ'},
  {'ticker': 'NVDA', 'name': 'NVIDIA Corporation', 'exchange': 'NASDAQ'},
  {'ticker': 'META', 'name': 'Meta Platforms Inc.', 'exchange': 'NASDAQ'},
  {'ticker': 'BRK.B', 'name': 'Berkshire Hathaway Inc.', 'exchange': 'NYSE'},
  {'ticker': 'JPM', 'name': 'JPMorgan Chase & Co.', 'exchange': 'NYSE'},
  {'ticker': 'V', 'name': 'Visa Inc.', 'exchange': 'NYSE'},
];

final _popularStocks = [
  {'ticker': 'AAPL', 'name': 'Apple Inc.', 'exchange': 'NASDAQ'},
  {'ticker': 'TSLA', 'name': 'Tesla Inc.', 'exchange': 'NASDAQ'},
  {'ticker': 'NVDA', 'name': 'NVIDIA Corporation', 'exchange': 'NASDAQ'},
  {'ticker': 'MSFT', 'name': 'Microsoft Corporation', 'exchange': 'NASDAQ'},
  {'ticker': 'AMZN', 'name': 'Amazon.com Inc.', 'exchange': 'NASDAQ'},
];
