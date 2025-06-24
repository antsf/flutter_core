/// Provides extension methods on [Widget] for common layout and positioning tasks.
/// These extensions offer a more concise syntax for wrapping widgets with
/// standard layout widgets like [Center], [Padding], [SizedBox], etc.
///
/// Example:
/// ```dart
/// MyWidget()
///   .padding(EdgeInsets.all(8.0))
///   .center()
///   .sizedBox(width: 100, height: 50);
/// ```
library layout_extensions;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Extension methods for [Widget] to simplify common layout compositions.
extension LayoutExtension on Widget {
  /// Wraps the widget in a [Center] widget.
  Widget center() => Center(child: this);

  /// Wraps the widget in an [Align] widget with the specified [alignment].
  Widget align(AlignmentGeometry alignment) => Align(
        alignment: alignment,
        child: this,
      );

  /// Wraps the widget in a [Padding] widget with the specified [padding].
  Widget padding(EdgeInsetsGeometry padding) => Padding(
        padding: padding,
        child: this,
      );

  /// Wraps the widget in a [Container] widget with the specified [margin].
  /// Note: This uses a [Container] to apply margin.
  Widget margin(EdgeInsetsGeometry margin) => Container(
        margin: margin,
        child: this,
      );

  /// Wraps the widget in a [SizedBox] with the specified [width] and [height].
  /// Width and height are scaled using [ScreenUtil]'s `.w` and `.h` extensions.
  Widget sizedBox({
    double? width,
    double? height,
  }) =>
      SizedBox(
        width: width?.w, // Scaled width
        height: height?.h, // Scaled height
        child: this,
      );

  /// Wraps the widget in an [Expanded] widget with the specified [flex] factor.
  Widget expanded({int flex = 1}) => Expanded(
        flex: flex,
        child: this,
      );

  /// Wraps the widget in a [Flexible] widget with the specified [flex] factor and [fit].
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) => Flexible(
        flex: flex,
        fit: fit,
        child: this,
      );

  /// Wraps the widget in an [AspectRatio] widget with the specified [aspectRatio].
  Widget aspectRatio(double aspectRatio) => AspectRatio(
        aspectRatio: aspectRatio,
        child: this,
      );

  /// Wraps the widget in a [ConstrainedBox] with the specified constraints.
  /// Min/max width and height are scaled using [ScreenUtil]'s `.w` and `.h` extensions.
  Widget constrainedBox({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth?.w ?? 0.0, // Scaled minWidth
          maxWidth: maxWidth?.w ?? double.infinity, // Scaled maxWidth
          minHeight: minHeight?.h ?? 0.0, // Scaled minHeight
          maxHeight: maxHeight?.h ?? double.infinity, // Scaled maxHeight
        ),
        child: this,
      );

  /// Wraps the widget in a [FractionallySizedBox] with the specified factors.
  Widget fractionallySizedBox({
    double? widthFactor,
    double? heightFactor,
    AlignmentGeometry alignment = Alignment.center,
  }) =>
      FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        alignment: alignment,
        child: this,
      );

  /// Wraps the widget in an [IntrinsicHeight] widget.
  Widget intrinsicHeight() => IntrinsicHeight(child: this);

  /// Wraps the widget in an [IntrinsicWidth] widget.
  Widget intrinsicWidth() => IntrinsicWidth(child: this);

  /// Wraps the widget in a [ClipRRect].
  ///
  /// [radius]: The circular radius for all corners, scaled by [ScreenUtil]'s `.r`.
  ///           This is used if [borderRadius] is null. Defaults to 8.
  /// [borderRadius]: An explicit [BorderRadius]. If provided, [radius] is ignored.
  Widget clipRRect({
    double radius = 8.0,
    BorderRadius? borderRadius,
  }) =>
      ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(radius.r), // Scaled radius
        child: this,
      );

  /// Wraps the widget in a [ClipOval].
  Widget clipOval() => ClipOval(child: this);

  /// Wraps the widget in a [ClipPath] using the provided [path].
  /// Uses a custom [_PathClipper].
  Widget clipPath(Path path) => ClipPath(
        clipper: _PathClipper(path),
        child: this,
      );

  /// Wraps the widget in a [Transform.scale] widget.
  Widget transformScale(double scale) => Transform.scale(
        scale: scale,
        child: this,
      );

  /// Wraps the widget in a [Transform.rotate] widget.
  /// [angle] is in radians.
  Widget transformRotate(double angle) => Transform.rotate(
        angle: angle,
        child: this,
      );

  /// Wraps the widget in a [Transform.translate] widget.
  Widget transformTranslate(Offset offset) => Transform.translate(
        offset: offset,
        child: this,
      );
}

/// A custom [CustomClipper] that uses a predefined [Path] to clip its child.
class _PathClipper extends CustomClipper<Path> {
  /// The path to be used for clipping.
  final Path path;

  /// Creates a [_PathClipper] with the given [path].
  _PathClipper(this.path);

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(covariant _PathClipper oldClipper) => oldClipper.path != path;
}
