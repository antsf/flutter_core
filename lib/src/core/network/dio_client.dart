import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../services/connectivity_service.dart';
import 'dio_cache_config.dart';
import 'dio_interceptor.dart';
import 'dio_retry_interceptor.dart';
import 'exceptions/network_exceptions.dart';

/// A Dio-based HTTP client with retry, caching, token refresh, and logging capabilities.
class DioClient {
  final Dio _dio;
  final ConnectivityService _connectivityService;

  DioClient({
    required String baseUrl,
    int connectTimeout = 15000,
    int receiveTimeout = 15000,
    DioCacheConfig? cacheConfig,
    Logger? logger,
    bool enableLogging = true,
    RetryOptions retryOptions = const RetryOptions(),
    Future<String?> Function(Dio dio)? refreshToken,
  })  : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(milliseconds: connectTimeout),
          receiveTimeout: Duration(milliseconds: receiveTimeout),
        )),
        _connectivityService = ConnectivityService.instance {
    _setupInterceptors(
      logger: logger,
      enableLogging: enableLogging,
      retryOptions: retryOptions,
      cacheConfig: cacheConfig,
      refreshToken: refreshToken,
    );
  }

  void _setupInterceptors({
    required Logger? logger,
    required bool enableLogging,
    required RetryOptions retryOptions,
    required DioCacheConfig? cacheConfig,
    required Future<String?> Function(Dio dio)? refreshToken,
  }) {
    _dio.interceptors
        .add(DioInterceptor(logger: logger, enableLogging: enableLogging));

    if (refreshToken != null) {
      _dio.interceptors.add(InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final newToken = await refreshToken(_dio);
              if (newToken != null) {
                setAuthToken(newToken);
                // Repeat the original request with the new token.
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (e) {
              // If token refresh fails, proceed with the original error.
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ));
    }

    _dio.interceptors.add(DioRetryInterceptor(
      options: retryOptions,
      logger: logger,
      enableLogging: enableLogging,
    ));

    if (cacheConfig != null) {
      _dio.interceptors.add(cacheConfig.interceptor);
    }
  }

  /// Executes a GET request.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// Executes a POST request.
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(
      () => _dio.post(
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
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(
      () => _dio.put(
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
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Executes a PATCH request.
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(
      () => _dio.patch(
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

  /// A generic request wrapper that handles connectivity checks and error translation.
  Future<Response> _request(Future<Response> Function() request) async {
    await _checkConnectivity();
    try {
      return await request();
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      // For non-Dio errors, rethrow them as a generic exception.
      // This part is debatable, but it ensures all thrown errors from this client are Exceptions.
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Checks for an active internet connection before making a request.
  Future<void> _checkConnectivity() async {
    if (!await _connectivityService.hasConnection()) {
      throw NoInternetConnectionException(
        dioException: DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );
    }
  }

  // --- Header and Token Management ---

  /// Adds a custom header to all subsequent requests.
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Removes a custom header.
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Clears all custom headers.
  void clearHeaders() {
    _dio.options.headers.clear();
  }

  /// Sets the authentication token (e.g., "Bearer token").
  void setAuthToken(String token) {
    addHeader('Authorization', 'Bearer $token');
  }

  /// Clears the authentication token.
  void clearAuthToken() {
    removeHeader('Authorization');
  }

  /// Gets the current authentication token.
  String? get authToken => _dio.options.headers['Authorization'] as String?;
}
