import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_corekit/flutter_corekit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

/// In-memory adapter: returns 401 until the request carries `Bearer fresh`
/// (or always, when [alwaysUnauthorized] is set).
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.alwaysUnauthorized = false});

  final bool alwaysUnauthorized;
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    final authed = !alwaysUnauthorized &&
        options.headers['Authorization'] == 'Bearer fresh';
    return ResponseBody.fromString(
      '{"ok":$authed}',
      authed ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockConnectivityService conn;

  setUp(() {
    conn = MockConnectivityService();
    when(() => conn.hasConnection()).thenAnswer((_) async => true);
  });

  DioClient buildClient(
    _StubAdapter adapter, {
    required Future<String?> Function(Dio) refreshToken,
  }) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    return DioClient(
      baseUrl: 'https://api.test',
      dio: dio,
      connectivityService: conn,
      enableLogging: false,
      refreshToken: refreshToken,
    );
  }

  test('concurrent 401s trigger exactly ONE token refresh (no stampede)',
      () async {
    final adapter = _StubAdapter();
    var refreshCalls = 0;
    final client = buildClient(
      adapter,
      refreshToken: (_) async {
        refreshCalls++;
        // Stay in flight long enough for all concurrent 401s to coalesce.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 'fresh';
      },
    );

    final results =
        await Future.wait(List.generate(5, (_) => client.get('/me')));

    expect(refreshCalls, 1, reason: 'refresh must be coalesced into one call');
    expect(results.every((r) => r.isSuccessful), isTrue);
  });

  test('a persistent 401 does not loop — one refresh, then fails', () async {
    final adapter = _StubAdapter(alwaysUnauthorized: true);
    var refreshCalls = 0;
    final client = buildClient(
      adapter,
      refreshToken: (_) async {
        refreshCalls++;
        return 'fresh';
      },
    );

    final result = await client.get('/me');

    expect(refreshCalls, 1, reason: 'refresh must be attempted at most once');
    expect(result.isFailure, isTrue);
    // 1 original request + 1 retry after refresh = 2 (no infinite loop).
    expect(adapter.requests, 2);
  });
}
