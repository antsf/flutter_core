import 'dart:convert';

extension StringX on String {
  /// true if null OR empty OR only white-space
  bool get isNullOrEmpty => trim().isEmpty;

  /// true if not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Parse JSON string → Map / List
  dynamic get jsonDecode => json.decode(this);

  /// Capitalize first letter
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalize first letter of every word.
  String get capitalizeWords {
    if (isEmpty) return this;
    return splitMapJoin(
      RegExp(r'\S+'),
      onMatch: (m) => m[0]![0].toUpperCase() + m[0]!.substring(1).toLowerCase(),
    );
  }

  /// Remove all white-space (including tabs, new-lines)
  String get removeAllWhitespace => replaceAll(RegExp(r'\s+'), '');
}
