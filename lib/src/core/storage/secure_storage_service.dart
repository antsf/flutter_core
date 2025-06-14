import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'key_manager.dart';

/// A custom exception for errors related to storage operations.
class StorageException implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;

  StorageException(this.message, {this.originalException, this.stackTrace});

  @override
  String toString() {
    return 'StorageException: $message'
        '${originalException != null ? '\nOriginal Exception: $originalException' : ''}';
  }
}

/// A service for secure, persistent, and versioned storage.
///
/// This service provides encrypted key-value storage using Hive, with a robust
/// system for handling data migrations between versions.
///
/// ---
///
/// ### Initialization
///
/// You must call `initialize()` once before using any other methods.
///
/// ```dart
/// final storage = StorageService(
///   version: 2,
///   migrations: [
///     Migration(version: 1, migrate: (box) async { /* ... */ }),
///     Migration(version: 2, migrate: (box) async { /* ... */ }),
///   ],
/// );
///
/// await storage.initialize();
/// ```
///
/// ### Basic Usage
///
/// ```dart
/// // Save data
/// await storage.save('user', {'name': 'John', 'age': 30});
///
/// // Load typed data
/// final user = await storage.load<Map<String, dynamic>>('user');
///
/// // Delete data
/// await storage.delete('user');
/// ```
class SecureStorageService {
  static const String _boxName = 'secure_storage';
  static const String _backupBoxName = 'backup_storage';
  static const String _versionKey = '_storage_version';

  final KeyManager _keyManager;
  final int version;
  final List<Migration> migrations;

  late final Box _box;
  late final Box _backupBox;
  bool _isInitialized = false;

  SecureStorageService({
    this.version = 1,
    this.migrations = const [],
    KeyManager? keyManager,
  })  : _keyManager = keyManager ?? KeyManager(),
        assert(version > 0, 'Version must be a positive integer.');

  /// Initializes the storage service, opens the Hive boxes, and runs migrations.
  ///
  /// This must be called once before any other methods are used.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint("StorageService is already initialized.");
      return;
    }

    try {
      await _keyManager.initialize();
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);

      _box = await Hive.openBox(_boxName);
      _backupBox = await Hive.openBox(_backupBoxName);

      await _runMigrations();

      _isInitialized = true;
    } catch (e, s) {
      throw StorageException('Failed to initialize storage service.',
          originalException: e, stackTrace: s);
    }
  }

  Future<void> _runMigrations() async {
    final currentVersion = _box.get(_versionKey, defaultValue: 0) as int;
    if (currentVersion >= version) {
      return; // Already up to date.
    }

    final applicableMigrations = migrations
        .where((m) => m.version > currentVersion && m.version <= version)
        .toList()
      ..sort((a, b) => a.version.compareTo(b.version));

    for (final migration in applicableMigrations) {
      await migration.migrate(_box);
    }

    await _box.put(_versionKey, version);
  }

  void _assertInitialized() {
    assert(_isInitialized,
        'StorageService not initialized. Call initialize() first.');
  }

  /// Saves a value with the given [key], encrypting it before storing.
  Future<void> save(String key, dynamic value) async {
    _assertInitialized();
    try {
      final encrypted = _encrypt(value);
      await _box.put(key, encrypted);
    } catch (e, s) {
      throw StorageException('Failed to save data for key "$key".',
          originalException: e, stackTrace: s);
    }
  }

  /// Loads and decrypts the value for the given [key].
  ///
  /// Returns the value cast to type [T], or `null` if the key does not exist.
  Future<T?> load<T>(String key) async {
    _assertInitialized();
    try {
      final encrypted = _box.get(key);
      if (encrypted == null) return null;
      return _decrypt(encrypted as String) as T?;
    } catch (e, s) {
      throw StorageException('Failed to load or decrypt data for key "$key".',
          originalException: e, stackTrace: s);
    }
  }

  /// Deletes the value for the given [key].
  Future<void> delete(String key) async {
    _assertInitialized();
    await _box.delete(key);
  }

  /// Deletes all data from the primary storage box.
  Future<void> clear() async {
    _assertInitialized();
    final version = _box.get(_versionKey);
    await _box.clear();
    if (version != null) {
      await _box.put(_versionKey, version); // Preserve version after clearing.
    }
  }

  /// Creates a backup of the current data with a given [backupName].
  Future<void> createBackup(String backupName) async {
    _assertInitialized();
    try {
      final data = Map<String, dynamic>.from(_box.toMap());
      await _backupBox.put(backupName, jsonEncode(data));
    } catch (e, s) {
      throw StorageException('Failed to create backup "$backupName".',
          originalException: e, stackTrace: s);
    }
  }

  /// Restores data from a backup named [backupName].
  Future<void> restoreBackup(String backupName) async {
    _assertInitialized();
    try {
      final backupData = _backupBox.get(backupName);
      if (backupData == null) {
        throw StorageException('Backup not found: $backupName');
      }
      final data = jsonDecode(backupData as String);
      await _box.clear();
      await _box.putAll(data as Map);
    } catch (e, s) {
      throw StorageException('Failed to restore backup "$backupName".',
          originalException: e, stackTrace: s);
    }
  }

  /// Returns a list of all available backup names.
  List<String> listBackups() {
    _assertInitialized();
    return _backupBox.keys.cast<String>().toList();
  }

  /// Deletes a backup by its [backupName].
  Future<void> deleteBackup(String backupName) async {
    _assertInitialized();
    await _backupBox.delete(backupName);
  }

  /// Checks if a [key] exists in storage.
  bool containsKey(String key) {
    _assertInitialized();
    return _box.containsKey(key);
  }

  String _encrypt(dynamic value) {
    final jsonStr = jsonEncode(value);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_keyManager.key, mode: encrypt.AESMode.cbc),
    );
    return encrypter.encrypt(jsonStr, iv: _keyManager.iv).base64;
  }

  dynamic _decrypt(String encrypted) {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_keyManager.key, mode: encrypt.AESMode.cbc),
    );
    final decrypted = encrypter.decrypt64(encrypted, iv: _keyManager.iv);
    return jsonDecode(decrypted);
  }
}

/// Represents a single migration operation from one version to the next.
class Migration {
  /// The version number this migration targets.
  final int version;

  /// The function to execute to perform the migration. It receives the
  /// Hive [Box] to be migrated.
  final Future<void> Function(Box box) migrate;

  const Migration({
    required this.version,
    required this.migrate,
  });
}
