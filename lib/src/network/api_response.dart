import 'package:flutter_core/flutter_core.dart';

/// A unified wrapper for API responses from [DioClient].
///
/// Holds either the successful data [T] (which may be null for empty responses)
/// or a [NetworkException] on failure.
///
/// ### Checking success
/// ```dart
/// if (result.isSuccessful) {
///   final user = result.data;  // T? — may be null for 204 No Content
/// }
/// ```
///
/// ### Exhaustive handling
/// ```dart
/// result.when(
///   onSuccess: (data) => print(data),
///   onFailure: (err) => print(err.message),
/// );
/// ```
class ApiResponse<T> {
  final T? data;
  final NetworkException? error;

  const ApiResponse._success(this.data) : error = null;
  const ApiResponse._failure(this.error) : data = null;

  /// Creates a successful response. [data] may be null for empty responses
  /// (e.g., 204 No Content).
  factory ApiResponse.success([T? data]) => ApiResponse._success(data);

  /// Creates a failed response with a [NetworkException].
  factory ApiResponse.failure(NetworkException error) =>
      ApiResponse._failure(error);

  /// True when the request succeeded, regardless of whether [data] is null.
  bool get isSuccessful => error == null;

  /// True when the request failed with a [NetworkException].
  bool get isFailure => error != null;

  /// Returns [data], throwing [error] if the request failed, or [StateError]
  /// if the request succeeded but [data] is null.
  T get requireData {
    if (isFailure) throw error!;
    if (data == null) throw StateError('ApiResponse has no data');
    return data as T;
  }

  /// Exhaustive handler for both success and failure cases.
  R when<R>({
    required R Function(T? data) onSuccess,
    required R Function(NetworkException error) onFailure,
  }) {
    return isSuccessful ? onSuccess(data) : onFailure(error!);
  }

  @override
  String toString() => isSuccessful
      ? 'ApiResponse.success(data: $data)'
      : 'ApiResponse.failure(error: $error)';
}

/// Extension to check for a successful HTTP status code (200–299).
extension ResponseExtension on Response {
  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
}
