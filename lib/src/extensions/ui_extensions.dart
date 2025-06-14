/// UI and device adaptation extension methods for BuildContext and num.
library ui_extensions;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/default.dart';

/// --- BuildContext Extensions ---
/// (Screen, theme, device info, insets, density, etc.)
/// Extension methods for [BuildContext] to access screen, theme, and device info.
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
  TextTheme get text => theme.textTheme;
  ColorScheme get color => theme.colorScheme;
  Color get primaryColor => theme.primaryColor;
  Color get accentColor => theme.colorScheme.secondary;
  Color get backgroundColor => theme.scaffoldBackgroundColor;
  Color get cardColor => theme.cardColor;
  Color get errorColor => theme.colorScheme.error;
  Color get dividerColor => theme.dividerColor;
  Color get disabledColor => theme.disabledColor;
  Color get hintColor => theme.hintColor;

  // Theme Components
  IconThemeData get iconTheme => theme.iconTheme;
  IconThemeData get primaryIconTheme => theme.primaryIconTheme;
  IconThemeData get accentIconTheme =>
      IconThemeData(color: theme.colorScheme.secondary.withOpacity(0.7));
  InputDecorationTheme get inputDecorationTheme => theme.inputDecorationTheme;
  ButtonThemeData get buttonTheme => theme.buttonTheme;
  ElevatedButtonThemeData get elevatedButtonTheme => theme.elevatedButtonTheme;
  TextButtonThemeData get textButtonTheme => theme.textButtonTheme;
  OutlinedButtonThemeData get outlinedButtonTheme => theme.outlinedButtonTheme;
  DialogTheme get dialogTheme => theme.dialogTheme;
  SnackBarThemeData get snackBarTheme => theme.snackBarTheme;
  BottomSheetThemeData get bottomSheetTheme => theme.bottomSheetTheme;
  PopupMenuThemeData get popupMenuTheme => theme.popupMenuTheme;
  TooltipThemeData get tooltipTheme => theme.tooltipTheme;
  ChipThemeData get chipTheme => theme.chipTheme;
  CardTheme get cardTheme => theme.cardTheme;
  DividerThemeData get dividerTheme => theme.dividerTheme;
  BottomNavigationBarThemeData get bottomNavigationBarTheme =>
      theme.bottomNavigationBarTheme;
  TabBarTheme get tabBarTheme => theme.tabBarTheme;
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
  bool get isWeb => platform == TargetPlatform.linux; // Consider using kIsWeb
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

/// --- Num Extensions ---
/// (Spacing, padding, radius helpers)
/// Extension methods for [num] to provide spacing, padding, and radius helpers.
extension NumExtension on num {
  /// Returns a [SizedBox] with both width and height as multiples of [kPadding].
  Widget get spacing => SizedBox(
        width: (this * kPadding).w,
        height: (this * kPadding).h,
      );

  /// Returns a horizontal spacing widget.
  Widget get spacingWidth => SizedBox(width: (this * kPadding).w);

  /// Returns a vertical spacing widget.
  Widget get spacingHeight => SizedBox(height: (this * kPadding).h);

  /// Returns [EdgeInsets] with all sides as multiples of [kPadding].
  EdgeInsets get padding => EdgeInsets.all((this * kPadding).w);

  /// Returns a [BorderRadius] with all corners as multiples of [kRadius].
  BorderRadius get radius => BorderRadius.circular((this * kRadius).r);

  /// Returns a [Radius] as a multiple of [kRadius].
  Radius get cornerRadius => Radius.circular((this * kRadius).r);
}

/// --- EdgeInsets Extensions ---
/// (Scaling)
/// Extension methods for [EdgeInsets] to provide scaling.
extension EdgeInsetsExtension on EdgeInsets {
  /// Returns a scaled [EdgeInsets] using [ScreenUtil].
  EdgeInsets get scaled => copyWith(
        left: left.w,
        right: right.w,
        top: top.h,
        bottom: bottom.h,
      );
}

/// --- BorderRadius Extensions ---
/// (Scaling)
/// Extension methods for [BorderRadius] to provide scaling.
extension BorderRadiusExtension on BorderRadius {
  /// Returns a scaled [BorderRadius] using [ScreenUtil].
  BorderRadius get scaled => BorderRadius.only(
        topLeft: Radius.circular(topLeft.x.r),
        topRight: Radius.circular(topRight.x.r),
        bottomLeft: Radius.circular(bottomLeft.x.r),
        bottomRight: Radius.circular(bottomRight.x.r),
      );
}

/// --- BoxShadow Extensions ---
/// (Scaling)
/// Extension methods for [BoxShadow] to provide scaling.
extension BoxShadowExtension on BoxShadow {
  /// Returns a scaled [BoxShadow] using [ScreenUtil].
  BoxShadow get scaled => BoxShadow(
        color: color,
        offset: Offset(offset.dx.w, offset.dy.h),
        blurRadius: blurRadius.r,
        spreadRadius: spreadRadius.r,
      );
}
