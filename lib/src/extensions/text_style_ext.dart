/// Provides extension methods on [TextStyle] to simplify common text styling
/// modifications and apply responsive font sizing.
///
/// These extensions allow for a fluent interface when customizing text styles.
///
/// Example:
/// ```dart
/// Text(
///   'Hello World',
///   style: TextStyle().bold.italic.fontSize(16).withColor(Colors.blue).underline,
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

  /// Returns a new [TextStyle] with [TextDecoration.underline].
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// Returns a new [TextStyle] with [TextDecoration.lineThrough] (strikethrough).
  ///
  /// This property replaces the invalid request for `textAlign.center`, as
  /// alignment is a property of the Text widget, not the TextStyle.
  TextStyle get strikethrough =>
      copyWith(decoration: TextDecoration.lineThrough);

  /// Returns a new [TextStyle] with the specified font [value] scaled by [ScreenUtil.sp].
  TextStyle fontSize(double value) => copyWith(fontSize: value.sp);

  /// Returns a new [TextStyle] with the specified line [value] (line spacing).
  TextStyle heightSpace(double value) => copyWith(height: value);

  /// Returns a new [TextStyle] with the specified letter [value].
  TextStyle letterSpace(double value) => copyWith(letterSpacing: value);

  /// Returns a new [TextStyle] with the specified [color].
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Returns a new [TextStyle] with the specified [TextOverflow].
  TextStyle withOverflow([TextOverflow overflow = TextOverflow.ellipsis]) =>
      copyWith(overflow: overflow);
}
