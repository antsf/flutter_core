// test/theme/theme_provider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import '../mocks/mock_local_storage.dart';
import '../test_helpers.dart';

void main() {
  late MockLocalStorage mockStorage;
  late ThemeProvider provider;

  setUp(() {
    ThemeProvider.reset(); // 🔥 Critical: reset singleton

    initScreenUtilForTests();
    setFontBuilderForTesting(setFontForTesting);

    mockStorage = MockLocalStorage();
    registerFallbackValue('any_string');

    when(() => mockStorage.get<bool>(any(), any()))
        .thenAnswer((_) async => null);
    when(() => mockStorage.get<String>(any(), any()))
        .thenAnswer((_) async => null);
    when(() => mockStorage.set<bool>(any(), any(), any()))
        .thenAnswer((_) async => true);
    when(() => mockStorage.set<String>(any(), any(), any()))
        .thenAnswer((_) async => true);

    ThemeProvider.localStorage = mockStorage;
    provider = ThemeProvider.instance;
  });

  test('initial theme is light', () {
    expect(provider.currentTheme.brightness, Brightness.light);
    expect(provider.isDarkMode, isFalse);
  });

  test('toggleTheme switches to dark and saves', () async {
    await provider.toggleTheme();
    expect(provider.isDarkMode, isTrue);
    expect(provider.currentTheme.brightness, Brightness.dark);

    verify(() => mockStorage.set<bool>(
        ThemeProvider.themeBoxName, ThemeProvider.themeKey, true)).called(1);
    verify(() => mockStorage.set<String>(any(), any(), any())).called(1);
  });

  test('configure sets custom dark theme', () async {
    // Use a DARK color scheme for dark theme
    final customDark = AppTheme.defaultDarkTheme.copyWith(
      colorScheme: ColorSchemes.darkGreen, // ✅ dark scheme
    );

    ThemeProvider.configure(darkTheme: customDark);

    // Switch to dark mode to activate it
    await ThemeProvider.instance.setThemeMode(true);

    expect(
      ThemeProvider.instance.currentTheme.colorScheme.primary,
      ColorSchemes.darkGreen.primary,
    );
  });

  test('loadThemeMode loads dark mode from storage', () async {
    when(() => mockStorage.get<bool>(
            ThemeProvider.themeBoxName, ThemeProvider.themeKey))
        .thenAnswer((_) async => true);
    when(() => mockStorage.get<String>(any(), any()))
        .thenAnswer((_) async => 'default');

    await provider.loadThemeMode();

    expect(provider.isDarkMode, isTrue);
    expect(provider.currentTheme.brightness, Brightness.dark);
  });
}
