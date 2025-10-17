// test/models/test_user_model.dart

import 'package:flutter_core/src/core/data/models/base_model.dart';

import '../entities/test_user_entity.dart';

class UserModel extends BaseModel<UserEntity> {
  final String id;
  final String name;
  final int age;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  @override
  UserEntity toEntity() {
    return UserEntity(id: id, name: name, age: age);
  }

  @override
  List<Object?> get props => [id, name, age];
}
