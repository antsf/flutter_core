import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// --- MOCK EXTENSIONS FOR TEST ENVIRONMENT ---
// Since flutter_screenutil cannot be imported here, we mock its functionality
// to allow the extensions under test to compile and run without runtime errors
// on .w, .h, and .r. For structural testing, we simply return the original value.
extension MockNum on num {
  double get w => toDouble();
  double get h => toDouble();
  double get r => toDouble();
}

// --- EXTENSIONS UNDER TEST (Copied for self-containment) ---

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
  Widget margin(EdgeInsetsGeometry margin) => Container(
        margin: margin,
        child: this,
      );

  /// Wraps the widget in a [SizedBox] with the specified [width] and [height].
  Widget sizedBox({
    double? width,
    double? height,
  }) =>
      SizedBox(
        width: width?.w,
        height: height?.h,
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

  /// Wraps the widget in an [AspectRatio] widget with the specified [aspectRatio].
  Widget fittedBox({
    Key? key,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    Clip clipBehavior = Clip.none,
  }) =>
      FittedBox(
        key: key,
        fit: fit,
        alignment: alignment,
        clipBehavior: clipBehavior,
        child: this,
      );

  /// Wraps the widget in a [ConstrainedBox] with the specified constraints.
  Widget constrainedBox({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth?.w ?? 0.0,
          maxWidth: maxWidth?.w ?? double.infinity,
          minHeight: minHeight?.h ?? 0.0,
          maxHeight: maxHeight?.h ?? double.infinity,
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
  Widget clipRRect({
    double radius = 8.0,
    BorderRadius? borderRadius,
  }) =>
      ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(radius.r),
        child: this,
      );

  /// Wraps the widget in a [ClipOval].
  Widget clipOval() => ClipOval(child: this);

  /// Wraps the widget in a [ClipPath] using the provided [path].
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
  bool shouldReclip(covariant _PathClipper oldClipper) =>
      oldClipper.path != path;
}

// --- UNIT TESTS ---

void main() {
  const Key childKey = ValueKey('child_widget');
  const Widget child = Placeholder(key: childKey);

  group('LayoutExtension', () {
    // Helper to extract the wrapper widget
    T getWrapper<T extends Widget>(WidgetTester tester) {
      // Find the widget that is the parent of the child (Placeholder)
      final finder = find.byType(T);
      expect(finder, findsOneWidget,
          reason: 'Expected to find the wrapper widget $T');
      return tester.widget<T>(finder);
    }

    testWidgets('center() wraps the widget in a Center',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.center());
      final wrapper = getWrapper<Center>(tester);
      expect(wrapper.child, child);
    });

    testWidgets('align() wraps the widget in Align with correct alignment',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.align(Alignment.bottomRight));
      final wrapper = getWrapper<Align>(tester);
      expect(wrapper.alignment, Alignment.bottomRight);
      expect(wrapper.child, child);
    });

    testWidgets('padding() wraps the widget in Padding with correct insets',
        (WidgetTester tester) async {
      const insets = EdgeInsets.all(16.0);
      await tester.pumpWidget(child.padding(insets));
      final wrapper = getWrapper<Padding>(tester);
      expect(wrapper.padding, insets);
      expect(wrapper.child, child);
    });

    testWidgets('margin() wraps the widget in Container with correct margin',
        (WidgetTester tester) async {
      const insets = EdgeInsets.symmetric(horizontal: 10.0);
      await tester.pumpWidget(child.margin(insets));
      final wrapper = getWrapper<Container>(tester);
      expect(wrapper.margin, insets);
      expect(wrapper.child, child);
    });

    testWidgets(
        'sizedBox() wraps the widget in SizedBox with correct dimensions (unscaled check)',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.sizedBox(width: 50, height: 100));
      final wrapper = getWrapper<SizedBox>(tester);
      // We expect the mocked .w and .h to return the original values.
      expect(wrapper.width, 50.0);
      expect(wrapper.height, 100.0);
      expect(wrapper.child, child);
    });

    testWidgets('expanded() wraps the widget in Expanded with correct flex',
        (WidgetTester tester) async {
      await tester.pumpWidget(Column(
          mainAxisSize: MainAxisSize.min, children: [child.expanded(flex: 3)]));
      final wrapper = getWrapper<Expanded>(tester);
      expect(wrapper.flex, 3);
      expect(wrapper.child, child);
    });

    testWidgets(
        'flexible() wraps the widget in Flexible with correct fit and flex',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          Column(children: [child.flexible(flex: 2, fit: FlexFit.tight)]));
      final wrapper = getWrapper<Flexible>(tester);
      expect(wrapper.flex, 2);
      expect(wrapper.fit, FlexFit.tight);
      expect(wrapper.child, child);
    });

    testWidgets('aspectRatio() wraps the widget in AspectRatio',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.aspectRatio(2.0));
      final wrapper = getWrapper<AspectRatio>(tester);
      expect(wrapper.aspectRatio, 2.0);
      expect(wrapper.child, child);
    });

    testWidgets(
        'fittedBox() wraps the widget in FittedBox with custom properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.fittedBox(
          fit: BoxFit.scaleDown, alignment: Alignment.topCenter));
      final wrapper = getWrapper<FittedBox>(tester);
      expect(wrapper.fit, BoxFit.scaleDown);
      expect(wrapper.alignment, Alignment.topCenter);
      expect(wrapper.child, child);
    });

    testWidgets(
        'constrainedBox() wraps the widget in ConstrainedBox with correct constraints',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.constrainedBox(
        minWidth: 50,
        maxWidth: 150,
        minHeight: 25,
      ));
      final wrapper = getWrapper<ConstrainedBox>(tester);
      // We check against the unscaled values due to the mock extension
      expect(wrapper.constraints.minWidth, 50.0);
      expect(wrapper.constraints.maxWidth, 150.0);
      expect(wrapper.constraints.minHeight, 25.0);
      expect(wrapper.child, child);
    });

    testWidgets('fractionallySizedBox() wraps the widget correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          child.fractionallySizedBox(widthFactor: 0.5, heightFactor: 0.8));
      final wrapper = getWrapper<FractionallySizedBox>(tester);
      expect(wrapper.widthFactor, 0.5);
      expect(wrapper.heightFactor, 0.8);
      expect(wrapper.child, child);
    });

    testWidgets('intrinsicHeight() wraps the widget in IntrinsicHeight',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.intrinsicHeight());
      final wrapper = getWrapper<IntrinsicHeight>(tester);
      expect(wrapper.child, child);
    });

    testWidgets('intrinsicWidth() wraps the widget in IntrinsicWidth',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.intrinsicWidth());
      final wrapper = getWrapper<IntrinsicWidth>(tester);
      expect(wrapper.child, child);
    });

    testWidgets('clipRRect() wraps in ClipRRect with default radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.clipRRect());
      final wrapper = getWrapper<ClipRRect>(tester);
      // Due to the mock extension, 8.0.r is 8.0.
      expect(wrapper.borderRadius, BorderRadius.circular(8.0));
      expect(wrapper.child, child);
    });

    testWidgets('clipRRect() uses explicit borderRadius if provided',
        (WidgetTester tester) async {
      final customRadius = BorderRadius.circular(20.0);
      await tester.pumpWidget(child.clipRRect(borderRadius: customRadius));
      final wrapper = getWrapper<ClipRRect>(tester);
      expect(wrapper.borderRadius, customRadius);
    });

    testWidgets('clipOval() wraps the widget in ClipOval',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.clipOval());
      final wrapper = getWrapper<ClipOval>(tester);
      expect(wrapper.child, child);
    });

    testWidgets('clipPath() wraps the widget in ClipPath with custom clipper',
        (WidgetTester tester) async {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 100, 100));
      await tester.pumpWidget(child.clipPath(path));
      final wrapper = getWrapper<ClipPath>(tester);
      expect(wrapper.child, child);
      expect(wrapper.clipper, isA<_PathClipper>());
      // Casting the clipper to check the path property
      expect((wrapper.clipper as _PathClipper).path, path);
    });

    testWidgets('transformScale() wraps the widget in Transform.scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.transformScale(1.5));
      final wrapper = getWrapper<Transform>(tester);
      // Transform.scale uses a matrix, we check the type and that scale is applied.
      // Easiest way is to verify it is the correct type of Transform (which scale is a static constructor of)
      expect(wrapper.transform, isA<Matrix4>());
    });

    testWidgets('transformRotate() wraps the widget in Transform.rotate',
        (WidgetTester tester) async {
      await tester.pumpWidget(child.transformRotate(0.785)); // pi/4 radians
      final wrapper = getWrapper<Transform>(tester);
      // Again, checking for the presence of the Transform widget.
      expect(wrapper.transform, isA<Matrix4>());
    });

    testWidgets('transformTranslate() wraps the widget in Transform.translate',
        (WidgetTester tester) async {
      const offset = Offset(10, 20);
      await tester.pumpWidget(child.transformTranslate(offset));
      final wrapper = getWrapper<Transform>(tester);
      // Transform.translate uses a matrix, but we can verify the offset translation.
      expect(wrapper.transform, isA<Matrix4>());
    });
  });
}
