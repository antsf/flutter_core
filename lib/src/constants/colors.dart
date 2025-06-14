/// App color palette and color utility methods for Flutter Core.
library fc_colors;

import 'package:flutter/material.dart';

/// App color palette
class FcColors {
  FcColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryContainer = Color(0xFFBBDEFB);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF0D47A1);

  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryContainer = Color(0xFFC8E6C9);
  static const Color onSecondary = Colors.white;
  static const Color onSecondaryContainer = Color(0xFF1B5E20);

  // Tertiary Colors
  static const Color tertiary = Color(0xFFFF9800);
  static const Color tertiaryLight = Color(0xFFFFB74D);
  static const Color tertiaryDark = Color(0xFFF57C00);
  static const Color tertiaryContainer = Color(0xFFFFE0B2);
  static const Color onTertiary = Colors.black;
  static const Color onTertiaryContainer = Color(0xFFE65100);

  // Error Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onError = Colors.white;
  static const Color onErrorContainer = Color(0xFFB71C1C);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEEEEEE);
  static const Color outline = Color(0xFFBDBDBD);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // Text Colors
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);
  static const Color tertiaryText = Color(0xFF9E9E9E);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF424242);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  static const Color disabled = Color(0xFFBDBDBD);

  // Gradient Colors
  static const List<Color> primaryGradient = [primary, primaryDark];
  static const List<Color> secondaryGradient = [secondary, secondaryDark];
  static const List<Color> tertiaryGradient = [tertiary, tertiaryDark];
  static const List<Color> errorGradient = [error, errorDark];
  static const List<Color> successGradient = [success, Color(0xFF2E7D32)];
  static const List<Color> warningGradient = [warning, Color(0xFFFFA000)];
  static const List<Color> infoGradient = [info, Color(0xFF1565C0)];

  /// Transparent color constant.
  static const Color transparent = Colors.transparent;

  // Color Utilities
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color blend(Color color1, Color color2, [double ratio = 0.5]) {
    assert(ratio >= 0 && ratio <= 1);
    return Color.lerp(color1, color2, ratio)!;
  }

  // Color Themes
  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        background: background,
        onBackground: onBackground,
        surface: surface,
        onSurface: onSurface,
        surfaceVariant: surfaceVariant,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      );

  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryLight,
        onPrimary: onPrimary,
        primaryContainer: primaryDark,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondaryLight,
        onSecondary: onSecondary,
        secondaryContainer: secondaryDark,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiaryLight,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryDark,
        onTertiaryContainer: onTertiaryContainer,
        error: errorLight,
        onError: onError,
        errorContainer: errorDark,
        onErrorContainer: onErrorContainer,
        background: Color(0xFF121212),
        onBackground: Colors.white,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
        surfaceVariant: Color(0xFF2C2C2C),
        onSurfaceVariant: Colors.white,
        outline: Color(0xFF424242),
        outlineVariant: Color(0xFF616161),
      );
}
