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
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // Hides method stack trace in logs
    colors: true, // Enables colored logs
    printEmojis: true, // Enables emojis in logs
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Log time format
  ),
);

typedef RemoteCall<T> = FutureResult<T> Function();

FutureResult<R?> safeRemoteCall<T, R>({
  required RemoteCall<T> remoteCall,
  R Function(T)? onSuccess,
  void Function(T)? onBeforeSuccess,
  String genericError = 'Terjadi kesalahan tak terduga',
}) async {
  try {
    final result = await remoteCall();
    _logger.d('safeRemoteCall result: $result');

    if (result.isSuccess) {
      final data = result.data;

      // if (data == null && onSuccess != null) {
      //   return Error(
      //       AuthFailure(message: result.failure?.message ?? genericError));
      // }

      onBeforeSuccess?.call(data as T);

      if (onSuccess != null) return Success(onSuccess(data as T));
      return const Success(null);
    } else {
      return Error(result.failure != null
          ? mapToFailure(result.failure!)
          : AuthFailure(message: genericError));
    }
  } on NetworkException catch (e) {
    _logger.e('NetworkException: ${e.message}');
    return Error(
        NetworkFailure(message: e.message, statusCode: e.statusCode ?? 400));
  } on DioException catch (e) {
    final networkException = NetworkException.fromDioException(e);
    _logger.e('DioException: ${networkException.message}');
    return Error(NetworkFailure(
        message: networkException.message,
        statusCode: networkException.statusCode ?? 400));
  } catch (e) {
    _logger.e('Unexpected error: $e');
    return Error(GenericFailure(message: e.toString()));
  }
}

Failure mapToFailure(Failure failure) {
  _logger.w('Mapped failure: ${failure}');
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
  _logger.d('safeRemoteCallVoid result: $result');
  return result;
}
