import 'dart:convert';
import 'dart:developer' show log;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple key-value storage backed by [FlutterSecureStorage].
///
/// Keys are namespaced by [boxName] using the format `boxName|key`, which
/// allows logical grouping of related values and bulk operations per box.
///
/// Supported types for [get] and [set]: [String], [int], [double], [bool],
/// [Map<String, dynamic>].
class LocalStorage {
  static const _options = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final FlutterSecureStorage _storage;

  LocalStorage({FlutterSecureStorage? secureStorage})
      : _storage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: _options,
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  /// No-op on secure-storage; kept for API compatibility.
  Future<void> init() async {
    log('LocalStorage: ready (FlutterSecureStorage)');
  }

  /* ---------- single-value CRUD ---------- */

  Future<T?> get<T>(String boxName, String key) async {
    try {
      final raw = await _storage.read(key: _key(boxName, key));
      return raw == null ? null : _fromString<T>(raw);
    } catch (e, s) {
      log('LocalStorage: get failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> set<T>(String boxName, String key, T value) async {
    try {
      await _storage.write(
        key: _key(boxName, key),
        value: _toString<T>(value),
      );
    } catch (e, s) {
      log('LocalStorage: set failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> delete(String boxName, String key) async {
    try {
      await _storage.delete(key: _key(boxName, key));
    } catch (e, s) {
      log('LocalStorage: delete failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<bool> containsKey(String boxName, String key) async =>
      await _storage.containsKey(key: _key(boxName, key));

  /* ---------- bulk helpers ---------- */

  Future<void> clearBox(String boxName) async {
    final all = await _storage.readAll();
    final keysToDelete = all.keys.where((k) => k.startsWith('$boxName|'));
    await Future.wait(keysToDelete.map((key) => _storage.delete(key: key)));
  }

  Future<List<String>> getKeys(String boxName) async {
    final all = await _storage.readAll();
    return all.keys
        .where((k) => k.startsWith('$boxName|'))
        .map((k) => k.substring(boxName.length + 1))
        .toList();
  }

  /// Returns all key-value pairs stored under [boxName].
  ///
  /// Values that cannot be deserialized to [T] are returned as `null`.
  Future<Map<String, T?>> getAllValues<T>(String boxName) async {
    final all = await _storage.readAll();
    final result = <String, T?>{};
    for (final entry in all.entries) {
      if (entry.key.startsWith('$boxName|')) {
        final key = entry.key.substring(boxName.length + 1);
        try {
          result[key] = _fromString<T>(entry.value);
        } catch (_) {
          result[key] = null;
        }
      }
    }
    return result;
  }

  /// Alias for [clearBox] — removes all keys under [boxName].
  Future<void> deleteBoxFromDisk(String boxName) async => clearBox(boxName);

  /* ---------- private ---------- */

  String _key(String boxName, String key) => '$boxName|$key';

  String _toString<T>(T value) {
    if (T == Map<String, dynamic>) return jsonEncode(value);
    return value.toString();
  }

  T? _fromString<T>(String raw) {
    if (T == String) return raw as T;
    if (T == int) return int.tryParse(raw) as T?;
    if (T == double) return double.tryParse(raw) as T?;
    if (T == bool) return (raw.toLowerCase() == 'true') as T;
    if (T == Map<String, dynamic>) return jsonDecode(raw) as T?;
    throw UnsupportedError(
        'LocalStorage: Type $T not supported. Supported: String, int, double, bool, Map<String, dynamic>');
  }
}
