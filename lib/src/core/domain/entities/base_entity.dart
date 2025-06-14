/// Base class for all domain entities
abstract class BaseEntity {
  const BaseEntity();

  /// Convert entity to JSON
  Map<String, dynamic> toJson();

  /// Create entity from JSON
  static T fromJson<T extends BaseEntity>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson() not implemented');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseEntity &&
          runtimeType == other.runtimeType &&
          toJson() == other.toJson();

  @override
  int get hashCode => toJson().hashCode;
}
