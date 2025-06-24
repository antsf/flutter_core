import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart'; // For getApplicationDocumentsDirectory

/// Configuration class for setting up HTTP caching with Dio, using [dio_cache_interceptor]
/// and [dio_cache_interceptor_hive_store].
///
/// This class simplifies the creation of a [DioCacheInterceptor] backed by a [HiveCacheStore].
/// It allows specifying the cache path (relative to Hive's initialization directory, or an absolute path),
/// maximum age of cached items, and the caching policy.
///
/// ### Usage:
/// ```dart
/// // Option 1: Using a default relative path for Hive store (e.g., 'my_app_cache/dio_cache')
/// // Ensure Hive is initialized (e.g., Hive.init('my_app_cache_directory');)
/// final cacheConfig = DioCacheConfig(
///   cachePath: 'dio_cache', // Relative path within Hive's initialized directory
///   maxAge: Duration(hours: 6),
///   policy: CachePolicy.forceCache,
/// );
///
/// // Option 2: Using an absolute path obtained from path_provider
/// final documentsPath = await DioCacheConfig.getApplicationDocumentsPath();
/// final absoluteCachePath = '$documentsPath/my_dio_cache';
/// // Ensure Hive is initialized if you want it in a specific main path,
/// // or HiveCacheStore will use its default if Hive.isInitialized is false.
/// // Hive.init(documentsPath); // Example if you want all Hive boxes under documentsPath
/// final cacheConfigWithPath = DioCacheConfig(
///   cachePath: absoluteCachePath, // Absolute path for the Hive box
///   maxAge: Duration(days: 1),
/// );
///
/// // Add the interceptor to Dio:
/// // dio.interceptors.add(cacheConfig.interceptor);
/// ```
class DioCacheConfig {
  /// The path for the Hive cache store.
  ///
  /// This can be a relative path (if Hive is initialized globally with `Hive.init(parentPath)`),
  /// in which case this path will be relative to `parentPath`.
  /// Or, it can be an absolute path where the Hive box for caching will be stored.
  /// If Hive is not initialized via `Hive.init()`, `HiveCacheStore` will use a default
  /// directory provided by Hive itself (platform-dependent).
  ///
  /// Defaults to `'dio_cache'`.
  final String cachePath;

  /// The maximum duration for which a cached response is considered fresh.
  /// After this duration, the cache entry is considered stale.
  /// This is used for the `maxStale` option in [CacheOptions].
  /// Defaults to 7 days.
  final Duration maxAge;

  /// The [CachePolicy] to be used for caching requests.
  /// Determines how requests are handled (e.g., fetch from cache first, force fetch, etc.).
  /// Defaults to [CachePolicy.request] (standard HTTP caching rules).
  final CachePolicy policy;

  /// Creates a [DioCacheConfig] instance.
  ///
  /// - [cachePath]: Path for the Hive cache store. See [DioCacheConfig.cachePath] for details.
  ///   Defaults to `'dio_cache'`.
  /// - [maxAge]: Maximum age for cached items. Defaults to 7 days.
  /// - [policy]: Caching policy. Defaults to [CachePolicy.request].
  const DioCacheConfig({
    this.cachePath = 'dio_cache', // Sensible default if Hive is initialized elsewhere
    this.maxAge = const Duration(days: 7),
    this.policy = CachePolicy.request,
  });

  /// Provides the configured [DioCacheInterceptor] instance.
  ///
  /// This getter creates a `DioCacheInterceptor` using a [HiveCacheStore]
  /// initialized with the specified [cachePath].
  ///
  /// The [CacheOptions] are configured with:
  /// - `store`: A [HiveCacheStore] instance using [cachePath].
  /// - `policy`: The specified [CachePolicy].
  /// - `maxStale`: Set to [maxAge].
  /// - `priority`: Defaults to [CachePriority.normal].
  /// - `keyBuilder`: Defaults to [CacheOptions.defaultCacheKeyBuilder].
  /// - `allowPostMethod`: Defaults to `false` (POST requests are typically not cached).
  DioCacheInterceptor get interceptor {
    return DioCacheInterceptor(
      options: CacheOptions(
        store: HiveCacheStore(cachePath),
        policy: policy,
        maxStale: maxAge, // How long the cache is considered fresh.
        priority: CachePriority.normal,
        // Standard key builder that uses method, URI, and headers (optional).
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        // Typically, POST requests are not cached as they are not idempotent.
        allowPostMethod: false,
      ),
    );
  }

  /// A static utility method to get the application's documents directory path.
  ///
  /// This can be used to construct an absolute [cachePath] for the [HiveCacheStore]
  /// if you want to ensure the cache is stored in a known, persistent location.
  ///
  /// Example:
  /// ```dart
  /// final String docPath = await DioCacheConfig.getApplicationDocumentsPath();
  /// final String fullCachePath = '$docPath/my_app_dio_cache';
  /// final config = DioCacheConfig(cachePath: fullCachePath);
  /// ```
  /// Returns a [Future<String>] containing the path to the documents directory.
  static Future<String> getApplicationDocumentsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}
