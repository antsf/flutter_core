import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../services/connectivity_service.dart';
import 'api_response.dart';
import 'dio_interceptor.dart';
import 'dio_retry_interceptor.dart';
import 'exceptions/network_exceptions.dart';

class _CacheEntry {
  final dynamic rawData;
  final DateTime expiresAt;

  _CacheEntry(this.rawData, Duration ttl) : expiresAt = DateTime.now().add(ttl);

  bool get isValid => DateTime.now().isBefore(expiresAt);
}

/// Dio-based HTTP client with connectivity checks, token refresh,
/// automatic retry, in-memory GET cache, and structured error handling.
///
/// All HTTP methods return [ApiResponse<T>] — no try-catch needed at the
/// call site.
///
/// ### Quick start
/// ```dart
/// final client = DioClient(
///   baseUrl: 'https://api.example.com',
///   refreshToken: (dio) async {
///     final res = await dio.post('/auth/refresh');
///     return res.data['accessToken'];
///   },
/// );
///
/// client.setAuthToken('your_token');
///
/// // GET with 5-minute in-memory cache
/// final result = await client.get(
///   '/users',
///   fromJson: (d) => User.fromJson(d),
///   cacheTtl: const Duration(minutes: 5),
/// );
///
/// result.when(
///   onSuccess: (user) => print(user?.name),
///   onFailure: (err) => print(err.message),
/// );
/// ```
class DioClient {
  final Dio _dio;
  final ConnectivityService _connectivityService;
  final Logger? _logger;
  final _cache = <String, _CacheEntry>{};

  DioClient({
    required String baseUrl,
    Dio? dio,
    ConnectivityService? connectivityService,
    int connectTimeoutMs = 15000,
    int receiveTimeoutMs = 15000,
    Logger? logger,
    bool enableLogging = true,
    RetryOptions retryOptions = const RetryOptions(),
    Future<String?> Function(Dio)? refreshToken,
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

  // --- HTTP Methods ---

  /// GET request. Pass [cacheTtl] to serve repeated calls from an in-memory
  /// cache. Use [forceRefresh] to bypass the cache for a single call.
  Future<ApiResponse<T>> get<T>(
    String path, {
    T Function(dynamic)? fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) {
    if (cacheTtl != null && !forceRefresh) {
      final key = _cacheKey(path, queryParameters);
      final entry = _cache[key];
      if (entry != null && entry.isValid) {
        return Future.value(_parseResponse<T>(entry.rawData, fromJson));
      }
    }
    return _execute<T>(
      () => _dio.get(path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress),
      fromJson: fromJson,
      cacheKey: cacheTtl != null ? _cacheKey(path, queryParameters) : null,
      cacheTtl: cacheTtl,
    );
  }

  /// POST request.
  Future<ApiResponse<T>> post<T>(
    String path, {
    T Function(dynamic)? fromJson,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _execute(
        () => _dio.post(path,
            data: body,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress),
        fromJson: fromJson,
      );

  /// PUT request.
  Future<ApiResponse<T>> put<T>(
    String path, {
    T Function(dynamic)? fromJson,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _execute(
        () => _dio.put(path,
            data: body,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress),
        fromJson: fromJson,
      );

  /// DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _execute(
        () => _dio.delete(path,
            data: body,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken),
        fromJson: fromJson,
      );

  /// PATCH request.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    T Function(dynamic)? fromJson,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _execute(
        () => _dio.patch(path,
            data: body,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress),
        fromJson: fromJson,
      );

  // --- File download ---

  /// Downloads a file from [urlPath] to [savePath].
  /// Throws [NetworkException] on failure (not wrapped in [ApiResponse]).
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
      await _dio.download(urlPath, savePath,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress);
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e, s) {
      _logger?.e('DioClient: download error', error: e, stackTrace: s);
      throw UnknownNetworkException(
          dioException:
              DioException(requestOptions: RequestOptions(path: urlPath)));
    }
  }

  // --- Cache management ---

  /// Clears all in-memory cached GET responses.
  void clearCache() => _cache.clear();

  /// Removes the cached response for [path] + optional [queryParameters].
  void invalidateCache(String path, {Map<String, dynamic>? queryParameters}) =>
      _cache.remove(_cacheKey(path, queryParameters));

  // --- Token & headers ---

  void setAuthToken(String token) =>
      _dio.options.headers['Authorization'] = 'Bearer $token';

  void clearAuthToken() => _dio.options.headers.remove('Authorization');

  void addHeader(String key, String value) => _dio.options.headers[key] = value;

  void removeHeader(String key) => _dio.options.headers.remove(key);

  void clearHeaders() => _dio.options.headers.clear();

  String? get authToken => _dio.options.headers['Authorization'] as String?;

  /// Direct access to the underlying [Dio] instance. Use with caution.
  Dio get dioInstance => _dio;

  // --- Private ---

  Future<ApiResponse<T>> _execute<T>(
    Future<Response<dynamic>> Function() call, {
    T Function(dynamic)? fromJson,
    String? cacheKey,
    Duration? cacheTtl,
  }) async {
    try {
      await _checkConnectivity();
      final response = await call();
      final rawData = response.data;
      if (cacheKey != null && cacheTtl != null && rawData != null) {
        _cache[cacheKey] = _CacheEntry(rawData, cacheTtl);
      }
      return _parseResponse<T>(rawData, fromJson);
    } on NetworkException catch (e) {
      return ApiResponse.failure(e);
    } on DioException catch (e) {
      return ApiResponse.failure(NetworkException.fromDioException(e));
    } catch (e, s) {
      _logger?.e('DioClient: unexpected error', error: e, stackTrace: s);
      return ApiResponse.failure(UnknownNetworkException(
          dioException:
              DioException(requestOptions: RequestOptions(path: ''))));
    }
  }

  ApiResponse<T> _parseResponse<T>(
      dynamic rawData, T Function(dynamic)? fromJson) {
    try {
      if (rawData == null) return ApiResponse.success();
      final parsed = fromJson != null ? fromJson(rawData) : rawData as T?;
      return ApiResponse.success(parsed);
    } catch (e, s) {
      _logger?.e('DioClient: response parse error', error: e, stackTrace: s);
      return ApiResponse.failure(UnknownNetworkException(
          dioException:
              DioException(requestOptions: RequestOptions(path: ''))));
    }
  }

  Future<void> _checkConnectivity() async {
    if (!await _connectivityService.hasConnection()) {
      throw NoInternetConnectionException(
        dioException: DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
          message: 'No internet connection.',
        ),
      );
    }
  }

  String _cacheKey(String path, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return path;
    final sorted = Map.fromEntries(
        query.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    return '$path?${sorted.entries.map((e) => '${e.key}=${e.value}').join('&')}';
  }

  void _setupInterceptors({
    required bool enableLogging,
    required RetryOptions retryOptions,
    required Future<String?> Function(Dio)? refreshTokenCallback,
  }) {
    if (enableLogging && _logger != null) {
      _dio.interceptors
          .add(DioLoggingInterceptor(logger: _logger, enableLogging: true));
    }

    if (refreshTokenCallback != null) {
      _dio.interceptors.add(InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            _logger?.i('DioClient: 401 received. Attempting token refresh.');
            try {
              final dioForRefresh =
                  Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
              final newToken = await refreshTokenCallback(dioForRefresh);
              if (newToken != null) {
                setAuthToken(newToken);
                _logger?.i('DioClient: Token refreshed. Retrying request.');
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                return handler.resolve(await _dio.fetch(error.requestOptions));
              }
              _logger?.w('DioClient: Token refresh returned null.');
            } catch (e, s) {
              _logger?.e('DioClient: Token refresh failed.',
                  error: e, stackTrace: s);
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
}
