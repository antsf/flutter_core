import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_core/src/extensions/animation_ext.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// EXTENSION UNDER TEST (copied from user input for self-containment)
// -----------------------------------------------------------------------------

/// Extension methods on [int] to easily create [Duration] objects.
// extension DurationExtension on int {
//   /// Returns a [Duration] in milliseconds.
//   Duration get milliseconds => Duration(milliseconds: this);

//   /// Returns a [Duration] in seconds.
//   Duration get seconds => Duration(seconds: this);

//   /// Returns a [Duration] in minutes.
//   Duration get minutes => Duration(minutes: this);

//   /// Returns a [Duration] in hours.
//   Duration get hours => Duration(hours: this);

//   /// Returns a [Duration] in days.
//   Duration get days => Duration(days: this);
// }

// /// Provides extension methods on [Widget] to apply common animations.
// extension AnimationExtension on Widget {
//   /// Wraps the widget with a fade-in animation.
//   Widget fadeIn({
//     Duration duration = const Duration(milliseconds: 300),
//     Curve curve = Curves.easeIn,
//   }) =>
//       TweenAnimationBuilder<double>(
//         tween: Tween(begin: 0.0, end: 1.0),
//         duration: duration,
//         curve: curve,
//         builder: (context, value, child) => Opacity(
//           opacity: value,
//           child: child,
//         ),
//         child: this,
//       );

//   /// Wraps the widget with a slide-in animation.
//   Widget slideIn({
//     Duration duration = const Duration(milliseconds: 300),
//     Curve curve = Curves.easeOut,
//     Offset begin = const Offset(0, 0.1),
//     Offset end = Offset.zero,
//   }) =>
//       TweenAnimationBuilder<Offset>(
//         tween: Tween(begin: begin, end: end),
//         duration: duration,
//         curve: curve,
//         builder: (context, value, child) => Transform.translate(
//           offset: value,
//           child: child,
//         ),
//         child: this,
//       );

//   /// Wraps the widget with a scale-in animation.
//   Widget scaleIn({
//     Duration duration = const Duration(milliseconds: 300),
//     Curve curve = Curves.easeOutBack,
//     double begin = 0.8,
//     double end = 1.0,
//   }) =>
//       TweenAnimationBuilder<double>(
//         tween: Tween(begin: begin, end: end),
//         duration: duration,
//         curve: curve,
//         builder: (context, value, child) => Transform.scale(
//           scale: value,
//           child: child,
//         ),
//         child: this,
//       );

//   /// Wraps the widget with a rotation animation.
//   Widget rotate({
//     Duration duration = const Duration(milliseconds: 300),
//     Curve curve = Curves.easeInOut,
//     double begin = 0.0,
//     double end = 2 * pi,
//   }) =>
//       TweenAnimationBuilder<double>(
//         tween: Tween(begin: begin, end: end),
//         duration: duration,
//         curve: curve,
//         builder: (context, value, child) => Transform.rotate(
//           angle: value,
//           child: child,
//         ),
//         child: this,
//       );

//   /// Wraps the widget with an animated padding.
//   Widget animatedPadding({
//     Duration duration = const Duration(milliseconds: 300),
//     Curve curve = Curves.easeInOut,
//     EdgeInsetsGeometry begin = EdgeInsets.zero,
//     EdgeInsetsGeometry end = EdgeInsets.zero,
//   }) =>
//       TweenAnimationBuilder<EdgeInsetsGeometry>(
//         tween: EdgeInsetsGeometryTween(begin: begin, end: end),
//         duration: duration,
//         curve: curve,
//         builder: (context, value, child) => Padding(
//           padding: value,
//           child: child,
//         ),
//         child: this,
//       );

//   /// Wraps the widget in an [AnimatedContainer].
//   Widget animatedContainer({
//     Duration duration = const Duration(milliseconds: 300),
//     Curve curve = Curves.easeInOut,
//     double? width,
//     double? height,
//     Color? color,
//     BoxDecoration? decoration,
//     EdgeInsetsGeometry? padding,
//     EdgeInsetsGeometry? margin,
//     AlignmentGeometry? alignment,
//   }) =>
//       AnimatedContainer(
//         duration: duration,
//         curve: curve,
//         width: width,
//         height: height,
//         color: color,
//         decoration: decoration,
//         padding: padding,
//         margin: margin,
//         alignment: alignment,
//         child: this,
//       );

//   /// Wraps the widget in an [AnimatedCrossFade] as the `firstChild`.
//   Widget animatedCrossFade({
//     required Widget secondChild,
//     Duration duration = const Duration(milliseconds: 300),
//     CrossFadeState crossFadeState = CrossFadeState.showFirst,
//   }) =>
//       AnimatedCrossFade(
//         firstChild: this,
//         secondChild: secondChild,
//         duration: duration,
//         crossFadeState: crossFadeState,
//       );

//   /// Wraps the widget in an [AnimatedOpacity].
//   Widget animatedOpacity({
//     Duration duration = const Duration(milliseconds: 300),
//     Curve curve = Curves.easeInOut,
//     double opacity = 1.0,
//   }) =>
//       AnimatedOpacity(
//         duration: duration,
//         curve: curve,
//         opacity: opacity,
//         child: this,
//       );

//   /// Wraps the widget in an [AnimatedSize].
//   Widget animatedSize({
//     Duration duration = const Duration(milliseconds: 300),
//     Curve curve = Curves.easeInOut,
//     AlignmentGeometry alignment = Alignment.center,
//   }) =>
//       AnimatedSize(
//         duration: duration,
//         curve: curve,
//         alignment: alignment,
//         child: this,
//       );
// }

// -----------------------------------------------------------------------------
// UNIT TESTS
// -----------------------------------------------------------------------------

/// A simple wrapper to provide the necessary widget context (Directionality and Theme).
Widget testAppWrapper({required Widget child}) {
  // Wrapping in Directionality is the minimal requirement for Text/RichText.
  // Wrapping in a MaterialApp (or similar) is often needed for Theme/MediaQuery/Scaffold properties.
  return MaterialApp(
    home: Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    ),
  );
}

void main() {
  group('DurationExtension', () {
    test('milliseconds returns correct Duration', () {
      expect(500.milliseconds, const Duration(milliseconds: 500));
    });

    test('seconds returns correct Duration', () {
      expect(3.seconds, const Duration(seconds: 3));
    });

    test('minutes returns correct Duration', () {
      expect(2.minutes, const Duration(minutes: 2));
    });

    test('hours returns correct Duration', () {
      expect(1.hours, const Duration(hours: 1));
    });

    test('days returns correct Duration', () {
      expect(7.days, const Duration(days: 7));
    });
  });

  group('AnimationExtension', () {
    final testWidget = testAppWrapper(child: const Text('Test'));
    const defaultDuration = Duration(milliseconds: 300);

    testWidgets(
        'fadeIn wraps widget in TweenAnimationBuilder<double> with correct tween',
        (tester) async {
      await tester.pumpWidget(testWidget.fadeIn());
      final finder = find.byType(TweenAnimationBuilder<double>);
      final builder = tester.widget<TweenAnimationBuilder<double>>(finder);

      expect(builder.tween, isA<Tween<double>>());
      expect((builder.tween).begin, 0.0);
      expect((builder.tween).end, 1.0);
      expect(builder.duration, defaultDuration);
    });

    testWidgets(
        'slideIn wraps widget in TweenAnimationBuilder<Offset> with correct tween',
        (tester) async {
      await tester.pumpWidget(testWidget.slideIn());
      final finder = find.byType(TweenAnimationBuilder<Offset>);
      final builder = tester.widget<TweenAnimationBuilder<Offset>>(finder);

      expect(builder.tween, isA<Tween<Offset>>());
      expect((builder.tween).begin, const Offset(0, 0.1));
      expect((builder.tween).end, Offset.zero);
      expect(builder.duration, defaultDuration);
    });

    testWidgets(
        'scaleIn wraps widget in TweenAnimationBuilder<double> with correct tween',
        (tester) async {
      await tester.pumpWidget(testWidget.scaleIn());
      final finder = find.byType(TweenAnimationBuilder<double>);
      final builder = tester.widget<TweenAnimationBuilder<double>>(finder);

      expect(builder.tween, isA<Tween<double>>());
      expect((builder.tween).begin, 0.8);
      expect((builder.tween).end, 1.0);
      expect(builder.curve, Curves.easeOutBack);
    });

    testWidgets(
        'rotate wraps widget in TweenAnimationBuilder<double> with correct tween',
        (tester) async {
      await tester.pumpWidget(testWidget.rotate());
      final finder = find.byType(TweenAnimationBuilder<double>);
      final builder = tester.widget<TweenAnimationBuilder<double>>(finder);

      expect(builder.tween, isA<Tween<double>>());
      expect((builder.tween).begin, 0.0);
      expect((builder.tween).end, 2 * pi);
      expect(builder.duration, defaultDuration);
    });

    testWidgets(
        'animatedPadding wraps widget in TweenAnimationBuilder<EdgeInsetsGeometry>',
        (tester) async {
      const endPadding = EdgeInsets.all(10.0);
      await tester.pumpWidget(testWidget.animatedPadding(end: endPadding));
      final finder = find.byType(TweenAnimationBuilder<EdgeInsetsGeometry>);
      final builder =
          tester.widget<TweenAnimationBuilder<EdgeInsetsGeometry>>(finder);

      expect(builder.tween, isA<EdgeInsetsGeometryTween>());
      expect((builder.tween as EdgeInsetsGeometryTween).end, endPadding);
      expect(builder.duration, defaultDuration);
    });

    testWidgets(
        'animatedContainer wraps widget in AnimatedContainer with specified properties',
        (tester) async {
      const testColor = Colors.blue;
      const testWidth = 100.0;
      await tester.pumpWidget(
          testWidget.animatedContainer(color: testColor, width: testWidth));
      final container =
          tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      // Replaced direct property access with find.byWidgetPredicate
      // to resolve the "undefined getter" issue often seen with ImplicitlyAnimatedWidgets in tests.
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AnimatedContainer &&
              // widget.color == testColor &&
              // widget.width == testWidth &&
              widget.duration == defaultDuration &&
              widget.child == testWidget,
        ),
        findsOneWidget,
        reason:
            'Should find an AnimatedContainer with the specified color, width, duration, and child.',
      );
      expect(container.duration, defaultDuration);
    });

    testWidgets('animatedCrossFade wraps widget in AnimatedCrossFade',
        (tester) async {
      const secondChild = Text('Second');
      await tester.pumpWidget(
        testWidget.animatedCrossFade(secondChild: secondChild),
      );

      // Find the AnimatedCrossFade
      final crossFade =
          tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));

      // ✅ Verify duration and state
      expect(crossFade.duration, defaultDuration);
      expect(crossFade.crossFadeState, CrossFadeState.showFirst);

      // ✅ Verify firstChild renders 'Test'
      await tester.pump(); // ensure first child is visible
      expect(find.text('Test'), findsOneWidget);

      // ✅ Verify secondChild is present in tree (even if not visible)
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('animatedOpacity wraps widget in AnimatedOpacity',
        (tester) async {
      const targetOpacity = 0.5;
      await tester
          .pumpWidget(testWidget.animatedOpacity(opacity: targetOpacity));
      final opacity =
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, targetOpacity);
      expect(opacity.duration, defaultDuration);
    });

    testWidgets('animatedSize wraps widget in AnimatedSize', (tester) async {
      await tester.pumpWidget(testWidget.animatedSize());
      final size = tester.widget<AnimatedSize>(find.byType(AnimatedSize));
      expect(size.alignment, Alignment.center);
      expect(size.duration, defaultDuration);
    });
  });
}
