import '../models/base_model.dart';

/// Abstract interface for data sources that communicate with a remote API.
///
/// A remote data source is responsible for:
/// - Making HTTP requests to specific endpoints.
/// - Deserializing JSON responses into data models ([BaseModel]).
/// - Handling network or server errors by throwing specific exceptions (e.g., ServerException).
///
/// Implementations of this class will typically use an HTTP client like Dio or http,
/// and will be called by a repository, which then maps exceptions to domain [Failure] types.
abstract class BaseRemoteDataSource<T extends BaseModel> {
  /// Retrieves a list of all models from the remote source.
  ///
  /// Throws an exception (e.g., `ServerException`) on API error.
  Future<List<T>> getAll();

  /// Retrieves a single model by its unique [id].
  ///
  /// Throws an exception (e.g., `ServerException`) if the resource is not found or on API error.
  Future<T> getById(String id);

  /// Creates a new resource on the remote server.
  ///
  /// Takes a [model] instance to be created.
  /// Returns the created model, which may include server-generated fields (like an ID or timestamp).
  ///
  /// Throws an exception (e.g., `ServerException`) on API error.
  Future<T> create(T model);

  /// Updates an existing resource on the remote server.
  ///
  /// Takes a [model] instance with updated data. The model should contain its identifier.
  /// Returns the updated model.
  ///
  /// Throws an exception (e.g., `ServerException`) on API error.
  Future<T> update(T model);

  /// Deletes a resource by its unique [id].
  ///
  /// Throws an exception (e.g., `ServerException`) on API error.
  Future<void> delete(String id);

  /// Searches for models matching a given [query].
  ///
  /// Throws an exception (e.g., `ServerException`) on API error.
  Future<List<T>> search({required String query});

  /// Retrieves a paginated list of models from the remote source.
  ///
  /// - [page]: The page number to retrieve.
  /// - [limit]: The number of items per page.
  /// - [sortBy]: The field to sort by.
  /// - [descending]: Whether to sort in descending order.
  ///
  /// Throws an exception (e.g., `ServerException`) on API error.
  Future<List<T>> getPaginated({
    required int page,
    required int limit,
    String? sortBy,
    bool descending = false,
  });
}
