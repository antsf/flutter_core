import 'package:flutter_core/flutter_core.dart';

/// Safely executes a remote data source call and wraps the result in [ApiResponse].
///
/// Returns [ApiResponse.success] on success, [ApiResponse.failure] on any error.
/// A null result from [call] (2xx but no data) is treated as a failure.
Future<ApiResponse<T>> safeCall<T>(Future<T?> Function() call) async {
  try {
    final result = await call();

    if (result != null) {
      return ApiResponse.success(result);
    } else {
      return ApiResponse.failure(
        ClientErrorException(
          specificMessage:
              'API call completed successfully (2xx) but resulting data was null/empty.',
          dioException: DioException(
            requestOptions: RequestOptions(path: 'safeCall'),
          ),
        ),
      );
    }
  } on DioException catch (e) {
    return ApiResponse.failure(NetworkException.fromDioException(e));
  } on Exception catch (e) {
    return ApiResponse.failure(
      UnknownNetworkException(
        dioException: DioException(
          requestOptions: RequestOptions(path: 'safeCall'),
          message: e.toString(),
        ),
      ),
    );
  }
}
