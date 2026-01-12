import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../core/extensions/datetime_extension.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/stock.dart';
import '../../domain/entities/time_frame.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/local/cache_manager.dart';
import '../datasources/remote/polygon_api.dart';

class StockRepositoryImpl implements StockRepository {
  final PolygonApi _api;
  final CacheManager _cache;

  StockRepositoryImpl({
    required PolygonApi api,
    required CacheManager cache,
  })  : _api = api,
        _cache = cache;

  @override
  Future<Either<Failure, List<Candle>>> getCandles({
    required String ticker,
    required TimeFrame timeFrame,
    required DateTime from,
    required DateTime to,
  }) async {
    final cacheKey =
        'candles_${ticker}_${timeFrame.name}_${from.toApiFormat()}_${to.toApiFormat()}';

    // 캐시 확인
    final cached = _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      try {
        final candles = cached
            .map((c) => Candle(
                  open: (c['o'] as num).toDouble(),
                  high: (c['h'] as num).toDouble(),
                  low: (c['l'] as num).toDouble(),
                  close: (c['c'] as num).toDouble(),
                  volume: (c['v'] as num).toDouble(),
                  vwap: c['vw'] != null ? (c['vw'] as num).toDouble() : null,
                  timestamp: DateTime.fromMillisecondsSinceEpoch(c['t'] as int),
                  transactions: c['n'] as int?,
                ))
            .toList();
        return Right(candles);
      } catch (_) {
        // 캐시 파싱 실패시 API 호출로 fallback
      }
    }

    try {
      final response = await _api.getAggregates(
        ticker: ticker,
        multiplier: timeFrame.multiplier,
        timespan: timeFrame.span,
        from: from.toApiFormat(),
        to: to.toApiFormat(),
      );

      if (response.results == null || response.results!.isEmpty) {
        return const Right([]);
      }

      final candles = response.results!.map((m) => m.toEntity()).toList();

      // 캐시 저장
      await _cache.set(
        cacheKey,
        response.results!.map((m) => m.toJson()).toList(),
        duration: const Duration(minutes: 5),
      );

      return Right(candles);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkFailure('No internet connection'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Stock>>> searchStocks(String query) async {
    try {
      final response = await _api.searchTickers(query: query);

      if (response.results == null) {
        return const Right([]);
      }

      final stocks = response.results!.map((m) => m.toEntity()).toList();
      return Right(stocks);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkFailure('No internet connection'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StockDetail>> getStockDetail(String ticker) async {
    try {
      final response = await _api.getTickerDetails(ticker);
      final results = response['results'] as Map<String, dynamic>?;

      if (results == null) {
        return const Left(ServerFailure('Ticker not found'));
      }

      return Right(StockDetail(
        ticker: results['ticker'] ?? ticker,
        name: results['name'] ?? '',
        market: results['market'] ?? 'stocks',
        exchange: results['primary_exchange'] ?? '',
        type: results['type'] ?? 'CS',
        active: results['active'] ?? true,
        description: results['description'],
        homepageUrl: results['homepage_url'],
        totalEmployees: results['total_employees'],
        listDate: results['list_date'],
        marketCap: results['market_cap']?.toDouble(),
        sicDescription: results['sic_description'],
      ));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkFailure('No internet connection'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
