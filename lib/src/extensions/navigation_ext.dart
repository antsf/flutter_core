/// Provides extension methods on [BuildContext] for simplified navigation,
/// dialog management, and displaying SnackBars or BottomSheets.
///
/// These extensions aim to reduce boilerplate code for common UI interactions.
///
/// Example:
/// ```dart
/// // Navigate to a named route
/// context.pushNamed('/details', arguments: {'id': 123});
///
/// // Show an error dialog
/// context.showErrorDialog(message: 'Something went wrong!');
///
/// // Show a loading indicator
/// context.showLoadingDialog(message: 'Loading...');
/// // ... later
/// context.back(); // To dismiss the loading dialog
/// ```
library navigation_extensions;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Extension methods on [BuildContext] for navigation, dialogs, and transient UI elements.
extension NavigationExtension on BuildContext {
  // --- Navigation ---

  /// Navigates to a new screen using its [routeName].
  ///
  /// Wraps `Navigator.of(this).pushNamed<T>()`.
  /// [routeName]: The name of the route to push.
  /// [arguments]: Optional arguments to pass to the new route.
  Future<T?> toNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushNamed<T>(
        routeName,
        arguments: arguments,
      );

  /// Replaces the current screen with a new one using its [routeName].
  ///
  /// Wraps `Navigator.of(this).pushReplacementNamed<T, Object?>()`.
  /// [routeName]: The name of the route to push.
  /// [arguments]: Optional arguments to pass to the new route.
  Future<T?> toReplacementNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushReplacementNamed<T, Object?>(
        routeName,
        arguments: arguments,
      );

  /// Navigates to a new screen using its [routeName] and removes all previous screens
  /// from the navigation stack.
  ///
  /// Wraps `Navigator.of(this).pushNamedAndRemoveUntil<T>()`.
  /// [routeName]: The name of the route to push.
  /// [arguments]: Optional arguments to pass to the new route.
  Future<T?> toNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushNamedAndRemoveUntil<T>(
        routeName,
        (_) =>
            false, // Predicate that always returns false to remove all routes
        arguments: arguments,
      );

  /// Navigates to a new screen by pushing the given [page] widget.
  ///
  /// Wraps `Navigator.of(this).push()` with a [MaterialPageRoute].
  /// [page]: The widget representing the new screen.
  Future<T?> to<T extends Object?>(Widget page) => Navigator.of(this).push<T>(
        MaterialPageRoute(builder: (_) => page),
      );

  /// Replaces the current screen with a new one by pushing the given [page] widget.
  ///
  /// Wraps `Navigator.of(this).pushReplacement()` with a [MaterialPageRoute].
  /// [page]: The widget representing the new screen.
  Future<T?> toReplacement<T extends Object?>(Widget page) =>
      Navigator.of(this).pushReplacement<T, Object?>(
        MaterialPageRoute(builder: (_) => page),
      );

  /// Navigates to a new screen by pushing the given [page] widget and removes
  /// all previous screens from the navigation stack.
  ///
  /// Wraps `Navigator.of(this).pushAndRemoveUntil()` with a [MaterialPageRoute].
  /// [page]: The widget representing the new screen.
  Future<T?> toAndRemoveUntil<T extends Object?>(Widget page) =>
      Navigator.of(this).pushAndRemoveUntil<T>(
        MaterialPageRoute(builder: (_) => page),
        (_) =>
            false, // Predicate that always returns false to remove all routes
      );

  /// Pops the current screen from the navigation stack.
  ///
  /// Wraps `Navigator.of(this).pop<T>(result)`.
  /// [result]: An optional value to return to the previous screen.
  void back<T extends Object?>([T? result]) =>
      Navigator.of(this).pop<T>(result);

  /// Checks if the navigator can be popped.
  ///
  /// Wraps `Navigator.canPop(this)`.
  bool canBack() => Navigator.canPop(this);

  /// Pops all routes until the initial route.
  /// If a [result] is provided, it's passed to the pop method for each route.
  ///
  /// **Caution**: This will pop all routes above the very first route in the stack.
  /// Ensure this is the desired behavior.
  void maybeBack<T extends Object?>([T? result]) {
    while (canBack()) {
      back<T>(result);
    }
  }

  // --- Keyboard & Focus ---
  /// Unfocuses all focus nodes, hiding the keyboard if open.
  void unfocusKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Requests focus for the given [FocusNode].
  void requestFocus(FocusNode node) {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(this).requestFocus(node);
  }

  /// Returns true if any input field currently has focus.
  bool get hasFocus => FocusManager.instance.primaryFocus != null;

  /// Returns true if the keyboard is currently visible.
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  // --- Dialogs & Modals ---

  /// Checks if a dialog is currently open over this context.
  ///
  /// This is a heuristic and might not be universally accurate for all types of
  /// modal routes or dialog implementations. It checks if the current route
  /// associated with this context is the topmost active route.
  bool get isDialogOpen => ModalRoute.of(this)?.isCurrent != true;

  /// Attempts to close an open dialog if [isDialogOpen] is true.
  ///
  /// Uses [back] to pop the current route, which is assumed to be a dialog.
  /// See caveats for [isDialogOpen].
  void closeDialog() {
    if (isDialogOpen) {
      back();
    }
  }

  /// Shows a generic dialog using `showDialog<T>()`.
  ///
  /// [child]: The widget to display as the dialog's content.
  /// [barrierDismissible]: Whether the dialog can be dismissed by tapping the barrier. Defaults to `true`.
  /// Other parameters correspond to the `showDialog` function.
  Future<T?> showDialogs<T extends Object?>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor, // Defaults to `Colors.black54`
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

  /// Shows a modal bottom sheet using `showModalBottomSheet<T>()`.
  ///
  /// [child]: The widget to display in the bottom sheet.
  /// Other parameters correspond to the `showModalBottomSheet` function.
  Future<T?> showBottomSheet<T extends Object?>({
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

  /// Shows a [SnackBar] using `ScaffoldMessenger.of(this).showSnackBar()`.
  ///
  /// [message]: The text message to display.
  /// Other parameters correspond to the [SnackBar] properties.
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
    SnackBarBehavior?
        behavior, // Defaults to SnackBarBehavior.fixed for Material 2, .floating for Material 3
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

  /// Shows a simple loading dialog with a [CircularProgressIndicator].
  ///
  /// The dialog is not dismissible by default and uses [PopScope] to prevent back dismissal.
  ///
  /// [message]: Optional text message to display below the indicator.
  /// [barrierDismissible]: Whether the dialog can be dismissed by tapping the barrier. Defaults to `false`.
  Future<void> showLoadingDialog({
    String? message,
    bool barrierDismissible = false,
  }) =>
      showDialog<void>(
        context: this,
        barrierDismissible: barrierDismissible,
        builder: (_) => PopScope(
          canPop:
              barrierDismissible, // Only allow pop if barrierDismissible is true
          child: Dialog(
            child: Padding(
              padding: EdgeInsets.all(16.w), // Scaled padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    SizedBox(height: 16.h), // Scaled spacing
                    Text(message),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

  /// Shows an error dialog using [AlertDialog].
  ///
  /// [message]: The error message to display.
  /// [title]: Optional title for the dialog.
  /// [confirmText]: Text for the confirmation button. Defaults to "OK".
  /// [onConfirm]: Callback when the confirm button is pressed. Defaults to popping the dialog.
  Future<void> showErrorDialog({
    required String message,
    String? title,
    String? confirmText,
    VoidCallback? onConfirm,
  }) =>
      showDialog<void>(
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

  /// Shows a confirmation dialog using [AlertDialog] and returns a [Future<bool>]
  /// indicating whether the user confirmed (true) or cancelled (false).
  ///
  /// [message]: The message to display in the dialog.
  /// [title]: Optional title for the dialog.
  /// [confirmText]: Text for the confirm button. Defaults to "Yes".
  /// [cancelText]: Text for the cancel button. Defaults to "No".
  /// Returns `true` if confirmed, `false` if cancelled or dialog dismissed.
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
            onPressed: () => back(false), // Cancel returns false
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => back(true), // Confirm returns true
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ??
        false; // If dialog is dismissed, result is null, treat as false
  }
}
