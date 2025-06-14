import 'package:flutter/material.dart';

extension DurationExtension on int {
  Duration get milliseconds => Duration(milliseconds: this);

  Duration get seconds => Duration(seconds: this);

  Duration get minutes => Duration(minutes: this);

  Duration get hours => Duration(hours: this);

  Duration get days => Duration(days: this);
}

/// Animation helper extensions for Widget
extension AnimationExtension on Widget {
  /// Fade in animation
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

  /// Slide in animation
  Widget slideIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
    Offset begin = const Offset(0, 0.1),
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

  /// Scale in animation
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

  /// Rotate animation
  Widget rotate({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double begin = 0,
    double end = 2 * 3.14159,
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

  /// Animated padding
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

  /// Animated container
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

  /// Animated cross fade between two widgets
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

  /// Animated opacity
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

  /// Animated size
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
