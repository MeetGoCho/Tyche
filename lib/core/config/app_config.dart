import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get polygonApiKey => dotenv.env['POLYGON_API_KEY'] ?? '';
  static String get environment => dotenv.env['ENV'] ?? 'development';

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}
