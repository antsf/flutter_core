import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// --- MOCK DEPENDENCIES ---

// 1. Mock FcColors class and methods
class FcColors {
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFC400);
  static const Color info = Color(0xFF29B6F6);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color transparent = Color(0x00000000);

  // Mock implementation for color manipulation methods
  static Color withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity);
  static Color darken(Color color, [double amount = 0.1]) =>
      Color.lerp(color, Colors.black, amount)!;
  static Color lighten(Color color, [double amount = 0.1]) =>
      Color.lerp(color, Colors.white, amount)!;
  static Color blend(Color color1, Color color2, [double ratio = 0.5]) =>
      Color.lerp(color1, color2, ratio)!;
}

// 2. Mock ScreenUtil extension for TextStyleExtension
// .sp usually scales the font size. We mock it to just return the value.
extension MockScreenUtil on num {
  double get sp => toDouble();
}

// 3. Mock BuildContext and ThemeData Setup
// This is necessary to access theme properties via BuildContext extensions.

// Define Mock ColorScheme and TextTheme for predictable testing
final mockColorScheme = const ColorScheme.light().copyWith(
  primary: const Color(0xFF0000FF), // Blue
  secondary: const Color(0xFF00FF00), // Green
  tertiary: const Color(0xFFFF0000), // Red
  error: const Color(0xFFFF00FF), // Magenta
  surface: const Color(0xFFCCCCCC),
  outline: const Color(0xFF333333),
);

const mockTextTheme = TextTheme(
  displayLarge: TextStyle(fontSize: 50.0),
  headlineMedium: TextStyle(fontSize: 30.0),
  bodySmall: TextStyle(fontSize: 12.0),
);

// Mock extension for BuildContext to provide access to ThemeData
extension MockBuildContextExtensions on BuildContext {
  ThemeData get theme => ThemeData.from(colorScheme: mockColorScheme)
      .copyWith(textTheme: mockTextTheme);
}

// --- EXTENSIONS UNDER TEST (Copied/Inlined for testing environment) ---

// ColorContextExtensions
extension ColorContextExtensions on BuildContext {
  ColorScheme get colorScheme => theme.colorScheme;
  Color get primaryColor => colorScheme.primary;
  Color get primaryContainerColor => colorScheme.primaryContainer;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get onPrimaryContainerColor => colorScheme.onPrimaryContainer;

  Color get secondaryColor => colorScheme.secondary;
  Color get secondaryContainerColor => colorScheme.secondaryContainer;
  Color get onSecondaryColor => colorScheme.onSecondary;
  Color get onSecondaryContainerColor => colorScheme.onSecondaryContainer;

  Color get tertiaryColor => colorScheme.tertiary;
  Color get tertiaryContainerColor => colorScheme.tertiaryContainer;
  Color get onTertiaryColor => colorScheme.onTertiary;
  Color get onTertiaryContainerColor => colorScheme.onTertiaryContainer;

  Color get errorColor => colorScheme.error;
  Color get errorContainerColor => colorScheme.errorContainer;
  Color get onErrorColor => colorScheme.onError;
  Color get onErrorContainerColor => colorScheme.onErrorContainer;

  Color get surfaceContainerColor => colorScheme.surfaceContainer;
  Color get surfaceColor => colorScheme.surface;
  Color get outlineColor => colorScheme.outline;
  Color get outlineVariantColor => colorScheme.outlineVariant;

  Color get onSurfaceColor => colorScheme.onSurface;
  Color get onSurfaceVariantColor => colorScheme.onSurfaceVariant;

  Color get successColor => FcColors.success;
  Color get warningColor => FcColors.warning;
  Color get infoColor => FcColors.info;
  Color get disabledColor => FcColors.disabled;

  Color get transparentColor => FcColors.transparent;

  Color withOpacity(Color color, double opacity) =>
      FcColors.withOpacity(color, opacity);
  Color darken(Color color, [double amount = 0.1]) =>
      FcColors.darken(color, amount);
  Color lighten(Color color, [double amount = 0.1]) =>
      FcColors.lighten(color, amount);
  Color blend(Color color1, Color color2, [double ratio = 0.5]) =>
      FcColors.blend(color1, color2, ratio);
}

// TextThemeExtensions
extension TextThemeExtensions on BuildContext {
  TextTheme get textTheme => theme.textTheme;

  // Display styles
  TextStyle? get displayLarge => textTheme.displayLarge;
  TextStyle? get displayMedium => textTheme.displayMedium;
  TextStyle? get displaySmall => textTheme.displaySmall;

  TextStyle? get displayLargeBold =>
      textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get displayMediumBold =>
      textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold);
  TextStyle? get displaySmallBold =>
      textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get displayLargeItalic =>
      textTheme.displayLarge?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get displayMediumItalic =>
      textTheme.displayMedium?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get displaySmallItalic =>
      textTheme.displaySmall?.copyWith(fontStyle: FontStyle.italic);

  // Headline styles (testing only one for brevity)
  TextStyle? get headlineMedium => textTheme.headlineMedium;

  TextStyle? get headlineMediumBold =>
      textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold);

  // Title styles (omitted for brevity, covered by Display/Headline)
  TextStyle? get titleLarge => textTheme.titleLarge;

  // Body styles
  TextStyle? get bodySmall => textTheme.bodySmall;

  TextStyle? get bodySmallItalic =>
      textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic);

  // Label styles (omitted for brevity)
  TextStyle? get labelLarge => textTheme.labelLarge;
}

// TextStyleExtension (The modified version)
extension TextStyleExtension on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  TextStyle get strikethrough =>
      copyWith(decoration: TextDecoration.lineThrough);
  TextStyle fontSizes(double value) => copyWith(fontSize: value.sp);
  TextStyle heightSpace(double value) => copyWith(height: value);
  TextStyle letterSpace(double value) => copyWith(letterSpacing: value);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withOverflow(TextOverflow overflow) => copyWith(overflow: overflow);
}

// --- TEST EXECUTION ---

void main() {
  // Use a mock widget to provide a BuildContext
  late BuildContext testContext;
  // setUp(() {
  //   testContext = find.byType(Placeholder).evaluate().first;
  // });

  // A helper function to create a testable context
  // This is required because find.byType().evaluate() needs to be run inside a widget test.
  // We use `MaterialApp` and `Placeholder` to create the context tree.
  Widget buildTestWidget() {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          testContext = context;
          return const Placeholder();
        },
      ),
    );
  }

  group('ColorContextExtensions', () {
    testWidgets('accesses standard ColorScheme colors correctly',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(testContext.primaryColor, mockColorScheme.primary);
      expect(testContext.secondaryColor, mockColorScheme.secondary);
      expect(testContext.tertiaryColor, mockColorScheme.tertiary);
      expect(testContext.errorColor, mockColorScheme.error);
      expect(testContext.surfaceColor, mockColorScheme.surface);
      expect(testContext.outlineColor, mockColorScheme.outline);
    });

    testWidgets('accesses custom FcColors correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(testContext.successColor, FcColors.success);
      expect(testContext.warningColor, FcColors.warning);
      expect(testContext.disabledColor, FcColors.disabled);
    });

    testWidgets('accesses color utility methods correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      const Color baseColor = Colors.black;
      const Color targetColor = Colors.white;

      // withOpacity
      expect(testContext.withOpacity(baseColor, 0.5),
          baseColor.withValues(alpha: .5));

      // darken (mocked to lerp to black)
      expect(
        testContext.darken(targetColor, 0.2),
        Color.lerp(targetColor, Colors.black, 0.2),
      );

      // lighten (mocked to lerp to white)
      expect(
        testContext.lighten(baseColor, 0.3),
        Color.lerp(baseColor, Colors.white, 0.3),
      );

      // blend (mocked to lerp)
      expect(
        testContext.blend(baseColor, targetColor, 0.75),
        Color.lerp(baseColor, targetColor, 0.75),
      );
    });
  });

  group('TextThemeExtensions', () {
    testWidgets('accesses base TextTheme styles correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(testContext.displayLarge, mockTextTheme.displayLarge);
      expect(testContext.headlineMedium, mockTextTheme.headlineMedium);
      expect(testContext.bodySmall, mockTextTheme.bodySmall);
      // Test a null one to ensure graceful handling
      expect(testContext.titleLarge, mockTextTheme.titleLarge);
    });

    testWidgets('accesses bold styles correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(testContext.displayLargeBold!.fontWeight, FontWeight.bold);
      expect(testContext.displayLargeBold!.fontSize,
          mockTextTheme.displayLarge!.fontSize);
      expect(testContext.headlineMediumBold!.fontWeight, FontWeight.bold);
    });

    testWidgets('accesses italic styles correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(testContext.displayLargeItalic?.fontStyle, FontStyle.italic);
      expect(testContext.bodySmallItalic!.fontStyle, FontStyle.italic);
    });
  });

  group('TextStyleExtension', () {
    const TextStyle baseStyle = TextStyle(
      fontSize: 10.0,
      color: Colors.red,
      fontWeight: FontWeight.normal,
    );

    test('applies bold weight', () {
      expect(baseStyle.bold.fontWeight, FontWeight.bold);
      // Ensure other properties are preserved
      expect(baseStyle.bold.color, baseStyle.color);
    });

    test('applies italic style', () {
      expect(baseStyle.italic.fontStyle, FontStyle.italic);
    });

    test('applies underline decoration', () {
      expect(baseStyle.underline.decoration, TextDecoration.underline);
    });

    test('applies strikethrough decoration', () {
      expect(baseStyle.strikethrough.decoration, TextDecoration.lineThrough);
    });

    test('applies font size (using mocked .sp)', () {
      // Mocked .sp returns the raw value, so fontSize should be 20.0
      expect(baseStyle.fontSizes(20.0).fontSize, 20.0);
    });

    test('applies height space', () {
      expect(baseStyle.heightSpace(1.5).height, 1.5);
    });

    test('applies letter space', () {
      expect(baseStyle.letterSpace(2.0).letterSpacing, 2.0);
    });

    test('applies color', () {
      expect(baseStyle.withColor(Colors.blue).color, Colors.blue);
    });

    test('applies overflow property', () {
      expect(baseStyle.withOverflow(TextOverflow.ellipsis).overflow,
          TextOverflow.ellipsis);
    });
  });
}
