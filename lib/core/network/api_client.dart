import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/logger.dart';

class ApiClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.polygonBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(LoggingInterceptor());

    return dio;
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Log.i('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Log.i(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.e(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      err,
    );
    super.onError(err, handler);
  }
}
