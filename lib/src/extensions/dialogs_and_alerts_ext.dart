import 'package:flutter/material.dart';
import 'package:flutter_core/src/constants/colors.dart' show FcColors;
import 'package:flutter_core/src/extensions/extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;

/// A centralized extension on [BuildContext] for showing various
/// dialogs, alerts, snack bars, and bottom sheets in a clean, reusable way.
///
/// Example:
/// ```dart
///
/// // Show an error dialog
/// context.showErrorDialog(message: 'Something went wrong!');
///
/// // Show a loading indicator
/// context.showLoadingDialog(message: 'Loading...');
/// // ... later
/// context.back(); // To dismiss the loading dialog
/// ```
extension DialogsAndAlerts on BuildContext {
  /// Returns the current color scheme from the theme.
  // ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// A shortcut to `Navigator.of(this).pop(result)`.
  void back<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  /// Shows a success snack bar with a green background.
  void showSuccessAlert(String message, {VoidCallback? onClose}) {
    showSnackBar(
      message: message,
      messageStyle: labelMediumBold?.copyWith(color: FcColors.background),
      messageColor: onPrimaryColor,
      backgroundColor: successColor,
      shape: RoundedRectangleBorder(borderRadius: 0.5.radius),
      onClose: onClose,
    );
  }

  /// Shows an error snack bar with a red background.
  void showErrorAlert(String message, {VoidCallback? onClose}) {
    showSnackBar(
      message: message,
      messageStyle: labelMediumBold?.copyWith(color: FcColors.errorContainer),
      backgroundColor: errorColor,
      messageColor: FcColors.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: 0.5.radius),
      onClose: onClose,
    );
  }

  /// Shows a date picker configured for the Indonesian locale.
  ///
  /// The `initialDate` defaults to the current date and the `firstDate`
  /// defaults to the current date. The `lastDate` is hardcoded to 2045.
  Future<DateTime?> showIndonesianDatePicker({
    DateTime? initialDate,
    DateTime? firstDate,
  }) {
    // Ensure Indonesian date formats are initialized.
    initializeDateFormatting('id_ID', null);

    return showDatePicker(
      context: this,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime(2045),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate ?? DateTime.now(),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('id', 'ID'),
          child: child!,
        );
      },
    );
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
    bool isScrollControlled = true,
    bool useSafeArea = true,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = false,
    bool useRootNavigator = false,
  }) =>
      showModalBottomSheet<T>(
        context: this,
        backgroundColor: backgroundColor ?? colorScheme.surfaceContainer,
        elevation: elevation,
        shape: shape,
        isScrollControlled: isScrollControlled,
        useSafeArea: useSafeArea,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        showDragHandle: showDragHandle,
        // barrierColor: colorScheme.outline,
        useRootNavigator: useRootNavigator,
        builder: (_) => child,
      );

  /// Shows a [SnackBar] using `ScaffoldMessenger.of(this).showSnackBar()`.
  ///
  /// [message]: The text message to display.
  /// Other parameters correspond to the [SnackBar] properties.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      {required String message,
      TextStyle? messageStyle,
      Color? messageColor,
      Duration duration = const Duration(seconds: 4),
      SnackBarAction? action,
      Color? backgroundColor,
      double? elevation,
      EdgeInsetsGeometry? margin,
      EdgeInsetsGeometry? padding,
      double? width,
      ShapeBorder? shape,
      SnackBarBehavior behavior = SnackBarBehavior.floating,
      Animation<double>? animation,
      VoidCallback? onClose}) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: onClose.isNotNull
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                    message,
                    style: messageStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
                  InkWell(
                      onTap: onClose,
                      child: Icon(
                        Icons.close,
                        color: messageColor,
                        size: 16,
                      ))
                ],
              )
            : Text(message, style: messageStyle),
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
  }

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
          canPop: barrierDismissible,
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

  /// Shows an error dialog using [AlertDialog].
  ///
  /// [message]: The error message to display.
  /// [title]: Optional title for the dialog.
  /// [confirmText]: Text for the confirmation button. Defaults to "OK".
  /// [onConfirm]: Callback when the confirm button is pressed. Defaults to popping the dialog.
  Future<void> showErrorDialog({
    required String message,
    String? title,
    Widget? icon,
    String? confirmText,
    VoidCallback? onConfirm,
  }) =>
      showDialog<void>(
        context: this,
        builder: (_) => AlertDialog(
          icon: icon,
          title: title.isNotNull ? Text(title!) : null,
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
        title: title.isNotNull ? Text(title!) : null,
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
    return result ?? false;
  }
}
