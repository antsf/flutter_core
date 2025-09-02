import 'dart:convert' show JsonEncoder;

extension MapX<K, V> on Map<K, V>? {
  /// true if null OR empty
  bool get isNullOrEmpty => this == null || this?.isEmpty == true;

  /// true if not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Get value or null safely
  V? get(K key) => this?[key];

  /// Pretty-print with indent
  String pretty() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(this);
  }
}
