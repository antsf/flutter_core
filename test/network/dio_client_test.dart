import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core/src/core/network/dio_client.dart';
import 'package:flutter_core/src/core/network/dio_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes using Mocktail
class MockDio extends Mock implements Dio {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockLogger extends Mock implements Logger {}

class MockRequestOptions extends Mock implements RequestOptions {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late DioClient dioClient;
  late MockDio mockDio;
  late MockConnectivityService mockConnectivityService;
  late MockLogger mockLogger;
  late BaseOptions baseOptions;
  late Interceptors interceptors; // Real Interceptors instance for mocking

  const baseUrl = 'https://api.example.com';
  const connectTimeoutMs = 15000;
  const receiveTimeoutMs = 15000;

  setUpAll(() {
    // Register fallbacks for complex types required by Mocktail
    registerFallbackValue(Uri.parse(baseUrl));
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(CancelToken());
    registerFallbackValue(Options());
    registerFallbackValue(StackTrace.empty);
    registerFallbackValue(
        DioException(requestOptions: RequestOptions(path: '')));
  });

  setUp(() {
    mockDio = MockDio();
    mockConnectivityService = MockConnectivityService();
    mockLogger = MockLogger();
    interceptors = Interceptors(); // Initialize real Interceptors instance

    // Mock BaseOptions for Dio
    baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: receiveTimeoutMs),
    );
    when(() => mockDio.options).thenReturn(baseOptions);
    // Mock interceptors property to return a real Interceptors instance
    when(() => mockDio.interceptors).thenReturn(interceptors);

    // Initialize DioClient with mocks
    dioClient = DioClient(
      baseUrl: baseUrl,
      dio: mockDio,
      connectivityService: mockConnectivityService,
      logger: mockLogger,
      enableLogging: true,
      refreshToken: (dio) async => 'new_refreshed_token',
    );

    // Register fallback values for any unmocked calls
    // registerFallbackValue(RequestOptions(path: ''));
    // registerFallbackValue(CancelToken());
    // registerFallbackValue(
    //     DioException(requestOptions: RequestOptions(path: '')));
  });

  group('DioClient Initialization', () {
    test('should initialize Dio with correct base URL and timeouts', () {
      expect(dioClient.dioInstance.options.baseUrl, baseUrl);
      expect(
        dioClient.dioInstance.options.connectTimeout,
        const Duration(milliseconds: connectTimeoutMs),
      );
      expect(
        dioClient.dioInstance.options.receiveTimeout,
        const Duration(milliseconds: receiveTimeoutMs),
      );
    });

    test('should add logging interceptor when enableLogging is true', () {
      expect(
        dioClient.dioInstance.interceptors
            .any((interceptor) => interceptor is DioLoggingInterceptor),
        isTrue,
      );
    });

    test(
        'should add token refresh interceptor when refreshToken callback is provided',
        () {
      expect(
        dioClient.dioInstance.interceptors
            .any((interceptor) => interceptor is InterceptorsWrapper),
        isTrue,
      );
    });
  });

  group('HTTP Requests', () {
    const testPath = '/test';
    final testData = {'key': 'value'};
    final testResponseData = {'result': 'success'};
    final response = Response(
      requestOptions: RequestOptions(path: testPath),
      data: {'result': 'success'},
      statusCode: 200,
    );

    setUp(() {
      when(() => mockConnectivityService.hasConnection())
          .thenAnswer((_) async => true);
    });

    test('GET request returns successful response', () async {
      when(() => mockDio.get(
            testPath,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenAnswer((_) async => response);

      final result = await dioClient.get(testPath);

      expect(result.data, testResponseData);
      expect(result.statusCode, 200);
      verify(() => mockDio.get(testPath)).called(1);
    });

    test('POST request returns successful response', () async {
      when(() => mockDio.post(
            testPath,
            data: testData,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenAnswer((_) async => response);

      final result = await dioClient.post(testPath, data: testData);

      expect(result.data, testResponseData);
      expect(result.statusCode, 200);
      verify(() => mockDio.post(testPath, data: testData)).called(1);
    });

    test('PUT request returns successful response', () async {
      when(() => mockDio.put(
            testPath,
            data: testData,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenAnswer((_) async => response);

      final result = await dioClient.put(testPath, data: testData);

      expect(result.data, testResponseData);
      expect(result.statusCode, 200);
      verify(() => mockDio.put(testPath, data: testData)).called(1);
    });

    test('DELETE request returns successful response', () async {
      when(() => mockDio.delete(
            testPath,
            data: testData,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer((_) async => response);

      final result = await dioClient.delete(testPath, data: testData);

      expect(result.data, testResponseData);
      expect(result.statusCode, 200);
      verify(() => mockDio.delete(testPath, data: testData)).called(1);
    });

    test('PATCH request returns successful response', () async {
      when(() => mockDio.patch(
            testPath,
            data: testData,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenAnswer((_) async => response);

      final result = await dioClient.patch(testPath, data: testData);

      expect(result.data, testResponseData);
      expect(result.statusCode, 200);
      verify(() => mockDio.patch(testPath, data: testData)).called(1);
    });
  });

  group('ApiResponse Wrapped Requests', () {
    const testPath = '/test';
    final testResponseData = {'result': 'success'};
    final response = Response(
      requestOptions: RequestOptions(path: testPath),
      data: testResponseData,
      statusCode: 200,
    );

    setUp(() {
      when(() => mockConnectivityService.hasConnection())
          .thenAnswer((_) async => true);
    });

    test('getWithSafeCallApi returns ApiResponse.success', () async {
      when(() => mockDio.get(
            testPath,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenAnswer((_) async => response);

      final result = await dioClient.getWithSafeCallApi<String>(
        testPath,
        dataBuilder: (data) => data['result'] as String,
      );

      expect(result.isSuccessful, isTrue);
      expect(result.data, 'success');
      verify(() => mockDio.get(testPath)).called(1);
    });

    test('postWithSafeCallApi handles null response data as failure', () async {
      final nullResponse = Response(
        requestOptions: RequestOptions(path: testPath),
        data: null,
        statusCode: 204,
      );

      when(() => mockDio.post(
            testPath,
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenAnswer((_) async => nullResponse);

      final result = await dioClient.postWithSafeCallApi<String>(
        testPath,
        dataBuilder: (data) => data['result'] as String,
        data: {'key': 'value'},
      );

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ClientErrorException>());
      verify(() => mockDio.post(testPath, data: any(named: 'data'))).called(1);
    });
  });

  group('Error Handling', () {
    const testPath = '/test';

    setUp(() {
      when(() => mockConnectivityService.hasConnection())
          .thenAnswer((_) async => true);
    });

    test('handles 401 Unauthorized with token refresh', () async {
      // ARRANGE
      final errorResponse = Response(
        requestOptions: RequestOptions(path: testPath),
        statusCode: 401,
      );
      final dioException = DioException(
        requestOptions: RequestOptions(path: testPath),
        response: errorResponse,
        type: DioExceptionType.badResponse,
      );
      final successResponse = Response(
        requestOptions: RequestOptions(path: testPath),
        data: {'result': 'success'},
        statusCode: 200,
      );

      // --- CRUCIAL MOCK SETUP ---
      // 1. Set up a mock sequence for the initial public API call (dio.get).
      // This is complicated because the refresh logic runs inside the interceptor.

      // Let's mock the internal method DioClient._request relies on: dio.fetch(any())
      // Use a CallSequence to throw first, then return success.
      // This pattern is complex because the interceptor makes the second call via dio.fetch(newOptions).

      // We will mock the external .get() call to throw the first time,
      // and then mock the internal .fetch() call (used by the interceptor for retry) to succeed.

      // Mock the initial public API call to throw the 401
      // Use setup that matches the first attempt exactly
      when(() => mockDio.get(
            testPath,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenThrow(dioException);

      // Mock the internal dio.fetch call which is used by the interceptor for the retry.
      // We rely on the interceptor to catch the 401 and call dio.fetch for the retry.
      // NOTE: This setup relies on your interceptor being correctly added to the real Interceptors list.
      when(() => mockDio.fetch(
            // Use a matcher to ensure it's the retried call (e.g., has the new token)
            any(
                that: isA<RequestOptions>().having(
                    (opt) => opt.headers['Authorization'],
                    'Authorization header',
                    'Bearer new_refreshed_token')),
          )).thenAnswer((_) async => successResponse);

      // ACT
      final result = await dioClient.get(testPath);

      // ASSERT
      expect(result.data, {'result': 'success'});
      expect(result.statusCode, 200);
      expect(dioClient.authToken, 'Bearer new_refreshed_token');

      // VERIFY
      // Initial call to .get() is made (it throws)
      verify(() => mockDio.get(testPath,
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onReceiveProgress: any(named: 'onReceiveProgress'))).called(1);

      // The retry call to .fetch() is made by the interceptor
      verify(() => mockDio.fetch(any())).called(1);
    });

    test('throws NoInternetConnectionException when connectivity check fails',
        () async {
      when(() => mockConnectivityService.hasConnection())
          .thenAnswer((_) async => false);

      expect(
        () => dioClient.get(testPath),
        throwsA(isA<NoInternetConnectionException>()),
      );
    });

    test('throws UnauthorizedException for 401 errors without refresh',
        () async {
      final errorResponse = Response(
        requestOptions: RequestOptions(path: testPath),
        statusCode: 401,
      );
      final dioException = DioException(
        requestOptions: RequestOptions(path: testPath),
        response: errorResponse,
        type: DioExceptionType.badResponse,
      );

      // Recreate DioClient without refreshToken callback
      dioClient = DioClient(
        baseUrl: baseUrl,
        dio: mockDio,
        connectivityService: mockConnectivityService,
        logger: mockLogger,
        enableLogging: true,
      );

      when(() => mockDio.get(
            testPath,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenThrow(dioException);

      expect(
        () => dioClient.get(testPath),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('throws TimeoutException for connection timeout', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: testPath),
        type: DioExceptionType.connectionTimeout,
      );

      when(() => mockDio.get(
            testPath,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenThrow(dioException);

      expect(
        () => dioClient.get(testPath),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('Header Management', () {
    test('adds and retrieves auth token correctly', () {
      const token = 'test_token';
      dioClient.setAuthToken(token);
      expect(dioClient.authToken, 'Bearer $token');
    });

    test('adds custom header', () {
      dioClient.addHeader('Custom-Header', 'value');
      expect(dioClient.dioInstance.options.headers['Custom-Header'], 'value');
    });

    test('removes header', () {
      dioClient.addHeader('Custom-Header', 'value');
      dioClient.removeHeader('Custom-Header');
      expect(dioClient.dioInstance.options.headers.containsKey('Custom-Header'),
          isFalse);
    });

    test('clears all headers', () {
      dioClient.addHeader('Header1', 'value1');
      dioClient.addHeader('Header2', 'value2');
      dioClient.clearHeaders();
      expect(dioClient.dioInstance.options.headers.isEmpty, isTrue);
    });

    test('clears auth token', () {
      dioClient.setAuthToken('test_token');
      dioClient.clearAuthToken();
      expect(dioClient.authToken, isNull);
    });
  });

  group('DioLoggingInterceptor', () {
    const testPath = '/test';
    final testRequestOptions = RequestOptions(path: testPath);
    final testResponse = Response(
      requestOptions: testRequestOptions,
      data: {'result': 'success'},
      statusCode: 200,
    );
    final dioException = DioException(
      requestOptions: testRequestOptions,
      response: Response(
        requestOptions: testRequestOptions,
        statusCode: 400,
        statusMessage: 'Bad Request',
      ),
      type: DioExceptionType.badResponse,
      stackTrace: StackTrace.current,
    );

    setUp(() {
      // Stub logger.e to handle any arguments
      when(() => mockLogger.e(
            any(),
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          )).thenReturn(null);
    });

    test('logs request details', () {
      final interceptor =
          DioLoggingInterceptor(logger: mockLogger, enableLogging: true);
      interceptor.onRequest(testRequestOptions, RequestInterceptorHandler());

      verify(() => mockLogger.i(any())).called(1);
    });

    test('logs response details', () {
      final interceptor =
          DioLoggingInterceptor(logger: mockLogger, enableLogging: true);
      interceptor.onResponse(testResponse, ResponseInterceptorHandler());

      verify(() => mockLogger.i(any())).called(1);
    });

    test('logs error details', () {
      final interceptor =
          DioLoggingInterceptor(logger: mockLogger, enableLogging: true);
      final handler = MockErrorInterceptorHandler();
      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onError(dioException, handler);

      verify(() => mockLogger.e(
            any(that: contains('Status Code: 400')),
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          )).called(1);
      verify(() => handler.next(dioException)).called(1);
    });

    test('does not log when enableLogging is false', () {
      final interceptor =
          DioLoggingInterceptor(logger: mockLogger, enableLogging: false);
      final handler = MockErrorInterceptorHandler();
      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onRequest(testRequestOptions, RequestInterceptorHandler());
      interceptor.onResponse(testResponse, ResponseInterceptorHandler());
      interceptor.onError(dioException, handler);

      verifyNever(() => mockLogger.i(any()));
      verifyNever(() => mockLogger.e(any(),
          error: any(named: 'error'), stackTrace: any(named: 'stackTrace')));
      verify(() => handler.next(dioException)).called(1);
    });
  });

  group('Download', () {
    const urlPath = '/download';
    const savePath = 'file_path';

    setUp(() {
      when(() => mockConnectivityService.hasConnection())
          .thenAnswer((_) async => true);
    });

    test('downloads file successfully', () async {
      when(() => mockDio.download(
                urlPath,
                savePath,
                queryParameters: any(named: 'queryParameters'),
                options: any(named: 'options'),
                cancelToken: any(named: 'cancelToken'),
                onReceiveProgress: any(named: 'onReceiveProgress'),
              ))
          .thenAnswer((_) async => Response(
              requestOptions: RequestOptions())); // Return Future<void>

      await dioClient.download(urlPath, savePath: savePath);

      verify(() => mockDio.download(urlPath, savePath)).called(1);
    });

    test('throws NetworkException on download failure', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: urlPath),
        type: DioExceptionType.connectionError,
      );

      when(() => mockDio.download(
            urlPath,
            savePath,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenThrow(dioException);

      expect(
        () => dioClient.download(urlPath, savePath: savePath),
        throwsA(isA<NoInternetConnectionException>()),
      );
    });
  });
}
