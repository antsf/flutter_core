import 'package:flutter/services.dart';

bool _isDigitCode(int c) => c >= 0x30 && c <= 0x39;

/// Counts digits (0-9) in [text] before [offset].
int _digitsBefore(String text, int offset) {
  final end = offset < 0 ? text.length : offset.clamp(0, text.length);
  var count = 0;
  for (var i = 0; i < end; i++) {
    if (_isDigitCode(text.codeUnitAt(i))) count++;
  }
  return count;
}

/// The offset in [formatted] just after [digitCount] digits — used to keep the
/// caret next to the same digit the user was editing, instead of jumping to the
/// end of the field.
int _offsetAfterDigits(String formatted, int digitCount) {
  if (digitCount <= 0) return 0;
  var seen = 0;
  for (var i = 0; i < formatted.length; i++) {
    if (_isDigitCode(formatted.codeUnitAt(i))) {
      seen++;
      if (seen == digitCount) return i + 1;
    }
  }
  return formatted.length;
}

TextEditingValue _withCaret(
  TextEditingValue newValue,
  String formatted,
) {
  final digitsBefore =
      _digitsBefore(newValue.text, newValue.selection.baseOffset);
  return TextEditingValue(
    text: formatted,
    selection: TextSelection.collapsed(
        offset: _offsetAfterDigits(formatted, digitsBefore)),
  );
}

/// Adds thousand separators while the user types.
///
/// For example: `1000000` becomes `1.000.000`.
class ThousandsFormatter extends TextInputFormatter {
  ThousandsFormatter({this.allowNegative = false});

  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow the field to be cleared.
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final negative = allowNegative && newValue.text.trimLeft().startsWith('-');

    // Operate on the raw digit string instead of parsing to `int`, so values
    // beyond the `int` range (≈19 digits) are still formatted rather than
    // reverting the field.
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      // Keep a lone "-" so the user can finish typing a negative number;
      // otherwise reject the (non-digit) input by reverting.
      return negative
          ? const TextEditingValue(
              text: '-', selection: TextSelection.collapsed(offset: 1))
          : oldValue;
    }
    // Drop leading zeros (keep a single "0").
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    return _withCaret(newValue, _formatDigits(digits, negative));
  }

  /// Groups a digit string with thousand separators, e.g. `1000000` → `1.000.000`.
  String _formatDigits(String digits, bool negative) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return (negative ? '-' : '') + buffer.toString();
  }
}

/// Formats a phone number with spaces.
///
/// For example: `081234567890` becomes `0812 3456 7890`.
class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      // Group in fours, e.g. "081234567890" -> "0812 3456 7890" (matches the
      // documented format; the previous `i == 3 || i == 7` produced "081 2345
      // 67890", which disagreed with the doc).
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    return _withCaret(newValue, buffer.toString());
  }
}

/// Formats a credit card number with spaces every four digits.
///
/// For example: `1234567890123456` becomes `1234 5678 9012 3456`.
class CreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    return _withCaret(newValue, buffer.toString());
  }
}
