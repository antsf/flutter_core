// lib/utils/safe_call.dart

import 'package:flutter_core/flutter_core.dart'
    show
        FutureResult,
        Success,
        Error,
        AuthFailure,
        NetworkException,
        NetworkFailure,
        GenericFailure,
        Failure;
import 'package:dio/dio.dart'; // Import Dio for DioException

typedef RemoteCall<T> = FutureResult<T> Function();

/// A safe wrapper to handle common API call patterns.
/// Supports both regular results and `void` results (e.g., DELETE, No Content).
///
/// - If [onSuccess] is provided: maps result to a value (normal case).
/// - If [onSuccess] is omitted: assumes the call is `void` and returns `Success(null)`.
FutureResult<R?> safeRemoteCall<T, R>({
  required RemoteCall<T> remoteCall,
  R Function(T)? onSuccess, // Optional: only needed if transforming data
  void Function(T)? onBeforeSuccess, // Optional side effect
  String genericError = 'Terjadi kesalahan tak terduga',
}) async {
  try {
    final result = await remoteCall();

    print('safeRemoteCall result: $result');

    if (result.isSuccess) {
      final data = result.data;

      // If data is null and we expect a value → error
      if (data == null && onSuccess != null) {
        return Error(
          AuthFailure(message: result.failure?.message ?? genericError),
        );
      }

      // Run side effect if needed
      onBeforeSuccess?.call(data as T);

      // If onSuccess is provided, map the data
      if (onSuccess != null) {
        return Success(onSuccess(data as T));
      }

      // Otherwise, treat as void operation
      return const Success(null);
    } else {
      return Error(
        result.failure != null
            ? mapToFailure(result.failure!)
            : AuthFailure(message: genericError),
      );
    }
  } on NetworkException catch (e) {
    return Error(
      NetworkFailure(message: e.message, statusCode: e.statusCode ?? 200),
    );
  } on DioException catch (e) {
    // Added this catch block
    // Directly handle DioExceptions here for better error message extraction
    final networkException = NetworkException.fromDioException(e);
    return Error(
      NetworkFailure(
          message: networkException.message,
          statusCode: networkException.statusCode ?? 200),
    );
  } catch (e) {
    return Error(GenericFailure(message: e.toString()));
  }
}

/// Optional: centralized failure mapping
Failure mapToFailure(Failure failure) {
  print('failure: ${failure.message}');
  // You can add extra logic here (e.g. logging, transformation)
  return failure;
}

FutureResult<void> safeRemoteCallVoid<T>({
  required RemoteCall<T> remoteCall,
  void Function(T)? onBeforeSuccess,
  String genericError = 'Terjadi kesalahan tak terduga',
}) async {
  final result = await safeRemoteCall<T, void>(
    remoteCall: remoteCall,
    onSuccess: null,
    onBeforeSuccess: onBeforeSuccess,
    genericError: genericError,
  );
  print('result: $result');
  return result;
}
