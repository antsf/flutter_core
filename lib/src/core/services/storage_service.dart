import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Service for managing Hive storage operations
class SimpleStorageService {
  final String _basePath;
  final Map<String, Box> _boxes = {};

  SimpleStorageService({String? basePath}) : _basePath = basePath ?? 'storage';

  /// Initializes Hive with the specified base path
  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    final path = '${appDir.path}/$_basePath';
    await Hive.initFlutter(path);
  }

  /// Opens a Hive box with the given name
  Future<Box> openBox(String name) async {
    if (!_boxes.containsKey(name)) {
      _boxes[name] = await Hive.openBox(name);
    }
    return _boxes[name]!;
  }

  /// Closes a Hive box with the given name
  Future<void> closeBox(String name) async {
    if (_boxes.containsKey(name)) {
      await _boxes[name]?.close();
      _boxes.remove(name);
    }
  }

  /// Clears all data from a Hive box
  Future<void> clearBox(String name) async {
    final box = await openBox(name);
    await box.clear();
  }

  /// Deletes a Hive box and its associated file
  Future<void> deleteBox(String name) async {
    await closeBox(name);
    final appDir = await getApplicationDocumentsDirectory();
    final path = '${appDir.path}/$_basePath/$name.hive';
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Gets a value from a box
  Future<T?> get<T>(String boxName, String key) async {
    final box = await openBox(boxName);
    return box.get(key) as T?;
  }

  /// Sets a value in a box
  Future<void> set(String boxName, String key, dynamic value) async {
    final box = await openBox(boxName);
    await box.put(key, value);
  }

  /// Deletes a value from a box
  Future<void> delete(String boxName, String key) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  /// Checks if a key exists in a box
  Future<bool> containsKey(String boxName, String key) async {
    final box = await openBox(boxName);
    return box.containsKey(key);
  }

  /// Gets all keys from a box
  Future<List<dynamic>> getKeys(String boxName) async {
    final box = await openBox(boxName);
    return box.keys.toList();
  }

  /// Gets all values from a box
  Future<List<dynamic>> getValues(String boxName) async {
    final box = await openBox(boxName);
    return box.values.toList();
  }
}
