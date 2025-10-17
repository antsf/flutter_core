// test/entities/test_user_entity.dart

import 'package:flutter_core/src/core/domain/entities/base_entity.dart';

class UserEntity extends BaseEntity {
  final String id;
  final String name;
  final int age;

  const UserEntity({
    required this.id,
    required this.name,
    required this.age,
  });

  @override
  List<Object?> get props => [id, name, age];

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  static UserEntity fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }
}
