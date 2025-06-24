import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/default.dart'; // kPadding
import '../extensions/ui_extensions.dart'; // .cornerRadius extension

/// A utility class providing helper methods and constants for building UI.
///
/// This class includes methods for creating spacing, insets, border radius,
/// and provides common UI constants like a default box shadow.
///
/// All methods and properties are static, so no instance of `UiHelper` needs to be created.
class UiHelper {
  /// Private constructor to prevent instantiation.
  UiHelper._();

  /// Default box shadow for UI elements.
  ///
  /// This shadow provides a subtle elevation effect.
  static final BoxShadow shadow = BoxShadow(
    color: Colors.black.withOpacity(0.1), // Shadow color with 10% opacity
    offset: const Offset(0, 6), // Offset from the top (y-axis)
    blurRadius: 6.0, // Spread of the shadow
  );

  /// Creates a spacing widget (SizedBox) with customizable width and height.
  ///
  /// The actual width and height are calculated by multiplying the provided
  /// values with `kPadding`. If width or height is null, it defaults to 0.
  ///
  /// Example:
  /// ```dart
  /// UiHelper.spacing(width: 1) // SizedBox(width: kPadding * 1)
  /// UiHelper.spacing(height: 0.5) // SizedBox(height: kPadding * 0.5)
  /// ```
  ///
  /// [width]: The multiplier for `kPadding` to determine the width.
  /// [height]: The multiplier for `kPadding` to determine the height.
  /// Returns a [SizedBox] widget.
  static Widget spacing({double? width, double? height}) {
    assert(width == null || width >= 0, 'Width must be non-negative');
    assert(height == null || height >= 0, 'Height must be non-negative');
    // Uses kPadding as a base unit for spacing.
    // The final dimension is not scaled by ScreenUtil here, assuming kPadding
    // is a logical unit and the context where spacing is used will handle scaling if needed,
    // or kPadding itself is designed to be used in a scaled manner.
    return SizedBox(
      width: kPadding * (width ?? 0),
      height: kPadding * (height ?? 0),
    );
  }

  /// Creates an [EdgeInsetsGeometry] with customizable insets for all sides.
  ///
  /// Each inset value is multiplied by `kPadding` and then scaled by ScreenUtil
  /// (`.w` for horizontal, `.h` for vertical).
  ///
  /// [left]: Multiplier for `kPadding` for the left inset.
  /// [top]: Multiplier for `kPadding` for the top inset.
  /// [right]: Multiplier for `kPadding` for the right inset.
  /// [bottom]: Multiplier for `kPadding` for the bottom inset.
  /// Returns an [EdgeInsets.fromLTRB] value.
  static EdgeInsetsGeometry inset(
      double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(
      (kPadding * left).w,
      (kPadding * top).h,
      (kPadding * right).w,
      (kPadding * bottom).h,
    );
  }

  /// Creates an [EdgeInsetsGeometry] with customizable insets for specific sides.
  ///
  /// Null values for sides will result in zero inset for that side.
  /// Each provided inset value is multiplied by `kPadding` and then scaled by ScreenUtil.
  ///
  /// Example:
  /// ```dart
  /// UiHelper.insetOn(left: 1, bottom: 2)
  /// // EdgeInsets.only(left: (kPadding * 1).w, bottom: (kPadding * 2).h)
  /// ```
  ///
  /// [left]: Multiplier for `kPadding` for the left inset.
  /// [top]: Multiplier for `kPadding` for the top inset.
  /// [right]: Multiplier for `kPadding` for the right inset.
  /// [bottom]: Multiplier for `kPadding` for the bottom inset.
  /// Returns an [EdgeInsets.only] value.
  static EdgeInsetsGeometry insetOn(
      {double? left, double? top, double? right, double? bottom}) {
    return EdgeInsets.only(
      left: (kPadding * (left ?? 0)).w,
      top: (kPadding * (top ?? 0)).h,
      right: (kPadding * (right ?? 0)).w,
      bottom: (kPadding * (bottom ?? 0)).h,
    );
  }

  /// Creates an [EdgeInsetsGeometry] with symmetric horizontal and vertical insets.
  ///
  /// Each inset value is multiplied by `kPadding` and then scaled by ScreenUtil.
  ///
  /// [x]: Multiplier for `kPadding` for horizontal (left and right) insets.
  /// [y]: Multiplier for `kPadding` for vertical (top and bottom) insets.
  /// Returns an [EdgeInsets.symmetric] value.
  static EdgeInsetsGeometry insetAxis({double? x, double? y}) {
    return EdgeInsets.symmetric(
      horizontal: (kPadding * (x ?? 0)).w,
      vertical: (kPadding * (y ?? 0)).h,
    );
  }

  /// Creates an [EdgeInsetsGeometry] with zero insets on all sides.
  ///
  /// Returns [EdgeInsets.zero].
  static EdgeInsetsGeometry insetZero() => EdgeInsets.zero;

  /// Creates a [BorderRadius] with customizable radius values for each corner.
  ///
  /// Each radius value is treated as a logical pixel value and then converted
  /// to a corner radius using the `.cornerRadius` extension (likely from [UiExtensions]).
  ///
  /// Example:
  /// ```dart
  /// UiHelper.radiusOn(topLeft: 2, bottomRight: 2)
  /// // BorderRadius.only(topLeft: 2.0.cornerRadius, bottomRight: 2.0.cornerRadius)
  /// ```
  ///
  /// [topLeft]: Radius for the top-left corner.
  /// [topRight]: Radius for the top-right corner.
  /// [bottomRight]: Radius for the bottom-right corner.
  /// [bottomLeft]: Radius for the bottom-left corner.
  /// Returns a [BorderRadius.only] value.
  static BorderRadius radiusOn({
    double? topLeft,
    double? topRight,
    double? bottomRight,
    double? bottomLeft,
  }) {
    return BorderRadius.only(
      topLeft: (topLeft ?? 0).cornerRadius,
      topRight: (topRight ?? 0).cornerRadius,
      bottomLeft: (bottomLeft ?? 0).cornerRadius,
      bottomRight: (bottomRight ?? 0).cornerRadius,
    );
  }

  /// Creates a [VisualDensity] with customizable horizontal and vertical densities.
  ///
  /// Defaults to `VisualDensity(horizontal: -4, vertical: -4)` if values are not provided.
  /// These default values typically make UI elements more compact.
  ///
  /// [x]: Horizontal visual density.
  /// [y]: Vertical visual density.
  /// Returns a [VisualDensity] object.
  static VisualDensity visualDensity({double? x, double? y}) {
    // Default values are common for a compact UI.
    return VisualDensity(horizontal: x ?? -4.0, vertical: y ?? -4.0);
  }
}
