/// Theme configurations and helpers for the Flutter Core package.
library;

import 'package:flutter/material.dart';
import 'text_theme.dart';
import '../constants/colors.dart';

/// Theme configurations
class AppTheme {
  AppTheme._();

  /// Light theme color scheme
  static ColorScheme get lightColorScheme => FcColors.lightColorScheme;

  /// Dark theme color scheme
  static ColorScheme get darkColorScheme => FcColors.darkColorScheme;

  /// Creates a base theme for the given [colorScheme].
  ///
  /// The [colorScheme] is passed directly to the [ThemeData] constructor so that
  /// scheme-derived defaults (scaffold background, app bar, etc.) are computed
  /// from it. Applying the scheme via `copyWith` afterwards would NOT recompute
  /// those derived colors, leaving them on the framework defaults.
  static ThemeData _baseTheme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        splashFactory: InkRipple.splashFactory,
        typography: Typography.material2021(),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      );

  /// Creates the default light theme
  static ThemeData get defaultLightTheme =>
      _baseTheme(lightColorScheme).copyWith(textTheme: TextThemes.light);

  /// Creates the default dark theme
  static ThemeData get defaultDarkTheme =>
      _baseTheme(darkColorScheme).copyWith(textTheme: TextThemes.dark);
}
