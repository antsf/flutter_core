import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor that retries failed requests with configurable options and exponential backoff.
/// Configuration options for retrying failed requests
class RetryOptions {
  /// Maximum number of retry attempts
  final int maxAttempts;

  /// Base delay between retries in milliseconds
  final int baseDelay;

  /// Maximum delay between retries in milliseconds
  final int maxDelay;

  /// Whether to use exponential backoff
  final bool useExponentialBackoff;

  /// HTTP status codes that should trigger a retry
  final List<int> retryableStatusCodes;

  /// Create a new [RetryOptions] instance
  const RetryOptions({
    this.maxAttempts = 3,
    this.baseDelay = 1000,
    this.maxDelay = 10000,
    this.useExponentialBackoff = true,
    this.retryableStatusCodes = const [408, 500, 502, 503, 504],
  });

  /// Calculate the delay for the next retry attempt
  int calculateDelay(int attempt) {
    if (!useExponentialBackoff) {
      return baseDelay;
    }

    final delay = baseDelay * (1 << (attempt - 1));
    return delay > maxDelay ? maxDelay : delay;
  }
}

/// Interceptor that retries failed requests
class DioRetryInterceptor extends Interceptor {
  final RetryOptions options;
  final Logger? logger;
  final bool enableLogging;
  late final Dio _dio;

  DioRetryInterceptor({
    this.options = const RetryOptions(),
    this.logger,
    this.enableLogging = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['attempt'] = 1;
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final response = err.response;
    final attempt = request.extra['attempt'] as int? ?? 1;

    // Check if we should retry
    if (attempt < options.maxAttempts &&
        (response == null ||
            options.retryableStatusCodes.contains(response.statusCode))) {
      final delay = options.calculateDelay(attempt);

      if (enableLogging) {
        logger?.i(
          'Retrying request ${request.uri} (attempt $attempt/${options.maxAttempts}) after ${delay}ms',
        );
      }

      // Wait before retrying
      await Future.delayed(Duration(milliseconds: delay));

      // Update attempt count
      request.extra['attempt'] = attempt + 1;

      // Retry the request
      try {
        final response = await _dio.fetch(request);
        handler.resolve(response);
      } catch (e) {
        handler.reject(err);
      }
    } else {
      handler.next(err);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}
