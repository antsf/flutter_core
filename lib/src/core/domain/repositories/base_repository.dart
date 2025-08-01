/// Defines the contract for repositories that manage domain entities.
///
/// This library provides the [BaseRepository] interface, which outlines
/// standard CRUD (Create, Read, Update, Delete) and query operations
/// for entities of type [T]. All operations return a [Result] type,
/// encapsulating either success data or a [Failure].
library base_repository;

import '../entities/base_entity.dart';
import '../failures/failures.dart'; // Provides Result typedef and Failure classes

/// An abstract interface defining the contract for repositories.
///
/// Repositories are responsible for abstracting data operations and providing
/// a clean API for use cases to interact with data sources (local or remote).
///
/// Type [T] must be a subclass of [BaseEntity].
/// All methods return a [Future] of [Result<DataType>], where `DataType`
/// is the expected data on success, and [Result] encapsulates potential failures.
abstract class BaseRepository<T extends BaseEntity> {
  /// Retrieves all entities of type [T].
  ///
  /// Returns a [Result] containing a list of entities on success,
  /// or a [Failure] on error.
  FutureResult<List<T>> getAll();

  /// Retrieves a single entity of type [T] by its unique [id].
  ///
  /// [id]: The unique identifier of the entity to retrieve.
  /// Returns a [Result] containing the entity on success,
  /// or a [Failure] if not found or on error.
  FutureResult<T> getById(String id);

  /// Creates a new entity.
  ///
  /// [entity]: The entity to be created.
  /// Returns a [Result] containing the created entity (which might include
  /// server-generated fields like an ID) on success, or a [Failure] on error.
  FutureResult<T> create(T entity);

  /// Updates an existing entity.
  ///
  /// [entity]: The entity with updated information. It should contain its identifier.
  /// Returns a [Result] containing the updated entity on success,
  /// or a [Failure] on error.
  FutureResult<T> update(T entity);

  /// Deletes an entity by its unique [id].
  ///
  /// [id]: The unique identifier of the entity to delete.
  /// Returns a [Result<void>] indicating success (with null data)
  /// or a [Failure] on error.
  FutureResult<void> delete(String id);

  /// Searches for entities matching the given [query].
  ///
  /// [query]: The search term or criteria.
  /// Returns a [Result] containing a list of matching entities on success,
  /// or a [Failure] on error.
  FutureResult<List<T>> search(String query);

  /// Retrieves a paginated list of entities.
  ///
  /// [page]: The page number to retrieve (usually 1-indexed).
  /// [limit]: The number of entities per page.
  /// [sortBy]: Optional field name to sort the results by.
  /// [descending]: Whether to sort in descending order. Defaults to `false`.
  /// Returns a [Result] containing the list of entities for the requested page
  /// on success, or a [Failure] on error.
  FutureResult<List<T>> getPaginated({
    required int page,
    required int limit,
    String? sortBy,
    bool descending = false,
  });
}
