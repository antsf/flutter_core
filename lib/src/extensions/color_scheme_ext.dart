import 'package:flutter/material.dart';
import 'package:flutter_core/src/constants/colors.dart' show FcColors;
import 'package:flutter_core/src/extensions/ui_ext.dart';

extension ColorContextExtensions on BuildContext {
  ColorScheme get colorScheme => theme.colorScheme;
  Color get primaryColor => colorScheme.primary;
  // Color get primaryLightColor => colorScheme.primaryLight;
  // Color get primaryDarkColor => colorScheme.primaryDark;
  Color get primaryContainerColor => colorScheme.primaryContainer;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get onPrimaryContainerColor => colorScheme.onPrimaryContainer;

  Color get secondaryColor => colorScheme.secondary;
  // Color get secondaryLightColor => colorScheme.secondaryLight;
  // Color get secondaryDarkColor => colorScheme.secondaryDark;
  Color get secondaryContainerColor => colorScheme.secondaryContainer;
  Color get onSecondaryColor => colorScheme.onSecondary;
  Color get onSecondaryContainerColor => colorScheme.onSecondaryContainer;

  Color get tertiaryColor => colorScheme.tertiary;
  // Color get tertiaryLightColor => colorScheme.tertiaryLight;
  // Color get tertiaryDarkColor => colorScheme.tertiaryDark;
  Color get tertiaryContainerColor => colorScheme.tertiaryContainer;
  Color get onTertiaryColor => colorScheme.onTertiary;
  Color get onTertiaryContainerColor => colorScheme.onTertiaryContainer;

  Color get errorColor => colorScheme.error;
  // Color get errorLightColor => colorScheme.errorLight;
  // Color get errorDarkColor => colorScheme.errorDark;
  Color get errorContainerColor => colorScheme.errorContainer;
  Color get onErrorColor => colorScheme.onError;
  Color get onErrorContainerColor => colorScheme.onErrorContainer;

  Color get surfaceContainerColor => colorScheme.surfaceContainer;
  Color get surfaceColor => colorScheme.surface;
  Color get outlineColor => colorScheme.outline;
  Color get outlineVariantColor => colorScheme.outlineVariant;

  // Color get primaryTextColor => colorScheme.primaryText;
  // Color get secondaryTextColor => colorScheme.secondaryText;
  // Color get tertiaryTextColor => colorScheme.tertiaryText;
  // Color get onBackgroundColor => colorScheme.onBackground;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get onSurfaceVariantColor => colorScheme.onSurfaceVariant;

  Color get successColor => FcColors.success;
  Color get warningColor => FcColors.warning;
  Color get infoColor => FcColors.info;
  Color get disabledColor => FcColors.disabled;

  Color get transparentColor => FcColors.transparent;

  Color withOpacity(Color color, double opacity) =>
      FcColors.withOpacity(color, opacity);
  Color darken(Color color, [double amount = 0.1]) =>
      FcColors.darken(color, amount);
  Color lighten(Color color, [double amount = 0.1]) =>
      FcColors.lighten(color, amount);
  Color blend(Color color1, Color color2, [double ratio = 0.5]) =>
      FcColors.blend(color1, color2, ratio);
}
