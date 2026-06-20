import 'package:flutter/services.dart';
import 'package:flutter_core/src/utils/formatter.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _val(String text, int offset) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );

void main() {
  group('ThousandsFormatter', () {
    final f = ThousandsFormatter();

    test('formats with thousand separators (caret at end)', () {
      final r = f.formatEditUpdate(TextEditingValue.empty, _val('1000000', 7));
      expect(r.text, '1.000.000');
      expect(r.selection.baseOffset, 9);
    });

    test('keeps the caret next to a mid-string edit', () {
      // User had "1.000.000" with the caret after "1", then typed "5".
      final r = f.formatEditUpdate(
        _val('1.000.000', 1),
        _val('15.000.000', 2),
      );
      expect(r.text, '15.000.000');
      // Caret should sit right after the digit just typed ("5"), not at the end.
      expect(r.selection.baseOffset, 2);
    });
  });

  group('PhoneFormatter', () {
    final f = PhoneFormatter();

    test('formats with spaces', () {
      final r =
          f.formatEditUpdate(TextEditingValue.empty, _val('081234567890', 12));
      expect(r.text, '0812 3456 7890');
      expect(r.selection.baseOffset, 14);
    });

    test('keeps the caret on a mid-string edit', () {
      // Caret after the 2nd digit; 2 digits should remain before it.
      final r = f.formatEditUpdate(
        _val('0812 3456 7890', 2),
        _val('09812 3456 7890', 2),
      );
      expect(r.text, '0981 2345 6789 0');
      expect(_digitsBeforeCaret(r), 2);
    });
  });

  group('CreditCardFormatter', () {
    final f = CreditCardFormatter();

    test('groups in fours', () {
      final r = f.formatEditUpdate(
          TextEditingValue.empty, _val('1234567890123456', 16));
      expect(r.text, '1234 5678 9012 3456');
      expect(r.selection.baseOffset, 19);
    });

    test('keeps the caret on a mid-string edit', () {
      final r = f.formatEditUpdate(
        _val('1234 5678', 2),
        _val('19234 5678', 2),
      );
      expect(r.text, '1923 4567 8');
      expect(_digitsBeforeCaret(r), 2);
    });
  });
}

/// Number of digits before the caret in a formatted value.
int _digitsBeforeCaret(TextEditingValue v) {
  final end = v.selection.baseOffset;
  var n = 0;
  for (var i = 0; i < end; i++) {
    final c = v.text.codeUnitAt(i);
    if (c >= 0x30 && c <= 0x39) n++;
  }
  return n;
}
