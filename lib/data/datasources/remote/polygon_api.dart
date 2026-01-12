import 'package:dio/dio.dart';
import '../../models/aggregate_response.dart';
import '../../models/ticker_response.dart';

class PolygonApi {
  final Dio _dio;
  final String _apiKey;

  PolygonApi({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  /// 주식 캔들 데이터 조회 (Aggregates)
  Future<AggregateResponse> getAggregates({
    required String ticker,
    required int multiplier,
    required String timespan,
    required String from,
    required String to,
    bool adjusted = true,
    String sort = 'asc',
    int limit = 5000,
  }) async {
    final response = await _dio.get(
      '/v2/aggs/ticker/$ticker/range/$multiplier/$timespan/$from/$to',
      queryParameters: {
        'adjusted': adjusted,
        'sort': sort,
        'limit': limit,
        'apiKey': _apiKey,
      },
    );
    return AggregateResponse.fromJson(response.data);
  }

  /// 티커 검색
  Future<TickerResponse> searchTickers({
    required String query,
    String type = 'CS',
    String market = 'stocks',
    bool active = true,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/v3/reference/tickers',
      queryParameters: {
        'search': query,
        'type': type,
        'market': market,
        'active': active,
        'limit': limit,
        'apiKey': _apiKey,
      },
    );
    return TickerResponse.fromJson(response.data);
  }

  /// 티커 상세 정보
  Future<Map<String, dynamic>> getTickerDetails(String ticker) async {
    final response = await _dio.get(
      '/v3/reference/tickers/$ticker',
      queryParameters: {
        'apiKey': _apiKey,
      },
    );
    return response.data;
  }

  /// 최신 거래 정보
  Future<Map<String, dynamic>> getLastTrade(String ticker) async {
    final response = await _dio.get(
      '/v2/last/trade/$ticker',
      queryParameters: {
        'apiKey': _apiKey,
      },
    );
    return response.data;
  }
}
