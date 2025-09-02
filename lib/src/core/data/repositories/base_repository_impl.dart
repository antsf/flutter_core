import 'dart:developer' show log; // For logging cache errors

import '../../domain/entities/base_entity.dart';
import '../../domain/failures/failures.dart';
import '../../domain/repositories/base_repository.dart'; // For Result typedef if defined there
import '../datasources/base_local_data_source.dart';
import '../datasources/base_remote_data_source.dart';
import '../models/base_model.dart';

// Assuming Result is a record type like:
// typedef Result<T> = ({T? data, Failure? failure});
// This should ideally be defined in the domain layer, possibly in base_repository.dart or failures.dart.

/// An abstract base implementation of the [BaseRepository] interface.
///
/// This class provides a standard implementation for common repository operations,
/// including fetching data from a remote source and caching it locally. It
/// orchestrates interactions between a [BaseRemoteDataSource] (handling network
/// communication and [BaseModel]s) and a [BaseLocalDataSource] (handling local
/// persistence and [BaseEntity]s).
///
/// ### Data Flow and Error Handling:
/// - For read operations ([getAll], [getById]):
///   - It first attempts to retrieve data from the [localDataSource].
///   - If data is found and valid, it's returned.
///   - If the local cache is empty or a cache error occurs (logged, but doesn't stop the flow),
///     it proceeds to fetch data from the [remoteDataSource].
///   - Successful remote data is then saved to the [localDataSource] and returned.
///   - Network errors from the [remoteDataSource] are caught and returned as a [NetworkFailure]
///     within the [Result] object.
/// - For write operations ([create], [update], [delete]):
///   - Data is sent to the [remoteDataSource].
///   - If successful, the corresponding operation (save or delete) is performed on the [localDataSource].
///   - Errors during these operations are caught and returned as a [NetworkFailure].
///
/// ### Caching Strategy:
/// - `getAll` and `getById`: Implement a cache-first, then network strategy. Successful network
///   responses update the local cache.
/// - `search` and `getPaginated`: Currently employ a naive caching strategy where results
///   overwrite the entire local cache. This might not be suitable for all use cases.
///   **Subclasses may need to override these methods to implement more sophisticated caching
///   or to disable caching for these specific operations.**
///
/// ### Subclassing Requirements:
/// Concrete subclasses must:
/// 1. Provide instances of [BaseRemoteDataSource] and [BaseLocalDataSource] via the constructor.
/// 2. Implement the [toModel] method, which converts a domain [BaseEntity]
///    into a data layer [BaseModel] (necessary for `create` and `update` operations
///    that send data to the remote source).
///
/// Type Parameters:
/// - [T]: The type of the domain [BaseEntity].
/// - [M]: The type of the data [BaseModel], which must extend `BaseModel<T>`.
abstract class BaseRepositoryImpl<T extends BaseEntity, M extends BaseModel<T>>
    implements BaseRepository<T> {
  /// The remote data source for fetching and manipulating data over the network.
  final BaseRemoteDataSource<M> remoteDataSource;

  /// The local data source for caching and retrieving data from local persistence.
  final BaseLocalDataSource<T> localDataSource;

  /// Constructs a [BaseRepositoryImpl].
  ///
  /// Requires [remoteDataSource] for network operations and
  /// [localDataSource] for local caching.
  BaseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Converts a domain entity [T] into its corresponding data model [M].
  ///
  /// This method is essential for operations like `create` and `update`,
  /// where the domain entity needs to be transformed into a data model
  /// before being sent to the remote data source.
  ///
  /// Subclasses must implement this conversion logic.
  M toModel(T entity);

  @override
  FutureResult<List<T>> getAll() async {
    try {
      // Attempt to fetch from the local cache first.
      // Cache is treated as an enhancement; network is the source of truth if cache fails or is empty.
      final localEntities = await localDataSource.getAll();
      if (localEntities.isNotEmpty) {
        log('getAll: Data successfully retrieved from local cache.');
        return Success(localEntities);
      }
    } catch (e) {
      // Log cache failure but proceed to network as cache is not critical for this read.
      log('getAll: Cache read failed, proceeding to network. Error: $e');
      return Error(ServerFailure(message: e.toString()));
    }

    // If cache is empty or fails, fetch from the remote source.
    try {
      final remoteModels = await remoteDataSource.getAll();
      final remoteEntities = remoteModels.map((m) => m.toEntity()).toList();
      try {
        await localDataSource.saveAll(remoteEntities);
        log('getAll: Data fetched from remote and saved to local cache.');
      } catch (cacheError) {
        log('getAll: Fetched from remote, but failed to save to cache. Error: $cacheError');
        // Still return remote data, cache save is secondary for success of getAll.
      }
      return Success(remoteEntities);
    } catch (e, stackTrace) {
      log('getAll: Network fetch failed. Error: $e');
      return Error(
        NetworkFailure(
          message: 'Failed to get all entities from remote source.',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  FutureResult<T> getById(String id) async {
    try {
      // Attempt to fetch from the local cache first.
      final localEntity = await localDataSource.getById(id);
      log('getById: Entity $id successfully retrieved from local cache.');
      return Success(localEntity);
    } catch (e) {
      // Log cache failure but proceed to network.
      log('getById: Cache read failed for entity $id, proceeding to network. Error: $e');
    }

    try {
      final remoteModel = await remoteDataSource.getById(id);
      final remoteEntity = remoteModel.toEntity();
      try {
        await localDataSource.save(remoteEntity);
        log('getById: Entity $id fetched from remote and saved to local cache.');
      } catch (cacheError) {
        log('getById: Fetched entity $id from remote, but failed to save to cache. Error: $cacheError');
      }
      return Success(remoteEntity);
    } catch (e, stackTrace) {
      log('getById: Network fetch failed for entity $id. Error: $e');
      return Error(
        NetworkFailure(
          message: 'Failed to get entity by id "$id" from remote source.',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  FutureResult<T> create(T entity) async {
    try {
      final modelToCreate = toModel(entity);
      final remoteModel = await remoteDataSource.create(modelToCreate);
      final createdEntity = remoteModel.toEntity();
      try {
        await localDataSource.save(createdEntity);
        log('create: Entity created remotely and saved locally: $createdEntity');
      } catch (cacheError) {
        log('create: Entity created remotely, but failed to save to cache. ID: $createdEntity. Error: $cacheError');
        // Remote creation succeeded, so we might still return success despite cache failure.
      }
      return Success(createdEntity);
    } catch (e, stackTrace) {
      log('create: Network operation to create entity failed. Error: $e');
      return Error(
        NetworkFailure(
          message: 'Failed to create entity on remote source.',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  FutureResult<T> update(T entity) async {
    try {
      final modelToUpdate = toModel(entity);
      final remoteModel = await remoteDataSource.update(modelToUpdate);
      final updatedEntity = remoteModel.toEntity();
      try {
        await localDataSource.save(updatedEntity);
        log('update: Entity updated remotely and saved locally: $updatedEntity');
      } catch (cacheError) {
        log('update: Entity updated remotely, but failed to save to cache. ID: $updatedEntity. Error: $cacheError');
      }
      return Success(updatedEntity);
    } catch (e, stackTrace) {
      log('update: Network operation to update entity failed. ID: $entity. Error: $e');
      return Error(
        NetworkFailure(
          message: 'Failed to update entity on remote source. ID: $entity',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  FutureResult<void> delete(String id) async {
    try {
      await remoteDataSource.delete(id);
      // If remote deletion is successful, attempt local deletion.
      try {
        await localDataSource.delete(id);
        log('delete: Entity $id deleted from remote and local sources.');
      } catch (cacheError) {
        log('delete: Entity $id deleted from remote, but failed to delete from cache. Error: $cacheError');
        // Remote deletion was successful, so overall operation is a success.
      }
      return const Success(null);
    } catch (e, stackTrace) {
      log('delete: Network operation to delete entity $id failed. Error: $e');
      return Error(
        NetworkFailure(
          message: 'Failed to delete entity on remote source. ID: $id',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  FutureResult<List<T>> search(String query) async {
    try {
      final remoteModels = await remoteDataSource.search(query: query);
      final entities = remoteModels.map((m) => m.toEntity()).toList();

      // WARNING: Naive caching for search results.
      // This overwrites the entire local cache with search results.
      // Subclasses may need to implement a more sophisticated caching strategy
      // or disable caching for search results if this behavior is not desired.
      log('search: Caching search results for query "$query". This will overwrite existing cache.');
      try {
        await localDataSource.saveAll(entities);
      } catch (cacheError) {
        log('search: Fetched search results for query "$query", but failed to save to cache. Error: $cacheError');
      }
      return Success(entities);
    } catch (e, stackTrace) {
      log('search: Network search for query "$query" failed. Error: $e');
      return Error(
        NetworkFailure(
          message: 'Failed to search entities with query "$query".',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  FutureResult<List<T>> getPaginated({
    required int page,
    required int limit,
    String? sortBy,
    bool descending = false,
  }) async {
    try {
      final remoteModels = await remoteDataSource.getPaginated(
        page: page,
        limit: limit,
        sortBy: sortBy,
        descending: descending,
      );
      final entities = remoteModels.map((m) => m.toEntity()).toList();

      // WARNING: Naive caching for paginated results.
      // This overwrites the entire local cache with the current page's data.
      // Subclasses should implement appropriate caching logic for pagination,
      // such as storing pages separately, appending, or disabling caching if needed.
      log('getPaginated: Caching page $page (limit $limit). This will overwrite existing cache.');
      try {
        await localDataSource.saveAll(entities);
      } catch (cacheError) {
        log('getPaginated: Fetched page $page, but failed to save to cache. Error: $cacheError');
      }
      return Success(entities);
    } catch (e, stackTrace) {
      log('getPaginated: Network fetch for page $page (limit $limit) failed. Error: $e');
      return Error(
        NetworkFailure(
          message:
              'Failed to get paginated entities (page $page, limit $limit).',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
