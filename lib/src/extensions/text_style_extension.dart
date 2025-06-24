/// Provides extension methods on [TextStyle] to simplify common text styling
/// modifications and apply responsive font sizing.
///
/// These extensions allow for a fluent interface when customizing text styles.
///
/// Example:
/// ```dart
/// Text(
///   'Hello World',
///   style: TextStyle().bold.italic.fontSize(16).withColor(Colors.blue),
/// );
/// ```
library text_style_extension;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Extension methods for [TextStyle] to enable fluent style modifications.
extension TextStyleExtension on TextStyle {
  /// Returns a new [TextStyle] with [FontWeight.bold].
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Returns a new [TextStyle] with [FontStyle.italic].
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// Returns a new [TextStyle] with the specified font [value] scaled by [ScreenUtil.sp].
  TextStyle fontSize(double value) => copyWith(fontSize: value.sp);

  /// Returns a new [TextStyle] with the specified line [value] (line spacing).
  TextStyle heightSpace(double value) => copyWith(height: value);

  /// Returns a new [TextStyle] with the specified letter [value].
  TextStyle letterSpace(double value) => copyWith(letterSpacing: value);

  /// Returns a new [TextStyle] with the specified [color].
  TextStyle withColor(Color color) => copyWith(color: color);
}
