import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_corekit/src/storage/secure_storage.dart';

import '../mocks/mock_flutter_secure_storage.dart'
    show MockFlutterSecureStorage;

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorage secureStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    // Inject mock via dynamic (since _storage is private)
    secureStorage = SecureStorage(secureStorage: mockStorage);
  });

  test('set and get store/retrieve string correctly', () async {
    when(() => mockStorage.write(key: 'prefs|token', value: 'abc123'))
        .thenAnswer((_) async {});
    when(() => mockStorage.read(key: 'prefs|token'))
        .thenAnswer((_) async => 'abc123');

    await secureStorage.set<String>('prefs', 'token', 'abc123');
    final result = await secureStorage.get<String>('prefs', 'token');
    expect(result, 'abc123');
  });

  test('get returns null for non-existent key', () async {
    when(() => mockStorage.read(key: 'box|key')).thenAnswer((_) async => null);
    final result = await secureStorage.get<String>('box', 'key');
    expect(result, null);
  });

  test('containsKey returns true if key exists', () async {
    when(() => mockStorage.containsKey(key: 'box|key'))
        .thenAnswer((_) async => true);
    expect(await secureStorage.containsKey('box', 'key'), isTrue);
  });

  group('bool deserialization', () {
    test('reads "true" and "false" correctly', () async {
      when(() => mockStorage.read(key: 'box|flag'))
          .thenAnswer((_) async => 'true');
      expect(await secureStorage.get<bool>('box', 'flag'), isTrue);

      when(() => mockStorage.read(key: 'box|flag'))
          .thenAnswer((_) async => 'false');
      expect(await secureStorage.get<bool>('box', 'flag'), isFalse);
    });

    test('returns null for a corrupt bool value (not silently false)',
        () async {
      when(() => mockStorage.read(key: 'box|flag'))
          .thenAnswer((_) async => 'garbage');
      expect(await secureStorage.get<bool>('box', 'flag'), isNull);
    });
  });

  test('clearBox deletes all keys with prefix', () async {
    when(() => mockStorage.readAll())
        .thenAnswer((_) async => {'box|a': '1', 'box|b': '2', 'other|c': '3'});
    when(() => mockStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});

    await secureStorage.clearBox('box');

    verify(() => mockStorage.delete(key: 'box|a')).called(1);
    verify(() => mockStorage.delete(key: 'box|b')).called(1);
    verifyNever(() => mockStorage.delete(key: 'other|c'));
  });
}
