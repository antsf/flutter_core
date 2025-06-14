/// Layout helper extensions for Widget, providing concise widget composition methods.
library layout_extensions;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Layout helper extensions for Widget
extension LayoutExtension on Widget {
  /// Center widget
  Widget center() => Center(child: this);

  /// Align widget
  Widget align(AlignmentGeometry alignment) => Align(
        alignment: alignment,
        child: this,
      );

  /// Padding
  Widget padding(EdgeInsetsGeometry padding) => Padding(
        padding: padding,
        child: this,
      );

  /// Margin
  Widget margin(EdgeInsetsGeometry margin) => Container(
        margin: margin,
        child: this,
      );

  /// SizedBox with width and height
  Widget sizedBox({
    double? width,
    double? height,
  }) =>
      SizedBox(
        width: width?.w,
        height: height?.h,
        child: this,
      );

  /// Expanded widget
  Widget expanded({int flex = 1}) => Expanded(
        flex: flex,
        child: this,
      );

  /// Flexible widget
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) => Flexible(
        flex: flex,
        fit: fit,
        child: this,
      );

  /// Aspect ratio
  Widget aspectRatio(double aspectRatio) => AspectRatio(
        aspectRatio: aspectRatio,
        child: this,
      );

  /// Constrained box
  Widget constrainedBox({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth?.w ?? 0,
          maxWidth: maxWidth?.w ?? double.infinity,
          minHeight: minHeight?.h ?? 0,
          maxHeight: maxHeight?.h ?? double.infinity,
        ),
        child: this,
      );

  /// Fractionally sized box
  Widget fractionallySizedBox({
    double? widthFactor,
    double? heightFactor,
  }) =>
      FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: this,
      );

  /// Intrinsic height
  Widget intrinsicHeight() => IntrinsicHeight(child: this);

  /// Intrinsic width
  Widget intrinsicWidth() => IntrinsicWidth(child: this);

  /// Clip rounded rectangle
  Widget clipRRect({
    double radius = 8,
    BorderRadius? borderRadius,
  }) =>
      ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(radius.r),
        child: this,
      );

  /// Clip oval
  Widget clipOval() => ClipOval(child: this);

  /// Clip path
  Widget clipPath(Path path) => ClipPath(
        clipper: _PathClipper(path),
        child: this,
      );

  /// Transform scale
  Widget transformScale(double scale) => Transform.scale(
        scale: scale,
        child: this,
      );

  /// Transform rotate
  Widget transformRotate(double angle) => Transform.rotate(
        angle: angle,
        child: this,
      );

  /// Transform translate
  Widget transformTranslate(Offset offset) => Transform.translate(
        offset: offset,
        child: this,
      );
}

/// Custom path clipper
class _PathClipper extends CustomClipper<Path> {
  final Path path;

  _PathClipper(this.path);

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
