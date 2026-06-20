import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:logger/logger.dart';

import '../result/failures.dart';
import '../result/result.dart';
import 'exceptions/network_exceptions.dart';

final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// Logs an error message in debug builds only.
///
/// We never log the full response/result here — those routinely contain PII or
/// tokens, and logging them in production is a compliance risk. Only short error
/// messages are logged, and only when not in release mode.
void _logError(String message) {
  if (!kReleaseMode) _logger.e(message);
}

typedef RemoteCall<T> = FutureResult<T> Function();

FutureResult<R?> safeRemoteCall<T, R>({
  required RemoteCall<T> remoteCall,
  R Function(T)? onSuccess,
  void Function(T)? onBeforeSuccess,
  String genericError = 'Terjadi kesalahan tak terduga',
}) async {
  try {
    final result = await remoteCall();

    if (result.isSuccess) {
      final data = result.data;
      onBeforeSuccess?.call(data as T);
      if (onSuccess != null) return Success(onSuccess(data as T));
      return const Success(null);
    } else {
      return Error(result.failure ?? GenericFailure(message: genericError));
    }
  } on NetworkException catch (e) {
    // NetworkException is a Failure — return it directly, preserving its
    // specific type (Unauthorized/NotFound/...) instead of flattening it.
    _logError('NetworkException: ${e.message}');
    return Error(e);
  } on DioException catch (e) {
    final networkException = NetworkException.fromDioException(e);
    _logError('DioException: ${networkException.message}');
    return Error(networkException);
  } catch (e) {
    _logError('Unexpected error: $e');
    return Error(GenericFailure(message: e.toString()));
  }
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
  return result;
}
