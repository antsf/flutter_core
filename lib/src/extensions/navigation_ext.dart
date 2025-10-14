/// Provides extension methods on [BuildContext] for simplified navigation,
/// dialog management, and displaying SnackBars or BottomSheets.
///
/// These extensions aim to reduce boilerplate code for common UI interactions.
///
/// Example:
/// ```dart
/// // Navigate to a named route
/// context.pushNamed('/details', arguments: {'id': 123});
/// ```
library navigation_extensions;

import 'package:flutter/material.dart';

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
  // bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

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
}
