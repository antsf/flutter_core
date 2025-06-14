/// Manages encryption keys securely for storage encryption.
library key_manager;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Manages encryption keys securely
class KeyManager {
  static const String _keyStorageKey = 'encryption_key';
  static const String _ivStorageKey = 'encryption_iv';
  static const int _keyLength = 32; // 256 bits for AES
  static const int _ivLength = 16; // 128 bits for AES

  final FlutterSecureStorage _secureStorage;
  late encrypt.Key _key;
  late encrypt.IV _iv;

  KeyManager({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initialize the key manager
  Future<void> initialize() async {
    await _loadOrGenerateKeys();
  }

  /// Get the encryption key
  encrypt.Key get key => _key;

  /// Get the initialization vector
  encrypt.IV get iv => _iv;

  Future<void> _loadOrGenerateKeys() async {
    final storedKey = await _secureStorage.read(key: _keyStorageKey);
    final storedIV = await _secureStorage.read(key: _ivStorageKey);

    if (storedKey != null && storedIV != null) {
      _key = encrypt.Key.fromBase64(storedKey);
      _iv = encrypt.IV.fromBase64(storedIV);
    } else {
      final newKey = _generateRandomBytes(_keyLength);
      final newIV = _generateRandomBytes(_ivLength);

      _key = encrypt.Key(Uint8List.fromList(newKey));
      _iv = encrypt.IV(Uint8List.fromList(newIV));

      await _secureStorage.write(
        key: _keyStorageKey,
        value: base64Encode(newKey),
      );
      await _secureStorage.write(
        key: _ivStorageKey,
        value: base64Encode(newIV),
      );
    }
  }

  List<int> _generateRandomBytes(int length) {
    final random = Random.secure();
    return List.generate(length, (_) => random.nextInt(256));
  }

  /// Rotate encryption keys
  Future<void> rotateKeys() async {
    final newKey = _generateRandomBytes(_keyLength);
    final newIV = _generateRandomBytes(_ivLength);

    _key = encrypt.Key(Uint8List.fromList(newKey));
    _iv = encrypt.IV(Uint8List.fromList(newIV));

    await _secureStorage.write(
      key: _keyStorageKey,
      value: base64Encode(newKey),
    );
    await _secureStorage.write(
      key: _ivStorageKey,
      value: base64Encode(newIV),
    );
  }

  /// Clear stored keys
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _ivStorageKey);
  }
}
