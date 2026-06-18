# Changelog

All notable changes to this project will be documented in this file.

---

## 1.1.0 — 2026-06-18

### Bug Fixes
- **`LocalStorage`**: Fixed `get<Map<String, dynamic>>()` throwing `UnsupportedError` — Map type is now properly deserialized via `jsonDecode`
- **`Failure`**: Fixed `statusCode` default from `200` (HTTP OK) to `0` (no status code)
- **`safeRemoteCall`**: Fixed fallback error returning `AuthFailure` instead of `GenericFailure` when no failure context is available
- **`safeCall`** (network): Fixed redundant nested `DioException` construction
- **`ui_ext.dart`**: Fixed compile error — `inputDecorationTheme` return type updated to `InputDecorationThemeData` (breaking change in Flutter 3.27+)
- **`ResultExtension.when()`**: Fixed unsafe cast replaced with `is` type check

### New Features
- **`LocalStorage.getAllValues<T>()`**: New method to retrieve all key-value pairs in a box as a typed map
- **`StringExt.isValidEmail`**: New getter for email validation
- **`StringExt.isValidIndonesianPhone`**: New getter for Indonesian phone number validation
- **`Result.map<R>()`**: New extension method to transform success values
- **`Result.mapFailure<G>()`**: New extension method to transform failure values
- **`DioRetryInterceptor`**: Retry interceptor is now active — automatic retry with exponential backoff (3 attempts by default on timeouts and 5xx errors)
- **`DioClient`**: New `retryOptions` parameter to configure retry behavior

### Improvements
- **`stream_ext.dart`**: Replaced `rxdart` dependency with native Dart `StreamController` — no external dependency required for debounce/throttle
- **`maskEmail()`**: Fixed separator between masked local and domain parts
- **`UseCase`**: Renamed generic type parameter `Type` → `Output` to avoid shadowing Dart's built-in `Type` class

### Removed
- **`rxdart`** dependency removed (debounce/throttle reimplemented natively)
- **`dio_cache_interceptor`** dependency removed (cache config was commented-out)
- **`path_provider`** dependency removed (only referenced in deleted stub files)
- Deleted stub files that were 100% commented-out:
  - `lib/src/core/network/dio_cache_config.dart`
  - `lib/src/core/storage/secure_storage_service.dart`
  - `lib/src/core/storage/key_manager.dart`
  - `lib/src/core/services/storage_service.dart`
- Removed re-export of `rxdart` from public API
- Cleaned up all commented-out `remoteCallWrapper` blocks in `BaseRepositoryImpl`
- Removed development notes (`🚀 UPDATED`) from production code

### Breaking Changes
- `UseCase<Type, Params>` → `UseCase<Output, Params>` — rename type parameter
- `Failure.statusCode` default changed from `200` to `0`
- `rxdart` is no longer re-exported from `flutter_core.dart` — add `rxdart` directly to your app if needed
- Deleted stub files are no longer exported

---

## 1.0.3 — 2025-xx-xx

- Fix default status codes, improve error handling
- Add Indonesian date formats
- Refine UI widgets

## 1.0.0 — 2025-xx-xx

- Initial stable release
