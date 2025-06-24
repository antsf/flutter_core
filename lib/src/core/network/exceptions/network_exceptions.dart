import 'package:dio/dio.dart';

/// Defines a hierarchy of custom exceptions related to network operations.
///
/// These exceptions provide more specific and user-friendly error information
/// compared to raw [DioException]s, and they integrate with the application's
/// [Failure] and [Result] error handling pattern.
library network_exceptions;

/// A base abstract class for all custom network-related exceptions.
///
/// Implements [Exception] to be throwable.
/// Each [NetworkException] carries a user-friendly [message], an optional
/// HTTP [statusCode], the original [error] (often a [DioException]), and
/// an optional [stackTrace].
///
/// The factory constructor `NetworkException.fromDioException` is provided to
/// conveniently convert a [DioException] into a more specific [NetworkException] subtype.
abstract class NetworkException implements Exception {
  /// A user-friendly message describing the error.
  final String message;

  /// The HTTP status code associated with the error, if applicable.
  final int? statusCode;

  /// The original error object, often a [DioException] or other low-level error.
  final dynamic error;

  /// The stack trace associated with the original error, if available.
  final StackTrace? stackTrace;

  /// Creates a const [NetworkException].
  const NetworkException({
    required this.message,
    this.statusCode,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();
    sb.write(runtimeType); // e.g., "TimeoutException"
    sb.write(': $message');
    if (statusCode != null) {
      sb.write(' (Status Code: $statusCode)');
    }
    if (error != null && error is DioException && (error as DioException).requestOptions.uri != null) {
      sb.write(' URL: ${(error as DioException).requestOptions.uri}');
    }
    // Optionally include more details from 'error' if needed, but keep it concise for typical logging.
    // if (error != null) {
    //   sb.write('\nOriginal Error: $error');
    // }
    return sb.toString();
  }

  /// Creates a specific [NetworkException] subtype from a given [DioException].
  ///
  /// This factory inspects the [dioException.type] and `dioException.response.statusCode`
  /// to determine the most appropriate custom exception to return.
  /// This helps in categorizing network errors for better handling in the application.
  factory NetworkException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(dioException: dioException);
      case DioExceptionType.badResponse:
        // Further categorize based on status code for bad responses
        final statusCode = dioException.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 500) { // Server errors (5xx)
            return ServerException(dioException: dioException, specificMessage: 'Server error occurred (Status $statusCode).');
          } else if (statusCode >= 400) { // Client errors (4xx)
             // Could be further specialized, e.g., NotFoundException (404), UnauthorizedException (401)
            return ClientErrorException(dioException: dioException, specificMessage: 'Client error: Bad request (Status $statusCode).');
          }
        }
        // Default for bad responses if status code doesn't fit specific categories above
        return ServerException(dioException: dioException);
      case DioExceptionType.cancel:
        return CancelledException(dioException: dioException);
      case DioExceptionType.connectionError:
        // This often indicates no internet or DNS resolution failure.
        return NoInternetConnectionException(dioException: dioException);
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate: // Treat bad certificate as an unknown/setup issue for now
      default:
        return UnknownNetworkException(dioException: dioException);
    }
  }
}

/// Exception thrown when a network request times out (connection, send, or receive).
class TimeoutException extends NetworkException {
  /// Creates a [TimeoutException].
  TimeoutException({required DioException dioException})
      : super(
          message: 'The network request timed out. Please check your connection and try again.',
          statusCode: dioException.response?.statusCode,
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}

/// Exception thrown when there is no internet connection or a connection error occurs.
class NoInternetConnectionException extends NetworkException {
  /// Creates a [NoInternetConnectionException].
  NoInternetConnectionException({required DioException dioException})
      : super(
          message: 'No internet connection. Please check your network settings and try again.',
          statusCode: dioException.response?.statusCode, // Usually null for connection errors
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}

/// Exception thrown for server-side errors (e.g., HTTP status codes 5xx).
class ServerException extends NetworkException {
  /// Creates a [ServerException].
  /// [specificMessage] can be provided if a more detailed message than the default is needed.
  ServerException({required DioException dioException, String? specificMessage})
      : super(
          message: specificMessage ?? 'A server error occurred. Please try again later.',
          statusCode: dioException.response?.statusCode,
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}

/// Exception thrown for client-side errors (e.g., HTTP status codes 4xx)
/// that are not more specifically handled (like Authentication or Validation failures).
class ClientErrorException extends NetworkException {
  /// Creates a [ClientErrorException].
  /// [specificMessage] can be provided if a more detailed message than the default is needed.
  ClientErrorException({required DioException dioException, String? specificMessage})
      : super(
          message: specificMessage ?? 'There was an issue with the request (Client Error).',
          statusCode: dioException.response?.statusCode,
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}

/// Exception thrown when a network request is cancelled by the client.
class CancelledException extends NetworkException {
  /// Creates a [CancelledException].
  CancelledException({required DioException dioException})
      : super(
          message: 'The network request was cancelled.',
          // statusCode is usually null for cancellations
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}

/// Exception thrown for unknown or unexpected network errors that don't fit
/// into other categories.
class UnknownNetworkException extends NetworkException {
  /// Creates an [UnknownNetworkException].
  UnknownNetworkException({required DioException dioException})
      : super(
          message: 'An unknown network error occurred. Please try again.',
          statusCode: dioException.response?.statusCode,
          error: dioException,
          stackTrace: dioException.stackTrace,
        );
}
