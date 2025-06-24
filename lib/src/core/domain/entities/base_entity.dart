import 'package:flutter/foundation.dart' show listEquals;

/// An abstract base class for all domain entities in the application.
///
/// Entities represent the core business objects and are independent of any specific
/// framework or technology. They should encapsulate the most general and high-level rules.
///
/// ### Characteristics:
/// - **Identity**: Entities typically have a unique identifier (e.g., `id`), although this
///   base class does not enforce a specific ID property to remain generic.
///   Subclasses should define their own identifiers if applicable.
/// - **Value Equality**: Entities should be comparable based on their properties,
///   not their memory location. This class provides a foundation for value equality
///   through the [props] getter and overridden `==` and `hashCode` operators.
/// - **Immutability**: It is highly recommended that subclasses are immutable.
///   Once an entity is created, its state should not change. If a change is needed,
///   a new instance of the entity should be created.
///
/// ### Subclassing Example:
/// ```dart
/// class UserEntity extends BaseEntity {
///   final String id;
///   final String name;
///   final int age;
///
///   const UserEntity({required this.id, required this.name, required this.age});
///
///   // 1. Implement 'props' for value equality.
///   @override
///   List<Object?> get props => [id, name, age];
///
///   // 2. (Optional) If direct JSON conversion is needed for the entity:
///   //    This is often handled by Data Models in the data layer, but if entities
///   //    are cached or transmitted directly, these can be useful.
///
///   // @override
///   // Map<String, dynamic> toJson() {
///   //   return {
///   //     'id': id,
///   //     'name': name,
///   //     'age': age,
///   //   };
///   // }
///
///   // static UserEntity fromJson(Map<String, dynamic> json) {
///   //   return UserEntity(
///   //     id: json['id'] as String,
///   //     name: json['name'] as String,
///   //     age: json['age'] as int,
///   //   );
///   // }
/// }
/// ```
abstract class BaseEntity {
  /// Constructs a const [BaseEntity].
  /// This allows subclasses to also be const, promoting immutability.
  const BaseEntity();

  /// The list of properties that will be used for value-based equality.
  ///
  /// Subclasses **must** override this getter and include all properties
  /// that define the entity's identity and state.
  ///
  /// Example: `List<Object?> get props => [id, name, email];`
  List<Object?> get props;

  /// (Optional) Converts this entity to a JSON representation.
  ///
  /// While entities are primarily domain objects, this method can be useful
  /// if entities need to be serialized directly (e.g., for caching as entities).
  /// Typically, JSON serialization/deserialization is handled by `BaseModel`
  /// in the data layer.
  ///
  /// If not needed, subclasses can leave this unimplemented or throw an error.
  /// If implemented, it should return a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() {
    throw UnimplementedError(
        'toJson() is not implemented for $runtimeType. '
        'Consider implementing it if direct entity serialization is needed, '
        'or rely on data models for JSON conversion.');
  }

  /// (Optional) A static factory method placeholder for creating an entity from JSON.
  ///
  /// Concrete subclasses should provide their own static `fromJson` factory
  /// if they support direct deserialization. This base method is a reminder
  /// and is not called directly.
  ///
  /// Example in `UserEntity`:
  /// `static UserEntity fromJson(Map<String, dynamic> json) => UserEntity(...);`
  ///
  /// **Note**: Due to Dart's limitations with static methods in abstract classes
  /// and generics, this method cannot be truly abstract or enforce a specific
  /// signature for subclasses in a way that `T.fromJson()` would work generically.
  /// It serves as a convention.
  static T fromJson<T extends BaseEntity>(Map<String, dynamic> json) {
    throw UnimplementedError(
        'fromJson() not implemented. Each BaseEntity subclass should provide its own '
        'static fromJson factory constructor.');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseEntity &&
          runtimeType == other.runtimeType &&
          // Use listEquals for a robust deep equality check on props.
          listEquals(props, other.props);

  @override
  int get hashCode => Object.hashAll(props);

  @override
  String toString() => '$runtimeType(${props.join(', ')})';
}
