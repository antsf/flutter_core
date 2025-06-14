import 'package:flutter/foundation.dart';

import '../../domain/entities/base_entity.dart';

/// An abstract base class for data models.
///
/// It enforces a contract for converting between models and domain entities,
/// serializing to JSON, and implementing robust value equality.
///
/// ### Subclassing Example:
///
/// ```dart
/// class UserModel extends BaseModel<UserEntity> {
///   final String id;
///   final String name;
///
///   UserModel({required this.id, required this.name});
///
///   // 1. Implement a factory constructor for JSON deserialization.
///   factory UserModel.fromJson(Map<String, dynamic> json) {
///     return UserModel(
///       id: json['id'] as String,
///       name: json['name'] as String,
///     );
///   }
///
///   // 2. Implement toJson for serialization.
///   @override
///   Map<String, dynamic> toJson() {
///     return {
///       'id': id,
///       'name': name,
///     };
///   }
///
///   // 3. Implement toEntity to convert to a domain entity.
///   @override
///   UserEntity toEntity() {
///     return UserEntity(id: id, name: name);
///   }
///
///   // 4. Override props for value equality.
///   @override
///   List<Object?> get props => [id, name];
/// }
/// ```
abstract class BaseModel<T extends BaseEntity> {
  /// Converts this data model into a domain [BaseEntity].
  ///
  /// This method is responsible for mapping the data model's properties
  /// to the corresponding entity's properties.
  T toEntity();

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson();

  /// The list of properties that will be used for value-based equality.
  ///
  /// Subclasses should override this getter and include all properties
  /// that define the model's identity.
  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseModel &&
          runtimeType == other.runtimeType &&
          // Using foundation.listEquals for a robust deep equality check on props.
          listEquals(props, other.props);

  @override
  int get hashCode => Object.hashAll(props);

  @override
  String toString() => '$runtimeType(${props.join(', ')})';
}
