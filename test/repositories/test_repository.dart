// test/repositories/test_repository.dart
import 'package:flutter_core/src/core/data/repositories/base_repository_impl.dart'
    show BaseRepositoryImpl;

import '../entities/test_entity.dart';
import '../models/test_model.dart';

class TestRepository extends BaseRepositoryImpl<TestEntity, TestModel> {
  TestRepository(
      {super.remoteDataSource, super.localDataSource, super.strategy});

  @override
  TestModel toModel(TestEntity entity) {
    return TestModel(id: entity.id, name: entity.name);
  }
}
