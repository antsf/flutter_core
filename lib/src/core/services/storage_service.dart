library simple_hive_storage_service;

import 'dart:async';
import 'dart:developer' show log;
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

// Consider defining custom StorageException types if more granular error handling is needed.
// class StorageException implements Exception {
//   final String message;
//   final dynamic error;
//   StorageException(this.message, {this.error});
//   @override
//   String toString() => 'StorageException: $message${error != null ? " (Original: $error)" : ""}';
// }
// class StorageInitializationException extends StorageException { ... }
// class StorageBoxOpenException extends StorageException { ... }
// class StorageOperationException extends StorageException { ... }

/// Provides a simple service wrapper around Hive for key-value storage.
///
/// This service, `SimpleStorageService`, facilitates common Hive operations such as
/// initializing Hive in a specific subdirectory, opening/closing boxes,
/// and performing CRUD operations on data within those boxes.
///
/// Note: The filename is `storage_service.dart` while the class is `SimpleStorageService`.
/// This might be a point of minor inconsistency if strict file-class name matching is desired.

/// A service class for managing data persistence using Hive.
///
/// `SimpleStorageService` offers a simplified interface for interacting with Hive boxes,
/// including initialization, opening, closing, and basic data manipulation (get, set, delete).
/// It manages opened boxes internally to reuse them.
///
/// ### Initialization:
/// Before using any storage methods, `init()` must be called. This method initializes
/// Hive within a subdirectory (specified by `basePath`) of the application's
/// documents directory.
///
/// ```dart
/// final storageService = SimpleStorageService(basePath: 'my_app_data');
/// await storageService.init();
/// ```
///
/// ### Usage:
/// ```dart
/// // Storing a value
/// await storageService.set('user_prefs', 'username', 'john_doe');
///
/// // Retrieving a value
/// String? username = await storageService.get<String>('user_prefs', 'username');
/// print('Username: $username');
///
/// // Deleting a value
/// await storageService.delete('user_prefs', 'username');
///
/// // Closing a box when no longer needed (optional, managed internally to some extent)
/// // await storageService.closeBox('user_prefs');
/// ```
class SimpleStorageService {
  final String _basePath;
  final Map<String, Box> _openedBoxes = {};

  /// Creates an instance of `SimpleStorageService`.
  ///
  /// [basePath]: An optional string specifying the subdirectory within the
  /// application's documents directory where Hive should store its files.
  /// Defaults to `'storage'`.
  SimpleStorageService({String? basePath}) : _basePath = basePath ?? 'storage';

  /// Initializes Hive for the application.
  ///
  /// This method sets up Hive to store its data in a subdirectory named [_basePath]
  /// within the application's documents directory.
  /// It **must** be called before any other Hive operations are performed by this service.
  ///
  /// Throws a `StorageException` (or underlying `HiveError`) if initialization fails.
  Future<void> init() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fullPath = '${appDir.path}/$_basePath';
      // Ensure the directory exists, as Hive.initFlutter might not create it.
      final dir = Directory(fullPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        log('SimpleStorageService: Created Hive storage directory at $fullPath');
      }
      await Hive.initFlutter(fullPath);
      log('SimpleStorageService: Hive initialized at $fullPath');
    } catch (e, s) {
      log('SimpleStorageService: Error initializing Hive at path $_basePath',
          error: e, stackTrace: s);
      // Consider rethrowing as a custom StorageInitializationException
      rethrow; // Rethrow to allow caller to handle critical init failure
    }
  }

  /// Opens a Hive box with the specified [name].
  ///
  /// If the box is already open and cached by this service, the cached instance
  /// is returned. Otherwise, a new box is opened and cached.
  ///
  /// [name]: The name of the Hive box to open.
  /// Returns the opened [Box].
  /// Throws a `StorageException` (or underlying `HiveError`) if opening the box fails.
  Future<Box<E>> openBox<E>(String name) async {
    if (_openedBoxes.containsKey(name) && _openedBoxes[name]!.isOpen) {
      return _openedBoxes[name]! as Box<E>;
    }
    try {
      final box = await Hive.openBox<E>(name);
      _openedBoxes[name] = box;
      log('SimpleStorageService: Opened Hive box "$name"');
      return box;
    } catch (e, s) {
      log('SimpleStorageService: Error opening Hive box "$name"',
          error: e, stackTrace: s);
      // Consider rethrowing as a custom StorageBoxOpenException
      rethrow;
    }
  }

  /// Closes a Hive box with the specified [name].
  ///
  /// If the box is found in the internal cache of opened boxes and is currently open,
  /// it will be closed and removed from the cache.
  ///
  /// [name]: The name of the Hive box to close.
  /// Throws a `StorageException` (or underlying `HiveError`) if closing fails.
  Future<void> closeBox(String name) async {
    if (_openedBoxes.containsKey(name)) {
      try {
        await _openedBoxes[name]?.close();
        _openedBoxes.remove(name);
        log('SimpleStorageService: Closed Hive box "$name"');
      } catch (e, s) {
        log('SimpleStorageService: Error closing Hive box "$name"',
            error: e, stackTrace: s);
        rethrow;
      }
    }
  }

  /// Clears all data from the Hive box specified by [name].
  ///
  /// The box will be opened if it's not already open.
  /// [name]: The name of the Hive box to clear.
  /// Throws a `StorageException` (or underlying `HiveError`) on failure.
  Future<void> clearBox(String name) async {
    try {
      final box = await openBox(name);
      await box.clear();
      log('SimpleStorageService: Cleared all data from Hive box "$name"');
    } catch (e, s) {
      log('SimpleStorageService: Error clearing Hive box "$name"',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Deletes a Hive box and its associated files from disk.
  ///
  /// The box is closed before deletion if it's currently open.
  /// This method uses Hive's built-in [Hive.deleteBoxFromDisk] to ensure
  /// consistent cleanup of both data and internal registry state.
  ///
  /// [name]: The name of the Hive box to delete.
  /// Throws a [HiveError] (or underlying exception) on failure.
  Future<void> deleteBoxFromDisk(String name) async {
    await closeBox(name); // Ensure the box is closed and removed from cache
    try {
      // ✅ Use Hive's official method — it handles file deletion AND registry cleanup
      await Hive.deleteBoxFromDisk(name);
      log('SimpleStorageService: Deleted Hive box "$name" from disk');
    } catch (e, s) {
      log('SimpleStorageService: Error deleting Hive box "$name" from disk',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Retrieves a value of type [T] from the specified [boxName] using [key].
  ///
  /// [boxName]: The name of the Hive box.
  /// [key]: The key of the value to retrieve.
  /// Returns the value if found and successfully cast to [T], otherwise `null`.
  /// Throws a `StorageException` (or underlying `HiveError`) on failure.
  Future<T?> get<T>(String boxName, String key) async {
    try {
      final box = await openBox<T>(boxName); // Specify type for Box<T>
      return box.get(key); // No need for `as T?` if Box is typed Box<T>
    } catch (e, s) {
      log('SimpleStorageService: Error getting key "$key" from box "$boxName"',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Stores a [value] with the given [key] in the specified [boxName].
  ///
  /// [boxName]: The name of the Hive box.
  /// [key]: The key under which to store the value.
  /// [value]: The value to store. Must be a primitive type or a HiveObject.
  /// Throws a `StorageException` (or underlying `HiveError`) on failure.
  Future<void> set<T>(String boxName, String key, T value) async {
    try {
      final box = await openBox<T>(boxName); // Specify type for Box<T>
      await box.put(key, value);
      log('SimpleStorageService: Set key "$key" in box "$value"');
    } catch (e, s) {
      log('SimpleStorageService: Error setting key "$key" in box "$boxName"',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Deletes a value associated with [key] from the specified [boxName].
  ///
  /// [boxName]: The name of the Hive box.
  /// [key]: The key of the value to delete.
  /// Throws a `StorageException` (or underlying `HiveError`) on failure.
  Future<void> delete(String boxName, String key) async {
    try {
      final box =
          await openBox(boxName); // Type arg not strictly needed for delete
      await box.delete(key);
      log('SimpleStorageService: Deleted key "$key" from box "$boxName"');
    } catch (e, s) {
      log('SimpleStorageService: Error deleting key "$key" from box "$boxName"',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Checks if a [key] exists in the specified [boxName].
  ///
  /// [boxName]: The name of the Hive box.
  /// [key]: The key to check for existence.
  /// Returns `true` if the key exists, `false` otherwise.
  /// Throws a `StorageException` (or underlying `HiveError`) on failure.
  Future<bool> containsKey(String boxName, String key) async {
    try {
      final box = await openBox(boxName);
      return box.containsKey(key);
    } catch (e, s) {
      log('SimpleStorageService: Error checking key "$key" in box "$boxName"',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Retrieves all keys from the specified [boxName].
  ///
  /// [boxName]: The name of the Hive box.
  /// Returns a list of all keys in the box. The keys are dynamic but often Strings.
  /// Throws a `StorageException` (or underlying `HiveError`) on failure.
  Future<List<dynamic>> getKeys(String boxName) async {
    try {
      final box = await openBox(boxName);
      return box.keys.toList();
    } catch (e, s) {
      log('SimpleStorageService: Error getting keys from box "$boxName"',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Retrieves all values from the specified [boxName].
  ///
  /// [boxName]: The name of the Hive box.
  /// Returns a list of all values in the box. The values are dynamic.
  /// If you need typed values, consider iterating keys and using `get<T>`.
  /// Throws a `StorageException` (or underlying `HiveError`) on failure.
  Future<List<E>> getValues<E>(String boxName) async {
    // Made generic
    try {
      final box = await openBox<E>(boxName); // Use typed box
      return box.values.toList();
    } catch (e, s) {
      log('SimpleStorageService: Error getting values from box "$boxName"',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Closes all currently opened Hive boxes managed by this service.
  ///
  /// This is useful for cleanup, perhaps when the application is shutting down,
  /// though Hive generally manages this well.
  Future<void> closeAllBoxes() async {
    log('SimpleStorageService: Closing all cached Hive boxes.');
    for (final boxName in _openedBoxes.keys.toList()) {
      // toList to avoid concurrent modification
      try {
        await _openedBoxes[boxName]?.close();
        log('SimpleStorageService: Closed box "$boxName" during closeAll.');
      } catch (e, s) {
        log('SimpleStorageService: Error closing box "$boxName" during closeAll',
            error: e, stackTrace: s);
        // Continue to attempt to close other boxes
      }
    }
    _openedBoxes.clear();
  }
}
