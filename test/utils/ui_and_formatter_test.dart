import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the files provided by the user (assuming they are in the current library scope)
// We will rename the file to avoid conflicts in a real project structure, but for this context,
// we rely on the user providing the classes in the context.

// Mocking external dependencies used by UiHelper:
// 1. kPadding: A constant base unit for spacing.
const double kPadding = 10.0;

// 2. Mocking the BoxShadow extension (Colors.black.withValues)
extension MockColorExtension on Color {
  Color withValues({double? alpha}) {
    if (this == Colors.black && alpha == 0.1) {
      // Return a predictable color for testing the shadow's color property
      return const Color(
          0x19000000); // 0x19 is 10% of 0xFF (25.5), 0x19 is close enough to represent 10%
    }
    return this;
  }
}

// 3. Mocking the flutter_screenutil extensions (.w and .h)
// These extensions usually return the number scaled by screen size.
// For testing, we mock them to simply return the original value * 2 to verify they are called.
extension MockScreenUtil on num {
  double get w => (this * 2).toDouble();
  double get h => (this * 3).toDouble();
}

// 4. Mocking the .cornerRadius extension (assuming it converts the value to Radius.circular)
extension MockUiExt on num {
  Radius get cornerRadius => Radius.circular(toDouble());
}

// --- UiHelper START ---

/// A utility class providing helper methods and constants for building UI.
class UiHelper {
  UiHelper._();

  static final BoxShadow shadow = BoxShadow(
    color: Colors.black.withValues(alpha: .1),
    offset: const Offset(0, 6),
    blurRadius: 6.0,
  );

  static Widget spacing({double? width, double? height}) {
    assert(width == null || width >= 0, 'Width must be non-negative');
    assert(height == null || height >= 0, 'Height must be non-negative');
    return SizedBox(
      width: kPadding * (width ?? 0),
      height: kPadding * (height ?? 0),
    );
  }

  static EdgeInsets inset(
      double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(
      (kPadding * left).w,
      (kPadding * top).h,
      (kPadding * right).w,
      (kPadding * bottom).h,
    );
  }

  static EdgeInsetsGeometry insetOn(
      {double? left, double? top, double? right, double? bottom}) {
    return EdgeInsets.only(
      left: (kPadding * (left ?? 0)).w,
      top: (kPadding * (top ?? 0)).h,
      right: (kPadding * (right ?? 0)).w,
      bottom: (kPadding * (bottom ?? 0)).h,
    );
  }

  static EdgeInsetsGeometry insetAxis({double? x, double? y}) {
    return EdgeInsets.symmetric(
      horizontal: (kPadding * (x ?? 0)).w,
      vertical: (kPadding * (y ?? 0)).h,
    );
  }

  static EdgeInsetsGeometry insetZero() => EdgeInsets.zero;

  static BorderRadius radiusOn({
    double? topLeft,
    double? topRight,
    double? bottomRight,
    double? bottomLeft,
  }) {
    return BorderRadius.only(
      topLeft: (topLeft ?? 0).cornerRadius,
      topRight: (topRight ?? 0).cornerRadius,
      bottomLeft: (bottomLeft ?? 0).cornerRadius,
      bottomRight: (bottomRight ?? 0).cornerRadius,
    );
  }

  static VisualDensity visualDensity({double? x, double? y}) {
    return VisualDensity(horizontal: x ?? -4.0, vertical: y ?? -4.0);
  }
}

// --- Formatter START ---

class ThousandsFormatter extends TextInputFormatter {
  ThousandsFormatter({this.allowNegative = false});

  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Note: The original code's `allowNegative` handling seems incomplete as it
    // always calls `value.abs()` then prepends the sign. We'll test the provided logic.
    final text = newValue.text.replaceAll('.', '');
    if (text.isEmpty) {
      return newValue;
    }

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

class PhoneFormatter extends TextInputFormatter {
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

// --- UNIT TESTS ---

void main() {
  group('UiHelper', () {
    test('shadow constant is correctly defined', () {
      final shadow = UiHelper.shadow;
      // Using the mocked color value (0x19000000)
      expect(shadow.color, const Color(0x19000000).withValues(alpha: .1));
      expect(shadow.offset, const Offset(0, 6));
      expect(shadow.blurRadius, 6.0);
    });

    group('spacing', () {
      test('returns correct width when only width is provided', () {
        final spacingWidget = UiHelper.spacing(width: 2.5);
        expect(spacingWidget, isA<SizedBox>());
        expect((spacingWidget as SizedBox).width, kPadding * 2.5);
        expect(spacingWidget.height, 0);
      });

      test('returns correct height when only height is provided', () {
        final spacingWidget = UiHelper.spacing(height: 1);
        expect((spacingWidget as SizedBox).width, 0);
        expect(spacingWidget.height, kPadding * 1);
      });

      test('returns zero sized box when no arguments are provided', () {
        final spacingWidget = UiHelper.spacing();
        expect((spacingWidget as SizedBox).width, 0);
        expect(spacingWidget.height, 0);
      });
    });

    group('inset', () {
      test('returns correct EdgeInsets with mocked screenutil scaling', () {
        // kPadding = 10.0
        // .w extension mocks: value * 2
        // .h extension mocks: value * 3
        final insets = UiHelper.inset(1, 2, 3, 4);

        // (10 * 1).w = 20.0
        // (10 * 2).h = 60.0
        // (10 * 3).w = 60.0
        // (10 * 4).h = 120.0
        expect(insets.left, 20.0);
        expect(insets.top, 60.0);
        expect(insets.right, 60.0);
        expect(insets.bottom, 120.0);
      });
    });

    group('insetOn', () {
      test('returns correct EdgeInsets.only for provided sides', () {
        final insets = UiHelper.insetOn(left: 1, bottom: 2);
        // (10 * 1).w = 20.0
        // (10 * 2).h = 60.0
        expect(insets, isA<EdgeInsets>());
        expect((insets as EdgeInsets).left, 20.0);
        expect(insets.bottom, 60.0);
        expect(insets.right, 0.0);
        expect(insets.top, 0.0);
      });
    });

    group('insetAxis', () {
      test('returns correct symmetric EdgeInsets', () {
        final insets = UiHelper.insetAxis(x: 1, y: 0.5);
        // (10 * 1).w = 20.0
        // (10 * 0.5).h = 15.0
        expect(insets, isA<EdgeInsets>());
        expect((insets as EdgeInsets).horizontal, 40.0);
        expect(insets.vertical, 30.0);
      });
    });

    test('insetZero returns EdgeInsets.zero', () {
      expect(UiHelper.insetZero(), EdgeInsets.zero);
    });

    group('radiusOn', () {
      test('returns correct BorderRadius.only using cornerRadius extension',
          () {
        final radius = UiHelper.radiusOn(
          topLeft: 5,
          bottomRight: 10,
        );
        // .cornerRadius mock returns Radius.circular(value)
        expect(radius, isA<BorderRadius>());
        expect(radius.topLeft, const Radius.circular(5.0));
        expect(radius.bottomRight, const Radius.circular(10.0));
        expect(radius.topRight, Radius.zero);
        expect(radius.bottomLeft, Radius.zero);
      });
    });

    group('visualDensity', () {
      test('returns default VisualDensity when no values are provided', () {
        final density = UiHelper.visualDensity();
        expect(density.horizontal, -4.0);
        expect(density.vertical, -4.0);
      });

      test('returns specified VisualDensity when values are provided', () {
        final density = UiHelper.visualDensity(x: 1.5, y: -2.0);
        expect(density.horizontal, 1.5);
        expect(density.vertical, -2.0);
      });
    });
  });

  group('TextInputFormatters', () {
    // Helper to simulate the TextEditValue update
    TextEditingValue format(TextInputFormatter formatter, String text) {
      return formatter.formatEditUpdate(
        const TextEditingValue(text: ''), // oldValue is usually irrelevant here
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      );
    }

    group('ThousandsFormatter', () {
      final formatter = ThousandsFormatter(allowNegative: true);

      test('formats large positive number correctly with dots', () {
        final result = format(formatter, '1234567890');
        expect(result.text, '1.234.567.890');
        expect(result.selection.end, result.text.length);
      });

      test('formats small number correctly (no separators needed)', () {
        final result = format(formatter, '999');
        expect(result.text, '999');
      });

      test('formats number at the threshold', () {
        final result = format(formatter, '1000');
        expect(result.text, '1.000');
      });

      test('removes existing separators from input', () {
        final result = format(formatter, '1.234.567');
        expect(result.text, '1.234.567');
      });

      test('returns empty string if input is empty', () {
        final result = format(formatter, '');
        expect(result.text, '');
      });

      test(
          'handles invalid input by returning old value (not fully testable, but verifies parse failure)',
          () {
        // Since we mock oldValue as empty, we verify it returns the empty string or the last valid state.
        final result = format(formatter, '1a234');
        expect(result.text, ''); // Should return oldValue, which is ''
      });

      test('formats negative number correctly', () {
        final result = format(formatter, '-12345');
        expect(result.text, '-12.345');
      });
    });

    group('PhoneFormatter', () {
      final formatter = PhoneFormatter();

      test('formats 12-digit phone number correctly', () {
        final result = format(formatter, '81234567890');
        expect(result.text, '812 3456 7890');
      });

      test('formats partial input correctly', () {
        final result = format(formatter, '812345');
        expect(result.text, '812 345');
      });

      test('strips non-digits from input', () {
        final result = format(formatter, '812-345-67x890');
        expect(result.text, '812 3456 7890');
      });

      test('returns original value for short input', () {
        final result = format(formatter, '123');
        expect(result.text, '123');
      });
    });

    group('CreditCardFormatter', () {
      final formatter = CreditCardFormatter();

      test('formats 16-digit card number correctly', () {
        final result = format(formatter, '1234567890123456');
        expect(result.text, '1234 5678 9012 3456');
      });

      test('formats partial input correctly', () {
        final result = format(formatter, '1234567');
        expect(result.text, '1234 567');
      });

      test('strips non-digits from input', () {
        final result = format(formatter, '1234-5678-9012-3456');
        expect(result.text, '1234 5678 9012 3456');
      });

      test('returns original value for short input', () {
        final result = format(formatter, '1234');
        expect(result.text, '1234');
      });
    });
  });
}
