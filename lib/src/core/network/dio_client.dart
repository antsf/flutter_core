import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_core/src/core/network/api_response.dart' show ApiResponse;
import 'package:flutter_core/src/core/network/safe_call.dart' show safeCall;
import 'package:logger/logger.dart';

import '../services/connectivity_service.dart';
import 'dio_interceptor.dart';
import 'dio_retry_interceptor.dart';
import 'exceptions/network_exceptions.dart';

/// A robust HTTP client built on [Dio] with connectivity checks, token refresh,
/// automatic retry with exponential backoff, and structured error handling.
///
/// ### Features:
/// - Configurable base URL, connect/receive timeouts
/// - [DioLoggingInterceptor]: request/response logging
/// - Token refresh: handles 401 by calling [refreshToken] and retrying
/// - [DioRetryInterceptor]: automatic retry on timeouts and 5xx errors
/// - Pre-flight connectivity check before every request
/// - All errors mapped to typed [NetworkException] subtypes
///
/// ### Example:
/// ```dart
/// final client = DioClient(
///   baseUrl: 'https://api.example.com',
///   logger: Logger(),
///   refreshToken: (dio) async {
///     final res = await dio.post('/auth/refresh');
///     return res.data['accessToken'];
///   },
/// );
/// client.setAuthToken('your_token');
/// ```
class DioClient {
  final Dio _dio;
  final ConnectivityService _connectivityService;
  final Logger? _logger;

  DioClient({
    required String baseUrl,
    Dio? dio,
    ConnectivityService? connectivityService,
    int connectTimeoutMs = 15000,
    int receiveTimeoutMs = 15000,
    Logger? logger,
    bool enableLogging = true,
    RetryOptions retryOptions = const RetryOptions(),
    Future<String?> Function(Dio dioForRefresh)? refreshToken,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: Duration(milliseconds: connectTimeoutMs),
              receiveTimeout: Duration(milliseconds: receiveTimeoutMs),
            )),
        _connectivityService =
            connectivityService ?? ConnectivityService.instance,
        _logger = logger {
    _setupInterceptors(
      enableLogging: enableLogging,
      retryOptions: retryOptions,
      refreshTokenCallback: refreshToken,
    );
  }

  void _setupInterceptors({
    required bool enableLogging,
    required RetryOptions retryOptions,
    required Future<String?> Function(Dio dioForRefresh)? refreshTokenCallback,
  }) {
    if (enableLogging && _logger != null) {
      _dio.interceptors
          .add(DioLoggingInterceptor(logger: _logger, enableLogging: true));
    }

    if (refreshTokenCallback != null) {
      _dio.interceptors.add(InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            if (_logger != null && enableLogging) {
              _logger.i('DioClient: 401 received. Attempting token refresh.');
            }
            try {
              final Dio dioForRefresh =
                  Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
              final newToken = await refreshTokenCallback(dioForRefresh);

              if (newToken != null) {
                setAuthToken(newToken);
                if (_logger != null && enableLogging) {
                  _logger.i('DioClient: Token refreshed. Retrying request.');
                }
                final originalRequestOptions = error.requestOptions;
                originalRequestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                final response = await _dio.fetch(originalRequestOptions);
                return handler.resolve(response);
              } else {
                if (_logger != null && enableLogging) {
                  _logger.w('DioClient: Token refresh returned null.');
                }
              }
            } catch (e, s) {
              if (_logger != null && enableLogging) {
                _logger.e('DioClient: Token refresh failed.',
                    error: e, stackTrace: s);
              }
            }
          }
          return handler.next(error);
        },
      ));
    }

    _dio.interceptors.add(DioRetryInterceptor(
      dio: _dio,
      options: retryOptions,
      logger: _logger,
      enableLogging: enableLogging,
    ));
  }

  // --- Throw-based API ---

  /// GET request. Throws [NetworkException] on failure.
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

  /// POST request. Throws [NetworkException] on failure.
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

  /// PUT request. Throws [NetworkException] on failure.
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

  /// DELETE request. Throws [NetworkException] on failure.
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

  /// PATCH request. Throws [NetworkException] on failure.
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

  Future<Response<T>> _request<T>(
      Future<Response<T>> Function() requestFunction) async {
    await _checkConnectivity();
    try {
      return await requestFunction();
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e, s) {
      if (_logger != null) {
        _logger.e('DioClient: Unexpected error during request.',
            error: e, stackTrace: s);
      }
      throw UnknownNetworkException(
          dioException: DioException(requestOptions: RequestOptions(path: '')));
    }
  }

  // --- Result-based API (ApiResponse) ---

  /// GET request returning [ApiResponse<T>].
  Future<ApiResponse<T>> getWithSafeCallApi<T>(
    String path, {
    required T Function(dynamic) dataBuilder,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
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

  /// POST request returning [ApiResponse<T>].
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

  /// PUT request returning [ApiResponse<T>].
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

  /// DELETE request returning [ApiResponse<T>].
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

  /// PATCH request returning [ApiResponse<T>].
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

  Future<ApiResponse<T>> _requestWithSafeCallApi<T>(
      Future<Response<dynamic>> Function() requestFunction,
      T Function(dynamic) dataBuilder) async {
    await _checkConnectivity();
    return safeCall<T>(() async {
      final response = await requestFunction();
      if (response.data != null) return dataBuilder(response.data);
      return null;
    });
  }

  // --- File download ---

  /// Downloads a file from [urlPath] and saves it to [savePath].
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
        _logger.e('DioClient: Unexpected error during download.',
            error: e, stackTrace: s);
      }
      throw UnknownNetworkException(
        dioException:
            DioException(requestOptions: RequestOptions(path: urlPath)),
      );
    }
  }

  // --- Connectivity ---

  Future<void> _checkConnectivity() async {
    if (!await _connectivityService.hasConnection()) {
      throw NoInternetConnectionException(
        dioException: DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
          message: 'No internet connection detected by ConnectivityService.',
        ),
      );
    }
  }

  // --- Header & token management ---

  void addHeader(String key, String value) =>
      _dio.options.headers[key] = value;

  void removeHeader(String key) => _dio.options.headers.remove(key);

  void clearHeaders() => _dio.options.headers.clear();

  void setAuthToken(String token) => addHeader('Authorization', 'Bearer $token');

  void clearAuthToken() => removeHeader('Authorization');

  String? get authToken => _dio.options.headers['Authorization'] as String?;

  /// Direct access to the underlying [Dio] instance. Use with caution.
  Dio get dioInstance => _dio;
}
