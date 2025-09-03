/// Additional color schemes for the app, including blue, green, purple, and more.
library color_schemes;

import 'package:flutter/material.dart';

/// Additional color schemes for the app
class ColorSchemes {
  ColorSchemes._();

  /// Blue color scheme
  static ColorScheme get blueScheme => const ColorScheme.light(
        primary: Color(0xFF1976D2),
        secondary: Color(0xFF2196F3),
        error: Color(0xFFE53935),
        surface: Colors.white,
        surfaceContainer: Color(0xFFF5F5F5),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
      );

  /// Green color scheme
  static ColorScheme get greenScheme => const ColorScheme.light(
        primary: Color(0xFF2E7D32),
        secondary: Color(0xFF4CAF50),
        error: Color(0xFFE53935),
        surface: Colors.white,
        surfaceContainer: Color(0xFFF5F5F5),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
      );

  /// Purple color scheme
  static ColorScheme get purple => const ColorScheme.light(
        primary: Color(0xFF6A1B9A),
        secondary: Color(0xFF9C27B0),
        surface: Colors.white,
        surfaceContainer: Color(0xFFF5F5F5),
        error: Color(0xFFE53935),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
      );

  /// Orange color scheme
  static ColorScheme get orange => const ColorScheme.light(
        primary: Color(0xFFE65100),
        secondary: Color(0xFFFF9800),
        surface: Colors.white,
        surfaceContainer: Color(0xFFF5F5F5),
        error: Color(0xFFE53935),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
      );

  /// Dark blue color scheme
  static ColorScheme get darkBlue => const ColorScheme.dark(
        primary: Color(0xFF1565C0),
        secondary: Color(0xFF1976D2),
        surface: Color(0xFF121212),
        surfaceContainer: Color(0xFF000000),
        error: Color(0xFFE53935),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white70,
        onError: Colors.white,
      );

  /// Dark green color scheme
  static ColorScheme get darkGreen => const ColorScheme.dark(
        primary: Color(0xFF1B5E20),
        secondary: Color(0xFF2E7D32),
        surface: Color(0xFF121212),
        surfaceContainer: Color(0xFF000000),
        error: Color(0xFFE53935),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white70,
        onError: Colors.white,
      );
}
