// test/theme/color_schemes_test.dart
import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_core/src/theme/color_schemes.dart' show ColorSchemes;
import 'package:test/test.dart';

void main() {
  group('ColorSchemes', () {
    test('blueScheme has correct primary color', () {
      expect(ColorSchemes.blueScheme.primary.toARGB32(), 0xFF1976D2);
    });

    test('greenScheme is light by default', () {
      expect(ColorSchemes.greenScheme.brightness, Brightness.light);
    });

    test('darkGreen is dark', () {
      expect(ColorSchemes.darkGreen.brightness, Brightness.dark);
    });
  });
}
