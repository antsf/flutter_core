// test/storage/simple_storage_service_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_core/src/core/services/storage_service.dart'
    show SimpleStorageService;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SimpleStorageService storage;

  setUp(() async {
    // ✅ Mock path_provider
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        // Return a temporary or in-memory path
        return '/tmp/test_app'; // Works on macOS/Linux; for Windows use 'C:\\temp\\test_app'
      }
      return null;
    });

    // Hive.initFlutter() uses a temporary directory in tests
    await Hive.initFlutter();

    storage = SimpleStorageService(basePath: 'test_storage');
    await storage.init();
  });

  tearDown(() async {
    await storage.closeAllBoxes();
    // Optional: reset mock
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('SimpleStorageService', () {
    const boxName = 'test_box';
    const key = 'test_key';
    const value = 'test_value';

    test('set and get store and retrieve data correctly', () async {
      await storage.set(boxName, key, value);
      final result = await storage.get<String>(boxName, key);
      expect(result, value);
    });

    test('get returns null for non-existent key', () async {
      final result = await storage.get<String>(boxName, 'non_existent');
      expect(result, null);
    });

    test('delete removes a key', () async {
      await storage.set(boxName, key, value);
      await storage.delete(boxName, key);
      final result = await storage.get<String>(boxName, key);
      expect(result, null);
    });

    test('containsKey returns true for existing key', () async {
      await storage.set(boxName, key, value);
      final exists = await storage.containsKey(boxName, key);
      expect(exists, isTrue);
    });

    test('containsKey returns false for non-existent key', () async {
      final exists = await storage.containsKey(boxName, 'non_existent');
      expect(exists, isFalse);
    });

    test('clearBox removes all data from a box', () async {
      await storage.set(boxName, 'key1', 'value1');
      await storage.set(boxName, 'key2', 'value2');
      await storage.clearBox(boxName);
      final result1 = await storage.get<String>(boxName, 'key1');
      final result2 = await storage.get<String>(boxName, 'key2');
      expect(result1, null);
      expect(result2, null);
    });

    test('getKeys returns all keys in a box', () async {
      await storage.set(boxName, 'key1', 'value1');
      await storage.set(boxName, 'key2', 'value2');
      final keys = await storage.getKeys(boxName);
      expect(keys, containsAll(['key1', 'key2']));
    });

    test('getValues returns all values in a box', () async {
      await storage.set<String>(boxName, 'key1', 'value1');
      await storage.set<String>(boxName, 'key2', 'value2');
      final values = await storage.getValues<String>(boxName);
      expect(values, containsAll(['value1', 'value2']));
    });

    test('closeBox closes and removes box from cache', () async {
      await storage.set(boxName, key, value);
      await storage.closeBox(boxName);
      // Re-open should work
      final result = await storage.get<String>(boxName, key);
      expect(result, value);
    });

    test('deleteBoxFromDisk removes box permanently', () async {
      const boxName = 'test_box';

      // Create box
      await storage.set(boxName, 'key', 'value');
      expect(await Hive.boxExists(boxName), isTrue);

      // Delete it
      await storage.deleteBoxFromDisk(boxName);

      // Verify it's gone
      expect(await Hive.boxExists(boxName), isFalse);
    });
  });
}
