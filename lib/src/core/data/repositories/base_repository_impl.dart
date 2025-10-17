import 'dart:developer' show log; // For logging cache errors

import 'package:flutter_core/src/core/data/repositories/data_source_strategy.dart'
    show DataSourceStrategy;
import 'package:flutter_core/src/core/data/repositories/safe_call.dart'
    show safeRemoteCall, safeRemoteCallVoid;

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
  final BaseRemoteDataSource<M>? remoteDataSource;

  /// The local data source for caching and retrieving data from local persistence.
  final BaseLocalDataSource<T>? localDataSource;

  final DataSourceStrategy strategy;

  /// Constructs a [BaseRepositoryImpl].
  ///
  /// Requires [remoteDataSource] for network operations and
  /// [localDataSource] for local caching.
  BaseRepositoryImpl({
    this.remoteDataSource,
    this.localDataSource,
    this.strategy = DataSourceStrategy.remoteOnly,
  }) {
    // Validate required sources based on strategy
    if (strategy == DataSourceStrategy.remoteOnly && remoteDataSource == null) {
      throw ArgumentError(
          'remoteDataSource is required for remoteOnly strategy');
    }
    if (strategy == DataSourceStrategy.localOnly && localDataSource == null) {
      throw ArgumentError('localDataSource is required for localOnly strategy');
    }
  }

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
    switch (strategy) {
      case DataSourceStrategy.localOnly:
        return _getAllFromLocal();

      case DataSourceStrategy.remoteOnly:
        return _getAllFromRemote();

      case DataSourceStrategy.localWithRemoteFallback:
        final localResult = await _getAllFromLocal();
        if (localResult.isSuccess && localResult.data!.isNotEmpty) {
          return localResult;
        }
        return _getAllFromRemote();

      case DataSourceStrategy.remoteWithLocalCache:
        final remoteResult = await _getAllFromRemote();
        if (remoteResult.isSuccess) {
          // Save to cache if localDataSource exists
          _saveAllToCache(remoteResult.data!);
        }
        return remoteResult;
    }
  }

// Private helpers
  FutureResult<List<T>> _getAllFromLocal() async {
    if (localDataSource == null) {
      return const Error(
          CacheFailure(message: 'Local data source not available'));
    }
    try {
      final data = await localDataSource!.getAll();
      return Success(data);
    } catch (e, s) {
      log('getAll: Local read failed', error: e, stackTrace: s);
      return Error(
          CacheFailure(message: 'Cache read failed', error: e, stackTrace: s));
    }
  }

  FutureResult<List<T>> _getAllFromRemote() async {
    if (remoteDataSource == null) {
      return const Error(
          NetworkFailure(message: 'Remote data source not available'));
    }

    // 1. Define the wrapper function to conform to RemoteCall<List<M>>.
    // This wrapper handles the exception-throwing call and returns a FutureResult.

    // 2. Use safeRemoteCall to execute the wrapper and transform the success data.
    final result = await safeRemoteCall<List<M>, List<T>>(
      remoteCall: () async {
        try {
          final models = await remoteDataSource!.getAll();
          return Success(models);
        } catch (e, s) {
          // This now creates the correct Failure type before safeRemoteCall sees it.
          return Error(NetworkFailure(
              message: 'Failed to get all items from remote',
              error: e,
              stackTrace: s));
        }
      },
      onSuccess: (models) {
        // Transform List<M> to List<T>
        return models.map((m) => m.toEntity()).toList();
      },
    );

    // 3. Return the Success data or the Failure error.
    if (result.isSuccess && result.data != null) {
      return Success(result.data as List<T>);
    } else {
      // safeRemoteCall has already mapped exceptions to Failures.
      return Error(result.failure ??
          const GenericFailure(message: 'Unknown remote fetch error'));
    }
  }

  void _saveAllToCache(List<T> entities) {
    if (localDataSource != null) {
      localDataSource!.saveAll(entities).catchError((e) {
        log('getAll: Failed to cache data: $e');
      });
    }
  }

  @override
  FutureResult<T> getById(String id) async {
    switch (strategy) {
      case DataSourceStrategy.localOnly:
        return _getByIdFromLocal(id);

      case DataSourceStrategy.remoteOnly:
        return _getByIdFromRemote(id);

      case DataSourceStrategy.localWithRemoteFallback:
        final local = await _getByIdFromLocal(id);
        if (local.isSuccess) return local;
        return _getByIdFromRemote(id);

      case DataSourceStrategy.remoteWithLocalCache:
        final remote = await _getByIdFromRemote(id);
        if (remote.isSuccess) {
          _saveToCache(remote.data!);
        }
        return remote;
    }
  }

  FutureResult<T> _getByIdFromLocal(String id) async {
    if (localDataSource == null) {
      return const Error(
          CacheFailure(message: 'Local data source not available'));
    }
    try {
      final data = await localDataSource!.getById(id);
      return Success(data);
    } catch (e, s) {
      return Error(
          CacheFailure(message: 'Cache read failed', error: e, stackTrace: s));
    }
  }

  FutureResult<T> _getByIdFromRemote(String id) async {
    if (remoteDataSource == null) {
      return const Error(
          NetworkFailure(message: 'Remote data source not available'));
    }

    // final RemoteCall<M> remoteCallWrapper = () async {
    //   try {
    //     final model = await remoteDataSource!.getById(id);
    //     return Success(model);
    //   } catch (e, s) {
    //     log('getById: Remote fetch failed inside wrapper',
    //         error: e, stackTrace: s);
    //     return const  Error(NetworkFailure(
    //         message: 'Network request failed', error: e, stackTrace: s));
    //   }
    // };

    final result = await safeRemoteCall<M, T>(
      remoteCall: () async {
        final model = await remoteDataSource!.getById(id);
        return Success(model);
      },
      onSuccess: (model) => model.toEntity(), // Transform M to T
    );

    if (result.isSuccess && result.data != null) {
      return Success(result.data as T);
    } else {
      return Error(result.failure ??
          const GenericFailure(message: 'Unknown remote fetch error'));
    }
  }

  void _saveToCache(T entity) {
    localDataSource?.save(entity).catchError((e) {
      log('getById: Failed to cache entity: $e');
    });
  }

  /// 🚀 UPDATED to use safeRemoteCall
  @override
  FutureResult<T> create(T entity) async {
    if (remoteDataSource == null) {
      return const Error(NetworkFailure(
          message: 'Remote data source required for write operations'));
    }

    final model = toModel(entity);

    // final RemoteCall<M> remoteCallWrapper = () async {
    //   try {
    //     final remoteModel = await remoteDataSource!.create(model);
    //     return Success(remoteModel);
    //   } catch (e, s) {
    //     log('create: Remote call failed inside wrapper',
    //         error: e, stackTrace: s);
    //     return Error(
    //         NetworkFailure(message: 'Create failed', error: e, stackTrace: s));
    //   }
    // };

    final result = await safeRemoteCall<M, T>(
      remoteCall: () async {
        try {
          final remoteModel = await remoteDataSource!.create(model);
          return Success(remoteModel);
        } catch (e, s) {
          // FIX: You must return the Error from the catch block.
          return Error(NetworkFailure(
              message: 'Create failed during remote call',
              error: e,
              stackTrace: s));
        }
      },
      onSuccess: (remoteModel) {
        final created = remoteModel.toEntity();
        // Side effect: Save to cache if available
        localDataSource?.save(created).catchError((e) {
          log('create: Failed to cache: $e');
        });
        return created;
      },
    );

    if (result.isSuccess && result.data != null) {
      return Success(result.data as T);
    } else {
      return Error(result.failure ??
          const GenericFailure(message: 'Unknown create error'));
    }
  }

  /// 🚀 UPDATED to use safeRemoteCall
  @override
  FutureResult<T> update(T entity) async {
    // Check is done by safeRemoteCall's failure handling if remoteDataSource is null,
    // but explicit check is better for early exit with clear message.
    if (remoteDataSource == null) {
      return const Error(NetworkFailure(
          message: 'Remote data source required for write operations'));
    }

    final modelToUpdate = toModel(entity);

    // final RemoteCall<M> remoteCallWrapper = () async {
    //   try {
    //     final remoteModel = await remoteDataSource!.update(modelToUpdate);
    //     return Success(remoteModel);
    //   } catch (e, s) {
    //     log('update: Remote call failed inside wrapper',
    //         error: e, stackTrace: s);
    //     return Error(
    //         NetworkFailure(message: 'Update failed', error: e, stackTrace: s));
    //   }
    // };

    final result = await safeRemoteCall<M, T>(
      remoteCall: () async {
        final remoteModel = await remoteDataSource!.update(modelToUpdate);
        return Success(remoteModel);
      },
      onSuccess: (remoteModel) {
        final updatedEntity = remoteModel.toEntity();
        // Side effect: Save to cache
        localDataSource?.save(updatedEntity).catchError((cacheError) {
          log('update: Entity updated remotely, but failed to save to cache. ID: $updatedEntity. Error: $cacheError');
        });
        return updatedEntity;
      },
    );

    if (result.isSuccess && result.data != null) {
      return Success(result.data as T);
    } else {
      return Error(result.failure ??
          const GenericFailure(message: 'Unknown update error'));
    }
  }

  /// 🚀 UPDATED to use safeRemoteCallVoid
  @override
  FutureResult<void> delete(String id) async {
    if (remoteDataSource == null) {
      return const Error(NetworkFailure(
          message: 'Remote data source required for write operations'));
    }

    // Step 1: Perform the remote operation using safeRemoteCall.
    final remoteResult = await safeRemoteCallVoid<void>(
      remoteCall: () async {
        try {
          await remoteDataSource!.delete(id);
          return const Success(null);
        } catch (e, s) {
          // FIX: Ensure this catch block returns a NetworkFailure.
          return Error(NetworkFailure(
              message: 'Delete failed during remote call',
              error: e,
              stackTrace: s));
        }
      },
    );

    // Step 2: If the remote operation failed, return the failure immediately.
    if (remoteResult.isFailure) {
      return remoteResult;
    }

    // Step 3: If remote succeeded, try to delete from local cache.
    // A try-catch ensures that any error here is logged but doesn't cause a failure.
    try {
      await localDataSource?.delete(id);
    } catch (e, s) {
      log(
        'delete: Failed to delete from local cache after successful remote delete. This is a non-fatal error.',
        error: e,
        stackTrace: s,
      );
      // IMPORTANT: Do not return an Error here.
    }

    // Step 4: Always return Success because the critical remote operation succeeded.
    return const Success(null);
  }

  /// 🚀 UPDATED to use safeRemoteCall
  @override
  FutureResult<List<T>> search(String query) async {
    if (remoteDataSource == null) {
      return const Error(NetworkFailure(
          message: 'Remote data source not available for searching'));
    }

    // 1. Define the wrapper function to conform to RemoteCall<List<M>>.
    // This wrapper handles the exception-throwing remoteDataSource.search call.
    // final RemoteCall<List<M>> remoteCallWrapper = () async {
    //   try {
    //     final remoteModels = await remoteDataSource!.search(query: query);
    //     return Success(remoteModels);
    //   } catch (e, s) {
    //     log('search: Remote call failed inside wrapper',
    //         error: e, stackTrace: s);
    //     return const Error(NetworkFailure(
    //         message: 'Search request failed', error: e, stackTrace: s));
    //   }
    // };

    // 2. Use safeRemoteCall to execute the wrapper and transform the success data.
    final result = await safeRemoteCall<List<M>, List<T>>(
      remoteCall: () async {
        final remoteModels = await remoteDataSource!.search(query: query);
        return Success(remoteModels);
      },
      onSuccess: (remoteModels) {
        // Transform List<M> to List<T>
        final entities = remoteModels.map((m) => m.toEntity()).toList();

        // Side effect: Caching search results
        log('search: Caching search results for query "$query". This will overwrite existing cache.');
        localDataSource?.saveAll(entities).catchError((cacheError) {
          log('search: Fetched search results for query "$query", but failed to save to cache. Error: $cacheError');
        });

        return entities;
      },
      genericError: 'Failed to search entities with query "$query".',
    );

    // 3. Return the Success data or the Failure error.
    if (result.isSuccess && result.data != null) {
      return Success(result.data as List<T>);
    } else {
      return Error(result.failure ??
          const GenericFailure(message: 'Unknown search error'));
    }
  }

// -----------------------------------------------------------------------------

  /// 🚀 UPDATED to use safeRemoteCall
  @override
  FutureResult<List<T>> getPaginated({
    required int page,
    required int limit,
    String? sortBy,
    bool descending = false,
  }) async {
    if (remoteDataSource == null) {
      return const Error(NetworkFailure(
          message: 'Remote data source not available for pagination'));
    }

    // 1. Define the wrapper function to conform to RemoteCall<List<M>>.
    // final RemoteCall<List<M>> remoteCallWrapper = () async {
    //   try {
    //     final remoteModels = await remoteDataSource!.getPaginated(
    //       page: page,
    //       limit: limit,
    //       sortBy: sortBy,
    //       descending: descending,
    //     );
    //     return Success(remoteModels);
    //   } catch (e, s) {
    //     log('getPaginated: Remote call failed inside wrapper',
    //         error: e, stackTrace: s);
    //     return const Error(NetworkFailure(
    //         message: 'Pagination request failed', error: e, stackTrace: s));
    //   }
    // };

    // 2. Use safeRemoteCall to execute the wrapper and transform the success data.
    final result = await safeRemoteCall<List<M>, List<T>>(
      remoteCall: () async {
        final remoteModels = await remoteDataSource!.getPaginated(
          page: page,
          limit: limit,
          sortBy: sortBy,
          descending: descending,
        );
        return Success(remoteModels);
      },
      onSuccess: (remoteModels) {
        // Transform List<M> to List<T>
        final entities = remoteModels.map((m) => m.toEntity()).toList();

        // Side effect: Caching paginated results
        log('getPaginated: Caching page $page (limit $limit). This will overwrite existing cache.');
        localDataSource?.saveAll(entities).catchError((cacheError) {
          log('getPaginated: Fetched page $page, but failed to save to cache. Error: $cacheError');
        });

        return entities;
      },
      genericError:
          'Failed to get paginated entities (page $page, limit $limit).',
    );

    // 3. Return the Success data or the Failure error.
    if (result.isSuccess && result.data != null) {
      return Success(result.data as List<T>);
    } else {
      return Error(result.failure ??
          const GenericFailure(message: 'Unknown pagination error'));
    }
  }
}
