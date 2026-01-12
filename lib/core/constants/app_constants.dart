abstract class AppConstants {
  static const String appName = 'Tyche';
  static const String appVersion = '1.0.0';

  // 기본 설정
  static const int defaultCandleLimit = 500;
  static const int maxCandleLimit = 5000;

  // 타임프레임
  static const List<String> timeFrames = ['1m', '5m', '15m', '1h', '4h', '1D', '1W'];

  // 점수 범위
  static const int scoreMin = 0;
  static const int scoreMax = 100;

  // 캐시 기간 (분)
  static const int cacheMinutes = 5;
}
