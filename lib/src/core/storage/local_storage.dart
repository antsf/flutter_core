import 'dart:convert';
import 'dart:developer' show log;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple key-value storage backed by flutter_secure_storage.
/// API mirrors SimpleStorageService for easy swapping.
class LocalStorage {
  static const _options = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: _options,
    iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device),
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

  Future<void> deleteBoxFromDisk(String boxName) async =>
      await clearBox(boxName);

  /* ---------- private ---------- */

  String _key(String boxName, String key) => '$boxName|$key';

  String _toString<T>(T value) {
    if (T == Map<String, dynamic>) {
      return jsonEncode(value);
    }
    return value.toString();
  }

  T? _fromString<T>(String raw) {
    if (T == String) return raw as T;
    if (T == int) return int.tryParse(raw) as T?;
    if (T == double) return double.tryParse(raw) as T?;
    if (T == bool) return (raw.toLowerCase() == 'true') as T;
    throw UnsupportedError('Type $T not supported');
  }
}
