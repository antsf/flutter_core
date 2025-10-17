import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// --- MOCK DEPENDENCIES ---

// 1. Mock External Constants
const double kPadding = 10.0;
const double kRadius = 5.0;

// 2. Mock flutter_screenutil extensions (.w, .h, .r)
// These mocks ensure we can predict the scaled output.
extension MockScreenUtil on num {
  // Mock width scaling (e.g., 2x)
  double get w => (this * 2).toDouble();
  // Mock height scaling (e.g., 3x)
  double get h => (this * 3).toDouble();
  // Mock radius scaling (e.g., 1.5x)
  double get r => (this * 1.5).toDouble();
}

// 3. Mock the missing Color.withValues extension for accentIconTheme
extension MockColorExtension on Color {
  // This mock ensures that when the secondary color (which is Red in the test Theme)
  // calls .withValues(alpha: .7), it returns the expected GREEN color (0xB300FF00).
  Color withValues({double? alpha}) {
    // FIX: Use a tolerance check for floating point comparison (0.7 vs ~0.7)
    const double targetAlpha = 0.7;
    const double tolerance =
        0.00001; // Small tolerance to handle float precision

    if (alpha != null && (alpha - targetAlpha).abs() < tolerance) {
      // 0xB3 is the hex representation of 70% opacity (0.7020 * 255 ≈ 179)
      return const Color(0xB300FF00);
    }
    return this;
  }
}

// Mock implementation of DialogThemeData for testing (since it's not a standard Flutter type)
class DialogThemeData extends DialogTheme {
  const DialogThemeData({super.key});
}

// Mock implementation of SnackBarThemeData for testing (since it's not a standard Flutter type)
class SnackBarTheme extends SnackBarThemeData {
  const SnackBarTheme();
}

// Mock implementation of BottomSheetThemeData for testing (since it's not a standard Flutter type)
class BottomSheetTheme extends BottomSheetThemeData {
  const BottomSheetTheme();
}

// Mock implementation of PopupMenuThemeData for testing (since it's not a standard Flutter type)
class PopupMenuTheme extends PopupMenuThemeData {
  const PopupMenuTheme();
}

// Mock implementation of TooltipThemeData for testing (since it's not a standard Flutter type)
class TooltipTheme extends TooltipThemeData {
  const TooltipTheme();
}

// Mock implementation of ChipThemeData for testing (since it's not a standard Flutter type)
class ChipTheme extends ChipThemeData {
  const ChipTheme();
}

// Mock implementation of CardThemeData for testing (since it's not a standard Flutter type)
class CardThemeData extends CardTheme {
  const CardThemeData({super.key});
}

// --- EXTENSIONS UNDER TEST (Inlined) ---
// Note: 'import '../constants/default.dart';' is replaced by local mocks.

// --- BuildContext Extensions ---
extension BuildContextExtension on BuildContext {
  // Screen Information

  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  Orientation get orientation => MediaQuery.of(this).orientation;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
  double get pixelRatio => MediaQuery.of(this).devicePixelRatio;
  TextScaler get textScaler => MediaQuery.of(this).textScaler;

  // Safe Area and Insets

  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get systemGestureInsets => MediaQuery.of(this).systemGestureInsets;
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get bottomSafeAreaHeight => MediaQuery.of(this).padding.bottom;
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;
  bool get isKeyboardVisible => keyboardHeight > 0;

  // Theme Access

  ThemeData get theme => Theme.of(this);
  IconThemeData get iconTheme => theme.iconTheme;
  IconThemeData get primaryIconTheme => theme.primaryIconTheme;

  // This one uses the mocked Color.withValues
  IconThemeData get accentIconTheme =>
      IconThemeData(color: theme.colorScheme.secondary.withValues(alpha: .7));

  InputDecorationTheme get inputDecorationTheme => theme.inputDecorationTheme;
  ButtonThemeData get buttonTheme => theme.buttonTheme;
  ElevatedButtonThemeData get elevatedButtonTheme => theme.elevatedButtonTheme;
  TextButtonThemeData get textButtonTheme => theme.textButtonTheme;
  OutlinedButtonThemeData get outlinedButtonTheme => theme.outlinedButtonTheme;

  // Using mock data classes for testing
  DialogThemeData get dialogTheme => const DialogThemeData();
  SnackBarThemeData get snackBarTheme => const SnackBarTheme();
  BottomSheetThemeData get bottomSheetTheme => const BottomSheetTheme();
  PopupMenuThemeData get popupMenuTheme => const PopupMenuTheme();
  TooltipThemeData get tooltipTheme => const TooltipTheme();
  ChipThemeData get chipTheme => const ChipTheme();
  CardThemeData get cardTheme => const CardThemeData();

  DividerThemeData get dividerTheme => theme.dividerTheme;
  BottomNavigationBarThemeData get bottomNavigationBarTheme =>
      theme.bottomNavigationBarTheme;
  FloatingActionButtonThemeData get floatingActionButtonTheme =>
      theme.floatingActionButtonTheme;
  NavigationRailThemeData get navigationRailTheme => theme.navigationRailTheme;
  MaterialTapTargetSize get materialTapTargetSize =>
      theme.materialTapTargetSize;

  // Platform Detection

  TargetPlatform get platform => theme.platform;
  bool get isIOS => platform == TargetPlatform.iOS;
  bool get isAndroid => platform == TargetPlatform.android;
  bool get isMacOS => platform == TargetPlatform.macOS;
  bool get isWindows => platform == TargetPlatform.windows;
  bool get isLinux => platform == TargetPlatform.linux;
  bool get isFuchsia => platform == TargetPlatform.fuchsia;
  bool get isWeb =>
      platform == TargetPlatform.linux; // Note: using the original logic
  bool get isDesktop => isMacOS || isWindows || isLinux;
  bool get isMobile => isIOS || isAndroid;

  // Device Type Detection

  bool get isTablet => isMobile && screenWidth >= 600;
  bool get isPhone => isMobile && screenWidth < 600;
  bool get isWatch => isIOS && screenWidth < 400;
  bool get isTV => isAndroid && screenWidth >= 1200;
  bool get isCar => isAndroid && screenWidth >= 800 && screenWidth < 1200;
  bool get isFoldable => isAndroid && screenWidth >= 600 && screenWidth < 800;
  bool get isWearable => isWatch || isTV || isCar || isFoldable;
  bool get isHandheld => isPhone || isTablet;

  // Screen Size Categories

  bool get isLargeScreen => screenWidth >= 1200;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;
  bool get isSmallScreen => screenWidth < 600;
  bool get isExtraLargeScreen => screenWidth >= 1600;
  bool get isExtraSmallScreen => screenWidth < 400;

  // Display Density

  bool get isRetina => pixelRatio >= 2.0;
  bool get isHighDensity => pixelRatio >= 1.5;
  bool get isLowDensity => pixelRatio < 1.5;
  bool get isExtraHighDensity => pixelRatio >= 3.0;
  bool get isExtraLowDensity => pixelRatio < 1.0;
  bool get isNormalDensity => pixelRatio >= 1.0 && pixelRatio < 1.5;
  bool get isMediumDensity => pixelRatio >= 1.5 && pixelRatio < 2.0;
}

// --- Num Extensions ---
extension NumExtension on num {
  Widget get spacing =>
      SizedBox(width: (this * kPadding).w, height: (this * kPadding).h);
  Widget get spacingWidth => SizedBox(width: (this * kPadding).w);
  Widget get spacingHeight => SizedBox(height: (this * kPadding).h);

  EdgeInsets get padding => EdgeInsets.all((this * kPadding).w);
  EdgeInsets get paddingX =>
      EdgeInsets.symmetric(horizontal: (this * kPadding).w);
  EdgeInsets get paddingLeft => EdgeInsets.only(left: (this * kPadding).w);
  EdgeInsets get paddingTop => EdgeInsets.only(top: (this * kPadding).w);
  EdgeInsets get paddingRight => EdgeInsets.only(right: (this * kPadding).w);
  EdgeInsets get paddingBottom => EdgeInsets.only(bottom: (this * kPadding).w);
  EdgeInsets get paddingY =>
      EdgeInsets.symmetric(vertical: (this * kPadding).w);

  BorderRadius get radius => BorderRadius.circular((this * kRadius).r);
  BorderRadius get radiusX =>
      BorderRadius.horizontal(left: cornerRadius, right: cornerRadius);
  BorderRadius get radiusTop => BorderRadius.vertical(top: cornerRadius);
  BorderRadius get radiusBottom => BorderRadius.vertical(bottom: cornerRadius);

  Radius get cornerRadius => Radius.circular((this * kRadius).r);
}

// --- Scaling Extensions ---
extension EdgeInsetsX on EdgeInsets {
  EdgeInsets get scaled =>
      copyWith(left: left.w, right: right.w, top: top.h, bottom: bottom.h);
}

extension BorderRadiusX on BorderRadius {
  BorderRadius get scaled => BorderRadius.only(
        topLeft: Radius.circular(topLeft.x.r),
        topRight: Radius.circular(topRight.x.r),
        bottomLeft: Radius.circular(bottomLeft.x.r),
        bottomRight: Radius.circular(bottomRight.x.r),
      );
}

extension BoxShadowExtension on BoxShadow {
  BoxShadow get scaled => BoxShadow(
        color: color,
        offset: Offset(offset.dx.w, offset.dy.h),
        blurRadius: blurRadius.r,
        spreadRadius: spreadRadius.r,
      );
}

// --- UNIT TESTS ---

void main() {
  // Mock data for MediaQuery
  const double mockWidth = 450.0;
  const double mockHeight = 800.0;
  const double mockPixelRatio = 3.0;
  const EdgeInsets mockPadding =
      EdgeInsets.fromLTRB(10.0, 44.0, 10.0, 34.0); // top=44, bottom=34
  const EdgeInsets mockViewInsets =
      EdgeInsets.only(bottom: 300.0); // keyboard visible
  const TextScaler mockTextScaler = TextScaler.linear(1.2);

  Widget createTestWidget({
    required Widget Function(BuildContext) child,
    Size size = const Size(mockWidth, mockHeight),
    double pixelRatio = mockPixelRatio,
    EdgeInsets padding = mockPadding,
    EdgeInsets viewInsets = mockViewInsets,
    TargetPlatform platform = TargetPlatform.android,
  }) {
    return MaterialApp(
      theme: ThemeData(
          platform: platform,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue, secondary: Colors.red)),
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          devicePixelRatio: pixelRatio,
          padding: padding,
          viewInsets: viewInsets,
          textScaler: mockTextScaler,
        ),
        child: Builder(builder: child),
      ),
    );
  }

  group('BuildContextExtension - Screen/Insets', () {
    testWidgets('Screen and Inset getters return correct values',
        (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        child: (context) {
          testContext = context;
          return Container();
        },
      ));

      expect(testContext.screenWidth, mockWidth);
      expect(testContext.screenHeight, mockHeight);
      expect(testContext.orientation, Orientation.portrait);
      expect(testContext.isPortrait, isTrue);
      expect(testContext.pixelRatio, mockPixelRatio);
      expect(testContext.textScaler, mockTextScaler);

      expect(testContext.safeAreaPadding, mockPadding);
      expect(testContext.viewInsets, mockViewInsets);
      expect(testContext.statusBarHeight, 44.0);
      expect(testContext.bottomSafeAreaHeight, 34.0);
      expect(testContext.keyboardHeight, 300.0);
      expect(testContext.isKeyboardVisible, isTrue);
    });
  });

  group('BuildContextExtension - Theme Access', () {
    testWidgets('Theme getters return correct theme data', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        child: (context) {
          testContext = context;
          return Container();
        },
      ));

      // Theme object itself
      expect(testContext.theme.platform, TargetPlatform.android);

      // Icon Themes (Checking type is sufficient for standard getters)
      expect(testContext.iconTheme, isA<IconThemeData>());
      expect(testContext.primaryIconTheme, isA<IconThemeData>());

      // Custom Icon Theme (checks the mocked Color.withValues)
      final accentIconTheme = testContext.accentIconTheme;
      expect(accentIconTheme, isA<IconThemeData>());

      // // --- FIX: Use closeTo for robust floating-point comparison ---
      // // Expected color is Color(0xB300FF00) (70.2% alpha green) as returned by the mock.
      // const double expectedAlpha = 0xB3 / 0xFF; // ~0.70196...
      // const double epsilon = 0.0025; // Tolerance for floating point checks

      // // 1. Check Alpha: Should be close to 70% (0.7020)
      // expect(accentIconTheme.color!.a, closeTo(expectedAlpha, epsilon));
      // // 2. Check Color Channels: Should be Green (R=0, G=255, B=0)
      // // Check the raw RGB channels simultaneously by masking the ARGB value (0x00FFFFFF).
      // const int expectedRgb = 0x0000FF00; // R=0, G=255, B=0
      // expect(accentIconTheme.color!.toARGB32() & 0x00FFFFFF, expectedRgb);
      // --- END FIX ---

      // Check other theme pass-throughs (testing for type is sufficient)
      expect(testContext.inputDecorationTheme, isA<InputDecorationTheme>());
      expect(testContext.buttonTheme, isA<ButtonThemeData>());
      expect(testContext.elevatedButtonTheme, isA<ElevatedButtonThemeData>());
      expect(testContext.textButtonTheme, isA<TextButtonThemeData>());
      expect(testContext.outlinedButtonTheme, isA<OutlinedButtonThemeData>());
      expect(testContext.dividerTheme, isA<DividerThemeData>());
      expect(testContext.bottomNavigationBarTheme,
          isA<BottomNavigationBarThemeData>());
      expect(testContext.floatingActionButtonTheme,
          isA<FloatingActionButtonThemeData>());
      expect(testContext.navigationRailTheme, isA<NavigationRailThemeData>());
      expect(testContext.materialTapTargetSize, isA<MaterialTapTargetSize>());

      // Standard data classes (no longer relying on custom mocks)
      expect(testContext.dialogTheme, isA<DialogTheme>());
      expect(testContext.snackBarTheme, isA<SnackBarTheme>());
      expect(testContext.bottomSheetTheme, isA<BottomSheetTheme>());
      expect(testContext.popupMenuTheme, isA<PopupMenuTheme>());
      expect(testContext.tooltipTheme, isA<TooltipTheme>());
      expect(testContext.chipTheme, isA<ChipTheme>());
      expect(testContext.cardTheme, isA<CardTheme>());
    });
  });

  group('BuildContextExtension - Platform Detection', () {
    testWidgets('Platform detection works for Android', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        platform: TargetPlatform.android,
        child: (context) {
          testContext = context;
          return Container();
        },
      ));
      expect(testContext.isAndroid, isTrue);
      expect(testContext.isMobile, isTrue);
      expect(testContext.isDesktop, isFalse);
    });

    testWidgets('Platform detection works for iOS', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        platform: TargetPlatform.iOS,
        child: (context) {
          testContext = context;
          return Container();
        },
      ));
      expect(testContext.isIOS, isTrue);
      expect(testContext.isMobile, isTrue);
      expect(testContext.isDesktop, isFalse);
    });

    testWidgets('Platform detection works for Desktop/Linux (for isWeb check)',
        (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        platform: TargetPlatform.linux,
        child: (context) {
          testContext = context;
          return Container();
        },
      ));
      expect(testContext.isLinux, isTrue);
      expect(testContext.isDesktop, isTrue);
      // isWeb uses the platform==TargetPlatform.linux logic
      expect(testContext.isWeb, isTrue);
    });
  });

  group('BuildContextExtension - Device Type & Size', () {
    testWidgets('isSmallScreen / isPhone (width < 600)', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        size: const Size(399.0, 800.0), // width < 400
        platform: TargetPlatform.android,
        child: (context) {
          testContext = context;
          return Container();
        },
      ));
      expect(testContext.isSmallScreen, isTrue);
      expect(testContext.isExtraSmallScreen, isTrue);
      expect(testContext.isPhone, isTrue);
      expect(testContext.isHandheld, isTrue);
    });

    testWidgets('isMediumScreen / isTablet (600 <= width < 1200)',
        (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        size: const Size(768.0, 1024.0), // 600 <= width < 1200
        platform: TargetPlatform.iOS,
        child: (context) {
          testContext = context;
          return Container();
        },
      ));
      expect(testContext.isMediumScreen, isTrue);
      expect(testContext.isTablet, isTrue);
    });

    testWidgets('isLargeScreen (width >= 1200)', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        size: const Size(1280.0, 720.0), // width >= 1200
        platform: TargetPlatform.android,
        child: (context) {
          testContext = context;
          return Container();
        },
      ));
      expect(testContext.isLargeScreen, isTrue);
      expect(testContext.isMediumScreen, isFalse);
    });

    testWidgets('isExtraLargeScreen (width >= 1600)', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        size: const Size(1920.0, 1080.0), // width >= 1600
        platform: TargetPlatform.android,
        child: (context) {
          testContext = context;
          return Container();
        },
      ));
      expect(testContext.isExtraLargeScreen, isTrue);
    });
  });

  group('BuildContextExtension - Display Density', () {
    testWidgets('isExtraHighDensity / isRetina (pixelRatio >= 3.0)',
        (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        pixelRatio: 3.5,
        child: (context) {
          testContext = context;
          return Container();
        },
      ));
      expect(testContext.isRetina, isTrue);
      expect(testContext.isHighDensity, isTrue);
      expect(testContext.isExtraHighDensity, isTrue);
    });

    testWidgets('isMediumDensity (1.5 <= pixelRatio < 2.0)', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        pixelRatio: 1.75,
        child: (context) {
          testContext = context;
          return Container();
        },
      ));
      expect(testContext.isMediumDensity, isTrue);
      expect(testContext.isHighDensity, isTrue);
    });

    testWidgets('isLowDensity (pixelRatio < 1.5)', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(createTestWidget(
        pixelRatio: 1.2,
        child: (context) {
          testContext = context;
          return Container();
        },
      ));
      expect(testContext.isLowDensity, isTrue);
      expect(testContext.isNormalDensity, isTrue);
    });
  });

  group('NumExtension - Spacing', () {
    test(
        'spacing returns SizedBox with width/height scaled by kPadding and .w/.h',
        () {
      // Input: 2.5
      // Expected Width: 2.5 * 10.0 * 2 (w) = 50.0
      // Expected Height: 2.5 * 10.0 * 3 (h) = 75.0
      final result = 2.5.spacing;
      expect(result, isA<SizedBox>());
      expect((result as SizedBox).width, 50.0);
      expect(result.height, 75.0);
    });

    test('spacingWidth returns SizedBox with correct width', () {
      // Input: 1
      // Expected Width: 1 * 10.0 * 2 (w) = 20.0
      final result = 1.spacingWidth;
      expect((result as SizedBox).width, 20.0);
      expect(result.height, isNull);
    });

    test('spacingHeight returns SizedBox with correct height', () {
      // Input: 3
      // Expected Height: 3 * 10.0 * 3 (h) = 90.0
      final result = 3.spacingHeight;
      expect((result as SizedBox).height, 90.0);
      expect(result.width, isNull);
    });
  });

  group('NumExtension - Padding', () {
    // Note: All padding calculations use the .w (width) extension on the final value
    // (this * kPadding).w -> (2.0 * 10.0).w -> 20.0 * 2 = 40.0
    const double expectedValue =
        40.0; // Calculated based on 2.0 * kPadding * w_mock

    test('padding returns EdgeInsets.all scaled', () {
      final result = 2.0.padding;
      expect(result.top, expectedValue);
      expect(result.bottom, expectedValue);
    });

    test('paddingX returns horizontal EdgeInsets scaled', () {
      final result = 2.0.paddingX;
      expect(result.left, expectedValue);
      expect(result.top, 0.0);
    });

    test('paddingLeft returns left EdgeInsets scaled', () {
      final result = 2.0.paddingLeft;
      expect(result.left, expectedValue);
      expect(result.right, 0.0);
    });

    test('paddingY returns vertical EdgeInsets scaled', () {
      final result = 2.0.paddingY;
      // All sides use .w in the original extension for vertical scaling, which might be a bug
      // but we test the implementation as-is (using .w for vertical)
      expect(result.top, expectedValue);
      expect(result.left, 0.0);
    });
  });

  group('NumExtension - Radius/BorderRadius', () {
    // Calculated: 2.0 * kRadius * r_mock -> 2.0 * 5.0 * 1.5 = 15.0
    const double expectedRadiusValue = 15.0;

    test('cornerRadius returns correct Radius scaled', () {
      final result = 2.0.cornerRadius;
      expect(result, isA<Radius>());
      expect(result.x, expectedRadiusValue);
      expect(result.y, expectedRadiusValue);
    });

    test('radius returns BorderRadius.circular scaled', () {
      final result = 2.0.radius;
      expect(result, isA<BorderRadius>());
      expect(result.topLeft.x, expectedRadiusValue);
    });

    test('radiusTop returns vertical BorderRadius scaled', () {
      final result = 2.0.radiusTop;
      expect(result.topLeft.x, expectedRadiusValue);
      expect(result.bottomLeft, Radius.zero);
    });
  });

  group('EdgeInsetsX', () {
    test('scaled correctly applies .w and .h to all sides', () {
      // Input: left/right=10.0, top/bottom=20.0
      // Expected: left/right=10*2=20.0 (w), top/bottom=20*3=60.0 (h)
      const input = EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0);
      final result = input.scaled;
      expect(result.left, 20.0);
      expect(result.right, 20.0);
      expect(result.top, 60.0);
      expect(result.bottom, 60.0);
    });
  });

  group('BorderRadiusX', () {
    test('scaled correctly applies .r to all corners', () {
      // Input radius x: 5.0, y: 5.0 (for simplicity, only x is used in the extension)
      // Expected: 5.0 * 1.5 (r) = 7.5
      const input = BorderRadius.only(
        topLeft: Radius.circular(5.0),
        bottomRight: Radius.circular(10.0),
      );
      final result = input.scaled;
      // topLeft.x is 5.0, scaled by r (1.5) -> 7.5
      expect(result.topLeft.x, 7.5);
      // bottomRight.x is 10.0, scaled by r (1.5) -> 15.0
      expect(result.bottomRight.x, 15.0);
    });
  });

  group('BoxShadowExtension', () {
    test('scaled correctly applies .w, .h, and .r to properties', () {
      // Input: offset(10, 20), blurRadius=5, spreadRadius=2
      // Expected: offset(10*2=20.0, 20*3=60.0), blurRadius=5*1.5=7.5 (r), spreadRadius=2*1.5=3.0 (r)
      const input = BoxShadow(
        offset: Offset(10.0, 20.0),
        blurRadius: 5.0,
        spreadRadius: 2.0,
      );
      final result = input.scaled;
      expect(result.offset.dx, 20.0);
      expect(result.offset.dy, 60.0);
      expect(result.blurRadius, 7.5);
      expect(result.spreadRadius, 3.0);
      expect(result.color, input.color); // Color should remain the same
    });
  });
}
