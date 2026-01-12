abstract class RouteNames {
  static const String home = '/';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String stockDetail = '/stock/:ticker';
  static const String chart = '/stock/:ticker/chart';
}

abstract class RoutePaths {
  static const String home = '/';
  static const String search = '/search';
  static const String settings = '/settings';

  static String stockDetail(String ticker) => '/stock/$ticker';
  static String chart(String ticker) => '/stock/$ticker/chart';
}
