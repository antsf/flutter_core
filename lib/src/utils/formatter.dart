import 'package:flutter/services.dart';

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
    final text = newValue.text.replaceAll('.', '');
    if (text.isEmpty) {
      return newValue;
    }

    // Attempt to parse the text as an integer
    final intValue = int.tryParse(text);
    if (intValue == null) {
      return oldValue;
    }

    final formatted = _formatNumber(intValue);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Formats the integer with thousand separators.
  String _formatNumber(int value) {
    final str = value.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return (value < 0 ? '-' : '') + buffer.toString();
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
      if (i == 3 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    final text = buffer.toString();
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
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

    final text = buffer.toString();
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// A simple main function to demonstrate the usage.
// void main() {
//   // This cannot be run directly in a main function as TextInputFormatter
//   // is designed to be used with a TextFormField, but this illustrates the purpose.
//   print('This file contains Flutter TextInputFormatters.');
//   print('You can use them with a `TextFormField` or `TextField`.');
//   print('Example: `TextFormField(inputFormatters: [ThousandsFormatter()])`');
// }
