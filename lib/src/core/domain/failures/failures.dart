import 'package:flutter/foundation.dart';

// --- 1. Failure Hierarchy ---

/// A base class for all failures in the application.
///
/// It enforces value equality and provides a standard structure for failure
/// information, including a message, the original error, and a stack trace.
@immutable
abstract class Failure {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.error,
    this.stackTrace,
  });

  /// The list of properties that will be used for value-based equality.
  List<Object?> get props => [message, error, stackTrace];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          listEquals(props, other.props);

  @override
  int get hashCode => Object.hashAll(props);

  @override
  String toString() => '$runtimeType(message: $message, error: $error)';
}

/// Represents a failure related to network operations (e.g., no internet, server error).
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

/// Represents a failure related to local cache operations (e.g., read/write error).
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

/// Represents a failure related to authentication (e.g., invalid credentials, token expired).
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

/// Represents a failure due to invalid input data.
class ValidationFailure extends Failure {
  final Map<String, String> errors;

  const ValidationFailure({
    required this.errors,
    super.error,
    super.stackTrace,
  }) : super(message: 'One or more validation errors occurred.');

  @override
  List<Object?> get props => super.props..add(errors);
}

/// Represents a generic or unexpected failure.
class GenericFailure extends Failure {
  const GenericFailure({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

// --- 2. Result Type Definition ---

/// A type alias for representing the result of an operation that can either
/// succeed with data of type [T] or fail with a [Failure].
///
/// This is a core component of the error handling strategy, ensuring that
/// all operations that can fail do so in a predictable and type-safe way.
typedef Result<T> = ({T? data, Failure? failure});

// --- 3. Result Extension for Safe Handling ---

/// Provides extension methods on the [Result] type for safe and convenient
/// handling of success and failure cases.
extension ResultExtension<T> on Result<T> {
  /// Returns `true` if the result is a success (data is not null and failure is null).
  bool get isSuccess => data != null && failure == null;

  /// Returns `true` if the result is a failure.
  bool get isFailure => failure != null;

  /// Gets the data from a successful result.
  ///
  /// Throws a [StateError] if the result is a failure. This should only be
  /// used after checking [isSuccess].
  T get requiredData {
    if (isFailure) {
      throw StateError(
          'Cannot access data from a failed result. Original failure: $failure');
    }
    return data as T;
  }

  /// Provides a functional and exhaustive way to handle both success and failure cases.
  ///
  /// This is the recommended way to process a [Result], as it forces the
  /// developer to handle both outcomes, preventing unhandled failure states.
  ///
  /// ### Example:
  /// ```dart
  /// final result = await myRepository.fetchData();
  /// result.when(
  ///   onSuccess: (user) => print('Success: ${user.name}'),
  ///   onFailure: (f) => print('Error: ${f.message}'),
  /// );
  /// ```
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onFailure(failure!);
    }
  }
}
