import 'package:dio/dio.dart';
import '../failures/failures.dart';
import './base_usecase.dart';

/// Example parameters for the use case
class ExampleParams {
  final String id;
  final Map<String, dynamic>? queryParams;

  const ExampleParams({
    required this.id,
    this.queryParams,
  });
}

/// Example use case implementation
class ExampleUseCase extends UseCase<Map<String, dynamic>, ExampleParams> {
  final Dio _client;

  ExampleUseCase({
    required Dio client,
    maxRetries,
    retryDelay,
    enableRetry,
  }) : _client = client;

  @override
  Future<Result<Map<String, dynamic>>> execute(ExampleParams params) async {
    final response = await _client.get(
      '/example/${params.id}',
      queryParameters: params.queryParams,
      // cancelToken: cancelToken,
    );

    return response.data as Result<Map<String, dynamic>>;
  }
}

/// Example usage:
/// 
/// ```dart
/// final useCase = ExampleUseCase(
///   client: dioClient,
///   cacheConfig: DioCacheConfig(
///     maxAge: Duration(hours: 1),
///   ),
///   maxRetries: 3,
///   retryDelay: Duration(seconds: 1),
/// );
/// 
/// // Execute with progress tracking
/// useCase.progress?.listen((progress) {
///   print('Progress: ${(progress * 100).toStringAsFixed(1)}%');
/// });
/// 
/// try {
///   final result = await useCase.execute(
///     ExampleParams(
///       id: '123',
///       queryParams: {'page': 1},
///     ),
///   );
///   print('Result: $result');
/// } catch (e) {
///   print('Error: $e');
/// }
/// 
/// // Cancel the operation
/// useCase.cancel();
/// ``` 