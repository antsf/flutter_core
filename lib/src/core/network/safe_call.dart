import 'package:flutter_core/flutter_core.dart';
import 'api_response.dart'; // Import the new ApiResponse

/// A utility function to safely execute a remote data source call and wrap the result.
///
/// It executes the [call] function, expecting it to throw a [NetworkException] on failure.
/// It wraps the successful result [T] in an [ApiResponse.success] or the caught
/// [NetworkException] in an [ApiResponse.failure].
///
/// [T] is the expected return type of the successful call.
/// [call] is the asynchronous function that executes the remote API call and DTO parsing.
Future<ApiResponse<T>> safeCall<T>(Future<T?> Function() call) async {
  try {
    // Execute the API call. The function 'call' is expected to handle DTO parsing
    // and only return null if the parsed data is intentionally empty or missing.
    final result = await call();

    if (result != null) {
      // If the result is not null, it's a successful API response
      return ApiResponse.success(result);
    } else {
      // This handles a business logic failure: 2xx status, but the resulting DTO was null.
      // This is wrapped as a ClientErrorException for consistency.
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
  } on NetworkException catch (e) {
    // Explicitly catch your custom exceptions thrown by the Dio wrapper (_request)
    return ApiResponse.failure(e);
  } on Exception catch (e) {
    // Catch-all for non-network exceptions (e.g., JSON parsing errors, other runtime errors)
    return ApiResponse.failure(
      UnknownNetworkException(
        dioException: DioException(
          requestOptions:
              DioException(requestOptions: RequestOptions(path: 'safeCall'))
                  .requestOptions,
          message: e.toString(),
        ),
      ),
    );
  }
}
