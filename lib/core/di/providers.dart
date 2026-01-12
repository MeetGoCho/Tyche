import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../../data/datasources/local/cache_manager.dart';
import '../../data/datasources/remote/polygon_api.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/repositories/stock_repository.dart';

// Dio 클라이언트
final dioProvider = Provider<Dio>((ref) {
  return ApiClient.createDio();
});

// API Key
final apiKeyProvider = Provider<String>((ref) {
  return AppConfig.polygonApiKey;
});

// 환경 설정
final environmentProvider = Provider<String>((ref) {
  return AppConfig.environment;
});

// Cache Manager
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

// Polygon API
final polygonApiProvider = Provider<PolygonApi>((ref) {
  return PolygonApi(
    dio: ref.watch(dioProvider),
    apiKey: ref.watch(apiKeyProvider),
  );
});

// Stock Repository
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepositoryImpl(
    api: ref.watch(polygonApiProvider),
    cache: ref.watch(cacheManagerProvider),
  );
});
