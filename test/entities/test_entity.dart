// test/entities/test_entity.dart
import 'package:flutter_core/src/core/domain/entities/base_entity.dart'
    show BaseEntity;

class TestEntity extends BaseEntity {
  final String id;
  final String name;

  const TestEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];

  static TestEntity fromJson(Map<String, dynamic> json) =>
      TestEntity(id: json['id'] as String, name: json['name'] as String);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
