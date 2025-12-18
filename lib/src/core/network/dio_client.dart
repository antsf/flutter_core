import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_core/src/core/network/api_response.dart'
    show ApiResponse;
import 'package:flutter_core/src/core/network/safe_call.dart' show safeCall;
import 'package:logger/logger.dart';

import '../services/connectivity_service.dart';
// import 'dio_cache_config.dart';
// import 'dio_interceptor.dart'; // Now DioLoggingInterceptor
import 'dio_interceptor.dart';
// import 'dio_retry_interceptor.dart';
import 'exceptions/network_exceptions.dart';

/// A robust HTTP client built on top of [Dio], incorporating features like
/// request logging, automatic retries, response caching, connectivity checks,
/// and streamlined error handling through custom [NetworkException]s.
/// It also includes support for automatic token refresh on 401 errors if a
/// `refreshToken` callback is provided.
///
/// ### Features:
/// - **Base URL and Timeouts**: Configurable base URL, connect, and receive timeouts.
/// - **Interceptors**:
///   - [DioLoggingInterceptor]: For detailed logging of requests and responses.
///   - Token Refresh: Handles 401 errors by attempting to refresh the token and retry the request.
///   - [DioRetryInterceptor]: Automatically retries failed requests based on [RetryOptions].
///   - Caching: Integrates with [DioCacheConfig] for response caching.
/// - **Connectivity Check**: Verifies internet connectivity before making a request.
/// - **Error Handling**: Converts [DioException]s into specific [NetworkException] subtypes.
/// - **Header Management**: Utility methods to add, remove, and manage request headers,
///   including authentication tokens.
///
/// ### Initialization Example:
/// ```dart
/// final dioClient = DioClient(
///   baseUrl: 'https://api.example.com',
///   logger: Logger(), // Your logger instance
///   cacheConfig: DioCacheConfig(cachePath: 'my_api_cache'),
///   retryOptions: RetryOptions(maxAttempts: 2),
///   refreshToken: (dioInstance) async {
///     // Your token refresh logic here, e.g., call a refresh token endpoint
///     // final response = await dioInstance.post('/auth/refresh', data: {'refreshToken': '...'});
///     // return response.data['accessToken'];
///     return 'new_refreshed_token';
///   },
/// );
///
/// // Set auth token if available
/// // dioClient.setAuthToken('your_initial_auth_token');
/// ```
class DioClient {
  /// The internal [Dio] instance used for making HTTP requests.
  final Dio _dio;

  /// Service to check for internet connectivity.
  final ConnectivityService _connectivityService;

  /// Logger instance for logging network activities.
  final Logger? _logger;

  /// Creates a [DioClient] instance.
  ///
  /// - [baseUrl]: The base URL for all API requests.
  /// - [connectTimeoutMs]: Connection timeout in milliseconds. Defaults to 15000ms.
  /// - [receiveTimeoutMs]: Receive timeout in milliseconds. Defaults to 15000ms.
  /// - [cacheConfig]: Optional [DioCacheConfig] for response caching.
  /// - [logger]: Optional [Logger] instance for request/response logging.
  /// - [enableLogging]: Whether to enable logging. Defaults to `true`. Ignored if [logger] is null.
  /// - [retryOptions]: Configuration for request retries. Defaults to `RetryOptions()`.
  /// - [refreshToken]: An optional asynchronous function that takes the current [Dio] instance
  ///   and attempts to refresh an authentication token. It should return the new token as a [String]
  ///   or `null` if refresh fails. If provided, 401 errors will trigger this refresh mechanism.
  ///   The passed Dio instance for `refreshToken` is a separate, clean instance to avoid
  ///   interceptor loops during the refresh process itself.
  DioClient({
    required String baseUrl,
    Dio? dio,
    ConnectivityService? connectivityService,
    int connectTimeoutMs = 15000,
    int receiveTimeoutMs = 15000,
    // DioCacheConfig? cacheConfig,
    Logger? logger,
    bool enableLogging = true,
    // RetryOptions retryOptions = const RetryOptions(),
    Future<String?> Function(Dio dioForRefresh)? refreshToken,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: Duration(milliseconds: connectTimeoutMs),
              receiveTimeout: Duration(milliseconds: receiveTimeoutMs),
              // Default headers can be set here if needed, e.g., {'Content-Type': 'application/json'}
            )),
        _connectivityService =
            connectivityService ?? ConnectivityService.instance,
        _logger = logger {
    _setupInterceptors(
      enableLogging: enableLogging,
      // retryOptions: retryOptions,
      // cacheConfig: cacheConfig,
      refreshTokenCallback: refreshToken,
    );
  }

  /// Configures and adds necessary interceptors to the Dio instance.
  void _setupInterceptors({
    required bool enableLogging,
    // required RetryOptions retryOptions,
    // required DioCacheConfig? cacheConfig,
    required Future<String?> Function(Dio dioForRefresh)? refreshTokenCallback,
  }) {
    // Logging Interceptor (conditionally added)
    if (enableLogging && _logger != null) {
      _dio.interceptors
          .add(DioLoggingInterceptor(logger: _logger, enableLogging: true));
    }

    // Token Refresh Interceptor (if callback is provided)
    if (refreshTokenCallback != null) {
      _dio.interceptors.add(InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            if (_logger != null && enableLogging) {
              _logger.i(
                  'DioClient: Received 401 Unauthorized. Attempting token refresh.');
            }
            try {
              // Create a new Dio instance for the refresh token call to avoid
              // recursive calls to this interceptor or using stale headers.
              final Dio dioForRefresh =
                  Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
              final newToken = await refreshTokenCallback(dioForRefresh);

              if (_logger != null && enableLogging) {
                _logger.i('DioClient: New token = $newToken');
              }

              if (newToken != null) {
                setAuthToken(
                    newToken); // Update the token in the main Dio instance
                if (_logger != null && enableLogging) {
                  _logger.i(
                      'DioClient: Token refreshed successfully. Retrying original request.');
                }
                // Clone the original request with the new token in headers
                final originalRequestOptions = error.requestOptions;
                originalRequestOptions.headers['Authorization'] =
                    'Bearer $newToken';

                final response = await _dio.fetch(originalRequestOptions);
                return handler.resolve(response);
              } else {
                if (_logger != null && enableLogging) {
                  _logger.w(
                      'DioClient: Token refresh returned null. Propagating original 401 error.');
                }
              }
            } catch (e, s) {
              if (_logger != null && enableLogging) {
                _logger.e('DioClient: Token refresh failed.',
                    error: e, stackTrace: s);
              }
              // If token refresh itself fails, proceed with the original error.
            }
          }
          return handler.next(error);
        },
      ));
    }

    // Retry Interceptor
    // _dio.interceptors.add(DioRetryInterceptor(
    //   dio: _dio, // Pass the Dio instance for retries
    //   options: retryOptions,
    //   logger: _logger,
    //   enableLogging: enableLogging,
    // ));

    // Cache Interceptor (if configured)
    // if (cacheConfig != null) {
    //   _dio.interceptors.add(cacheConfig.interceptor);
    // }
  }

  /// Executes a GET request.
  ///
  /// Throws a [NetworkException] subtype on failure.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request<T>(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// Executes a POST request.
  ///
  /// Throws a [NetworkException] subtype on failure.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request<T>(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// Executes a PUT request.
  ///
  /// Throws a [NetworkException] subtype on failure.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request<T>(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// Executes a DELETE request.
  ///
  /// Throws a [NetworkException] subtype on failure.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request<T>(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Executes a PATCH request.
  ///
  /// Throws a [NetworkException] subtype on failure.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request<T>(
      () => _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// Generic request wrapper that handles connectivity check and error translation.
  ///
  /// It first checks for internet connectivity. If connected, it executes the
  /// provided [request] function. [DioException]s are caught and converted
  /// to [NetworkException]s. Other exceptions are rethrown as generic [Exception]s.
  Future<Response<T>> _request<T>(
      Future<Response<T>> Function() requestFunction) async {
    await _checkConnectivity();
    try {
      return await requestFunction();
    } on DioException catch (e) {
      // Convert DioException to a custom NetworkException
      throw NetworkException.fromDioException(e);
    } catch (e, s) {
      // For non-Dio errors that are not already NetworkExceptions,
      // wrap them in a generic UnknownNetworkException or rethrow if appropriate.
      if (_logger != null) {
        _logger.e(
            'DioClient: An unexpected non-Dio error occurred during request.',
            error: e,
            stackTrace: s);
      }
      // To maintain consistency of throwing NetworkException subtypes:
      throw UnknownNetworkException(
          dioException: DioException(requestOptions: RequestOptions(path: '')));
      // Alternatively, rethrow e if specific handling outside is preferred:
      // throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- API Response Wrapper Methods (Updated to use _requestWithSafeCallApi) ---

  /// Executes a GET request that returns an `ApiResponse<T>`.
  Future<ApiResponse<T>> getWithSafeCallApi<T>(
    String path, {
    required T Function(dynamic) dataBuilder,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Simply call the centralized request function
    return _requestWithSafeCallApi<T>(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
      dataBuilder,
    );
  }

  /// Executes a POST request that returns an `ApiResponse<T>`.
  Future<ApiResponse<T>> postWithSafeCallApi<T>(
    String path, {
    required T Function(dynamic) dataBuilder,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Simply call the centralized request function
    return _requestWithSafeCallApi<T>(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      dataBuilder,
    );
  }

  /// Executes a PUT request that returns an `ApiResponse<T>`.
  Future<ApiResponse<T>> putWithSafeCallApi<T>(
    String path, {
    required T Function(dynamic) dataBuilder,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _requestWithSafeCallApi<T>(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      dataBuilder,
    );
  }

  /// Executes a DELETE request that returns an `ApiResponse<T>`.
  Future<ApiResponse<T>> deleteWithSafeCallApi<T>(
    String path, {
    required T Function(dynamic) dataBuilder,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _requestWithSafeCallApi<T>(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      dataBuilder,
    );
  }

  /// Executes a PATCH request that returns an `ApiResponse<T>`.
  Future<ApiResponse<T>> patchWithSafeCallApi<T>(
    String path, {
    required T Function(dynamic) dataBuilder,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _requestWithSafeCallApi<T>(
      () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      dataBuilder,
    );
  }

  /// Generic request wrapper for the Result Pattern that uses [safeCall]
  /// to automatically handle all exceptions.
  ///
  /// This function now focuses purely on executing the request and performing DTO mapping.
  Future<ApiResponse<T>> _requestWithSafeCallApi<T>(
      Future<Response<dynamic>> Function() requestFunction,
      T Function(dynamic) dataBuilder) async {
    await _checkConnectivity();
    // Wrap the execution and mapping logic in safeCall
    return safeCall<T>(() async {
      // Note: We assume _checkConnectivity is handled either before this function
      // is called or within the requestFunction's internal logic.

      final response = await requestFunction();

      // Check if data is present and map it.
      if (response.data != null) {
        // Assuming response.data is the JSON map that dataBuilder expects.
        // We explicitly return the result of the DTO building.
        return dataBuilder(response.data);
      }

      // If response.data is null (e.g., 204 No Content), return null.
      // safeCall will interpret this as a business failure and wrap it appropriately.
      return null;
    });
  }

  /// Downloads a file from the specified [urlPath] and saves it to [savePath].
  ///
  /// - [urlPath]: The endpoint to download the file from (appended to the base URL).
  /// - [savePath]: The local file path where the downloaded file will be saved.
  /// - [queryParameters]: Optional query parameters for the request.
  /// - [options]: Optional Dio request options (e.g., headers).
  /// - [cancelToken]: Optional token to cancel the download.
  /// - [onReceiveProgress]: Optional callback to track download progress.
  /// Throws a [NetworkException] subtype on failure.
  Future<void> download(
    String urlPath, {
    required dynamic savePath,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    await _checkConnectivity();
    try {
      await _dio.download(
        urlPath,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e, s) {
      if (_logger != null) {
        _logger.e(
          'DioClient: An unexpected error occurred during download.',
          error: e,
          stackTrace: s,
        );
      }
      throw UnknownNetworkException(
        dioException:
            DioException(requestOptions: RequestOptions(path: urlPath)),
      );
    }
  }

  /// Checks for an active internet connection before making a request.
  /// Throws [NoInternetConnectionException] if no connection is available.
  Future<void> _checkConnectivity() async {
    if (!await _connectivityService.hasConnection()) {
      // Construct a minimal DioException to pass to NoInternetConnectionException
      // as it expects one, even if the root cause isn't a Dio network layer error
      // but rather a pre-flight check failure.
      final artificialDioException = DioException(
          requestOptions: RequestOptions(path: ''), // Dummy path
          type: DioExceptionType.connectionError, // Appropriate type
          message: 'No internet connection detected by ConnectivityService.');
      throw NoInternetConnectionException(dioException: artificialDioException);
    }
  }

  // --- Header and Token Management ---

  /// Adds a custom header to all subsequent requests made by this Dio instance.
  /// If a header with the same [key] already exists, its value is updated.
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Removes a custom header identified by [key] from subsequent requests.
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Clears all custom headers from the Dio instance's options.
  void clearHeaders() {
    _dio.options.headers.clear();
  }

  /// Sets the 'Authorization' header with a Bearer token.
  ///
  /// [token]: The authentication token (without the "Bearer " prefix).
  void setAuthToken(String token) {
    addHeader('Authorization', 'Bearer $token');
  }

  /// Clears the 'Authorization' header.
  void clearAuthToken() {
    removeHeader('Authorization');
  }

  /// Gets the current value of the 'Authorization' header.
  /// Returns the full header value (e.g., "Bearer your_token") or null if not set.
  String? get authToken => _dio.options.headers['Authorization'] as String?;

  /// Provides direct access to the underlying [Dio] instance.
  ///
  /// **Use with caution.** Modifying the Dio instance directly (e.g., adding interceptors
  /// not managed by this class) might lead to unexpected behavior.
  /// This is exposed for advanced use cases or if direct Dio functionalities are needed.
  Dio get dioInstance => _dio;
}
