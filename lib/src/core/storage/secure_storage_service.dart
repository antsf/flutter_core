// library secure_storage_service;

// import 'dart:convert';
// import 'dart:developer' show log;

// import 'package:encrypt/encrypt.dart' as encrypt;
// import 'package:flutter/foundation.dart'
//     show debugPrint; // For initialize check
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';

// import 'key_manager.dart';

// /// Provides secure, versioned, and encrypted key-value storage using Hive.
// ///
// /// This library contains [SecureStorageService] for managing sensitive data
// /// with features like data migration, encryption, and backup/restore.
// /// It also defines [StorageException] for error handling and [Migration]
// /// for defining data migration steps.

// /// A custom exception for errors encountered during storage operations
// /// within [SecureStorageService].
// class StorageException implements Exception {
//   /// A descriptive message about the error.
//   final String message;

//   /// The original exception that caused this storage exception, if any.
//   final dynamic originalException;

//   /// The stack trace associated with the original exception, if any.
//   final StackTrace? stackTrace;

//   /// Creates a [StorageException].
//   StorageException(this.message, {this.originalException, this.stackTrace});

//   @override
//   String toString() {
//     return 'StorageException: $message'
//         '${originalException != null ? '\nOriginal Exception: $originalException' : ''}';
//   }
// }

// /// A service for secure, persistent, and versioned key-value storage using Hive.
// ///
// /// This service encrypts all data before storing it in a Hive box and decrypts
// /// it upon retrieval. It uses a [KeyManager] to handle encryption keys.
// /// It supports data versioning and provides a mechanism for running data migrations
// /// if the stored data schema changes between application versions.
// /// Additionally, it offers basic backup and restore functionality to a separate Hive box.
// ///
// /// ### Initialization:
// /// Before any operations can be performed, the service **must** be initialized by calling `initialize()`.
// /// This sets up the encryption keys, initializes Hive at the application documents directory,
// /// opens the necessary Hive boxes, and runs any pending data migrations.
// ///
// /// ```dart
// /// // Example Migration
// /// final migrationToV2 = Migration(
// ///   version: 2,
// ///   migrate: (box) async {
// ///     // Example: Rename a key or transform data
// ///     final oldData = box.get('old_settings');
// ///     if (oldData != null) {
// ///       await box.put('new_settings', {'theme': oldData['theme_preference']});
// ///       await box.delete('old_settings');
// ///     }
// ///   },
// /// );
// ///
// /// final storageService = SecureStorageService(
// ///   version: 2, // Current application data version
// ///   migrations: [migrationToV2],
// ///   keyManager: KeyManager(), // Optionally provide a pre-configured KeyManager
// /// );
// ///
// /// await storageService.initialize();
// /// ```
// ///
// /// ### Basic Usage:
// /// ```dart
// /// // Save data (value will be JSON encoded and then encrypted)
// /// await storageService.save('user_profile', {'name': 'Alice', 'age': 30});
// ///
// /// // Load and decrypt data
// /// final userProfile = await storageService.load<Map<String, dynamic>>('user_profile');
// /// if (userProfile != null) {
// ///   print('User: ${userProfile['name']}');
// /// }
// ///
// /// // Delete data
// /// await storageService.delete('user_profile');
// ///
// /// // Check if a key exists
// /// bool hasProfile = storageService.containsKey('user_profile');
// ///
// /// // Clear all data (respects version key)
// /// await storageService.clear();
// /// ```
// class SecureStorageService {
//   static const String _primaryBoxName = 'app_secure_storage_box';
//   static const String _backupBoxName = 'app_backup_storage_box';
//   static const String _versionStorageKey = '_app_data_version';

//   final KeyManager _keyManager;

//   /// The current version of the data schema. Used for migrations.
//   final int version;

//   /// A list of [Migration] objects to be applied if the stored data version
//   /// is older than the current [version].
//   final List<Migration> migrations;

//   late final Box _dataBox; // For main encrypted data
//   late final Box
//       _metaBox; // For backup data (unencrypted map of encrypted main box)

//   bool _isInitialized = false;

//   /// Constructs a [SecureStorageService].
//   ///
//   /// - [version]: The current data schema version for the application. Must be > 0.
//   ///   Defaults to `1`.
//   /// - [migrations]: A list of [Migration] functions to upgrade data from older versions.
//   ///   Defaults to an empty list.
//   /// - [keyManager]: An optional [KeyManager] instance. If not provided, a default
//   ///   `KeyManager()` is created.
//   SecureStorageService({
//     this.version = 1,
//     this.migrations = const [],
//     KeyManager? keyManager,
//   })  : _keyManager = keyManager ?? KeyManager(),
//         assert(version > 0, 'Version must be a positive integer.');

//   /// Initializes the storage service.
//   ///
//   /// This method performs the following steps:
//   /// 1. Initializes the [KeyManager] to load or generate encryption keys.
//   /// 2. Initializes Hive at the application's documents directory.
//   /// 3. Opens the primary data box (`_primaryBoxName`) and the backup box (`_backupBoxName`).
//   /// 4. Runs any pending data migrations based on the stored version and current [version].
//   /// 5. Marks the service as initialized.
//   ///
//   /// This **must be called once** before any other storage operations are used.
//   /// Throws a [StorageException] if initialization fails at any step.
//   Future<void> initialize() async {
//     if (_isInitialized) {
//       debugPrint(
//           "SecureStorageService is already initialized. Skipping redundant call.");
//       return;
//     }
//     log('SecureStorageService: Initializing...');
//     try {
//       await _keyManager.initialize();
//       log('SecureStorageService: KeyManager initialized.');

//       // Hive is initialized at the root of app documents directory.
//       // Box names will be files like 'app_secure_storage_box.hive'.
//       final appDir = await getApplicationDocumentsDirectory();
//       Hive.init(appDir.path);
//       log('SecureStorageService: Hive initialized at path: ${appDir.path}');

//       _dataBox = await Hive.openBox(_primaryBoxName);
//       log('SecureStorageService: Primary data box "$_primaryBoxName" opened.');
//       _metaBox = await Hive.openBox(
//           _backupBoxName); // Changed from _backupBoxName to _metaBox for actual use
//       log('SecureStorageService: Backup metadata box "$_backupBoxName" opened.');

//       await _runMigrations();

//       _isInitialized = true;
//       log('SecureStorageService: Initialization complete. Current data version: ${_dataBox.get(_versionStorageKey)}');
//     } catch (e, s) {
//       log('SecureStorageService: Initialization failed.',
//           error: e, stackTrace: s);
//       throw StorageException('Failed to initialize SecureStorageService.',
//           originalException: e, stackTrace: s);
//     }
//   }

//   /// Runs data migrations if the stored data version is older than the service's [version].
//   Future<void> _runMigrations() async {
//     _assertInitialized(
//         forInternalCall: true); // KeyManager and boxes must be ready
//     final storedVersion =
//         _dataBox.get(_versionStorageKey, defaultValue: 0) as int;
//     log('SecureStorageService: Checking migrations. Stored version: $storedVersion, App version: $version');

//     if (storedVersion >= version) {
//       log('SecureStorageService: Data version is up to date. No migrations needed.');
//       // Ensure version key is set if it was default 0 and app version is >0
//       if (storedVersion == 0 &&
//           version > 0 &&
//           !_dataBox.containsKey(_versionStorageKey)) {
//         await _dataBox.put(_versionStorageKey, version);
//         log('SecureStorageService: Initial version key set to $version.');
//       }
//       return;
//     }

//     final applicableMigrations = migrations
//         .where((m) => m.version > storedVersion && m.version <= version)
//         .toList()
//       ..sort((a, b) => a.version.compareTo(b.version));

//     if (applicableMigrations.isNotEmpty) {
//       log('SecureStorageService: Found ${applicableMigrations.length} applicable migrations.');
//       for (final migration in applicableMigrations) {
//         log('SecureStorageService: Running migration for version ${migration.version}...');
//         try {
//           // Pass the _dataBox to the migration function
//           await migration.migrate(_dataBox);
//           log('SecureStorageService: Migration for version ${migration.version} completed.');
//         } catch (e, s) {
//           log('SecureStorageService: Error during migration for version ${migration.version}.',
//               error: e, stackTrace: s);
//           throw StorageException(
//               'Migration for version ${migration.version} failed.',
//               originalException: e,
//               stackTrace: s);
//         }
//       }
//     } else {
//       log('SecureStorageService: No applicable migrations found, but stored version ($storedVersion) is less than app version ($version). Setting version key.');
//     }

//     await _dataBox.put(_versionStorageKey, version);
//     log('SecureStorageService: Data version updated to $version.');
//   }

//   /// Asserts that the service has been initialized.
//   /// Throws an [AssertionError] if not initialized.
//   void _assertInitialized({bool forInternalCall = false}) {
//     // For internal calls like _runMigrations, we might not want to assert _isInitialized itself
//     // but rather that its dependencies (like boxes) are ready if _isInitialized isn't true yet.
//     // However, simpler to just ensure _isInitialized is true for all operations.
//     assert(
//         _isInitialized ||
//             forInternalCall, // Allow internal calls during init sequence
//         'SecureStorageService not initialized. Call initialize() first.');
//   }

//   /// Saves a [value] associated with the given [key].
//   /// The [value] is JSON encoded and then encrypted before being stored in Hive.
//   ///
//   /// Throws a [StorageException] if saving or encryption fails.
//   Future<void> save(String key, dynamic value) async {
//     _assertInitialized();
//     if (key == _versionStorageKey) {
//       throw ArgumentError(
//           'The key "$_versionStorageKey" is reserved for internal use.');
//     }
//     log('SecureStorageService: Saving data for key "$key".');
//     try {
//       final encryptedValue = _encrypt(value);
//       await _dataBox.put(key, encryptedValue);
//       log('SecureStorageService: Data saved and encrypted for key "$key".');
//     } catch (e, s) {
//       log('SecureStorageService: Failed to save data for key "$key".',
//           error: e, stackTrace: s);
//       throw StorageException('Failed to save data for key "$key".',
//           originalException: e, stackTrace: s);
//     }
//   }

//   /// Loads and decrypts the value associated with the given [key].
//   ///
//   /// Returns the decrypted value cast to type [T], or `null` if the key
//   /// does not exist or if the data is null.
//   /// The caller is responsible for ensuring [T] matches the stored data structure.
//   ///
//   /// Throws a [StorageException] if loading or decryption fails.
//   Future<T?> load<T>(String key) async {
//     _assertInitialized();
//     if (key == _versionStorageKey) {
//       throw ArgumentError(
//           'The key "$_versionStorageKey" is reserved. Use internal methods to access version.');
//     }
//     log('SecureStorageService: Loading data for key "$key".');
//     try {
//       final encryptedValue = _dataBox.get(key);
//       if (encryptedValue == null) {
//         log('SecureStorageService: No data found for key "$key".');
//         return null;
//       }
//       final decryptedValue = _decrypt(encryptedValue as String);
//       log('SecureStorageService: Data loaded and decrypted for key "$key".');
//       return decryptedValue as T?;
//     } catch (e, s) {
//       log('SecureStorageService: Failed to load or decrypt data for key "$key".',
//           error: e, stackTrace: s);
//       throw StorageException('Failed to load or decrypt data for key "$key".',
//           originalException: e, stackTrace: s);
//     }
//   }

//   /// Deletes the value associated with the given [key] from storage.
//   ///
//   /// Throws a [StorageException] if deletion fails.
//   Future<void> delete(String key) async {
//     _assertInitialized();
//     if (key == _versionStorageKey) {
//       throw ArgumentError(
//           'Cannot delete the reserved version key "$_versionStorageKey". Use clear() with caution.');
//     }
//     log('SecureStorageService: Deleting data for key "$key".');
//     try {
//       await _dataBox.delete(key);
//       log('SecureStorageService: Data deleted for key "$key".');
//     } catch (e, s) {
//       log('SecureStorageService: Failed to delete data for key "$key".',
//           error: e, stackTrace: s);
//       throw StorageException('Failed to delete data for key "$key".',
//           originalException: e, stackTrace: s);
//     }
//   }

//   /// Deletes all data from the primary storage box, except for the internal version key.
//   ///
//   /// **Warning**: This operation is destructive and cannot be undone easily unless a backup exists.
//   /// The data schema version key (`_versionStorageKey`) is preserved.
//   /// Throws a [StorageException] if clearing fails.
//   Future<void> clear() async {
//     _assertInitialized();
//     log('SecureStorageService: Clearing all data from primary box, preserving version key.');
//     try {
//       final currentVersion = _dataBox.get(_versionStorageKey);
//       await _dataBox.clear();
//       if (currentVersion != null) {
//         await _dataBox.put(_versionStorageKey, currentVersion);
//       }
//       log('SecureStorageService: Primary box cleared. Version key preserved if existed.');
//     } catch (e, s) {
//       log('SecureStorageService: Failed to clear primary box.',
//           error: e, stackTrace: s);
//       throw StorageException('Failed to clear storage.',
//           originalException: e, stackTrace: s);
//     }
//   }

//   /// Creates a backup of the current primary data box content.
//   ///
//   /// The entire content of the primary data box is serialized to a JSON string
//   /// (values are already encrypted strings) and stored in the backup box under [backupName].
//   ///
//   /// [backupName]: A unique name for this backup.
//   /// Throws a [StorageException] if backup creation fails.
//   Future<void> createBackup(String backupName) async {
//     _assertInitialized();
//     log('SecureStorageService: Creating backup "$backupName".');
//     try {
//       // _dataBox.toMap() returns Map<dynamic, dynamic> where values are encrypted strings
//       final Map<String, String> dataToBackup = {};
//       for (var key in _dataBox.keys) {
//         if (key is String && _dataBox.get(key) is String) {
//           dataToBackup[key] = _dataBox.get(key) as String;
//         }
//       }
//       await _metaBox.put(backupName, jsonEncode(dataToBackup));
//       log('SecureStorageService: Backup "$backupName" created successfully.');
//     } catch (e, s) {
//       log('SecureStorageService: Failed to create backup "$backupName".',
//           error: e, stackTrace: s);
//       throw StorageException('Failed to create backup "$backupName".',
//           originalException: e, stackTrace: s);
//     }
//   }

//   /// Restores data from a named backup into the primary data box.
//   ///
//   /// **Warning**: This operation clears the current primary data box and replaces
//   /// its content with the backup data. The data version after restore will be
//   /// the version stored in the backup. Migrations may need to run again if this
//   /// version is older than the application's current [version] upon next initialization
//   /// or by manually triggering migrations.
//   ///
//   /// [backupName]: The name of the backup to restore.
//   /// Throws a [StorageException] if the backup is not found or restoration fails.
//   Future<void> restoreBackup(String backupName) async {
//     _assertInitialized();
//     log('SecureStorageService: Attempting to restore backup "$backupName".');
//     try {
//       final backupJsonString = _metaBox.get(backupName);
//       if (backupJsonString == null || backupJsonString is! String) {
//         log('SecureStorageService: Backup "$backupName" not found or invalid format.');
//         throw StorageException('Backup not found or invalid: $backupName');
//       }
//       final Map<String, dynamic> backupDataMap = jsonDecode(backupJsonString);

//       await _dataBox.clear(); // Clear current data
//       // Restore all data, including the version key from the backup
//       await _dataBox.putAll(backupDataMap.cast<String, String>());
//       log('SecureStorageService: Backup "$backupName" restored successfully. Current data version is now from backup.');
//       // Note: After restore, the version in _dataBox is from the backup.
//       // If an app restart/re-init happens, migrations will run based on this restored version.
//     } catch (e, s) {
//       log('SecureStorageService: Failed to restore backup "$backupName".',
//           error: e, stackTrace: s);
//       throw StorageException('Failed to restore backup "$backupName".',
//           originalException: e, stackTrace: s);
//     }
//   }

//   /// Returns a list of all available backup names.
//   List<String> listBackups() {
//     _assertInitialized();
//     return _metaBox.keys.cast<String>().toList();
//   }

//   /// Deletes a specific backup by its [backupName].
//   ///
//   /// Throws a [StorageException] if deletion fails.
//   Future<void> deleteBackup(String backupName) async {
//     _assertInitialized();
//     log('SecureStorageService: Deleting backup "$backupName".');
//     try {
//       await _metaBox.delete(backupName);
//       log('SecureStorageService: Backup "$backupName" deleted.');
//     } catch (e, s) {
//       log('SecureStorageService: Failed to delete backup "$backupName".',
//           error: e, stackTrace: s);
//       throw StorageException('Failed to delete backup "$backupName".',
//           originalException: e, stackTrace: s);
//     }
//   }

//   /// Checks if a [key] exists in the primary storage box.
//   /// Does not check the backup box.
//   bool containsKey(String key) {
//     _assertInitialized();
//     return _dataBox.containsKey(key);
//   }

//   /// Encrypts the given [value] using AES with CBC mode.
//   /// The value is first JSON encoded.
//   String _encrypt(dynamic value) {
//     final String jsonString = jsonEncode(value);
//     final encrypter = encrypt.Encrypter(
//       encrypt.AES(_keyManager.key, mode: encrypt.AESMode.cbc),
//     );
//     final encrypted = encrypter.encrypt(jsonString, iv: _keyManager.iv);
//     return encrypted.base64;
//   }

//   /// Decrypts the given base64 [encryptedString] using AES with CBC mode.
//   /// The result is then JSON decoded.
//   dynamic _decrypt(String encryptedString) {
//     final encrypter = encrypt.Encrypter(
//       encrypt.AES(_keyManager.key, mode: encrypt.AESMode.cbc),
//     );
//     final String decryptedJson =
//         encrypter.decrypt64(encryptedString, iv: _keyManager.iv);
//     return jsonDecode(decryptedJson);
//   }
// }

// /// Represents a single data migration operation to a specific [version].
// class Migration {
//   /// The target version number this migration achieves.
//   /// Migrations are applied if their version is greater than the currently
//   /// stored data version and less than or equal to the application's [SecureStorageService.version].
//   final int version;

//   /// The asynchronous function to execute to perform the data migration.
//   /// It receives the primary Hive [Box] (`_dataBox`) which contains the data
//   /// to be migrated. This function should handle all data transformations
//   /// required to bring the data up to this [version].
//   final Future<void> Function(Box dataBox) migrate;

//   /// Creates a [Migration] instance.
//   ///
//   /// - [version]: The target version for this migration.
//   /// - [migrate]: The function that performs the migration logic.
//   const Migration({
//     required this.version,
//     required this.migrate,
//   });
// }
