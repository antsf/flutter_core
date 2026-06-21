import 'dart:convert';
import 'dart:developer' show log;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key-value storage backed by [FlutterSecureStorage].
///
/// **Use this for small, sensitive values** — auth/refresh tokens, API keys,
/// PINs. It is NOT a general-purpose app database.
///
/// ### Performance & security caveats
/// - Backed by the platform Keychain (iOS/macOS) / Keystore-encrypted prefs
///   (Android). Reads/writes are far slower than `shared_preferences` or a DB,
///   so don't use it for large or frequently-accessed non-sensitive data.
/// - The bulk helpers ([clearBox], [getKeys], [getAllValues]) call `readAll()`,
///   which reads and **decrypts every stored entry** (O(n)). Keep boxes small.
/// - Security guarantees vary by platform. On the web there is no OS keychain,
///   so data is **not** strongly protected — avoid storing high-value secrets
///   on web targets.
///
/// Keys are namespaced by [boxName] using the format `boxName|key`.
///
/// Supported value types for [get]/[set]: [String], [int], [double], [bool],
/// `Map<String, dynamic>`, and `List<dynamic>` (the last two are JSON-encoded).
class SecureStorage {
  static const _options = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? secureStorage})
      : _storage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: _options,
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  /// No-op on secure-storage; kept for API compatibility.
  Future<void> init() async {
    log('SecureStorage: ready (FlutterSecureStorage)');
  }

  /* ---------- single-value CRUD ---------- */

  Future<T?> get<T>(String boxName, String key) async {
    try {
      final raw = await _storage.read(key: _key(boxName, key));
      return raw == null ? null : _fromString<T>(raw);
    } catch (e, s) {
      log('SecureStorage: get failed', error: e, stackTrace: s);
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
      log('SecureStorage: set failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> delete(String boxName, String key) async {
    try {
      await _storage.delete(key: _key(boxName, key));
    } catch (e, s) {
      log('SecureStorage: delete failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<bool> containsKey(String boxName, String key) async =>
      await _storage.containsKey(key: _key(boxName, key));

  /* ---------- bulk helpers ---------- */

  /// Removes all keys under [boxName].
  ///
  /// Note: reads (and decrypts) all stored entries to find matching keys.
  Future<void> clearBox(String boxName) async {
    final all = await _storage.readAll();
    final keysToDelete = all.keys.where((k) => k.startsWith('$boxName|'));
    await Future.wait(keysToDelete.map((key) => _storage.delete(key: key)));
  }

  /// Returns the keys under [boxName].
  ///
  /// Note: reads (and decrypts) all stored entries.
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
  /// Note: reads (and decrypts) all stored entries.
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

  /* ---------- private ---------- */

  String _key(String boxName, String key) => '$boxName|$key';

  String _toString<T>(T value) {
    if (value is Map || value is List) return jsonEncode(value);
    return value.toString();
  }

  T? _fromString<T>(String raw) {
    if (T == String) return raw as T;
    if (T == int) return int.tryParse(raw) as T?;
    if (T == double) return double.tryParse(raw) as T?;
    if (T == bool) {
      final lower = raw.toLowerCase();
      if (lower == 'true') return true as T;
      if (lower == 'false') return false as T;
      // Corrupt/garbage value — return null like the other tryParse branches
      // instead of silently coercing to `false`.
      return null;
    }
    if (T == Map<String, dynamic>) return jsonDecode(raw) as T?;
    if (T == List<dynamic>) return jsonDecode(raw) as T?;
    throw UnsupportedError(
        'SecureStorage: Type $T not supported. Supported: String, int, double, '
        'bool, Map<String, dynamic>, List<dynamic>');
  }
}

/// Deprecated alias for [SecureStorage].
///
/// Renamed to make it explicit that this is encrypted secure storage (backed by
/// flutter_secure_storage), not general-purpose local storage. Will be removed
/// in a future release.
@Deprecated('Renamed to SecureStorage. Will be removed in a future release.')
typedef LocalStorage = SecureStorage;
