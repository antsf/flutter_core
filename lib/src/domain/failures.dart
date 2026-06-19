import 'package:flutter/foundation.dart';

// --- 1. Failure Hierarchy ---

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

// --- 2. Result Type Definition ---

/// Represents the result of an operation that can either succeed with [T] or
/// fail with a [Failure]. Use [Success] and [Error] as concrete implementations.
abstract class Result<T, F> {
  const Result();
  bool get isSuccess;
  bool get isFailure;
  T? get data;
  F? get failure;
}

class Success<T, F> extends Result<T, F> {
  final T value;
  const Success(this.value);
  @override
  bool get isSuccess => true;
  @override
  bool get isFailure => false;
  @override
  T? get data => value;
  @override
  F? get failure => null;
}

class Error<T, F> extends Result<T, F> {
  final F error;
  const Error(this.error);
  @override
  bool get isSuccess => false;
  @override
  bool get isFailure => true;
  @override
  T? get data => null;
  @override
  F? get failure => error;
}

typedef FutureResult<T> = Future<Result<T, Failure>>;

// --- 3. Result Extensions ---

/// Safe handling and transformation utilities for [Result].
extension ResultExtension<T, F> on Result<T, F> {
  /// Gets the data, throwing [StateError] if the result is a failure.
  T get requiredData {
    if (isFailure) {
      throw StateError(
          'Cannot access data from a failed result. Original failure: $failure');
    }
    return data as T;
  }

  /// Exhaustive handler for both success and failure cases.
  ///
  /// ```dart
  /// result.when(
  ///   onSuccess: (user) => print('User: ${user.name}'),
  ///   onFailure: (f) => print('Error: ${f.message}'),
  /// );
  /// ```
  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(F failure) onFailure,
  }) {
    if (this is Success<T, F>) {
      return onSuccess((this as Success<T, F>).value);
    } else {
      return onFailure((this as Error<T, F>).error);
    }
  }

  /// Transforms the success value, leaving failures untouched.
  Result<R, F> map<R>(R Function(T value) transform) {
    if (this is Success<T, F>) {
      return Success(transform((this as Success<T, F>).value));
    }
    return Error((this as Error<T, F>).error);
  }

  /// Transforms the failure value, leaving successes untouched.
  Result<T, G> mapFailure<G>(G Function(F failure) transform) {
    if (this is Error<T, F>) {
      return Error(transform((this as Error<T, F>).error));
    }
    return Success((this as Success<T, F>).value);
  }
}
