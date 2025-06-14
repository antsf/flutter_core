import 'dart:async';
import '../failures/failures.dart';

/// An abstract class representing a single business use case.
///
/// This class provides a standard structure for all use cases in the application,
/// including support for cancellation. It is designed to be simple and focused,
/// leaving concerns like retries to the data layer.
///
/// ### Subclassing Example:
///
/// ```dart
/// class GetUserDetailsUseCase extends UseCase<User, String> {
///   final IUserRepository _repository;
///
///   GetUserDetailsUseCase(this._repository);
///
///   @override
///   Future<Result<User>> execute(String userId) {
///     return _repository.getUserById(userId);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  StreamController<void>? _cancelController;

  /// Executes the use case.
  ///
  /// This method orchestrates the execution, including checking for cancellation
  /// and converting any thrown exceptions into a [Failure] within the [Result].
  Future<Result<Type>> call(Params params) async {
    _cancelController = StreamController<void>();

    try {
      if (_cancelController!.isClosed) {
        return (
          data: null,
          failure: const GenericFailure(message: 'Operation was cancelled.'),
        );
      }
      return await execute(params);
    } catch (e, s) {
      if (_cancelController!.isClosed) {
        return (
          data: null,
          failure: const GenericFailure(message: 'Operation was cancelled.'),
        );
      }
      return (data: null, failure: _handleError(e, s));
    } finally {
      _cancelController?.close();
      _cancelController = null;
    }
  }

  /// The core logic of the use case.
  ///
  /// Subclasses must implement this method to perform the actual business logic,
  /// typically by calling one or more repository methods.
  Future<Result<Type>> execute(Params params);

  /// Handles exceptions and converts them into a domain [Failure].
  Failure _handleError(dynamic error, StackTrace stackTrace) {
    if (error is Failure) {
      return error;
    }
    // For unknown errors, return a generic Failure.
    return GenericFailure(
      message: 'An unexpected error occurred: ${error.toString()}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Cancels the current use case execution.
  ///
  /// If the use case is running, this will cause it to return a [Failure].
  void cancel() {
    if (_cancelController != null && !_cancelController!.isClosed) {
      _cancelController!.close();
    }
  }

  /// A token that can be used to listen for cancellation events.
  Stream<void>? get onCancel => _cancelController?.stream;
}

/// A class representing the absence of parameters for a use case.
class NoParams {
  const NoParams();
}
