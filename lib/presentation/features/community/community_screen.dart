import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
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
        title: const Text('Community'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'By Stock'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralBoard(),
          _buildStockBoard(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showComingSoonDialog(context);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('Post creation will be available after backend integration.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralBoard() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockPosts.length,
      itemBuilder: (context, index) {
        final post = _mockPosts[index];
        return _PostCard(
          author: post['author']!,
          title: post['title']!,
          content: post['content']!,
          likes: post['likes']!,
          comments: post['comments']!,
          time: post['time']!,
        );
      },
    );
  }

  Widget _buildStockBoard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search stock (e.g., \$AAPL)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mockStockPosts.length,
            itemBuilder: (context, index) {
              final post = _mockStockPosts[index];
              return _PostCard(
                author: post['author']!,
                title: post['title']!,
                content: post['content']!,
                likes: post['likes']!,
                comments: post['comments']!,
                time: post['time']!,
                stockTag: post['stockTag'],
              );
            },
          ),
        ),
      ],
    );
  }

  static const List<Map<String, String>> _mockPosts = [
    {
      'author': 'TradeMaster',
      'title': 'Market outlook for this week',
      'content': 'Based on current indicators, I expect volatility to increase...',
      'likes': '42',
      'comments': '15',
      'time': '2h ago',
    },
    {
      'author': 'AlgoTrader',
      'title': 'New RSI strategy backtesting results',
      'content': 'I\'ve been testing a modified RSI strategy and here are the results...',
      'likes': '38',
      'comments': '23',
      'time': '5h ago',
    },
    {
      'author': 'SwingKing',
      'title': 'How I use Bollinger Bands',
      'content': 'Many traders misuse Bollinger Bands. Here\'s my approach...',
      'likes': '56',
      'comments': '31',
      'time': '8h ago',
    },
    {
      'author': 'DayTraderPro',
      'title': 'Volume analysis tips',
      'content': 'Volume is often overlooked. Here are some patterns I look for...',
      'likes': '29',
      'comments': '12',
      'time': '1d ago',
    },
  ];

  static const List<Map<String, String>> _mockStockPosts = [
    {
      'author': 'TechAnalyst',
      'title': 'AAPL breaking out of consolidation',
      'content': 'Apple showing strong momentum after earnings...',
      'likes': '89',
      'comments': '45',
      'time': '1h ago',
      'stockTag': '\$AAPL',
    },
    {
      'author': 'ValueHunter',
      'title': 'NVDA technical analysis',
      'content': 'NVIDIA approaching key resistance level...',
      'likes': '67',
      'comments': '28',
      'time': '3h ago',
      'stockTag': '\$NVDA',
    },
    {
      'author': 'SwingTrader',
      'title': 'TSLA support levels to watch',
      'content': 'Tesla testing important support zone...',
      'likes': '54',
      'comments': '36',
      'time': '6h ago',
      'stockTag': '\$TSLA',
    },
  ];
}

class _PostCard extends StatelessWidget {
  final String author;
  final String title;
  final String content;
  final String likes;
  final String comments;
  final String time;
  final String? stockTag;

  const _PostCard({
    required this.author,
    required this.title,
    required this.content,
    required this.likes,
    required this.comments,
    required this.time,
    this.stockTag,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Coming Soon'),
              content: const Text('Post details will be available after backend integration.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      author[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    author,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (stockTag != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    stockTag!,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    likes,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.comment_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    comments,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
