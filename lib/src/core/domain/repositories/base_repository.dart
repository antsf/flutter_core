/// Base repository interface for CRUD and query operations on entities.
///
/// This interface defines the basic operations for managing entities,
/// including creating, reading, updating, deleting, and searching entities.
/// It also supports pagination and sorting of entity results.
library base_repository;

import '../entities/base_entity.dart';
import '../failures/failures.dart';

/// Base repository interface for CRUD and query operations on entities.
abstract class BaseRepository<T extends BaseEntity> {
  /// Get all entities
  Future<Result<List<T>>> getAll();

  /// Get entity by id
  Future<Result<T>> getById(String id);

  /// Create new entity
  Future<Result<T>> create(T entity);

  /// Update existing entity
  Future<Result<T>> update(T entity);

  /// Delete entity by id
  Future<Result<void>> delete(String id);

  /// Search entities with query
  Future<Result<List<T>>> search(String query);

  /// Get entities with pagination
  Future<Result<List<T>>> getPaginated({
    required int page,
    required int limit,
    String? sortBy,
    bool descending = false,
  });
}
