import 'dart:math' show pi;
import 'package:flutter/material.dart';

/// Extension methods on [int] to easily create [Duration] objects.
///
/// Example:
/// ```dart
/// final duration = 500.milliseconds;
/// final timeout = 3.seconds;
/// ```
extension DurationExtension on int {
  /// Returns a [Duration] in milliseconds.
  Duration get milliseconds => Duration(milliseconds: this);

  /// Returns a [Duration] in seconds.
  Duration get seconds => Duration(seconds: this);

  /// Returns a [Duration] in minutes.
  Duration get minutes => Duration(minutes: this);

  /// Returns a [Duration] in hours.
  Duration get hours => Duration(hours: this);

  /// Returns a [Duration] in days.
  Duration get days => Duration(days: this);
}

/// Provides extension methods on [Widget] to apply common animations.
///
/// These methods wrap the widget with a [TweenAnimationBuilder] or an
/// appropriate `AnimatedWidget` to achieve the desired effect.
///
/// Example:
/// ```dart
/// MyWidget().fadeIn(duration: 500.milliseconds);
/// MyWidget().slideIn(begin: Offset(-100, 0));
/// ```
extension AnimationExtension on Widget {
  /// Wraps the widget with a fade-in animation.
  ///
  /// [duration]: The duration of the animation. Defaults to 300ms.
  /// [curve]: The curve of the animation. Defaults to [Curves.easeIn].
  Widget fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeIn,
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        curve: curve,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: child,
        ),
        child: this,
      );

  /// Wraps the widget with a slide-in animation.
  ///
  /// [duration]: The duration of the animation. Defaults to 300ms.
  /// [curve]: The curve of the animation. Defaults to [Curves.easeOut].
  /// [begin]: The starting offset of the slide. Defaults to `Offset(0, 0.1)`.
  /// [end]: The ending offset of the slide. Defaults to [Offset.zero].
  Widget slideIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
    Offset begin = const Offset(0, 0.1), // Slides from slightly below
    Offset end = Offset.zero,
  }) =>
      TweenAnimationBuilder<Offset>(
        tween: Tween(begin: begin, end: end),
        duration: duration,
        curve: curve,
        builder: (context, value, child) => Transform.translate(
          offset: value,
          child: child,
        ),
        child: this,
      );

  /// Wraps the widget with a scale-in animation.
  ///
  /// [duration]: The duration of the animation. Defaults to 300ms.
  /// [curve]: The curve of the animation. Defaults to [Curves.easeOutBack].
  /// [begin]: The starting scale factor. Defaults to 0.8.
  /// [end]: The ending scale factor. Defaults to 1.0.
  Widget scaleIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutBack,
    double begin = 0.8,
    double end = 1.0,
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: begin, end: end),
        duration: duration,
        curve: curve,
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: child,
        ),
        child: this,
      );

  /// Wraps the widget with a rotation animation.
  ///
  /// [duration]: The duration of the animation. Defaults to 300ms.
  /// [curve]: The curve of the animation. Defaults to [Curves.easeInOut].
  /// [begin]: The starting angle in radians. Defaults to 0.
  /// [end]: The ending angle in radians. Defaults to a full circle (2 * pi).
  Widget rotate({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double begin = 0.0,
    double end = 2 * pi, // Full circle rotation
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: begin, end: end),
        duration: duration,
        curve: curve,
        builder: (context, value, child) => Transform.rotate(
          angle: value,
          child: child,
        ),
        child: this,
      );

  /// Wraps the widget with an animated padding.
  ///
  /// Uses [TweenAnimationBuilder] with an [EdgeInsetsGeometryTween].
  ///
  /// [duration]: The duration of the animation. Defaults to 300ms.
  /// [curve]: The curve of the animation. Defaults to [Curves.easeInOut].
  /// [begin]: The starting padding. Defaults to [EdgeInsets.zero].
  /// [end]: The ending padding. Defaults to [EdgeInsets.zero].
  Widget animatedPadding({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    EdgeInsetsGeometry begin = EdgeInsets.zero,
    EdgeInsetsGeometry end = EdgeInsets.zero,
  }) =>
      TweenAnimationBuilder<EdgeInsetsGeometry>(
        tween: EdgeInsetsGeometryTween(begin: begin, end: end),
        duration: duration,
        curve: curve,
        builder: (context, value, child) => Padding(
          padding: value,
          child: child,
        ),
        child: this,
      );

  /// Wraps the widget in an [AnimatedContainer].
  ///
  /// This allows animating properties like width, height, color, decoration, etc.
  ///
  /// [duration]: The duration of the animation. Defaults to 300ms.
  /// [curve]: The curve of the animation. Defaults to [Curves.easeInOut].
  /// Other parameters correspond to [AnimatedContainer] properties.
  Widget animatedContainer({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double? width,
    double? height,
    Color? color,
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    AlignmentGeometry? alignment,
  }) =>
      AnimatedContainer(
        duration: duration,
        curve: curve,
        width: width,
        height: height,
        color: color,
        decoration: decoration,
        padding: padding,
        margin: margin,
        alignment: alignment,
        child: this,
      );

  /// Wraps the widget in an [AnimatedCrossFade] as the `firstChild`.
  ///
  /// [secondChild]: The widget to cross-fade to/from.
  /// [duration]: The duration of the cross-fade. Defaults to 300ms.
  /// [crossFadeState]: The state controlling which child is visible. Defaults to [CrossFadeState.showFirst].
  Widget animatedCrossFade({
    required Widget secondChild,
    Duration duration = const Duration(milliseconds: 300),
    CrossFadeState crossFadeState = CrossFadeState.showFirst,
  }) =>
      AnimatedCrossFade(
        firstChild: this,
        secondChild: secondChild,
        duration: duration,
        crossFadeState: crossFadeState,
      );

  /// Wraps the widget in an [AnimatedOpacity].
  ///
  /// [duration]: The duration of the animation. Defaults to 300ms.
  /// [curve]: The curve of the animation. Defaults to [Curves.easeInOut].
  /// [opacity]: The target opacity. Defaults to 1.0 (fully opaque).
  Widget animatedOpacity({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double opacity = 1.0,
  }) =>
      AnimatedOpacity(
        duration: duration,
        curve: curve,
        opacity: opacity,
        child: this,
      );

  /// Wraps the widget in an [AnimatedSize].
  ///
  /// Animates its size when its child's size changes.
  ///
  /// [duration]: The duration of the animation. Defaults to 300ms.
  /// [curve]: The curve of the animation. Defaults to [Curves.easeInOut].
  /// [alignment]: The alignment of the child within the parent. Defaults to [Alignment.center].
  Widget animatedSize({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    AlignmentGeometry alignment = Alignment.center,
  }) =>
      AnimatedSize(
        duration: duration,
        curve: curve,
        alignment: alignment,
        child: this,
      );
}
