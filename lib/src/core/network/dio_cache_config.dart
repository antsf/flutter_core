import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';

/// Configuration for Dio HTTP caching using Hive.
///
/// This class configures and provides a `DioCacheInterceptor` instance
/// that can be directly added to a Dio client.
class DioCacheConfig {
  final String cachePath;
  final Duration maxAge;
  final CachePolicy policy;

  const DioCacheConfig({
    this.cachePath = 'dio_cache',
    this.maxAge = const Duration(days: 7),
    this.policy = CachePolicy.request,
  });

  /// The configured cache interceptor instance.
  ///
  /// This getter creates a `DioCacheInterceptor` with a `HiveCacheStore`.
  /// The store is initialized in a temporary directory.
  DioCacheInterceptor get interceptor {
    return DioCacheInterceptor(
      options: CacheOptions(
        // A default store is required for the interceptor.
        // This uses a Hive-based store in the application's temporary directory.
        store: HiveCacheStore(cachePath),
        // The cache policy determines how requests are handled.
        policy: policy,
        // The maximum duration for which a response is considered fresh.
        maxStale: maxAge,
        // Other options can be configured here as needed.
        priority: CachePriority.normal,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false,
      ),
    );
  }

  /// A static method to initialize the cache store's path.
  ///
  /// While the interceptor can work without this, calling this ensures
  /// the path is set from a well-known location like `getApplicationDocumentsDirectory`.
  static Future<String> getCachePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}
