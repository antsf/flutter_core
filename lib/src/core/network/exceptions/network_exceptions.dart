import 'package:dio/dio.dart';

/// A base class for all network-related exceptions.
///
/// This class provides a consistent structure for handling errors that occur
/// during network communication. It includes the error message, the HTTP status code,
/// and the original exception for debugging purposes.
abstract class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;
  final StackTrace? stackTrace;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'NetworkException: $message'
        '${statusCode != null ? ' (Status Code: $statusCode)' : ''}'
        '${error != null ? '\nOriginal Error: $error' : ''}';
  }

  /// Creates a [NetworkException] from a [DioException].
  ///
  /// This factory constructor simplifies error handling by converting low-level
  /// Dio exceptions into specific, high-level [NetworkException] types.
  factory NetworkException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(dioException: dioException);
      case DioExceptionType.badResponse:
        // You can add more specific handling for different status codes here.
        return ServerException(dioException: dioException);
      case DioExceptionType.cancel:
        return CancelledException(dioException: dioException);
      case DioExceptionType.connectionError:
        return NoInternetConnectionException(dioException: dioException);
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
      default:
        return UnknownException(dioException: dioException);
    }
  }
}

/// Thrown when a network request times out.
class TimeoutException extends NetworkException {
  TimeoutException({required DioException dioException})
      : super(
          message: 'The request timed out. Please try again.',
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}

/// Thrown when there is no internet connection.
class NoInternetConnectionException extends NetworkException {
  NoInternetConnectionException({required DioException dioException})
      : super(
          message:
              'No internet connection. Please check your network settings.',
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}

/// Thrown for server-side errors (e.g., HTTP status codes 5xx).
class ServerException extends NetworkException {
  ServerException({required DioException dioException})
      : super(
          message: 'A server error occurred. Please try again later.',
          statusCode: dioException.response?.statusCode,
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}

/// Thrown when a network request is cancelled by the client.
class CancelledException extends NetworkException {
  CancelledException({required DioException dioException})
      : super(
          message: 'The request was cancelled.',
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}

/// Thrown for unknown or unexpected network errors.
class UnknownException extends NetworkException {
  UnknownException({required DioException dioException})
      : super(
          message: 'An unknown network error occurred.',
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}
