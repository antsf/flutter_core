// test/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_core/src/theme/text_theme.dart';
import 'package:flutter_core/src/theme/theme.dart';
import 'package:test/test.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(() {
    // Initialize ScreenUtil for tests
    // Use a common screen size (e.g., iPhone 13: 390x844)
    initScreenUtilForTests();
    setFontBuilderForTesting(setFontForTesting);
  });

  group('AppTheme', () {
    test('defaultLightTheme uses light color scheme and light text theme', () {
      final theme = AppTheme.defaultLightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
      // Verify it uses expected colors (e.g., primary from FcColors)
      expect(theme.colorScheme.primary.toARGB32(),
          0xFF2196F3); // adjust if your FcColors differ
    });

    test('defaultDarkTheme uses dark color scheme and dark text theme', () {
      final theme = AppTheme.defaultDarkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('both themes use Material 3', () {
      expect(AppTheme.defaultLightTheme.useMaterial3, isTrue);
      expect(AppTheme.defaultDarkTheme.useMaterial3, isTrue);
    });
  });
}
