import 'dart:async';
import '../failures/failures.dart'; // Provides Result typedef and Failure classes

/// An abstract class representing a single, discrete business operation or use case.
///
/// Use cases encapsulate the application's business logic and orchestrate interactions
/// between entities and repositories. Each use case should have a single responsibility.
///
/// ### Type Parameters:
/// - [Type]: The data type of the successful result of the use case.
/// - [Params]: The type of parameters required to execute the use case.
///   Use [NoParams] if the use case does not require parameters.
///
/// ### Execution:
/// Use cases are typically executed by calling their `call` method, which is an
/// alias for invoking the instance as a function. The `call` method handles
/// boilerplate logic such as cancellation checks and error conversion to [Failure].
/// Subclasses must implement the `execute` method to define the core business logic.
///
/// ### Error Handling:
/// The `call` method ensures that any exception thrown during `execute` is caught
/// and converted into a [Failure] object, wrapped in a [Result]. This promotes
/// consistent error handling across the application.
///
/// ### Cancellation:
/// Use cases can be cancelled via the [cancel] method. If a use case is cancelled
/// while it's executing, its `call` method will attempt to return a [Result]
/// with a [GenericFailure] indicating cancellation. The [onCancel] stream can be
/// used to listen for cancellation events externally.
///
/// ### Subclassing Example:
/// ```dart
/// // Define parameters for the use case
/// class GetUserDetailsParams {
///   final String userId;
///   GetUserDetailsParams(this.userId);
/// }
///
/// // Define the use case
/// class GetUserDetailsUseCase extends UseCase<UserEntity, GetUserDetailsParams> {
///   final IUserRepository _repository; // Depends on an abstract repository
///
///   GetUserDetailsUseCase(this._repository);
///
///   @override
///   Future<Result<UserEntity>> execute(GetUserDetailsParams params) async {
///     // Core logic: call repository method
///     return _repository.getUserById(params.userId);
///   }
/// }
///
/// // Usage:
/// // final getUserDetails = GetUserDetailsUseCase(userRepository);
/// // final result = await getUserDetails(GetUserDetailsParams('123'));
/// // result.when(
/// //   onSuccess: (user) => print('User: ${user.name}'),
/// //   onFailure: (failure) => print('Error: ${failure.message}'),
/// // );
/// ```
abstract class UseCase<Type, Params> {
  StreamController<void>? _cancelController;

  /// Executes the use case with the given [params].
  ///
  /// This method orchestrates the execution flow:
  /// 1. Initializes a cancellation controller.
  /// 2. Checks for immediate cancellation before execution.
  /// 3. Calls the `execute(params)` method implemented by the subclass.
  /// 4. Catches any exceptions thrown during `execute` and converts them to a [Failure].
  /// 5. Checks for cancellation again after execution or if an error occurs.
  /// 6. Cleans up the cancellation controller.
  ///
  /// Returns a [Result] object, which will contain either the success data [Type]
  /// or a [Failure].
  FutureResult<Type> call(Params params) async {
    // Initialize a new controller for this specific call.
    _cancelController = StreamController<void>.broadcast();

    try {
      if (_cancelController!.isClosed) {
        return const Error(
          GenericFailure(message: 'Operation was cancelled before execution.'),
        );
      }
      // Delegate the core logic to the subclass's implementation.
      return await execute(params);
    } catch (e, s) {
      // If cancelled during an exception, prioritize the cancellation failure.
      if (_cancelController!.isClosed) {
        return const Error(
          GenericFailure(
              message: 'Operation was cancelled during error handling.'),
        );
      }
      // Convert any other exception to a domain Failure.
      return Error(_handleError(e, s));
    } finally {
      // Ensure the controller is closed and cleaned up.
      if (_cancelController != null && !_cancelController!.isClosed) {
        _cancelController!.close();
      }
      _cancelController = null;
    }
  }

  /// The core logic of the use case that must be implemented by subclasses.
  ///
  /// This method should contain the actual business rules and interactions,
  /// typically involving calls to one or more repositories.
  ///
  /// [params]: The parameters required for this use case execution.
  /// Returns a [Future] of [Result<Type>], encapsulating the success data or a failure.
  FutureResult<Type> execute(Params params);

  /// Converts a caught error/exception into a domain-specific [Failure].
  ///
  /// If the caught [error] is already a [Failure], it's returned directly.
  /// Otherwise, it's wrapped in a [GenericFailure].
  ///
  /// [error]: The caught error or exception.
  /// [stackTrace]: The stack trace associated with the error.
  /// Returns a [Failure] object.
  Failure _handleError(dynamic error, StackTrace stackTrace) {
    if (error is Failure) {
      return error; // Avoid double-wrapping if it's already a Failure.
    }
    // For unknown errors, return a generic Failure.
    // Consider adding more specific error handling here if needed (e.g., based on error type).
    return GenericFailure(
      message:
          'An unexpected error occurred during use case execution: ${error.toString()}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Cancels the current execution of the use case, if it is running.
  ///
  /// This method signals the `_cancelController` to close. The `call` method
  /// checks this controller's state and will attempt to short-circuit execution
  /// and return a [GenericFailure] indicating cancellation.
  ///
  /// Note: This provides cooperative cancellation. If the `execute` method
  /// involves long-running synchronous operations or asynchronous operations
  /// that do not listen to a cancellation mechanism themselves, this might not
  /// immediately stop them.
  void cancel() {
    if (_cancelController != null && !_cancelController!.isClosed) {
      _cancelController!.add(null); // Signal any listeners
      _cancelController!.close();
    }
  }

  /// A stream that emits an event when the use case execution is cancelled.
  ///
  /// This can be used by the caller (e.g., UI layer) to react to cancellation,
  /// such as updating UI state or stopping loading indicators.
  /// The stream is valid only during a single `call()` execution.
  Stream<void>? get onCancel => _cancelController?.stream;
}

/// A utility class representing the absence of parameters for a [UseCase].
///
/// When a use case does not require any input parameters, `NoParams` can be used
/// as the `Params` type argument for `UseCase<Type, NoParams>`.
/// An instance of `const NoParams()` can then be passed to the `call` method.
class NoParams {
  /// Creates an instance of [NoParams].
  const NoParams();
}
