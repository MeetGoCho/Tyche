abstract class ApiConstants {
  static const String polygonBaseUrl = 'https://api.polygon.io';

  // Endpoints
  static const String aggregates = '/v2/aggs/ticker';
  static const String tickers = '/v3/reference/tickers';
  static const String tickerDetails = '/v3/reference/tickers';
  static const String lastTrade = '/v2/last/trade';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
