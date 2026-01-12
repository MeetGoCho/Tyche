# API 가이드

이 문서는 Tyche에서 사용하는 Polygon.io API 연동 방법을 설명합니다.

## Polygon.io 개요

[Polygon.io](https://polygon.io/)는 미국 주식 시장의 실시간 및 과거 데이터를 제공하는 API 서비스입니다.

### API 키 발급

1. [Polygon.io](https://polygon.io/) 회원가입
2. Dashboard에서 API Key 확인
3. `.env` 파일에 키 설정

```
POLYGON_API_KEY=your_api_key_here
```

## 사용하는 API 엔드포인트

### 1. Aggregates (캔들 데이터)

주식의 OHLCV (Open, High, Low, Close, Volume) 데이터를 조회합니다.

**엔드포인트**
```
GET /v2/aggs/ticker/{ticker}/range/{multiplier}/{timespan}/{from}/{to}
```

**파라미터**
| 파라미터 | 설명 | 예시 |
|---------|------|------|
| ticker | 종목 코드 | AAPL |
| multiplier | 시간 단위 배수 | 1 |
| timespan | 시간 단위 | day, hour, minute |
| from | 시작일 | 2024-01-01 |
| to | 종료일 | 2024-12-31 |
| adjusted | 분할/배당 조정 | true |
| sort | 정렬 | asc |
| limit | 최대 결과 수 | 5000 |

**응답 예시**
```json
{
  "ticker": "AAPL",
  "queryCount": 100,
  "resultsCount": 100,
  "adjusted": true,
  "results": [
    {
      "o": 150.25,    // Open
      "h": 152.30,    // High
      "l": 149.80,    // Low
      "c": 151.90,    // Close
      "v": 45000000,  // Volume
      "vw": 151.05,   // VWAP
      "t": 1704067200000,  // Timestamp (ms)
      "n": 250000     // Number of transactions
    }
  ],
  "status": "OK"
}
```

### 2. Tickers (종목 검색)

종목을 검색합니다.

**엔드포인트**
```
GET /v3/reference/tickers
```

**파라미터**
| 파라미터 | 설명 | 예시 |
|---------|------|------|
| search | 검색어 | Apple |
| type | 종목 유형 | CS (Common Stock) |
| market | 시장 | stocks |
| active | 활성 여부 | true |
| limit | 최대 결과 수 | 20 |

**응답 예시**
```json
{
  "results": [
    {
      "ticker": "AAPL",
      "name": "Apple Inc.",
      "market": "stocks",
      "locale": "us",
      "primary_exchange": "XNAS",
      "type": "CS",
      "active": true,
      "currency_name": "usd"
    }
  ],
  "status": "OK",
  "count": 1
}
```

### 3. Ticker Details (종목 상세)

종목의 상세 정보를 조회합니다.

**엔드포인트**
```
GET /v3/reference/tickers/{ticker}
```

## 코드 구현

### PolygonApi 클래스

```dart
// lib/data/datasources/remote/polygon_api.dart

class PolygonApi {
  final Dio _dio;
  final String _apiKey;

  PolygonApi({required Dio dio, required String apiKey})
      : _dio = dio,
        _apiKey = apiKey;

  /// 캔들 데이터 조회
  Future<AggregateResponse> getAggregates({
    required String ticker,
    required int multiplier,
    required String timespan,
    required String from,
    required String to,
  }) async {
    final response = await _dio.get(
      '/v2/aggs/ticker/$ticker/range/$multiplier/$timespan/$from/$to',
      queryParameters: {
        'adjusted': true,
        'sort': 'asc',
        'limit': 5000,
        'apiKey': _apiKey,
      },
    );
    return AggregateResponse.fromJson(response.data);
  }

  /// 종목 검색
  Future<TickerResponse> searchTickers({required String query}) async {
    final response = await _dio.get(
      '/v3/reference/tickers',
      queryParameters: {
        'search': query,
        'type': 'CS',
        'market': 'stocks',
        'active': true,
        'limit': 20,
        'apiKey': _apiKey,
      },
    );
    return TickerResponse.fromJson(response.data);
  }
}
```

### Repository 구현

```dart
// lib/data/repositories/stock_repository_impl.dart

class StockRepositoryImpl implements StockRepository {
  final PolygonApi _api;
  final CacheManager _cache;

  @override
  Future<Either<Failure, List<Candle>>> getCandles({
    required String ticker,
    required TimeFrame timeFrame,
    required DateTime from,
    required DateTime to,
  }) async {
    // 캐시 확인
    final cacheKey = 'candles_${ticker}_${timeFrame.name}';
    final cached = _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return Right(/* 캐시 데이터 변환 */);
    }

    try {
      final response = await _api.getAggregates(
        ticker: ticker,
        multiplier: timeFrame.multiplier,
        timespan: timeFrame.span,
        from: from.toApiFormat(),
        to: to.toApiFormat(),
      );

      final candles = response.results?.map((m) => m.toEntity()).toList() ?? [];

      // 캐시 저장
      await _cache.set(cacheKey, candles, duration: Duration(minutes: 5));

      return Right(candles);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }
}
```

## TimeFrame 매핑

| TimeFrame | multiplier | timespan |
|-----------|------------|----------|
| 1m | 1 | minute |
| 5m | 5 | minute |
| 15m | 15 | minute |
| 1H | 1 | hour |
| 4H | 4 | hour |
| 1D | 1 | day |
| 1W | 1 | week |

## 에러 처리

### HTTP 에러
```dart
on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.connectionError:
      return Left(NetworkFailure('No internet connection'));
    case DioExceptionType.connectionTimeout:
      return Left(ServerFailure('Connection timeout'));
    default:
      return Left(ServerFailure(e.message ?? 'Unknown error'));
  }
}
```

### API 에러 코드
| 코드 | 의미 | 처리 |
|------|------|------|
| 200 | 성공 | 정상 처리 |
| 401 | 인증 실패 | API 키 확인 |
| 429 | Rate Limit | 요청 제한 |
| 500 | 서버 에러 | 재시도 |

## 캐싱 전략

- **캐시 키**: `candles_{ticker}_{timeframe}_{from}_{to}`
- **TTL**: 5분 (실시간 데이터 특성)
- **저장소**: Hive (로컬)

```dart
// 캐시 저장
await _cache.set(
  key,
  data,
  duration: const Duration(minutes: 5),
);

// 캐시 조회
final cached = _cache.get<T>(key);
```

## Rate Limiting

Polygon.io Free Plan 제한:
- 5 API calls/minute
- 무제한 과거 데이터

**권장 사항**:
- 캐시 적극 활용
- 불필요한 중복 호출 방지
- 에러 시 exponential backoff 적용
