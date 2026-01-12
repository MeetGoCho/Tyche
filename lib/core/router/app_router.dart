import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';
import '../../presentation/common/widgets/main_shell.dart';
import '../../presentation/features/home/home_screen.dart';
import '../../presentation/features/search/search_screen.dart';
import '../../presentation/features/stock_detail/stock_detail_screen.dart';
import '../../presentation/features/chart/chart_screen.dart';
import '../../presentation/features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.search,
            name: 'search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.settings,
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
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
