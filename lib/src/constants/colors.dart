/// Defines the application's color palette, color utility methods, and color schemes.
///
/// This library provides a centralized place for managing all color-related
/// definitions used throughout the Flutter Core package and applications using it.
/// It includes named color constants, methods for color manipulation (like darken, lighten),
/// and pre-defined light and dark [ColorScheme]s.
library fc_colors;

import 'package:flutter/material.dart';

/// A collection of static color constants and utility methods for the application.
///
/// `FcColors` (Flutter Core Colors) provides a standardized palette based on Material Design
/// principles, including primary, secondary, tertiary, error, neutral, text, and status colors.
/// It also offers utility functions for color manipulation and pre-configured
/// [ColorScheme] objects for light and dark themes.
///
/// All members are static, so this class is not meant to be instantiated.
class FcColors {
  /// Private constructor to prevent instantiation.
  FcColors._();

  //region Primary Colors
  /// The main brand color, typically used for prominent UI elements.
  static const Color primary = Color(0xFF2196F3); // Blue 500
  /// A lighter shade of the primary color.
  static const Color primaryLight = Color(0xFF64B5F6); // Blue 300
  /// A darker shade of the primary color.
  static const Color primaryDark = Color(0xFF1976D2); // Blue 700
  /// A color used for elements needing less emphasis than [primary], often for backgrounds of primary-colored content.
  static const Color primaryContainer = Color(0xFFBBDEFB); // Blue 100
  /// A color that contrasts well with [primary], typically for text or icons on primary backgrounds.
  static const Color onPrimary = Colors.white;
  /// A color that contrasts well with [primaryContainer].
  static const Color onPrimaryContainer = Color(0xFF0D47A1); // Blue 900
  //endregion

  //region Secondary Colors
  /// An accent color, used for secondary actions and highlights.
  static const Color secondary = Color(0xFF4CAF50); // Green 500
  /// A lighter shade of the secondary color.
  static const Color secondaryLight = Color(0xFF81C784); // Green 300
  /// A darker shade of the secondary color.
  static const Color secondaryDark = Color(0xFF388E3C); // Green 700
  /// A color used for elements needing less emphasis than [secondary].
  static const Color secondaryContainer = Color(0xFFC8E6C9); // Green 100
  /// A color that contrasts well with [secondary].
  static const Color onSecondary = Colors.white;
  /// A color that contrasts well with [secondaryContainer].
  static const Color onSecondaryContainer = Color(0xFF1B5E20); // Green 900
  //endregion

  //region Tertiary Colors
  /// A tertiary accent color, used for elements like tags or highlights that need to stand out.
  static const Color tertiary = Color(0xFFFF9800); // Orange 500
  /// A lighter shade of the tertiary color.
  static const Color tertiaryLight = Color(0xFFFFB74D); // Orange 300
  /// A darker shade of the tertiary color.
  static const Color tertiaryDark = Color(0xFFF57C00); // Orange 700
  /// A color used for elements needing less emphasis than [tertiary].
  static const Color tertiaryContainer = Color(0xFFFFE0B2); // Orange 100
  /// A color that contrasts well with [tertiary].
  static const Color onTertiary = Colors.black;
  /// A color that contrasts well with [tertiaryContainer].
  static const Color onTertiaryContainer = Color(0xFFE65100); // Orange 900
  //endregion

  //region Error Colors
  /// Color used for indicating errors or dangerous actions.
  static const Color error = Color(0xFFD32F2F); // Red 700
  /// A lighter shade of the error color.
  static const Color errorLight = Color(0xFFEF5350); // Red 400
  /// A darker shade of the error color.
  static const Color errorDark = Color(0xFFC62828); // Red 800
  /// A color used for elements needing less emphasis than [error].
  static const Color errorContainer = Color(0xFFFFCDD2); // Red 100
  /// A color that contrasts well with [error].
  static const Color onError = Colors.white;
  /// A color that contrasts well with [errorContainer].
  static const Color onErrorContainer = Color(0xFFB71C1C); // Red 900
  //endregion

  //region Neutral Colors
  /// The default background color for the app.
  static const Color background = Color(0xFFFAFAFA); // Grey 50
  /// The color of surfaces like cards, dialogs, and sheets.
  static const Color surface = Colors.white;
  /// A variant of [surface] color, typically slightly different for visual hierarchy.
  static const Color surfaceVariant = Color(0xFFEEEEEE); // Grey 200
  /// Color used for outlines, borders, and dividers.
  static const Color outline = Color(0xFFBDBDBD); // Grey 400
  /// A variant of [outline] color, typically slightly different.
  static const Color outlineVariant = Color(0xFFE0E0E0); // Grey 300
  //endregion

  //region Text Colors
  /// The primary text color, used for main headings and body text.
  static const Color primaryText = Color(0xFF212121); // Grey 900
  /// Secondary text color, for less important text like subtitles or captions.
  static const Color secondaryText = Color(0xFF757575); // Grey 600
  /// Tertiary text color, for hints or disabled text.
  static const Color tertiaryText = Color(0xFF9E9E9E); // Grey 500
  /// Text color that contrasts with [background].
  static const Color onBackground = Color(0xFF212121); // Grey 900
  /// Text color that contrasts with [surface].
  static const Color onSurface = Color(0xFF212121); // Grey 900
  /// Text color that contrasts with [surfaceVariant].
  static const Color onSurfaceVariant = Color(0xFF424242); // Grey 800
  //endregion

  //region Status Colors
  /// Color indicating a successful operation or positive status.
  static const Color success = Color(0xFF4CAF50); // Green 500 (same as secondary)
  /// Color indicating a warning or potential issue.
  static const Color warning = Color(0xFFFFC107); // Amber 500
  /// Color for informational messages or neutral status.
  static const Color info = Color(0xFF2196F3); // Blue 500 (same as primary)
  /// Color for disabled elements or text.
  static const Color disabled = Color(0xFFBDBDBD); // Grey 400 (same as outline)
  //endregion

  //region Gradient Colors
  /// A gradient using [primary] and [primaryDark] colors.
  static const List<Color> primaryGradient = [primary, primaryDark];
  /// A gradient using [secondary] and [secondaryDark] colors.
  static const List<Color> secondaryGradient = [secondary, secondaryDark];
  /// A gradient using [tertiary] and [tertiaryDark] colors.
  static const List<Color> tertiaryGradient = [tertiary, tertiaryDark];
  /// A gradient using [error] and [errorDark] colors.
  static const List<Color> errorGradient = [error, errorDark];
  /// A gradient using [success] and a darker shade of green.
  static const List<Color> successGradient = [success, Color(0xFF2E7D32)]; // Green 800
  /// A gradient using [warning] and a darker shade of amber.
  static const List<Color> warningGradient = [warning, Color(0xFFFFA000)]; // Amber 700
  /// A gradient using [info] and a darker shade of blue.
  static const List<Color> infoGradient = [info, Color(0xFF1565C0)]; // Blue 800
  //endregion

  /// A fully transparent color.
  static const Color transparent = Colors.transparent;

  //region Color Utilities
  /// Returns the given [color] with the specified [opacity].
  ///
  /// [color]: The original color.
  /// [opacity]: The opacity value, ranging from 0.0 (fully transparent) to 1.0 (fully opaque).
  /// Returns a new [Color] instance with the applied opacity.
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Darkens the given [color] by a specified [amount].
  ///
  /// [color]: The color to darken.
  /// [amount]: The amount to darken, as a decimal between 0.0 and 1.0. Defaults to 0.1 (10%).
  /// Returns a new [Color] instance that is darker.
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Lightens the given [color] by a specified [amount].
  ///
  /// [color]: The color to lighten.
  /// [amount]: The amount to lighten, as a decimal between 0.0 and 1.0. Defaults to 0.1 (10%).
  /// Returns a new [Color] instance that is lighter.
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Blends two colors, [color1] and [color2], by a given [ratio].
  ///
  /// A [ratio] of 0.0 will return [color1], 0.5 will return a 50/50 blend,
  /// and 1.0 will return [color2].
  ///
  /// [color1]: The first color.
  /// [color2]: The second color.
  /// [ratio]: The blend ratio. Defaults to 0.5.
  /// Returns the blended [Color].
  static Color blend(Color color1, Color color2, [double ratio = 0.5]) {
    assert(ratio >= 0 && ratio <= 1, 'Ratio must be between 0.0 and 1.0');
    // Color.lerp can return null if both colors are null, but here they are not.
    return Color.lerp(color1, color2, ratio)!;
  }
  //endregion

  //region Color Schemes
  /// A pre-defined light [ColorScheme] based on the `FcColors` palette.
  ///
  /// This scheme is suitable for light-themed UIs and follows Material Design guidelines.
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
        // Inverse colors can be added if needed, e.g.,
        // inversePrimary: onPrimary,
        // inverseSurface: onSurface,
        // onInverseSurface: surface,
        // shadow: Colors.black, // Default shadow color
        // surfaceTint: primary, // Default surface tint color
      );

  /// A pre-defined dark [ColorScheme] based on the `FcColors` palette.
  ///
  /// This scheme is suitable for dark-themed UIs, using adjusted shades for better
  /// readability and visual appeal in dark environments.
  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryLight, // Lighter primary for dark theme
        onPrimary: onPrimary, // Text on primary usually stays the same or high contrast
        primaryContainer: primaryDark, // Darker container for dark theme
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondaryLight, // Lighter secondary
        onSecondary: onSecondary,
        secondaryContainer: secondaryDark, // Darker container
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiaryLight, // Lighter tertiary
        onTertiary: onTertiary, // Black text on light orange might need adjustment
        tertiaryContainer: tertiaryDark, // Darker container
        onTertiaryContainer: onTertiaryContainer,
        error: errorLight, // Lighter error
        onError: onError, // Text on error usually stays high contrast
        errorContainer: errorDark, // Darker container
        onErrorContainer: onErrorContainer,
        background: Color(0xFF121212), // Common dark theme background
        onBackground: Colors.white, // White text on dark background
        surface: Color(0xFF1E1E1E), // Slightly lighter surface for cards
        onSurface: Colors.white, // White text on surface
        surfaceVariant: Color(0xFF2C2C2C), // Variant surface
        onSurfaceVariant: Colors.white, // White text on surface variant
        outline: Color(0xFF424242), // Darker outline
        outlineVariant: Color(0xFF616161), // Darker outline variant
      );
  //endregion
}
