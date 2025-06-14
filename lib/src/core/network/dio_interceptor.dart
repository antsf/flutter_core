/// Interceptor for logging requests, responses, and errors in Dio.
library dio_interceptor;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor for logging and error handling
class DioInterceptor extends Interceptor {
  final Logger? logger;
  final bool enableLogging;

  DioInterceptor({
    this.logger,
    this.enableLogging = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enableLogging) {
      logger?.i(
        'Request: ${options.method} ${options.uri}\n'
        'Headers: ${options.headers}\n'
        'Data: ${options.data}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enableLogging) {
      logger?.i(
        'Response: ${response.statusCode} ${response.statusMessage}\n'
        'Data: ${response.data}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enableLogging) {
      logger?.e(
        'Error: ${err.type}\n'
        'Message: ${err.message}\n'
        'Response: ${err.response?.statusCode} ${err.response?.statusMessage}\n'
        'Data: ${err.response?.data}',
      );
    }
    handler.next(err);
  }
}
