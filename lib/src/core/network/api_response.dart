// Import the necessary NetworkException library

import 'package:flutter_core/flutter_core.dart';

/// A unified wrapper for API responses.
///
/// Holds either the successful data [T] or a specific [NetworkException]
/// on failure, promoting explicit error handling in the data layer.
class ApiResponse<T> {
  final T? data;
  final NetworkException? error;

  /// Private constructor for a successful response.
  const ApiResponse._success(this.data) : error = null;

  /// Private constructor for a failed response.
  const ApiResponse._failure(this.error) : data = null;

  /// Factory constructor for a successful response.
  factory ApiResponse.success(T data) => ApiResponse._success(data);

  /// Factory constructor for a failed response.
  factory ApiResponse.failure(NetworkException error) =>
      ApiResponse._failure(error);

  /// Checks if the response holds a successful result.
  bool get isSuccessful => data != null && error == null;

  /// Checks if the response holds an error.
  bool get isFailure => error != null;

  /// Returns the data if successful, otherwise throws the stored NetworkException.
  T get requireData {
    if (isSuccessful) {
      return data as T;
    }
    // Since this is only used in the data layer, throwing the
    // NetworkException directly allows the repository/bloc to handle it.
    throw error ??
        UnknownNetworkException(
          dioException: // Placeholder for a missing DioException for clean code
              // In a real scenario, you'd make sure error is never null here.
              // For simplicity, we create a basic DioException
              DioException(requestOptions: RequestOptions(path: '')),
        );
  }

  @override
  String toString() {
    if (isSuccessful) {
      return 'ApiResponse.success(data: $data)';
    }
    return 'ApiResponse.failure(error: $error)';
  }
}

/// Extension to check for a successful HTTP status code (200-299 range).
extension ResponseExtension on Response {
  /// Returns true if the status code indicates a successful request (200 to 299).
  bool get isSuccess {
    return statusCode != null && statusCode! >= 200 && statusCode! < 300;
  }
}
