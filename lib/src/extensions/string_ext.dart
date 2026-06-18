import 'dart:convert';

/// Extension methods on [String] for common utility operations.
extension StringExt on String {
  /// Masks the email address, leaving the first character of the local part
  /// and the last 7 characters of the domain visible.
  ///
  /// Example: `john.doe@example.com` → `jxxxxxxx@xxxxple.com`
  String maskEmail() {
    if (isEmpty) return this;

    final parts = split('@');
    if (parts.length != 2) return this;

    final local = parts[0];
    final domain = parts[1];

    if (local.isEmpty || domain.isEmpty) return this;

    final maskedLocal = local[0] + ('x' * (local.length - 1));

    const keepLast = 7;
    final maskLen = domain.length - keepLast;
    final maskedDomain = (maskLen > 0 ? 'x' * maskLen : '') +
        domain.substring(domain.length - keepLast.clamp(0, domain.length));

    return '$maskedLocal@$maskedDomain';
  }

  /// Masks a phone number, leaving only the last 3 digits visible.
  ///
  /// Example: `081234567890` → `xxxxxxxxx890`
  String maskPhoneNumber() {
    if (isEmpty) return this;
    return length > 3
        ? substring(0, length - 3).replaceAll(RegExp(r'\d'), 'x') +
            substring(length - 3)
        : replaceAll(RegExp(r'\d'), 'x');
  }

  /// Formats a phone number to Indonesian format with country code `62`.
  ///
  /// Example: `081234567890` → `62 812 3456 7890`
  String? formatPhoneNumber({bool useHyphen = false}) {
    final digits = replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return this;

    String formatted = digits;
    if (formatted.startsWith('0')) {
      formatted = '62${formatted.substring(1)}';
    } else if (!formatted.startsWith('62')) {
      formatted = '62$formatted';
    }

    final sep = useHyphen ? '-' : ' ';

    if (formatted.length >= 12) {
      return '${formatted.substring(0, 2)}$sep'
          '${formatted.substring(2, 5)}$sep'
          '${formatted.substring(5, 9)}$sep'
          '${formatted.substring(9, 13)}'
          '${formatted.length > 13 ? formatted.substring(13) : ''}';
    } else if (formatted.length >= 9) {
      return '${formatted.substring(0, 2)}$sep'
          '${formatted.substring(2, 5)}$sep'
          '${formatted.substring(5, 9)}'
          '${formatted.length > 9 ? '$sep${formatted.substring(9)}' : ''}';
    } else {
      return formatted;
    }
  }

  /// Removes the `62` country code prefix, if present.
  String toRemove62() {
    if (startsWith('62')) return substring(2);
    return this;
  }

  /// Parses a JSON string into a Dart [Map] or [List].
  dynamic get jsonDecode => json.decode(this);

  /// Capitalizes the first letter. Example: `hello` → `Hello`.
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalizes the first letter of every word. Example: `hello world` → `Hello World`.
  String get capitalizeWords {
    if (isEmpty) return this;
    return splitMapJoin(
      RegExp(r'\S+'),
      onMatch: (m) => m[0]![0].toUpperCase() + m[0]!.substring(1).toLowerCase(),
    );
  }

  /// Removes all whitespace characters from the string.
  String get removeAllWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Returns `true` if the string is a valid email address.
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(this);

  /// Returns `true` if the string is a valid Indonesian phone number.
  ///
  /// Accepts formats starting with `0` or `62`, 10–13 digits total.
  bool get isValidIndonesianPhone {
    final digits = replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^(62|0)[0-9]{9,12}$').hasMatch(digits);
  }
}

/// Extension methods on nullable [String?] for convenience.
extension StringNullExt on String? {
  /// Converts to Indonesian phone format starting with `62`.
  /// Returns empty string if null.
  String toPhoneNumber62() {
    final digits = this?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.isEmpty) return '';

    String formatted = digits;
    if (formatted.startsWith('0')) {
      formatted = '62${formatted.substring(1)}';
    } else if (!formatted.startsWith('62')) {
      formatted = '62$formatted';
    }
    return formatted;
  }

  /// Returns `true` if the string is `null` or empty.
  bool get isNullOrEmpty => this == null || this?.isEmpty == true;

  /// Returns `true` if the string is not `null` and not empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
