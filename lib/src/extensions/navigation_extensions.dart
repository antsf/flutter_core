/// Navigation and dialog extension methods for BuildContext.
library navigation_extensions;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Navigation and UI helper extensions for BuildContext
extension NavigationExtension on BuildContext {
  /// Navigate to a new screen using routeName
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushNamed<T>(
        routeName,
        arguments: arguments,
      );

  /// Replace current screen with a new one using routeName
  Future<T?> pushReplacementNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushReplacementNamed<T, Object?>(
        routeName,
        arguments: arguments,
      );

  /// Navigate to a new screen and remove all previous screens using routeName
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushNamedAndRemoveUntil<T>(
        routeName,
        (_) => false,
        arguments: arguments,
      );

  /// Navigate to a new screen
  Future<T?> push<T>(Widget page) => Navigator.of(this).push(
        MaterialPageRoute(builder: (_) => page),
      );

  /// Replace current screen with a new one
  Future<T?> pushReplacement<T>(Widget page) =>
      Navigator.of(this).pushReplacement(
        MaterialPageRoute(builder: (_) => page),
      );

  /// Navigate to a new screen and remove all previous screens
  Future<T?> pushAndRemoveUntil<T>(Widget page) =>
      Navigator.of(this).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => page),
        (_) => false,
      );

  /// Pop current screen
  void back<T>([T? result]) => Navigator.of(this).pop(result);

  bool canBack() => Navigator.canPop(this);

  void maybeBack<T extends Object?>([T? result]) {
    while (canBack()) {
      back(result);
    }
  }

  bool get isDialogOpen => ModalRoute.of(this)?.isCurrent != true;

  void closeDialog() => isDialogOpen ? back() : null;

  /// Show a dialog
  Future<T?> showDialogs<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
  }) =>
      showDialog<T>(
        context: this,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        useSafeArea: useSafeArea,
        routeSettings: routeSettings,
        builder: (_) => child,
      );

  /// Show a bottom sheet
  Future<T?> showBottomSheet<T>({
    required Widget child,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    bool isScrollControlled = false,
    bool useSafeArea = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) =>
      showModalBottomSheet<T>(
        context: this,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        isScrollControlled: isScrollControlled,
        useSafeArea: useSafeArea,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        builder: (_) => child,
      );

  /// Show a snackbar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    Color? backgroundColor,
    double? elevation,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? width,
    ShapeBorder? shape,
    SnackBarBehavior? behavior,
    Animation<double>? animation,
  }) =>
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
          backgroundColor: backgroundColor,
          elevation: elevation,
          margin: margin,
          padding: padding,
          width: width,
          shape: shape,
          behavior: behavior,
          animation: animation,
        ),
      );

  /// Show a loading dialog
  Future<void> showLoadingDialog({
    String? message,
    bool barrierDismissible = false,
  }) =>
      showDialog(
        context: this,
        barrierDismissible: barrierDismissible,
        builder: (_) => PopScope(
          canPop: false,
          child: Dialog(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    SizedBox(height: 16.h),
                    Text(message),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

  /// Show an error dialog
  Future<void> showErrorDialog({
    required String message,
    String? title,
    String? confirmText,
    VoidCallback? onConfirm,
  }) =>
      showDialog(
        context: this,
        builder: (_) => AlertDialog(
          title: title != null ? Text(title) : null,
          content: Text(message),
          actions: [
            TextButton(
              onPressed: onConfirm ?? () => back(),
              child: Text(confirmText ?? 'OK'),
            ),
          ],
        ),
      );

  /// Show a confirmation dialog
  Future<bool> showConfirmationDialog({
    required String message,
    String? title,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (_) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => back(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => back(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
