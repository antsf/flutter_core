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
library;

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
        MaterialPageRoute<T>(builder: (_) => page),
      );

  /// Replaces the current screen with a new one by pushing the given [page] widget.
  ///
  /// Wraps `Navigator.of(this).pushReplacement()` with a [MaterialPageRoute].
  /// [page]: The widget representing the new screen.
  Future<T?> toReplacement<T extends Object?>(Widget page) =>
      Navigator.of(this).pushReplacement<T, Object?>(
        MaterialPageRoute<T>(builder: (_) => page),
      );

  /// Navigates to a new screen by pushing the given [page] widget and removes
  /// all previous screens from the navigation stack.
  ///
  /// Wraps `Navigator.of(this).pushAndRemoveUntil()` with a [MaterialPageRoute].
  /// [page]: The widget representing the new screen.
  Future<T?> toAndRemoveUntil<T extends Object?>(Widget page) =>
      Navigator.of(this).pushAndRemoveUntil<T>(
        MaterialPageRoute<T>(builder: (_) => page),
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
  bool canGoBack() => Navigator.canPop(this);

  /// Pops every route until the initial (root) route is reached.
  /// If a [result] is provided, it's passed to each pop.
  ///
  /// **Caution**: this pops *all* routes above the first one in the stack — it is
  /// not a single conditional pop. Use [back] for that.
  void popToRoot<T extends Object?>([T? result]) {
    while (canGoBack()) {
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

  /// Returns true if a focusable node (e.g. a text field) currently holds
  /// primary focus.
  ///
  /// Note: this deliberately excludes [FocusScopeNode]. The root focus scope is
  /// almost always the primary focus when nothing is focused, so a plain
  /// `primaryFocus != null` check would report `true` even with no field active.
  bool get hasFocus {
    final focus = FocusManager.instance.primaryFocus;
    return focus != null && focus is! FocusScopeNode && focus.hasPrimaryFocus;
  }

  /// Returns true if the keyboard is currently visible.
  // bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  // --- Dialogs & Modals ---

  /// Whether this context's route is currently covered by another route on top
  /// (e.g. a dialog, bottom sheet, or pushed page).
  ///
  /// This is a heuristic: it reports `true` whenever this route is not the
  /// topmost active route. It cannot tell *what* is on top (dialog vs. page).
  bool get isCoveredByRoute => ModalRoute.of(this)?.isCurrent != true;

  /// Pops the topmost route if this context's route is [isCoveredByRoute]
  /// (commonly used to dismiss an open dialog/bottom sheet).
  ///
  /// See the caveats on [isCoveredByRoute] — it dismisses whatever is on top,
  /// not specifically a dialog.
  void dismissTopRoute() {
    if (isCoveredByRoute) {
      back();
    }
  }
}
