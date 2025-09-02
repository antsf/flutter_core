import 'package:flutter/material.dart';
import 'package:flutter_core/src/extensions/ui_ext.dart';

extension TextThemeExtensions on BuildContext {
  TextTheme get textTheme => theme.textTheme;
  TextStyle? get headlineLargeBold =>
      textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get headlineSmallBold =>
      textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get titleLargeBold =>
      textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get titleMediumBold =>
      textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get titleSmallBold =>
      textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get bodyLargeBold =>
      textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get bodyMediumBold =>
      textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get bodySmallBold =>
      textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get labelLargeBold =>
      textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get labelMediumBold =>
      textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get labelSmallBold =>
      textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get headlineLargeItalic =>
      textTheme.headlineLarge?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get headlineSmallItalic =>
      textTheme.headlineSmall?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get titleLargeItalic =>
      textTheme.titleLarge?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get titleMediumItalic =>
      textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get titleSmallItalic =>
      textTheme.titleSmall?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get bodyLargeItalic =>
      textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get bodyMediumItalic =>
      textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get bodySmallItalic =>
      textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get labelLargeItalic =>
      textTheme.labelLarge?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get labelMediumItalic =>
      textTheme.labelMedium?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get labelSmallItalic =>
      textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic);

  TextStyle? get headlineLarge => textTheme.headlineLarge;
  TextStyle? get headlineSmall => textTheme.headlineSmall;
  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get titleMedium => textTheme.titleMedium;
  TextStyle? get titleSmall => textTheme.titleSmall;
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodySmall => textTheme.bodySmall;
  TextStyle? get labelLarge => textTheme.labelLarge;
  TextStyle? get labelMedium => textTheme.labelMedium;
  TextStyle? get labelSmall => textTheme.labelSmall;
}
