import 'package:flutter/foundation.dart';

/// A base class for all failures in the application.
///
/// Enforces value equality and provides a standard structure for failure
/// information, including a message, the original error, and a stack trace.
@immutable
abstract class Failure {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final int statusCode;

  const Failure({
    required this.message,
    this.error,
    this.stackTrace,
    this.statusCode = 0,
  });

  List<Object?> get props => [message, error, stackTrace, statusCode];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          listEquals(props, other.props);

  @override
  int get hashCode => Object.hashAll(props);

  @override
  String toString() =>
      '$runtimeType(message: $message, error: $error, statusCode: $statusCode)';
}

/// Represents a failure related to server operations (e.g., 5xx errors).
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.error,
    super.stackTrace,
    super.statusCode,
  });
}

/// Represents a failure related to network operations (e.g., no internet).
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.error,
    super.stackTrace,
    super.statusCode,
  });
}

/// Represents a failure related to local cache operations (e.g., read/write error).
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.error,
    super.stackTrace,
    super.statusCode,
  });
}

/// Represents a failure related to authentication (e.g., invalid credentials, token expired).
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.error,
    super.stackTrace,
    super.statusCode,
  });
}

/// Represents a failure due to invalid input data.
class ValidationFailure extends Failure {
  final Map<String, String> errors;

  const ValidationFailure({
    required this.errors,
    super.error,
    super.stackTrace,
    super.statusCode,
  }) : super(message: 'One or more validation errors occurred.');

  @override
  List<Object?> get props => [...super.props, errors];
}

/// Represents a generic or unexpected failure.
class GenericFailure extends Failure {
  const GenericFailure({
    required super.message,
    super.error,
    super.stackTrace,
    super.statusCode,
  });
}
