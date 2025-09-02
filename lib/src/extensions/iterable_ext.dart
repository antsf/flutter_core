extension IterableX<T> on Iterable<T>? {
  /// true if null OR empty
  bool get isNullOrEmpty => this == null || this?.isEmpty == true;

  /// true if not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Returns second element or null
  T? get second => (this?.length ?? 0) > 1 ? this?.elementAt(1) : null;

  /// Returns last element or null
  T? get lastOrNull => isNullOrEmpty ? null : this?.last;

  /// Returns first element matching test or null
  T? firstWhereOrNull(bool Function(T) test) {
    if (isNotNullOrEmpty) {
      for (final e in this!) {
        if (test(e)) return e;
      }
    }
    return null;
  }
}
