/// Provides various UI and device-related helper extensions on [BuildContext],
/// [num], [EdgeInsets], [BorderRadius], and [BoxShadow].
///
/// These extensions simplify access to MediaQuery, Theme, platform information,
/// and allow for creating responsive spacing and dimensions using [ScreenUtil]
/// and predefined constants like [kPadding] and [kRadius].
library ui_extensions;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/default.dart'; // For kPadding, kRadius

// --- BuildContext Extensions ---

/// Extension methods on [BuildContext] to conveniently access screen properties,
/// theme data, platform information, and device characteristics.
extension BuildContextExtension on BuildContext {
  //region Screen Information
  /// Returns the [Size] of the media query's screen.
  Size get screenSize => MediaQuery.of(this).size;
  /// Returns the width of the media query's screen.
  double get screenWidth => screenSize.width;
  /// Returns the height of the media query's screen.
  double get screenHeight => screenSize.height;
  /// Returns the [Orientation] of the media query's screen.
  Orientation get orientation => MediaQuery.of(this).orientation;
  /// Returns `true` if the device orientation is portrait.
  bool get isPortrait => orientation == Orientation.portrait;
  /// Returns `true` if the device orientation is landscape.
  bool get isLandscape => orientation == Orientation.landscape;
  /// Returns the device's pixel ratio.
  double get pixelRatio => MediaQuery.of(this).devicePixelRatio;
  /// Returns the [TextScaler] for the current media query.
  TextScaler get textScaler => MediaQuery.of(this).textScaler;
  //endregion

  //region Safe Area and Insets
  /// Returns the padding needed to avoid system intrusions (e.g., status bar, notches).
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;
  /// Returns the insets created by system UI, like the keyboard.
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  /// Returns the padding representing the view area.
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  /// Returns the system gesture insets.
  EdgeInsets get systemGestureInsets => MediaQuery.of(this).systemGestureInsets;
  /// Returns the height of the status bar.
  double get statusBarHeight => safeAreaPadding.top;
  /// Returns the height of the bottom safe area (e.g., for navigation gestures).
  double get bottomSafeAreaHeight => safeAreaPadding.bottom;
  /// Returns the current height of the on-screen keyboard.
  double get keyboardHeight => viewInsets.bottom;
  /// Returns `true` if the keyboard is currently visible.
  bool get isKeyboardVisible => keyboardHeight > 0;
  //endregion

  //region Theme Access
  /// Returns the current [ThemeData].
  ThemeData get theme => Theme.of(this);
  /// Returns the current [TextTheme] from the theme.
  TextTheme get text => theme.textTheme;
  /// Returns the current [ColorScheme] from the theme.
  ColorScheme get color => theme.colorScheme;
  /// Returns the primary color from the theme.
  Color get primaryColor => theme.primaryColor;
  /// Returns the secondary (accent) color from the theme's color scheme.
  Color get accentColor => theme.colorScheme.secondary;
  /// Returns the scaffold background color from the theme.
  Color get backgroundColor => theme.scaffoldBackgroundColor;
  /// Returns the card color from the theme.
  Color get cardColor => theme.cardColor;
  /// Returns the error color from the theme's color scheme.
  Color get errorColor => theme.colorScheme.error;
  /// Returns the divider color from the theme.
  Color get dividerColor => theme.dividerColor;
  /// Returns the disabled color from the theme.
  Color get disabledColor => theme.disabledColor;
  /// Returns the hint color from the theme.
  Color get hintColor => theme.hintColor;
  //endregion

  //region Theme Components Access
  /// Returns the default [IconThemeData].
  IconThemeData get iconTheme => theme.iconTheme;
  /// Returns the [IconThemeData] for primary icons.
  IconThemeData get primaryIconTheme => theme.primaryIconTheme;
  /// Returns the [IconThemeData] for accent-colored icons.
  IconThemeData get accentIconTheme =>
      IconThemeData(color: theme.colorScheme.secondary.withOpacity(0.7));
  /// Returns the [InputDecorationTheme].
  InputDecorationTheme get inputDecorationTheme => theme.inputDecorationTheme;
  /// Returns the [ButtonThemeData].
  ButtonThemeData get buttonTheme => theme.buttonTheme;
  /// Returns the [ElevatedButtonThemeData].
  ElevatedButtonThemeData get elevatedButtonTheme => theme.elevatedButtonTheme;
  /// Returns the [TextButtonThemeData].
  TextButtonThemeData get textButtonTheme => theme.textButtonTheme;
  /// Returns the [OutlinedButtonThemeData].
  OutlinedButtonThemeData get outlinedButtonTheme => theme.outlinedButtonTheme;
  /// Returns the [DialogTheme].
  DialogTheme get dialogTheme => theme.dialogTheme;
  /// Returns the [SnackBarThemeData].
  SnackBarThemeData get snackBarTheme => theme.snackBarTheme;
  /// Returns the [BottomSheetThemeData].
  BottomSheetThemeData get bottomSheetTheme => theme.bottomSheetTheme;
  /// Returns the [PopupMenuThemeData].
  PopupMenuThemeData get popupMenuTheme => theme.popupMenuTheme;
  /// Returns the [TooltipThemeData].
  TooltipThemeData get tooltipTheme => theme.tooltipTheme;
  /// Returns the [ChipThemeData].
  ChipThemeData get chipTheme => theme.chipTheme;
  /// Returns the [CardTheme].
  CardTheme get cardTheme => theme.cardTheme;
  /// Returns the [DividerThemeData].
  DividerThemeData get dividerTheme => theme.dividerTheme;
  /// Returns the [BottomNavigationBarThemeData].
  BottomNavigationBarThemeData get bottomNavigationBarTheme =>
      theme.bottomNavigationBarTheme;
  /// Returns the [TabBarTheme].
  TabBarTheme get tabBarTheme => theme.tabBarTheme;
  /// Returns the [FloatingActionButtonThemeData].
  FloatingActionButtonThemeData get floatingActionButtonTheme =>
      theme.floatingActionButtonTheme;
  /// Returns the [NavigationRailThemeData].
  NavigationRailThemeData get navigationRailTheme => theme.navigationRailTheme;
  /// Returns the [MaterialTapTargetSize].
  MaterialTapTargetSize get materialTapTargetSize =>
      theme.materialTapTargetSize;
  //endregion

  //region Platform Detection
  /// Returns the current [TargetPlatform].
  TargetPlatform get platform => theme.platform;
  /// Returns `true` if the current platform is iOS.
  bool get isIOS => platform == TargetPlatform.iOS;
  /// Returns `true` if the current platform is Android.
  bool get isAndroid => platform == TargetPlatform.android;
  /// Returns `true` if the current platform is macOS.
  bool get isMacOS => platform == TargetPlatform.macOS;
  /// Returns `true` if the current platform is Windows.
  bool get isWindows => platform == TargetPlatform.windows;
  /// Returns `true` if the current platform is Linux.
  bool get isLinux => platform == TargetPlatform.linux;
  /// Returns `true` if the current platform is Fuchsia.
  bool get isFuchsia => platform == TargetPlatform.fuchsia;
  /// Returns `true` if the application is running on the web. Uses `kIsWeb`.
  bool get isWeb => kIsWeb;
  /// Returns `true` if the current platform is a desktop platform (macOS, Windows, Linux).
  bool get isDesktop => isMacOS || isWindows || isLinux;
  /// Returns `true` if the current platform is a mobile platform (iOS, Android).
  bool get isMobile => isIOS || isAndroid;
  //endregion

  //region Device Type Detection (Heuristics)
  /// Returns `true` if the device is likely a tablet.
  /// This is a heuristic based on screen width (>= 600 logical pixels on mobile).
  bool get isTablet => isMobile && screenWidth >= 600;
  /// Returns `true` if the device is likely a phone.
  /// This is a heuristic based on screen width (< 600 logical pixels on mobile).
  bool get isPhone => isMobile && screenWidth < 600;
  // Note: The following device type detections are examples and might need refinement
  // based on specific project needs or more robust device detection libraries.
  /// Returns `true` if the device is likely an Apple Watch (heuristic).
  bool get isWatch => isIOS && screenWidth < 400; // Example heuristic
  /// Returns `true` if the device is likely an Android TV (heuristic).
  bool get isTV => isAndroid && screenWidth >= 1200; // Example heuristic
  //endregion

  //region Screen Size Categories (Based on Material Design Breakpoints)
  /// Returns `true` if the screen width is considered large (>= 1200dp).
  bool get isLargeScreen => screenWidth >= 1200;
  /// Returns `true` if the screen width is considered medium (>= 600dp and < 1200dp).
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;
  /// Returns `true` if the screen width is considered small (< 600dp).
  bool get isSmallScreen => screenWidth < 600;
  //endregion

  //region Display Density
  /// Returns `true` if the device pixel ratio suggests a "Retina" display (>= 2.0).
  bool get isRetina => pixelRatio >= 2.0;
  /// Returns `true` if the device pixel ratio is high (>= 1.5).
  bool get isHighDensity => pixelRatio >= 1.5;
  /// Returns `true` if the device pixel ratio is low (< 1.5).
  bool get isLowDensity => pixelRatio < 1.5;
  //endregion
}

// --- Num Extensions ---

/// Extension methods for [num] (int, double) to create responsive spacing widgets,
/// padding, and radius values using [ScreenUtil] and predefined constants.
extension NumExtension on num {
  /// Returns a [SizedBox] with responsive width and height.
  /// Both dimensions are `this * kPadding`, scaled by `.w` and `.h` respectively.
  /// Example: `1.spacing` gives `SizedBox(width: (1 * kPadding).w, height: (1 * kPadding).h)`.
  Widget get spacing => SizedBox(
        width: (this * kPadding).w,
        height: (this * kPadding).h,
      );

  /// Returns a horizontal [SizedBox] with responsive width.
  /// Width is `this * kPadding`, scaled by `.w`.
  /// Example: `0.5.spacingWidth` gives `SizedBox(width: (0.5 * kPadding).w)`.
  Widget get spacingWidth => SizedBox(width: (this * kPadding).w);

  /// Returns a vertical [SizedBox] with responsive height.
  /// Height is `this * kPadding`, scaled by `.h`.
  /// Example: `2.spacingHeight` gives `SizedBox(height: (2 * kPadding).h)`.
  Widget get spacingHeight => SizedBox(height: (this * kPadding).h);

  /// Returns responsive [EdgeInsets.all].
  /// The value is `this * kPadding`, scaled by `.w` (applied to all sides).
  /// Example: `1.padding` gives `EdgeInsets.all((1 * kPadding).w)`.
  EdgeInsets get padding => EdgeInsets.all((this * kPadding).w);

  /// Returns a responsive [BorderRadius.circular].
  /// The radius is `this * kRadius`, scaled by `.r`.
  /// Example: `1.radius` gives `BorderRadius.circular((1 * kRadius).r)`.
  BorderRadius get radius => BorderRadius.circular((this * kRadius).r);

  /// Returns a responsive [Radius.circular].
  /// The radius value is `this * kRadius`, scaled by `.r`.
  /// This is used by `UiHelper.radiusOn`.
  /// Example: `1.cornerRadius` gives `Radius.circular((1 * kRadius).r)`.
  Radius get cornerRadius => Radius.circular((this * kRadius).r);
}

// --- EdgeInsets Extensions ---

/// Extension methods for [EdgeInsets] to provide convenient scaling.
extension EdgeInsetsExtension on EdgeInsets {
  /// Returns a new [EdgeInsets] with its `left`, `right`, `top`, and `bottom`
  /// values scaled by [ScreenUtil]'s `.w` and `.h` extensions respectively.
  EdgeInsets get scaled => copyWith(
        left: left.w,
        right: right.w,
        top: top.h,
        bottom: bottom.h,
      );
}

// --- BorderRadius Extensions ---

/// Extension methods for [BorderRadius] to provide convenient scaling.
extension BorderRadiusExtension on BorderRadius {
  /// Returns a new [BorderRadius] with its corner radii scaled by [ScreenUtil]'s `.r` extension.
  /// This specifically scales the `x` component of each [Radius.elliptical].
  /// For circular radii, `x` and `y` are the same.
  BorderRadius get scaled => BorderRadius.only(
        topLeft: Radius.circular(topLeft.x.r),
        topRight: Radius.circular(topRight.x.r),
        bottomLeft: Radius.circular(bottomLeft.x.r),
        bottomRight: Radius.circular(bottomRight.x.r),
      );
}

// --- BoxShadow Extensions ---

/// Extension methods for [BoxShadow] to provide convenient scaling.
extension BoxShadowExtension on BoxShadow {
  /// Returns a new [BoxShadow] with its `offset`, `blurRadius`, and `spreadRadius`
  /// scaled by [ScreenUtil]'s `.w`, `.h`, and `.r` extensions respectively.
  BoxShadow get scaled => BoxShadow(
        color: color,
        offset: Offset(offset.dx.w, offset.dy.h), // Scale offset components
        blurRadius: blurRadius.r, // Scale blur radius
        spreadRadius: spreadRadius.r, // Scale spread radius
      );
}
