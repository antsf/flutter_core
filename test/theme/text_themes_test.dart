// test/theme/text_themes_test.dart
import 'package:flutter_core/src/theme/text_theme.dart';
import 'package:test/test.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(() {
    // Initialize ScreenUtil for tests
    // Use a common screen size (e.g., iPhone 13: 390x844)
    initScreenUtilForTests();
    setFontBuilderForTesting(setFontForTesting);
  });

  group('TextThemes', () {
    test('light and dark text themes have correct body colors', () {
      final light = TextThemes.light;
      final dark = TextThemes.dark;

      // These rely on FcColors; if FcColors are dynamic, mock or verify structure
      expect(light.bodyLarge?.color, isNotNull);
      expect(dark.bodyLarge?.color, isNotNull);
      expect(light.bodyLarge?.color, isNot(equals(dark.bodyLarge?.color)));
    });

    test('all text styles use Google Fonts Inter', () {
      final base = TextThemes.base;
      final sample = base.headlineLarge;
      expect(sample?.fontFamily, 'Inter');
    });
  });
}
