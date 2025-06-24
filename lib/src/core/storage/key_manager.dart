/// Manages the secure generation, storage, and retrieval of encryption keys (key and IV)
/// used for data encryption, particularly with AES.
///
/// This library provides the [KeyManager] class, which interfaces with
/// `flutter_secure_storage` to persist keys securely and makes them available
/// for encryption/decryption operations.
library key_manager;

import 'dart:convert';
import 'dart:developer' show log;
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages AES encryption keys (key and Initialization Vector - IV) by securely
/// storing and retrieving them using [FlutterSecureStorage].
///
/// On initialization, it attempts to load existing keys. If they are not found,
/// it generates new random keys and stores them securely. This class is crucial
/// for services like [SecureStorageService] that require encryption.
///
/// ### Key Details:
/// - **Key Length**: 256 bits (32 bytes) for AES.
/// - **IV Length**: 128 bits (16 bytes) for AES (especially CBC mode).
/// - **Storage**: Keys and IVs are stored base64 encoded in `FlutterSecureStorage`.
class KeyManager {
  static const String _keyStorageIdentifier = 'app_encryption_master_key';
  static const String _ivStorageIdentifier = 'app_encryption_master_iv';
  static const int _keyBitLength = 256; // For AES-256
  static const int _ivBitLength = 128;  // For AES block size (e.g., CBC mode)

  final FlutterSecureStorage _secureStorage;
  late encrypt.Key _encryptionKey;
  late encrypt.IV _initializationVector;

  /// Creates an instance of [KeyManager].
  ///
  /// An optional [secureStorage] instance can be provided, primarily for testing.
  /// If not provided, a default instance of `FlutterSecureStorage` is used.
  KeyManager({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initializes the [KeyManager] by loading existing encryption keys and IVs
  /// from secure storage, or generating and storing new ones if they don't exist.
  ///
  /// This method **must be called** before accessing [key] or [iv].
  ///
  /// Throws an exception if reading/writing from/to `FlutterSecureStorage` fails.
  Future<void> initialize() async {
    log('KeyManager: Initializing...');
    try {
      await _loadOrGenerateKeys();
      log('KeyManager: Initialization complete. Keys are ready.');
    } catch (e, s) {
      log('KeyManager: Error during initialization.', error: e, stackTrace: s);
      // Rethrowing to indicate critical failure in key setup.
      // Consider wrapping in a custom KeyManagementException.
      throw Exception('KeyManager failed to initialize: $e');
    }
  }

  /// The AES encryption key.
  ///
  /// Available only after [initialize] has been successfully called.
  encrypt.Key get key => _encryptionKey;

  /// The AES Initialization Vector (IV).
  ///
  /// Available only after [initialize] has been successfully called.
  encrypt.IV get iv => _initializationVector;

  /// Loads keys from secure storage if they exist, otherwise generates new ones.
  Future<void> _loadOrGenerateKeys() async {
    final String? storedKeyBase64 = await _secureStorage.read(key: _keyStorageIdentifier);
    final String? storedIvBase64 = await _secureStorage.read(key: _ivStorageIdentifier);

    if (storedKeyBase64 != null && storedIvBase64 != null) {
      log('KeyManager: Found existing keys in secure storage. Loading them.');
      _encryptionKey = encrypt.Key.fromBase64(storedKeyBase64);
      _initializationVector = encrypt.IV.fromBase64(storedIvBase64);
      // Basic validation for key/IV length after loading
      if (_encryptionKey.bytes.length != (_keyBitLength / 8).round() ||
          _initializationVector.bytes.length != (_ivBitLength / 8).round()) {
        log('KeyManager: Loaded keys have incorrect length. Regenerating.');
        await _generateAndStoreNewKeys();
      }
    } else {
      log('KeyManager: No existing keys found. Generating new keys and IV.');
      await _generateAndStoreNewKeys();
    }
  }

  /// Generates new random key and IV and stores them securely.
  Future<void> _generateAndStoreNewKeys() async {
    final newKeyBytes = _generateRandomBytes((_keyBitLength / 8).round());
    final newIvBytes = _generateRandomBytes((_ivBitLength / 8).round());

    _encryptionKey = encrypt.Key(newKeyBytes);
    _initializationVector = encrypt.IV(newIvBytes);

    await _secureStorage.write(
      key: _keyStorageIdentifier,
      value: _encryptionKey.base64, // Use getter from encrypt.Key
    );
    await _secureStorage.write(
      key: _ivStorageIdentifier,
      value: _initializationVector.base64, // Use getter from encrypt.IV
    );
    log('KeyManager: New keys generated and stored securely.');
  }

  /// Generates a list of random bytes of the specified [length].
  /// Uses [Random.secure] for cryptographically secure random numbers.
  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return Uint8List.fromList(values);
  }

  /// Rotates the encryption key and IV.
  ///
  /// This generates a new key and IV, stores them in secure storage (overwriting
  /// the old ones), and updates the in-memory [key] and [iv] properties.
  ///
  /// **Warning**: Rotating keys will make all data encrypted with the old keys
  /// unrecoverable unless a separate key migration strategy is implemented.
  /// This method is typically used when old keys might be compromised or as part
  /// of a scheduled key rotation policy.
  ///
  /// Throws an exception if writing to `FlutterSecureStorage` fails.
  Future<void> rotateKeys() async {
    log('KeyManager: Rotating encryption keys...');
    try {
      await _generateAndStoreNewKeys();
      log('KeyManager: Keys rotated successfully.');
    } catch (e, s) {
      log('KeyManager: Error rotating keys.', error: e, stackTrace: s);
      throw Exception('KeyManager failed to rotate keys: $e');
    }
  }

  /// Clears the stored encryption key and IV from secure storage.
  ///
  /// After calling this, subsequent calls to [initialize] will generate new keys.
  /// **Warning**: This makes any data encrypted with the cleared keys unrecoverable.
  /// Use with extreme caution.
  ///
  /// Throws an exception if deletion from `FlutterSecureStorage` fails.
  Future<void> clearKeys() async {
    log('KeyManager: Clearing stored encryption keys...');
    try {
      await _secureStorage.delete(key: _keyStorageIdentifier);
      await _secureStorage.delete(key: _ivStorageIdentifier);
      log('KeyManager: Stored keys cleared successfully.');
    } catch (e, s) {
      log('KeyManager: Error clearing keys from secure storage.', error: e, stackTrace: s);
      throw Exception('KeyManager failed to clear keys: $e');
    }
  }
}
