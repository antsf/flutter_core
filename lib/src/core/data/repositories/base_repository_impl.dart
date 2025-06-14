import 'dart:developer';

import '../../domain/entities/base_entity.dart';
import '../../domain/failures/failures.dart';
import '../../domain/repositories/base_repository.dart';
import '../datasources/base_local_data_source.dart';
import '../datasources/base_remote_data_source.dart';
import '../models/base_model.dart';

/// An abstract base implementation of the [BaseRepository].
///
/// This class provides a standard implementation for a repository that fetches data
/// from a remote source and caches it locally. It orchestrates calls between a
/// [BaseRemoteDataSource] (which deals with [BaseModel]s and network exceptions)
/// and a [BaseLocalDataSource] (which deals with [BaseEntity]s and cache exceptions).
///
/// It implements a "cache-then-network" strategy for read operations.
///
/// ### Subclassing
///
/// A concrete implementation must provide:
/// 1. The [BaseRemoteDataSource] and [BaseLocalDataSource].
/// 2. An implementation for the `toModel` method to convert a domain [BaseEntity]
///    into a data [BaseModel] for `create` and `update` operations.
abstract class BaseRepositoryImpl<T extends BaseEntity, M extends BaseModel<T>>
    implements BaseRepository<T> {
  final BaseRemoteDataSource<M> remoteDataSource;
  final BaseLocalDataSource<T> localDataSource;

  BaseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Converts a domain [BaseEntity] into a [BaseModel].
  /// Required for `create` and `update` operations.
  M toModel(T entity);

  @override
  Future<Result<List<T>>> getAll() async {
    try {
      // Attempt to fetch from the local cache first.
      final localEntities = await localDataSource.getAll();
      if (localEntities.isNotEmpty) {
        return (data: localEntities, failure: null);
      }
    } catch (e) {
      // Log cache failure but proceed to network.
      log('Cache read failed for getAll: $e');
    }

    // If cache is empty or fails, fetch from the remote source.
    try {
      final remoteModels = await remoteDataSource.getAll();
      final remoteEntities = remoteModels.map((m) => m.toEntity()).toList();
      await localDataSource.saveAll(remoteEntities);
      return (data: remoteEntities, failure: null);
    } catch (e, stackTrace) {
      return (
        data: null,
        failure: NetworkFailure(
          message: 'Failed to get all entities from remote.',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<T>> getById(String id) async {
    try {
      final localEntity = await localDataSource.getById(id);
      return (data: localEntity, failure: null);
    } catch (e) {
      log('Cache read failed for getById: $e');
    }

    try {
      final remoteModel = await remoteDataSource.getById(id);
      final remoteEntity = remoteModel.toEntity();
      await localDataSource.save(remoteEntity);
      return (data: remoteEntity, failure: null);
    } catch (e, stackTrace) {
      return (
        data: null,
        failure: NetworkFailure(
          message: 'Failed to get entity by id from remote.',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<T>> create(T entity) async {
    try {
      final modelToCreate = toModel(entity);
      final remoteModel = await remoteDataSource.create(modelToCreate);
      final createdEntity = remoteModel.toEntity();
      await localDataSource.save(createdEntity);
      return (data: createdEntity, failure: null);
    } catch (e, stackTrace) {
      return (
        data: null,
        failure: NetworkFailure(
          message: 'Failed to create entity.',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<T>> update(T entity) async {
    try {
      final modelToUpdate = toModel(entity);
      final remoteModel = await remoteDataSource.update(modelToUpdate);
      final updatedEntity = remoteModel.toEntity();
      await localDataSource.save(updatedEntity);
      return (data: updatedEntity, failure: null);
    } catch (e, stackTrace) {
      return (
        data: null,
        failure: NetworkFailure(
          message: 'Failed to update entity.',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await remoteDataSource.delete(id);
      await localDataSource.delete(id);
      return (data: (), failure: null);
    } catch (e, stackTrace) {
      return (
        data: null,
        failure: NetworkFailure(
          message: 'Failed to delete entity.',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<T>>> search(String query) async {
    try {
      final remoteModels = await remoteDataSource.search(query: query);
      final entities = remoteModels.map((m) => m.toEntity()).toList();
      // Note: Caching search results might not always be desirable.
      // This implementation caches them for consistency with the original code.
      await localDataSource.saveAll(entities);
      return (data: entities, failure: null);
    } catch (e, stackTrace) {
      return (
        data: null,
        failure: NetworkFailure(
          message: 'Failed to search entities.',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<T>>> getPaginated({
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
      // Note: Caching paginated results might require more complex logic
      // (e.g., storing by page). This simple implementation overwrites the cache.
      await localDataSource.saveAll(entities);
      return (data: entities, failure: null);
    } catch (e, stackTrace) {
      return (
        data: null,
        failure: NetworkFailure(
          message: 'Failed to get paginated entities.',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
