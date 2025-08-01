extension NullableX<T> on T? {
  /// Run block if value is NOT null
  R? let<R>(R Function(T) block) => this == null ? null : block(this!);

  /// Provide default when null
  T or(T defaultValue) => this ?? defaultValue;

  /// true if value is null
  bool get isNull => this == null;

  /// true if value is NOT null
  bool get isNotNull => this != null;
}
