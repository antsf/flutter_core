/// Provides a service to monitor network connectivity status and changes.
///
/// This library includes [ConnectivityService], a singleton that wraps the
/// `connectivity_plus` package to offer methods for checking current connection
/// status and listening to connectivity changes. It also provides a utility
/// extension [ConnectivityX] on `List<ConnectivityResult>` to easily determine
/// if an online connection is active.
library connectivity_service;

import 'dart:async';
import 'dart:developer' show log;

import 'package:connectivity_plus/connectivity_plus.dart';

/// A singleton service for checking network connectivity and listening to changes.
///
/// This service utilizes the `connectivity_plus` package to provide information
/// about the device's network connection state (e.g., Wi-Fi, mobile data, none).
///
/// Access the singleton instance via `ConnectivityService.instance`.
///
/// ### Example:
/// ```dart
/// // Check current connection
/// bool isConnected = await ConnectivityService.instance.hasConnection();
/// print(isConnected ? 'Device is online' : 'Device is offline');
///
/// // Listen to changes
/// final subscription = ConnectivityService.instance.listenToConnectivityChanges(
///   (results) {
///     if (results.isOnline) {
///       print('Connectivity changed: Now online');
///     } else {
///       print('Connectivity changed: Now offline');
///     }
///   },
/// );
/// // Remember to cancel the subscription when no longer needed
/// // subscription.cancel();
/// ```
class ConnectivityService {
  /// Private constructor for singleton pattern.
  ConnectivityService._();

  static ConnectivityService? _instance;

  /// Provides access to the singleton instance of [ConnectivityService].
  ///
  /// If an instance does not exist, it is created.
  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  /// Checks if the device currently has an active internet connection.
  ///
  /// An active connection is typically considered to be Wi-Fi or mobile data.
  /// See [ConnectivityX.isOnline] for the specific check.
  ///
  /// Returns `true` if an online connection is detected, `false` otherwise (including on error).
  /// Errors during the check are logged.
  Future<bool> hasConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      log("ConnectivityService: Current connectivity results: $results");
      return results.isOnline;
    } catch (e, stackTrace) {
      log("ConnectivityService: Error checking connectivity", error: e, stackTrace: stackTrace);
      return false; // Safe default in case of error
    }
  }

  /// A stream that emits events when the network connectivity changes.
  ///
  /// Each event is a `List<ConnectivityResult>`, which might contain multiple
  /// active connection types (e.g., mobile and VPN simultaneously).
  /// Use the [ConnectivityX.isOnline] extension on the list to determine overall online status.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Retrieves the current list of active connectivity types.
  ///
  /// This method provides a snapshot of the current connection state(s).
  /// Returns a list of [ConnectivityResult]s.
  /// On error, logs the error and returns an empty list.
  Future<List<ConnectivityResult>> getCurrentConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e, stackTrace) {
      log("ConnectivityService: Error getting current connectivity", error: e, stackTrace: stackTrace);
      return <ConnectivityResult>[]; // Return empty list on error
    }
  }

  /// Subscribes to changes in network connectivity.
  ///
  /// [onData]: A callback function that is invoked with a `List<ConnectivityResult>`
  ///           whenever the connectivity state changes. This parameter is required.
  /// [onError]: Optional callback for errors on the stream.
  /// [onDone]: Optional callback for when the stream is closed.
  /// [cancelOnError]: Whether the subscription should be automatically cancelled on error.
  ///
  /// Returns a [StreamSubscription] which can be used to later cancel the subscription.
  StreamSubscription<List<ConnectivityResult>> listenToConnectivityChanges({
    required void Function(List<ConnectivityResult> results) onData,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _connectivity.onConnectivityChanged.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Cancels the given [StreamSubscription] to connectivity changes.
  ///
  /// It's important to cancel subscriptions when they are no longer needed
  /// (e.g., in a widget's `dispose` method) to prevent memory leaks.
  ///
  /// [subscription]: The subscription to cancel.
  /// Errors during cancellation are logged.
  void cancelConnectivitySubscription(
      StreamSubscription<List<ConnectivityResult>>? subscription) {
    try {
      subscription?.cancel();
    } catch (e, stackTrace) {
      log("ConnectivityService: Error cancelling connectivity subscription", error: e, stackTrace: stackTrace);
    }
  }
}

/// Extension methods for `List<ConnectivityResult>` to provide utility checks.
extension ConnectivityX on List<ConnectivityResult> {
  /// Determines if the list of connectivity results indicates an online state.
  ///
  /// Returns `true` if the list contains [ConnectivityResult.mobile],
  /// [ConnectivityResult.wifi], [ConnectivityResult.ethernet], or [ConnectivityResult.vpn]
  /// (assuming VPN implies an underlying connection).
  /// Returns `false` if the list is empty, contains only [ConnectivityResult.none],
  /// or [ConnectivityResult.bluetooth] (as Bluetooth alone isn't typically internet).
  ///
  /// Note: `ConnectivityResult.other` is not explicitly checked here as its nature is undefined.
  bool get isOnline =>
      contains(ConnectivityResult.mobile) ||
      contains(ConnectivityResult.wifi) ||
      contains(ConnectivityResult.ethernet) ||
      contains(ConnectivityResult.vpn); // VPN usually implies an underlying connection.
}
