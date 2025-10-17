import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_core/src/core/storage/key_manager.dart';

import '../mocks/mock_flutter_secure_storage.dart'
    show MockFlutterSecureStorage;

void main() {
  late MockFlutterSecureStorage mockStorage;
  late KeyManager keyManager;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    keyManager = KeyManager(secureStorage: mockStorage);
  });

  test('initialize loads existing keys if present', () async {
    const keyB64 = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
    const ivB64 = 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=';
    when(() => mockStorage.read(key: 'app_encryption_master_key'))
        .thenAnswer((_) async => keyB64);
    when(() => mockStorage.read(key: 'app_encryption_master_iv'))
        .thenAnswer((_) async => ivB64);

    await keyManager.initialize();

    expect(keyManager.key.base64, keyB64);
    expect(keyManager.iv.base64, ivB64);
  });

  test('initialize generates new keys if none exist', () async {
    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});

    await keyManager.initialize();

    expect(keyManager.key.bytes.length, 32); // 256 bits
    expect(keyManager.iv.bytes.length, 16); // 128 bits
  });

  test('rotateKeys generates and stores new keys', () async {
    // First initialize
    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    await keyManager.initialize();
    final oldKey = keyManager.key;
    final oldIv = keyManager.iv;

    // Rotate
    await keyManager.rotateKeys();

    expect(keyManager.key, isNot(oldKey));
    expect(keyManager.iv, isNot(oldIv));
  });

  test('clearKeys deletes keys from storage', () async {
    when(() => mockStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
    await keyManager.clearKeys();
    verify(() => mockStorage.delete(key: 'app_encryption_master_key'))
        .called(1);
    verify(() => mockStorage.delete(key: 'app_encryption_master_iv')).called(1);
  });
}
