import 'package:flutter/material.dart';
import 'package:flutter_core/src/extensions/ui_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/default.dart';

class UiHelper {
  UiHelper._();

  /// Creates a spacing widget with customizable width and height.
  static Widget spacing({double? width, double? height}) {
    assert(width == null || width >= 0, 'Width must be non-negative');
    assert(height == null || height >= 0, 'Height must be non-negative');
    return SizedBox(
      width: kPadding * (width ?? 0),
      height: kPadding * (height ?? 0),
    );
  }

  /// Creates an EdgeInsetsGeometry with customizable insets.
  EdgeInsetsGeometry inset(
      double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(
      (kPadding * left).w,
      (kPadding * top).h,
      (kPadding * right).w,
      (kPadding * bottom).h,
    );
  }

  /// Creates an EdgeInsetsGeometry with customizable insets.
  EdgeInsetsGeometry insetOn(
      {double? left, double? top, double? right, double? bottom}) {
    return EdgeInsets.only(
      left: (kPadding * (left ?? 0)).w,
      top: (kPadding * (top ?? 0)).h,
      right: (kPadding * (right ?? 0)).w,
      bottom: (kPadding * (bottom ?? 0)).h,
    );
  }

  /// Creates an EdgeInsetsGeometry with symmetric insets.
  EdgeInsetsGeometry insetAxis({double? x, double? y}) {
    return EdgeInsets.symmetric(
      horizontal: (kPadding * (x ?? 0)).w,
      vertical: (kPadding * (y ?? 0)).h,
    );
  }

  /// Creates an EdgeInsetsGeometry with zero insets.
  EdgeInsetsGeometry insetZero() => EdgeInsets.zero;

  /// Creates a BorderRadius with customizable values for each corner.
  BorderRadius radiusOn({
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

  /// Default box shadow for UI elements.
  final BoxShadow shadow = BoxShadow(
    color: Colors.black.withOpacity(.1),
    offset: const Offset(0, 6),
    blurRadius: 6.0,
  );

  /// Creates a VisualDensity with customizable values.
  VisualDensity visualDensity({double? x, double? y}) {
    return VisualDensity(horizontal: x ?? -4, vertical: y ?? -4);
  }
}
