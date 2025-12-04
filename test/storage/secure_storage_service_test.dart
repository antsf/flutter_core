// import 'dart:convert' show jsonEncode;

// import 'package:encrypt/encrypt.dart' as encrypt;
// import 'package:flutter/services.dart' show MethodChannel, MethodCall;
// import 'package:flutter_test/flutter_test.dart'
//     show TestWidgetsFlutterBinding, TestDefaultBinaryMessengerBinding;
// import 'package:test/test.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:flutter_core/src/core/storage/secure_storage_service.dart';

// import '../mocks/mock_key_manager.dart' show MockKeyManager;

// void main() {
//   // ✅ Initialize Flutter test binding FIRST
//   TestWidgetsFlutterBinding.ensureInitialized();

//   late MockKeyManager mockKeyManager;
//   late SecureStorageService storage;

//   setUp(() async {
//     // ✅ Mock path_provider
//     const channel = MethodChannel('plugins.flutter.io/path_provider');
//     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
//         .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
//       if (methodCall.method == 'getApplicationDocumentsDirectory') {
//         // Return a temporary or in-memory path
//         return '/tmp/test_app'; // Works on macOS/Linux; for Windows use 'C:\\temp\\test_app'
//       }
//       return null;
//     });

//     // ✅ Initialize Hive in test environment (uses temp dir)
//     await Hive.initFlutter();

//     mockKeyManager = MockKeyManager();
//     when(() => mockKeyManager.initialize()).thenAnswer((_) async {});

//     storage = SecureStorageService(
//       version: 1,
//       keyManager: mockKeyManager,
//     );
//     await storage.initialize(); // This now works
//   });

//   tearDown(() async {
//     await Hive.close();
//   });

//   test('save and load encrypt/decrypt data correctly', () async {
//     final data = {'name': 'Alice', 'age': 30};
//     await storage.save('user', data);
//     final result = await storage.load<Map<String, dynamic>>('user');
//     expect(result, data);
//   });

//   test('load returns null for non-existent key', () async {
//     final result = await storage.load<Map<String, dynamic>>('missing');
//     expect(result, null);
//   });

//   test('delete removes data', () async {
//     await storage.save('temp', 'value');
//     await storage.delete('temp');
//     final result = await storage.load<String>('temp');
//     expect(result, null);
//   });

//   test('clear preserves version key', () async {
//     await storage.save('data', 'test');
//     await storage.clear();
//     expect(storage.containsKey('data'), isFalse);
//     expect(storage.containsKey('_app_data_version'), isTrue);
//   });

//   test('backup and restore work', () async {
//     await storage.save('user', {'name': 'Bob'});
//     await storage.createBackup('v1');

//     await storage.clear();
//     expect(await storage.load<Map<String, dynamic>>('user'), null);

//     await storage.restoreBackup('v1');
//     final restored = await storage.load<Map<String, dynamic>>('user');
//     expect(restored?['name'], 'Bob');
//   });

//   test('migrations run when version increases', () async {
//     // 1. Simulate v1 data: manually store encrypted 'old_settings'
//     final box = await Hive.openBox('app_secure_storage_box');
//     await box.put('_app_data_version', 1);

//     // Encrypt mock v1 data
//     final v1Data = {'theme_preference': 'dark'};
//     final encrypter = encrypt.Encrypter(
//       encrypt.AES(mockKeyManager.key, mode: encrypt.AESMode.cbc),
//     );
//     final encrypted =
//         encrypter.encrypt(jsonEncode(v1Data), iv: mockKeyManager.iv);
//     await box.put('old_settings', encrypted.base64);
//     await box.close();

//     // 2. Define migration (exactly as in your example)
//     final migrationToV2 = Migration(
//       version: 2,
//       migrate: (box) async {
//         final oldData = box.get('old_settings');
//         if (oldData != null) {
//           // Decrypt, transform, re-encrypt would be ideal,
//           // but for simplicity in migration, we assume structure is known
//           // and just move the encrypted blob if format is compatible.
//           // In real apps, you might decrypt with old key, transform, re-encrypt with new key.
//           await box.put('new_settings', oldData);
//           await box.delete('old_settings');
//         }
//       },
//     );

//     // 3. Initialize v2 service — triggers migration
//     final service = SecureStorageService(
//       version: 2,
//       migrations: [migrationToV2],
//       keyManager: mockKeyManager,
//     );
//     await service.initialize();

//     // 4. Load transformed data
//     final result = await service.load<Map<String, dynamic>>('new_settings');
//     expect(result?['theme_preference'], 'dark');

//     // 5. Verify old key is gone
//     expect(service.containsKey('old_settings'), isFalse);
//   });
// }
