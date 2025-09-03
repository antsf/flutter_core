import 'dart:convert';

/// Extension methods on [String] for common utility operations.
extension StringExt on String {
  /// Masks the email address, leaving the first and last characters of the local part visible.
  ///
  /// For example, `john.doe@example.com` becomes `jxxx@example.com`.
  String maskEmail() {
    if (isEmpty) return this;

    // Split the email into local part and domain
    final parts = split('@');
    if (parts.length != 2) return this;

    // Mask the local part, leaving the first and last characters visible
    final localPart = parts[0];
    final maskedLocalPart = localPart.length > 2
        ? '${localPart.substring(0, 1)}xxx${localPart.substring(localPart.length - 1)}'
        : 'xxx';

    return '$maskedLocalPart@${parts[1]}';
  }

  /// Masks a phone number, leaving only the last 3 digits visible.
  ///
  /// For example, `081234567890` becomes `xxxxxxxxxxx7890`.
  String maskPhoneNumber() {
    if (isEmpty) return this;

    // Mask all but the last 3 digits
    final maskedPhoneNumber = length > 3
        ? substring(0, length - 3).replaceAll(RegExp(r'\d'), 'x') +
            substring(length - 3)
        : replaceAll(RegExp(r'\d'), 'x');

    return maskedPhoneNumber;
  }

  /// Formats a phone number for the Indonesian locale, adding '62' as the country code
  /// and spaces for readability.
  ///
  /// For example, `081234567890` becomes `62 812 3456 7890`.
  String? formatPhoneNumber({bool useHyphen = false}) {
    // Remove all non-digit characters
    final digits = replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return this;

    // Ensure the phone number starts with '62'
    String formatted = digits;
    if (formatted.startsWith('0')) {
      formatted = '62${formatted.substring(1)}';
    } else if (!formatted.startsWith('62')) {
      formatted = '62$formatted';
    }

    // Determine the separator based on the `useHyphen` flag
    final separator = useHyphen ? '-' : ' ';

    // Format as '62 812 3456 7810' or '62-812-3456-7810'
    if (formatted.length >= 12) {
      return '${formatted.substring(0, 2)}$separator'
          '${formatted.substring(2, 5)}$separator'
          '${formatted.substring(5, 9)}$separator'
          '${formatted.substring(9, 13)}'
          '${formatted.length > 13 ? formatted.substring(13) : ''}';
    } else if (formatted.length >= 9) {
      return '${formatted.substring(0, 2)}$separator'
          '${formatted.substring(2, 5)}$separator'
          '${formatted.substring(5, 9)}'
          '${formatted.length > 9 ? '$separator${formatted.substring(9)}' : ''}';
    } else {
      return formatted;
    }
  }

  /// Parses a JSON string into a Dart `Map` or `List`.
  ///
  /// Throws a `FormatException` if the string is not valid JSON.
  dynamic get jsonDecode => json.decode(this);

  /// Capitalizes the first letter of the string.
  ///
  /// For example, `hello` becomes `Hello`.
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalizes the first letter of every word in the string.
  ///
  /// For example, `hello world` becomes `Hello World`.
  String get capitalizeWords {
    if (isEmpty) return this;
    return splitMapJoin(
      RegExp(r'\S+'),
      onMatch: (m) => m[0]![0].toUpperCase() + m[0]!.substring(1).toLowerCase(),
    );
  }

  /// Removes all whitespace characters (spaces, tabs, new-lines) from the string.
  String get removeAllWhitespace => replaceAll(RegExp(r'\s+'), '');
}

/// Extension methods on a nullable [String?] for convenience.
extension StringNullExt on String? {
  /// Converts a phone number string to the Indonesian format, starting with '62'.
  /// Returns an empty string if the input is `null`.
  ///
  /// For example, `0812...` or `812...` becomes `62812...`.
  String toPhoneNumber62() {
    // Remove all non-digit characters
    final digits = this?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.isEmpty) return '';

    // Ensure the phone number starts with '62'
    String formatted = digits;
    if (formatted.startsWith('0')) {
      formatted = '62${formatted.substring(1)}';
    } else if (!formatted.startsWith('62')) {
      formatted = '62$formatted';
    }

    return formatted;
  }

  /// Checks if a string is `null` or empty.
  bool get isNullOrEmpty => this == null || this?.isEmpty == true;

  /// Checks if a string is not `null` and not empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}

// A simple main function to demonstrate the usage.
// void main() {
//   // Demonstrate StringExt
//   print('StringExt:');
//   final email = 'example.user@email.com';
//   final phone = '081234567890';
//   print('  Masked Email: ${email.maskEmail()}');
//   print('  Masked Phone: ${phone.maskPhoneNumber()}');
//   print('  Formatted Phone: ${phone.formatPhoneNumber()}');
//   print(
//       '  Formatted Phone (Hyphenated): ${phone.formatPhoneNumber(useHyphen: true)}');
//   print('  Capitalize: ${"hello world".capitalize}');
//   print('  Capitalize Words: ${"hello world".capitalizeWords}');
//   print('  Remove Whitespace: ${"hello world".removeAllWhitespace}');

//   // Demonstrate StringNullExt
//   print('\nStringNullExt:');
//   String? nullableString = null;
//   String? emptyString = '';
//   String? filledString = '  hello ';
//   print('  isNullOrEmpty (null): ${nullableString.isNullOrEmpty}');
//   print('  isNotNullOrEmpty (null): ${nullableString.isNotNullOrEmpty}');
//   print('  isNullOrEmpty (""): ${emptyString.isNullOrEmpty}');
//   print('  isNotNullOrEmpty (""): ${emptyString.isNotNullOrEmpty}');
//   print('  isNullOrEmpty ("  "): ${"  ".isNullOrEmpty}');
//   print('  isNotNullOrEmpty ("  "): ${"  ".isNotNullOrEmpty}');
//   print(
//       '  toPhoneNumber62 ("081234567890"): ${"081234567890".toPhoneNumber62()}');
//   print(
//       '  toPhoneNumber62 ("81234567890"): ${"81234567890".toPhoneNumber62()}');
// }
