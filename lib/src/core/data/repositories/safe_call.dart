import 'package:flutter_core/flutter_core.dart'
    show
        FutureResult,
        Success,
        Error,
        NetworkException,
        NetworkFailure,
        GenericFailure;
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
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
      onBeforeSuccess?.call(data as T);
      if (onSuccess != null) return Success(onSuccess(data as T));
      return const Success(null);
    } else {
      return Error(result.failure ?? GenericFailure(message: genericError));
    }
  } on NetworkException catch (e) {
    _logger.e('NetworkException: ${e.message}');
    return Error(
        NetworkFailure(message: e.message, statusCode: e.statusCode ?? 0));
  } on DioException catch (e) {
    final networkException = NetworkException.fromDioException(e);
    _logger.e('DioException: ${networkException.message}');
    return Error(NetworkFailure(
        message: networkException.message,
        statusCode: networkException.statusCode ?? 0));
  } catch (e) {
    _logger.e('Unexpected error: $e');
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
  _logger.d('safeRemoteCallVoid result: $result');
  return result;
}
