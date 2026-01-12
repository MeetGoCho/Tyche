import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

class Log {
  static void d(dynamic message) => appLogger.d(message);
  static void i(dynamic message) => appLogger.i(message);
  static void w(dynamic message) => appLogger.w(message);
  static void e(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      appLogger.e(message, error: error, stackTrace: stackTrace);
}
