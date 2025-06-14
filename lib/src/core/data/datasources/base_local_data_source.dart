import '../../domain/entities/base_entity.dart';

/// Abstract interface for data sources that manage local data persistence (caching).
///
/// A local data source is responsible for:
/// - Storing, retrieving, and deleting domain entities ([BaseEntity]) from a local store (e.g., Hive, SharedPreferences, SQLite).
/// - Handling local storage errors by throwing a specific `CacheException`.
///
/// This interface works directly with domain entities, as it's a cache for the objects
/// the application's business logic operates on.
abstract class BaseLocalDataSource<T extends BaseEntity> {
  /// Retrieves a list of all entities from the local cache.
  ///
  /// Returns an empty list if no entities are found.
  /// Throws a `CacheException` if the read operation fails.
  Future<List<T>> getAll();

  /// Retrieves a single entity by its unique [id] from the local cache.
  ///
  /// Throws a `CacheException` if the entity is not found or the read operation fails.
  Future<T> getById(String id);

  /// Saves a single [entity] to the local cache.
  ///
  /// If an entity with the same ID already exists, it will be overwritten.
  /// Throws a `CacheException` if the write operation fails.
  Future<void> save(T entity);

  /// Saves a list of [entities] to the local cache.
  ///
  /// This should be an atomic operation if possible. If any entity fails to save,
  /// the implementation should decide whether to roll back or report a partial success.
  /// Throws a `CacheException` if the write operation fails.
  Future<void> saveAll(List<T> entities);

  /// Deletes an entity by its unique [id] from the local cache.
  ///
  /// Throws a `CacheException` if the delete operation fails.
  Future<void> delete(String id);

  /// Clears all entities of type [T] from the local cache.
  ///
  /// Throws a `CacheException` if the clear operation fails.
  Future<void> clear();

  /// Checks if an entity with the given [id] exists in the cache.
  ///
  /// Returns `true` if it exists, `false` otherwise.
  /// Throws a `CacheException` if the check fails.
  Future<bool> exists(String id);
}
