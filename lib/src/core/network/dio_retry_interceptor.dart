// import 'dart:async';
// import 'dart:math' show pow; // For exponential backoff calculation

// import 'package:dio/dio.dart';
// import 'package:logger/logger.dart';

// /// Configuration options for retrying failed Dio HTTP requests.
// ///
// /// Defines parameters such as the maximum number of retry attempts,
// /// delays between retries (fixed or exponential), and which HTTP status
// /// codes should trigger a retry.
// class RetryOptions {
//   /// The maximum number of times a failed request should be retried.
//   /// Defaults to 3.
//   final int maxAttempts;

//   /// The base delay between retry attempts, in milliseconds.
//   /// If [useExponentialBackoff] is `false`, this delay is used for all retries.
//   /// If `true`, this is the initial delay for the first retry.
//   /// Defaults to 1000ms (1 second).
//   final int baseDelayMs;

//   /// The maximum delay between retries, in milliseconds, when using exponential backoff.
//   /// This caps the delay calculated by the exponential backoff.
//   /// Defaults to 10000ms (10 seconds).
//   final int maxDelayMs;

//   /// Whether to use exponential backoff for calculating retry delays.
//   /// If `true`, the delay between retries increases exponentially (`baseDelayMs * 2^(attempt-1)`).
//   /// If `false`, [baseDelayMs] is used for all retries.
//   /// Defaults to `true`.
//   final bool useExponentialBackoff;

//   /// A list of HTTP status codes that should trigger a retry attempt.
//   /// Requests failing with these status codes will be considered for retrying.
//   /// Defaults to common transient error codes: `[408, 500, 502, 503, 504]`.
//   final List<int> retryableStatusCodes;

//   /// Creates a new [RetryOptions] instance.
//   const RetryOptions({
//     this.maxAttempts = 3,
//     this.baseDelayMs = 1000,
//     this.maxDelayMs = 10000,
//     this.useExponentialBackoff = true,
//     this.retryableStatusCodes = const [
//       408, // Request Timeout
//       500, // Internal Server Error
//       502, // Bad Gateway
//       503, // Service Unavailable
//       504, // Gateway Timeout
//     ],
//   });

//   /// Calculates the delay for the next retry attempt based on the current [attempt] number.
//   ///
//   /// [attempt]: The current retry attempt number (e.g., 1 for the first retry).
//   /// Returns the calculated delay in milliseconds.
//   int calculateDelay(int attempt) {
//     if (!useExponentialBackoff) {
//       return baseDelayMs;
//     }
//     // Exponential backoff: baseDelayMs * 2^(attempt - 1)
//     // Ensure attempt is at least 1 for the power calculation.
//     final exponentialDelay = baseDelayMs *
//         pow(2, (attempt - 1).clamp(0, 30)); // Clamp to avoid overflow
//     return (exponentialDelay > maxDelayMs
//         ? maxDelayMs
//         : exponentialDelay.toInt());
//   }
// }

// /// A Dio [Interceptor] that automatically retries failed HTTP requests.
// ///
// /// This interceptor catches specific types of failures (e.g., network issues or
// /// certain HTTP status codes) and retries the request according to the configured [RetryOptions].
// /// It supports exponential backoff for retry delays.
// ///
// /// **Important:** This interceptor requires a [Dio] instance to be provided to its
// /// constructor to be able to re-execute requests.
// class DioRetryInterceptor extends Interceptor {
//   /// The [Dio] instance used to perform the retry requests.
//   final Dio dio;

//   /// Configuration for retry behavior.
//   final RetryOptions options;

//   /// An optional [Logger] for logging retry attempts.
//   final Logger? logger;

//   /// Enables or disables logging of retry attempts.
//   /// Logging only occurs if [logger] is also provided.
//   final bool enableLogging;

//   /// Creates a [DioRetryInterceptor].
//   ///
//   /// [dio]: The [Dio] client instance that this interceptor will use to retry requests.
//   ///        This should be the same Dio instance to which this interceptor is added.
//   /// [options]: Configuration for retry behavior. Defaults to `RetryOptions()`.
//   /// [logger]: An optional logger for debugging retry attempts.
//   /// [enableLogging]: Whether to log retry attempts. Defaults to `true`.
//   DioRetryInterceptor({
//     required this.dio,
//     this.options = const RetryOptions(),
//     this.logger,
//     this.enableLogging = true,
//   });

//   /// Called when a request is about to be sent.
//   /// Initializes the attempt counter in the request's `extra` field.
//   @override
//   void onRequest(
//       RequestOptions requestOptions, RequestInterceptorHandler handler) {
//     requestOptions.extra['retry_attempt'] = 1;
//     handler.next(requestOptions);
//   }

//   /// Called when an error occurs during a request.
//   ///
//   /// This method implements the core retry logic:
//   /// - Checks if the error is retryable based on the current attempt count and status code.
//   /// - Calculates the delay for the next attempt.
//   /// - Waits for the calculated delay.
//   /// - Increments the attempt counter.
//   /// - Re-executes the request using the provided [dio] instance.
//   @override
//   Future<void> onError(
//     DioException err,
//     ErrorInterceptorHandler handler,
//   ) async {
//     final requestOptions = err.requestOptions;
//     final currentAttempt = requestOptions.extra['retry_attempt'] as int? ?? 1;

//     // Determine if the request should be retried.
//     final bool shouldRetry;
//     if (err.type == DioExceptionType.connectionTimeout ||
//         err.type == DioExceptionType.sendTimeout ||
//         err.type == DioExceptionType.receiveTimeout ||
//         err.type == DioExceptionType.connectionError) {
//       // Retry on timeout or connection errors
//       shouldRetry = true;
//     } else if (err.response != null) {
//       // Retry on specific HTTP status codes
//       shouldRetry =
//           options.retryableStatusCodes.contains(err.response!.statusCode);
//     } else {
//       // Don't retry for other error types (e.g., bad request, cancellation) by default
//       shouldRetry = false;
//     }

//     if (currentAttempt < options.maxAttempts && shouldRetry) {
//       final delayMs = options.calculateDelay(currentAttempt);

//       if (enableLogging && logger != null) {
//         logger!.i(
//           'DioRetryInterceptor: Retrying request ${requestOptions.method} ${requestOptions.uri} '
//           '(attempt ${currentAttempt + 1}/${options.maxAttempts}) after ${delayMs}ms. Error: ${err.message}',
//         );
//       }

//       // Wait for the calculated delay before retrying.
//       await Future.delayed(Duration(milliseconds: delayMs));

//       // Update the attempt counter for the next try.
//       requestOptions.extra['retry_attempt'] = currentAttempt + 1;

//       try {
//         // Re-execute the request using the dio instance.
//         final Response response = await dio.fetch(requestOptions);
//         // If successful, resolve the handler with the new response.
//         return handler.resolve(response);
//       } on DioException catch (retryErr) {
//         // If the retry also fails, pass the new error to the handler.
//         // This ensures the final error reflects the last attempt.
//         return handler.next(retryErr);
//       } catch (e) {
//         // Should not happen if dio.fetch only throws DioException, but as a safeguard.
//         return handler.next(DioException(
//             requestOptions: requestOptions,
//             error: e,
//             message: "Retry failed with non-Dio exception"));
//       }
//     } else {
//       // If max attempts reached or error is not retryable, pass the original error.
//       if (enableLogging && logger != null && shouldRetry) {
//         logger!.w(
//           'DioRetryInterceptor: Max retry attempts reached for ${requestOptions.method} ${requestOptions.uri}. Error: ${err.message}',
//         );
//       }
//       return handler.next(err);
//     }
//   }

//   // onResponse is not typically needed for a retry interceptor,
//   // but it's good practice to include the override if it might be used later.
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     handler.next(response);
//   }
// }
