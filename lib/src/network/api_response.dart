import '../result/failures.dart';
import '../result/result.dart';
import 'exceptions/network_exceptions.dart';

/// A unified wrapper for HTTP responses from [DioClient].
///
/// Holds either the successful data [T] (which may be null for empty responses
/// such as 204 No Content) or a [NetworkException] on failure.
///
/// ### Relationship to [Result]
/// `ApiResponse` is the HTTP transport type; [Result] is the domain error model.
/// They share a single error currency: [NetworkException] **is a** [Failure], so
/// [error] is always a [Failure]. Use [toResult] to bridge an `ApiResponse` into
/// a `Result<T?, Failure>` for domain/use-case code.
///
/// `ApiResponse` exists separately from `Result` only because HTTP allows a
/// *successful response with no body* (204), which `Result.Success<T>` (a
/// non-null `T`) cannot represent.
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
///   onFailure: (failure) => print(failure.message),
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

  /// Creates a failed response with a [NetworkException] (which is a [Failure]).
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

  /// Bridges this transport response into the unified [Result] model.
  ///
  /// The success value is nullable (`T?`) to honour empty 204 responses; the
  /// failure is the same [Failure] carried by [error].
  Result<T?, Failure> toResult() =>
      isFailure ? ResultError(error!) : Success(data);

  @override
  String toString() => isSuccessful
      ? 'ApiResponse.success(data: $data)'
      : 'ApiResponse.failure(error: $error)';
}
