// lib/domain/repositories/data_source_strategy.dart
enum DataSourceStrategy {
  remoteOnly,
  localOnly,
  remoteWithLocalCache, // default
  localWithRemoteFallback,
}
