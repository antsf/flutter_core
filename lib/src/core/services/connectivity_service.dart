/// Connectivity service for checking network status and listening to changes.
library connectivity_service;

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for checking network connectivity and listening to changes.
///
/// This class is a singleton. Use [ConnectivityService.instance] to access it.
class ConnectivityService {
  /// Private constructor to prevent external instantiation.
  ConnectivityService._();

  static ConnectivityService? _instance;

  /// Returns the singleton instance of [ConnectivityService].
  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  /// Checks if the device currently has an internet connection.
  ///
  /// Returns `true` if connected to mobile data or Wi-Fi, otherwise `false`.
  /// Catches and logs errors, returning `false` on failure.
  Future<bool> hasConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      log("Connectivity results: $results");
      return results.isOnline;
    } catch (e, stack) {
      log("Error checking connectivity: $e", stackTrace: stack);
      return false;
    }
  }

  /// Stream of connectivity changes.
  ///
  /// Emits a list of [ConnectivityResult] whenever the connectivity changes.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Checks the current connectivity status.
  ///
  /// Returns a list of [ConnectivityResult]s.
  /// Catches and logs errors, returning an empty list on failure.
  Future<List<ConnectivityResult>> getCurrentConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e, stack) {
      log("Error getting current connectivity: $e", stackTrace: stack);
      return <ConnectivityResult>[];
    }
  }

  /// Subscribes to connectivity changes.
  ///
  /// [onData] is called with the new connectivity results.
  /// Returns a [StreamSubscription] that can be cancelled.
  /// Throws [ArgumentError] if [onData] is null.
  StreamSubscription<List<ConnectivityResult>> listenToConnectivityChanges(
    void Function(List<ConnectivityResult>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (onData == null) {
      throw ArgumentError.notNull('onData');
    }
    return _connectivity.onConnectivityChanged.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Cancels a connectivity subscription.
  ///
  /// Catches and logs errors if cancellation fails.
  void cancelConnectivitySubscription(
      StreamSubscription<List<ConnectivityResult>> subscription) {
    try {
      subscription.cancel();
    } catch (e, stack) {
      log("Error cancelling connectivity subscription: $e", stackTrace: stack);
    }
  }
}

/// Extension for [List<ConnectivityResult>] to check if online.
extension ConnectivityX on List<ConnectivityResult> {
  /// Returns `true` if the device is connected to mobile data or Wi-Fi.
  bool get isOnline =>
      contains(ConnectivityResult.mobile) || contains(ConnectivityResult.wifi);
}
