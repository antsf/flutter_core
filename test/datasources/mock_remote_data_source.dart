// test/datasources/mock_remote_data_source.dart
import 'package:flutter_core/src/core/data/datasources/base_remote_data_source.dart'
    show BaseRemoteDataSource;
import '../models/test_model.dart';

class MockRemoteDataSource extends BaseRemoteDataSource<TestModel> {
  final List<TestModel> _data = [
    TestModel(id: '1', name: 'Alice'),
    TestModel(id: '2', name: 'Bob'),
  ];
  bool shouldThrow = false;

  @override
  Future<List<TestModel>> getAll() async {
    if (shouldThrow) throw Exception('Network error');
    return _data;
  }

  @override
  Future<TestModel> getById(String id) async {
    if (shouldThrow) throw Exception('Network error');
    final model = _data.firstWhere((m) => m.id == id,
        orElse: () => throw Exception('Not found'));
    return model;
  }

  @override
  Future<TestModel> create(TestModel model) async {
    if (shouldThrow) throw Exception('Network error');
    _data.add(model);
    return model;
  }

  @override
  Future<TestModel> update(TestModel model) async {
    if (shouldThrow) throw Exception('Network error');
    final index = _data.indexWhere((m) => m.id == model.id);
    if (index == -1) throw Exception('Not found');
    _data[index] = model;
    return model;
  }

  @override
  Future<void> delete(String id) async {
    if (shouldThrow) throw Exception('Network error');
    _data.removeWhere((m) => m.id == id);
  }

  @override
  Future<List<TestModel>> search({required String query}) async {
    if (shouldThrow) throw Exception('Network error');
    return _data
        .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<TestModel>> getPaginated({
    required int page,
    required int limit,
    String? sortBy,
    bool descending = false,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    final start = (page - 1) * limit;
    final end = start + limit;
    return _data.skip(start).take(end).toList();
  }
}
