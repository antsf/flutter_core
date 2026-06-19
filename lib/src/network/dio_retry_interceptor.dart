import 'dart:async';
import 'dart:math' show pow;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Configuration options for retrying failed Dio HTTP requests.
class RetryOptions {
  /// Maximum number of retry attempts. Defaults to 3.
  final int maxAttempts;

  /// Base delay between retries in milliseconds. Defaults to 1000ms.
  final int baseDelayMs;

  /// Maximum delay cap when using exponential backoff. Defaults to 10000ms.
  final int maxDelayMs;

  /// Whether to use exponential backoff. Defaults to `true`.
  final bool useExponentialBackoff;

  /// HTTP status codes that trigger a retry. Defaults to transient error codes.
  final List<int> retryableStatusCodes;

  const RetryOptions({
    this.maxAttempts = 3,
    this.baseDelayMs = 1000,
    this.maxDelayMs = 10000,
    this.useExponentialBackoff = true,
    this.retryableStatusCodes = const [408, 500, 502, 503, 504],
  });

  int calculateDelay(int attempt) {
    if (!useExponentialBackoff) return baseDelayMs;
    final exponentialDelay = baseDelayMs * pow(2, (attempt - 1).clamp(0, 30));
    return exponentialDelay > maxDelayMs
        ? maxDelayMs
        : exponentialDelay.toInt();
  }
}

/// Dio interceptor that automatically retries failed HTTP requests.
///
/// Retries on timeout/connection errors and configurable HTTP status codes,
/// with optional exponential backoff via [RetryOptions].
class DioRetryInterceptor extends Interceptor {
  final Dio dio;
  final RetryOptions options;
  final Logger? logger;
  final bool enableLogging;

  DioRetryInterceptor({
    required this.dio,
    this.options = const RetryOptions(),
    this.logger,
    this.enableLogging = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['retry_attempt'] ??= 1;
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final currentAttempt = requestOptions.extra['retry_attempt'] as int? ?? 1;

    final shouldRetry = _shouldRetry(err);

    if (currentAttempt < options.maxAttempts && shouldRetry) {
      final delayMs = options.calculateDelay(currentAttempt);

      if (enableLogging && logger != null) {
        logger!.i(
          'DioRetryInterceptor: Retrying ${requestOptions.method} ${requestOptions.uri} '
          '(attempt ${currentAttempt + 1}/${options.maxAttempts}) after ${delayMs}ms.',
        );
      }

      await Future.delayed(Duration(milliseconds: delayMs));
      requestOptions.extra['retry_attempt'] = currentAttempt + 1;

      try {
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      } catch (e) {
        return handler.next(DioException(
          requestOptions: requestOptions,
          error: e,
          message: 'Retry failed with non-Dio exception',
        ));
      }
    } else {
      if (enableLogging && logger != null && shouldRetry) {
        logger!.w(
          'DioRetryInterceptor: Max retry attempts reached for '
          '${requestOptions.method} ${requestOptions.uri}.',
        );
      }
      return handler.next(err);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    if (err.response != null) {
      return options.retryableStatusCodes.contains(err.response!.statusCode);
    }
    return false;
  }
}
