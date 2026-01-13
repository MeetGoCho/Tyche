abstract class RouteNames {
  static const String market = '/market';
  static const String community = '/community';
  static const String home = '/';
  static const String storage = '/storage';
  static const String mypage = '/mypage';
  static const String search = '/search';
  static const String stockDetail = '/stock/:ticker';
  static const String chart = '/stock/:ticker/chart';
}

abstract class RoutePaths {
  static const String market = '/market';
  static const String community = '/community';
  static const String home = '/';
  static const String storage = '/storage';
  static const String mypage = '/mypage';
  static const String search = '/search';

  static String stockDetail(String ticker) => '/stock/$ticker';
  static String chart(String ticker) => '/stock/$ticker/chart';
}
