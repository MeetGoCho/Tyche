import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';
import '../../presentation/common/widgets/main_shell.dart';
import '../../presentation/features/home/home_screen.dart';
import '../../presentation/features/search/search_screen.dart';
import '../../presentation/features/stock_detail/stock_detail_screen.dart';
import '../../presentation/features/chart/chart_screen.dart';
import '../../presentation/features/market/market_screen.dart';
import '../../presentation/features/community/community_screen.dart';
import '../../presentation/features/storage/storage_screen.dart';
import '../../presentation/features/mypage/mypage_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.market,
            name: 'market',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MarketScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.community,
            name: 'community',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommunityScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.storage,
            name: 'storage',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StorageScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.mypage,
            name: 'mypage',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyPageScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.search,
            name: 'search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.stockDetail,
        name: 'stockDetail',
        builder: (context, state) {
          final ticker = state.pathParameters['ticker']!;
          return StockDetailScreen(ticker: ticker);
        },
        routes: [
          GoRoute(
            path: 'chart',
            name: 'chart',
            builder: (context, state) {
              final ticker = state.pathParameters['ticker']!;
              return ChartScreen(ticker: ticker);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
