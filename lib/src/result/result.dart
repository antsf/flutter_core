import 'failures.dart';

/// Represents the result of an operation that can either succeed with [T] or
/// fail with a [Failure]. Use [Success] and [ResultError] as concrete
/// implementations.
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

/// The failure variant of a [Result]. Named `ResultError` (not `Error`) to
/// avoid shadowing `dart:core`'s [Error].
class ResultError<T, F> extends Result<T, F> {
  final F error;
  const ResultError(this.error);
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
      return onFailure((this as ResultError<T, F>).error);
    }
  }

  /// Transforms the success value, leaving failures untouched.
  Result<R, F> map<R>(R Function(T value) transform) {
    if (this is Success<T, F>) {
      return Success(transform((this as Success<T, F>).value));
    }
    return ResultError((this as ResultError<T, F>).error);
  }

  /// Transforms the failure value, leaving successes untouched.
  Result<T, G> mapFailure<G>(G Function(F failure) transform) {
    if (this is ResultError<T, F>) {
      return ResultError(transform((this as ResultError<T, F>).error));
    }
    return Success((this as Success<T, F>).value);
  }
}
