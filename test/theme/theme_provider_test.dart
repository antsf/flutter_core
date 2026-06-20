// test/theme/theme_provider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_corekit/flutter_corekit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

void main() {
  // Needed for the shared_preferences mock method channel.
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ThemeProvider.reset();
    initScreenUtilForTests();
    setFontBuilderForTesting(setFontForTesting);
    provider = ThemeProvider.instance;
  });

  test('initial theme is light', () {
    expect(provider.currentTheme.brightness, Brightness.light);
    expect(provider.isDarkMode, isFalse);
  });

  test('toggleTheme switches to dark, persists, and reloads', () async {
    await provider.toggleTheme();
    expect(provider.isDarkMode, isTrue);
    expect(provider.currentTheme.brightness, Brightness.dark);

    // Round-trip: a fresh provider should load the persisted dark mode.
    ThemeProvider.reset();
    final reloaded = ThemeProvider.instance;
    await reloaded.loadThemeMode();
    expect(reloaded.isDarkMode, isTrue);
    expect(reloaded.currentTheme.brightness, Brightness.dark);
  });

  test('configure sets custom dark theme', () async {
    final customDark = AppTheme.defaultDarkTheme.copyWith(
      colorScheme: ColorSchemes.darkGreen,
    );

    ThemeProvider.configure(darkTheme: customDark);
    await ThemeProvider.instance.setThemeMode(true);

    expect(
      ThemeProvider.instance.currentTheme.colorScheme.primary,
      ColorSchemes.darkGreen.primary,
    );
  });

  test('loadThemeMode reads dark mode from storage', () async {
    SharedPreferences.setMockInitialValues({ThemeProvider.themeKey: true});
    ThemeProvider.reset();
    final p = ThemeProvider.instance;
    setFontBuilderForTesting(setFontForTesting);

    await p.loadThemeMode();

    expect(p.isDarkMode, isTrue);
    expect(p.currentTheme.brightness, Brightness.dark);
  });
}
