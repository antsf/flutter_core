import 'package:flutter_corekit/flutter_corekit.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dioErr(int status) {
  final ro = RequestOptions(path: '/x');
  return DioException(
    requestOptions: ro,
    // fromDioException maps by type first; badResponse routes to status-code
    // classification (401 -> UnauthorizedException, etc.).
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: ro, statusCode: status),
  );
}

void main() {
  group('M1 — unified error model (Failure as the single currency)', () {
    test('a NetworkException IS a Failure (and still an Exception)', () {
      final e = NotFoundException(dioException: _dioErr(404));
      expect(e, isA<Failure>());
      expect(e, isA<NetworkException>());
      expect(e, isA<Exception>());
      expect(e.statusCode, 404);
    });

    test('NetworkException.fromDioException yields a Failure', () {
      final f = NetworkException.fromDioException(_dioErr(401));
      expect(f, isA<Failure>());
      expect(f, isA<UnauthorizedException>());
    });
  });

  group('ApiResponse.toResult bridge', () {
    test('failure -> ResultError carrying the same Failure', () {
      final ne = UnauthorizedException(dioException: _dioErr(401));
      final result = ApiResponse<int>.failure(ne).toResult();
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<Failure>());
      expect(result.failure, same(ne));
    });

    test('success -> Result.Success with the data', () {
      final result = ApiResponse<int>.success(42).toResult();
      expect(result.isSuccess, isTrue);
      expect(result.data, 42);
    });

    test('null-data success (e.g. 204) -> Result.Success with null', () {
      final result = ApiResponse<int>.success().toResult();
      expect(result.isSuccess, isTrue);
      expect(result.data, isNull);
    });
  });
}
