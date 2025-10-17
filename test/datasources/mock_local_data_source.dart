// test/datasources/mock_local_data_source.dart
import 'package:flutter_core/src/core/data/datasources/base_local_data_source.dart'
    show BaseLocalDataSource;

import '../entities/test_entity.dart' show TestEntity;

class MockLocalDataSource extends BaseLocalDataSource<TestEntity> {
  final Map<String, TestEntity> _store = {};
  bool shouldThrow = false;

  @override
  Future<List<TestEntity>> getAll() async {
    if (shouldThrow) throw Exception('Cache read failed');
    return _store.values.toList();
  }

  @override
  Future<TestEntity> getById(String id) async {
    if (shouldThrow) throw Exception('Cache read failed');
    final entity = _store[id];
    if (entity == null) throw Exception('Not found');
    return entity;
  }

  @override
  Future<void> save(TestEntity entity) async {
    if (shouldThrow) throw Exception('Cache write failed');
    _store[entity.id] = entity;
  }

  @override
  Future<void> saveAll(List<TestEntity> entities) async {
    if (shouldThrow) throw Exception('Cache write failed');
    for (var e in entities) {
      _store[e.id] = e;
    }
  }

  @override
  Future<void> delete(String id) async {
    if (shouldThrow) throw Exception('Cache delete failed');
    _store.remove(id);
  }

  @override
  Future<void> clear() async {
    if (shouldThrow) throw Exception('Cache clear failed');
    _store.clear();
  }

  @override
  Future<bool> exists(String id) async {
    if (shouldThrow) throw Exception('Cache check failed');
    return _store.containsKey(id);
  }
}
