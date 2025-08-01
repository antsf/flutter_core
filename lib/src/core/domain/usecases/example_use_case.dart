// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_local_variable
// Disabling some lints for this example file as it's illustrative.
import 'dart:async';
import 'dart:developer';

import '../entities/base_entity.dart';
import '../failures/failures.dart';
import '../repositories/base_repository.dart'; // For Result
import './base_usecase.dart';

// --- Dummy/Illustrative Components for the Example ---

/// An example domain entity.
class ExampleEntity extends BaseEntity {
  final String id;
  final String data;

  const ExampleEntity({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];

  @override
  String toString() => 'ExampleEntity(id: $id, data: $data)';
}

/// An abstract repository interface for fetching [ExampleEntity].
/// This would typically be in the `domain/repositories` directory.
abstract class IExampleRepository extends BaseRepository {
  FutureResult<ExampleEntity> getExampleData(
      String id, Map<String, dynamic>? queryParams);
  FutureResult<List<ExampleEntity>> getMultipleExampleData(List<String> ids);
  FutureResult<void> performSomeSideEffect();
}

// --- Example Use Case Implementation ---

/// Parameters for the [GetExampleDataUseCase].
class ExampleParams {
  final String id;
  final Map<String, dynamic>? queryParams;

  const ExampleParams({
    required this.id,
    this.queryParams,
  });
}

/// An example use case demonstrating how to extend [UseCase].
///
/// This use case fetches a single [ExampleEntity] using an [IExampleRepository].
class GetExampleDataUseCase extends UseCase<ExampleEntity, ExampleParams> {
  final IExampleRepository _repository;

  /// Creates an [GetExampleDataUseCase].
  ///
  /// Requires an instance of [IExampleRepository] to fetch data.
  GetExampleDataUseCase(this._repository);

  @override
  FutureResult<ExampleEntity> execute(ExampleParams params) async {
    // Here you would typically call a method on the repository.
    // The repository is responsible for fetching data (e.g., from a remote API or local cache)
    // and converting it from a data model to a domain entity.
    return _repository.getExampleData(params.id, params.queryParams);
  }
}

/// Parameters for [GetMultipleExampleDataUseCase].
class MultipleExampleParams {
  final List<String> ids;
  const MultipleExampleParams(this.ids);
}

/// An example use case demonstrating fetching multiple entities.
class GetMultipleExampleDataUseCase
    extends UseCase<List<ExampleEntity>, MultipleExampleParams> {
  final IExampleRepository _repository;

  GetMultipleExampleDataUseCase(this._repository);

  @override
  FutureResult<List<ExampleEntity>> execute(MultipleExampleParams params) {
    return _repository.getMultipleExampleData(params.ids);
  }
}

/// Example of a use case that requires no parameters.
class PerformActionUseCase extends UseCase<void, NoParams> {
  final IExampleRepository
      _repository; // Assuming some action might involve a repo

  PerformActionUseCase(this._repository);

  @override
  FutureResult<void> execute(NoParams params) async {
    // Perform some action, e.g.,
    await _repository.performSomeSideEffect();
    // For this example, we'll just simulate success.
    await Future.delayed(
        const Duration(milliseconds: 100)); // Simulate async work
    return const Success(null); // Success with no data
  }
}

// --- Example Usage (Illustrative) ---
// This section demonstrates how the use cases might be invoked.
// In a real app, this would be in a presentation layer component (e.g., BLoC, ViewModel).

/// Illustrates how to use the defined example use cases.
///
/// **Note**: This is for demonstration purposes only and would not typically
/// reside in this file in a production application.
void exampleUseCaseUsage() async {
  // In a real application, IExampleRepository would be implemented in the data layer
  // and provided via dependency injection.
  final IExampleRepository mockRepository = MockExampleRepository();

  // Instantiate the use cases
  final getExampleData = GetExampleDataUseCase(mockRepository);
  final getMultipleExampleData = GetMultipleExampleDataUseCase(mockRepository);
  final performAction = PerformActionUseCase(mockRepository);

  log('--- Running GetExampleDataUseCase ---');
  final singleResult = await getExampleData(
      const ExampleParams(id: '123', queryParams: {'page': 1}));
  singleResult.when(
    onSuccess: (entity) => log('Success! Fetched: $entity'),
    onFailure: (failure) => log('Error! ${failure.message}'),
  );

  // Example of cancellation (conceptual)
  // Timer(const Duration(milliseconds: 50), () {
  //   log('Attempting to cancel getExampleData for id 456...');
  //   getExampleData.cancel(); // This would cancel if called during an active 'call'
  // });
  // final cancellableResult = await getExampleData(ExampleParams(id: '456')); // New call needed
  // cancellableResult.when(
  //   onSuccess: (entity) => log('Success (456)! Fetched: $entity'),
  //   onFailure: (failure) => log('Error (456)! ${failure.message}'),
  // );

  log('\n--- Running GetMultipleExampleDataUseCase ---');
  final multipleResult = await getMultipleExampleData(
      const MultipleExampleParams(['a', 'b', 'c']));
  multipleResult.when(
    onSuccess: (entities) =>
        log('Success! Fetched ${entities.length} entities: $entities'),
    onFailure: (failure) => log('Error! ${failure.message}'),
  );

  log('\n--- Running PerformActionUseCase (NoParams) ---');
  final actionResult = await performAction(const NoParams());
  actionResult.when(
    onSuccess: (_) => log('Action performed successfully!'),
    onFailure: (failure) => log('Action failed! ${failure.message}'),
  );
}

/// A mock implementation of [IExampleRepository] for demonstration purposes.
class MockExampleRepository implements IExampleRepository {
  @override
  FutureResult<ExampleEntity> getExampleData(
      String id, Map<String, dynamic>? queryParams) async {
    await Future.delayed(
        const Duration(milliseconds: 100)); // Simulate network delay
    if (id == 'error') {
      return Error(NetworkFailure(message: 'Failed to fetch entity $id'));
    }
    if (id == 'cancelled_target') {
      await Future.delayed(const Duration(milliseconds: 500)); // Longer delay
      return Success(
        ExampleEntity(id: id, data: 'Data for $id with params $queryParams'),
      );
    }
    return Success(
      ExampleEntity(id: id, data: 'Data for $id with params $queryParams'),
    );
  }

  @override
  FutureResult<List<ExampleEntity>> getMultipleExampleData(
      List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (ids.contains('error_multi')) {
      return const Error(
          NetworkFailure(message: 'Failed to fetch one of the entities'));
    }
    final entities = ids
        .map((id) => ExampleEntity(id: id, data: 'Multiple data for $id'))
        .toList();
    return Success(entities);
  }

  @override
  FutureResult<void> performSomeSideEffect() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Simulate work
    // Simulate a random failure or success for demonstration
    const shouldFail = false; // Change to true to simulate failure

    return const Success(null);
  }

  @override
  FutureResult<BaseEntity> create(BaseEntity entity) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  FutureResult<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  FutureResult<List<BaseEntity>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  FutureResult<BaseEntity> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  FutureResult<List<BaseEntity>> getPaginated(
      {required int page,
      required int limit,
      String? sortBy,
      bool descending = false}) {
    // TODO: implement getPaginated
    throw UnimplementedError();
  }

  @override
  FutureResult<List<BaseEntity>> search(String query) {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  FutureResult<BaseEntity> update(BaseEntity entity) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

/*
/// Old Example usage comment (for reference during refactoring):
///
/// ```dart
/// final useCase = ExampleUseCase( // Old name
///   client: dioClient, // Direct Dio dependency - not ideal for domain layer
///   // cacheConfig, maxRetries, retryDelay - Data layer concerns
/// );
///
/// // useCase.progress?.listen - BaseUseCase does not have progress
///
/// try {
///   final result = await useCase.execute( // Should be useCase.call() or useCase()
///     ExampleParams(
///       id: '123',
///       queryParams: {'page': 1},
///     ),
///   );
///   log('Result: $result');
/// } catch (e) {
///   log('Error: $e');
/// }
///
/// // Cancel the operation
/// useCase.cancel();
/// ```
*/
