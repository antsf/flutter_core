import 'package:dio/dio.dart';
import 'package:flutter_corekit/src/network/dio_retry_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockErrorHandler extends Mock implements ErrorInterceptorHandler {}

/// Builds a [DioException] for [method] with an optional status code / type.
DioException _err(
  String method, {
  int? status,
  DioExceptionType type = DioExceptionType.badResponse,
  Map<String, dynamic>? extra,
}) {
  final ro = RequestOptions(path: '/x', method: method, extra: extra ?? {});
  return DioException(
    requestOptions: ro,
    type: type,
    response: status != null
        ? Response(requestOptions: ro, statusCode: status)
        : null,
  );
}

void main() {
  late MockDio dio;
  late MockErrorHandler handler;
  late DioRetryInterceptor interceptor;

  // baseDelayMs:1 + no jitter keeps the retry delay ~instant for tests.
  const fastOptions = RetryOptions(
    baseDelayMs: 1,
    maxDelayMs: 1,
    useJitter: false,
  );

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(
        DioException(requestOptions: RequestOptions(path: '/')));
    registerFallbackValue(
        Response(requestOptions: RequestOptions(path: '/'), statusCode: 200));
  });

  setUp(() {
    dio = MockDio();
    handler = MockErrorHandler();
    interceptor = DioRetryInterceptor(
        dio: dio, options: fastOptions, enableLogging: false);

    when(() => dio.fetch(any())).thenAnswer(
      (inv) async => Response(
        requestOptions: inv.positionalArguments.first as RequestOptions,
        statusCode: 200,
      ),
    );
    when(() => handler.resolve(any())).thenReturn(null);
    when(() => handler.next(any())).thenReturn(null);
  });

  group('idempotency-aware retry (C4)', () {
    test('GET on 503 IS retried', () async {
      await interceptor.onError(_err('GET', status: 503), handler);
      verify(() => dio.fetch(any())).called(1);
      verify(() => handler.resolve(any())).called(1);
    });

    test('POST on 503 is NOT retried by default', () async {
      await interceptor.onError(_err('POST', status: 503), handler);
      verifyNever(() => dio.fetch(any()));
      verify(() => handler.next(any())).called(1);
    });

    test('PUT on 503 is NOT retried by default', () async {
      await interceptor.onError(_err('PUT', status: 503), handler);
      verifyNever(() => dio.fetch(any()));
      verify(() => handler.next(any())).called(1);
    });

    test('POST opts in via extra[retry]=true -> retried', () async {
      await interceptor.onError(
        _err('POST', status: 503, extra: {'retry': true}),
        handler,
      );
      verify(() => dio.fetch(any())).called(1);
      verify(() => handler.resolve(any())).called(1);
    });

    test('POST on connection timeout is NOT retried by default', () async {
      await interceptor.onError(
        _err('POST', type: DioExceptionType.connectionError),
        handler,
      );
      verifyNever(() => dio.fetch(any()));
      verify(() => handler.next(any())).called(1);
    });

    test('GET on a non-retryable status (400) is NOT retried', () async {
      await interceptor.onError(_err('GET', status: 400), handler);
      verifyNever(() => dio.fetch(any()));
      verify(() => handler.next(any())).called(1);
    });
  });

  group('backoff', () {
    test('exponential without jitter is deterministic and capped', () {
      const o = RetryOptions(
        baseDelayMs: 100,
        maxDelayMs: 1000,
        useJitter: false,
      );
      expect(o.calculateDelay(1), 100); // 100 * 2^0
      expect(o.calculateDelay(2), 200); // 100 * 2^1
      expect(o.calculateDelay(3), 400); // 100 * 2^2
      expect(o.calculateDelay(10), 1000); // capped at maxDelayMs
    });

    test('jitter keeps the delay within [half, capped]', () {
      const o = RetryOptions(baseDelayMs: 1000, maxDelayMs: 1000);
      for (var i = 0; i < 200; i++) {
        final d = o.calculateDelay(5); // capped at 1000
        expect(d, inInclusiveRange(500, 1000));
      }
    });
  });
}
