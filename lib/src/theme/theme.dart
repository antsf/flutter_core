/// Theme configurations and helpers for the Flutter Core package.
library theme;

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

  /// Creates a base theme
  static ThemeData _baseTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
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
      _baseTheme(Brightness.light).copyWith(
        textTheme: TextThemes.light,
        colorScheme: lightColorScheme,
      );

  /// Creates the default dark theme
  static ThemeData get defaultDarkTheme => _baseTheme(Brightness.dark).copyWith(
        textTheme: TextThemes.dark,
        colorScheme: darkColorScheme,
      );
}
