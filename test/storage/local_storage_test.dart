import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_core/src/core/storage/local_storage.dart';

import '../mocks/mock_flutter_secure_storage.dart'
    show MockFlutterSecureStorage;

void main() {
  late MockFlutterSecureStorage mockStorage;
  late LocalStorage localStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    // Inject mock via dynamic (since _storage is private)
    localStorage = LocalStorage(secureStorage: mockStorage);
  });

  test('set and get store/retrieve string correctly', () async {
    when(() => mockStorage.write(key: 'prefs|token', value: 'abc123'))
        .thenAnswer((_) async {});
    when(() => mockStorage.read(key: 'prefs|token'))
        .thenAnswer((_) async => 'abc123');

    await localStorage.set<String>('prefs', 'token', 'abc123');
    final result = await localStorage.get<String>('prefs', 'token');
    expect(result, 'abc123');
  });

  test('get returns null for non-existent key', () async {
    when(() => mockStorage.read(key: 'box|key')).thenAnswer((_) async => null);
    final result = await localStorage.get<String>('box', 'key');
    expect(result, null);
  });

  test('containsKey returns true if key exists', () async {
    when(() => mockStorage.containsKey(key: 'box|key'))
        .thenAnswer((_) async => true);
    expect(await localStorage.containsKey('box', 'key'), isTrue);
  });

  test('clearBox deletes all keys with prefix', () async {
    when(() => mockStorage.readAll())
        .thenAnswer((_) async => {'box|a': '1', 'box|b': '2', 'other|c': '3'});
    when(() => mockStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});

    await localStorage.clearBox('box');

    verify(() => mockStorage.delete(key: 'box|a')).called(1);
    verify(() => mockStorage.delete(key: 'box|b')).called(1);
    verifyNever(() => mockStorage.delete(key: 'other|c'));
  });
}
