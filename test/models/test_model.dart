// test/models/test_model.dart

import 'package:flutter_core/src/core/data/models/base_model.dart'
    show BaseModel;

import '../entities/test_entity.dart';

class TestModel extends BaseModel<TestEntity> {
  final String id;
  final String name;

  TestModel({required this.id, required this.name});

  factory TestModel.fromJson(Map<String, dynamic> json) =>
      TestModel(id: json['id'] as String, name: json['name'] as String);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  TestEntity toEntity() => TestEntity(id: id, name: name);

  @override
  List<Object?> get props => [id, name];
}
