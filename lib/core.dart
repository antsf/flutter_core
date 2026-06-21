/// Exports core functionalities, services, and UI utilities for Flutter applications.
///
/// This library serves as the main entry point for the `flutter_corekit` package.
/// It provides the [FlutterCore] class for initializing essential services like
/// networking and storage, and the [ScreenUtilWrapper] widget for setting up
/// responsive UI utilities.
///
/// ## Usage
///
/// Before using any services from this package, you must initialize [FlutterCore]:
///
/// ```dart
/// import 'package:flutter_corekit/flutter_corekit.dart';
/// import 'package:flutter/material.dart';
///
/// void main() async {
///   // Ensure Flutter bindings are initialized for async operations before runApp.
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize Flutter Core services (e.g., network, storage).
///   await FlutterCore.initialize(baseUrl: 'https://api.example.com');
///
///   runApp(MyApp());
/// }
/// ```
///
/// Then, wrap your root widget (usually `MaterialApp`) with [ScreenUtilWrapper]
/// to enable responsive screen sizing:
///
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ScreenUtilWrapper(
///       // designSize is optional, defaults to 375x812
///       child: MaterialApp(
///         home: MyHomePage(),
///       ),
///     );
///   }
/// }
/// ```
library;

import 'package:dio/dio.dart' show Dio, Interceptor;
import 'package:flutter/material.dart';
import 'package:flutter_corekit/src/storage/secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';

import 'src/network/dio_client.dart';
import 'src/services/connectivity_service.dart';

/// Main class for initializing and accessing core functionalities of the Flutter Core package.
///
/// This class provides static methods to initialize services like networking
/// ([dioClient]) and secure storage ([secureStorage]).
///
/// The [initialize] method **must** be called before accessing any services.
///
/// Accessing services before initialization will result in a [LateInitializationError].
class FlutterCore {
  /// A private flag to track whether [initialize] has been called.
  /// This prevents redundant initializations.
  static bool _isInitialized = false;

  /// Provides access to the configured [DioClient] instance for making network requests.
  ///
  /// Available after [initialize] has been successfully called.
  /// Throws a [LateInitializationError] if accessed before initialization.
  static late final DioClient dioClient;

  /// Provides access to the [SecureStorage] instance for secure data persistence.
  ///
  /// Available after [initialize] has been successfully called.
  /// Throws a [LateInitializationError] if accessed before initialization.
  static late final SecureStorage secureStorage;

  /// Initializes core non-UI services of the Flutter Core package.
  ///
  /// This method sets up:
  /// - [SecureStorage]: For secure local data storage.
  /// - [DioClient]: For network communication, configured with base URL, timeouts, and logging.
  /// - [ConnectivityService]: To monitor network connectivity status.
  ///
  /// This method **must be called once** at application startup, typically in `main()`,
  /// before `runApp()`.
  ///
  /// Parameters:
  /// - [baseUrl]: The base URL for the [DioClient] (required).
  /// - [connectTimeout]: Connection timeout for network requests in milliseconds (default: 30000ms).
  /// - [receiveTimeout]: Receive timeout for network requests in milliseconds (default: 30000ms).
  /// - [enableLogging]: Enables network request and response logging via [Logger] (default: true).
  /// If called more than once, subsequent calls will be ignored and a debug message will be printed.
  static Future<void> initialize({
    required String baseUrl,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
    bool enableLogging = true,
    Interceptor? interceptor,
    Future<String?> Function(Dio)? refreshToken,
  }) async {
    if (_isInitialized) {
      debugPrint(
          "FlutterCore.initialize() called multiple times. Ignoring subsequent calls.");
      return;
    }

    // 1. Initialize secure storage.
    secureStorage = SecureStorage();
    await secureStorage.init();

    // 2. Initialize the network client (Dio).
    dioClient = DioClient(
      baseUrl: baseUrl,
      connectTimeoutMs: connectTimeout,
      receiveTimeoutMs: receiveTimeout,
      enableLogging: enableLogging,
      logger: Logger(
        printer: PrettyPrinter(
          methodCount: 0, // Hides method stack trace in logs
          colors: true, // Enables colored logs
          printEmojis: true, // Enables emojis in logs
          dateTimeFormat:
              DateTimeFormat.onlyTimeAndSinceStart, // Log time format
        ),
      ),
      interceptor: interceptor,
      refreshToken: refreshToken, // <-- Pass refreshToken to DioClient
    );

    // 3. Initialize Connectivity Service
    // This service monitors the device's network connection status.
    // It's a singleton and can be initialized here to check initial connection state.
    await ConnectivityService.instance.hasConnection();

    _isInitialized = true;
    debugPrint("FlutterCore initialized successfully.");
  }

  /// Resets the initialization flag of FlutterCore.
  ///
  /// Primarily for testing, where services may need re-initialization between
  /// tests.
  ///
  /// **Note:** the `late final` static fields (`dioClient`, `secureStorage`)
  /// cannot be reset without restarting the app or a proper DI container, so
  /// this only resets the `_isInitialized` flag.
  static Future<void> resetInitialization() async {
    if (!_isInitialized) {
      debugPrint(
          "FlutterCore.resetInitialization() called but core is not initialized.");
      return;
    }

    _isInitialized = false;
    debugPrint(
        "FlutterCore cleaned up. Ready for re-initialization if needed.");
  }
}

/// A wrapper widget that initializes [ScreenUtil] for responsive UI development.
///
/// Place this widget at the root of your application, typically wrapping your [MaterialApp]
/// or [CupertinoApp]. It enables the use of `.w`, `.h`, and `.sp` extensions on numbers
/// for creating responsive dimensions and font sizes based on a design draft size.
///
/// Example:
/// ```dart
/// ScreenUtilWrapper(
///   designSize: const Size(360, 690), // Your design draft size
///   child: MaterialApp(
///     home: HomeScreen(),
///   ),
/// )
/// ```
class ScreenUtilWrapper extends StatelessWidget {
  /// The widget below this widget in the tree, typically your main app widget.
  final Widget child;

  /// The size of the device screen in the design draft, in logical pixels.
  /// Defaults to `Size(375, 812)` (e.g., iPhone X/XS/11 Pro).
  final Size designSize;

  /// Whether to adapt text size based on the screen width or the smaller of width/height.
  /// Defaults to `true`.
  final bool minTextAdapt;

  /// Whether to support screen splitting for foldable and large screen devices.
  /// Defaults to `true`.
  final bool splitScreenMode;

  /// Creates a [ScreenUtilWrapper].
  ///
  /// - [child]: The widget to be wrapped (required).
  /// - [designSize]: The screen size of the design draft (defaults to 375x812).
  /// - [minTextAdapt]: Controls text adaptation behavior (defaults to true).
  /// - [splitScreenMode]: Enables support for split screen mode (defaults to true).
  const ScreenUtilWrapper({
    super.key,
    required this.child,
    this.designSize = const Size(375, 812), // Corresponds to iPhone X/XS/11 Pro
    this.minTextAdapt = true,
    this.splitScreenMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: minTextAdapt,
      splitScreenMode: splitScreenMode,
      // The builder ensures that the child is built within the ScreenUtil context,
      // making ScreenUtil available to all descendants.
      // builder: (_, widgetChild) =>
      //     widgetChild!, // widgetChild is the 'child' passed to ScreenUtilInit
      child: child, // This is the 'child' property of ScreenUtilWrapper
    );
  }
}
