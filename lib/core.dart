/// Exports core functionalities, services, and UI utilities for Flutter applications.
///
/// This library serves as the main entry point for the `flutter_core` package.
/// It provides the [FlutterCore] class for initializing essential services like
/// networking and storage, and the [ScreenUtilWrapper] widget for setting up
/// responsive UI utilities.
///
/// ## Usage
///
/// Before using any services from this package, you must initialize [FlutterCore]:
///
/// ```dart
/// import 'package:flutter_core/flutter_core.dart';
/// import 'package:flutter/material.dart';
///
/// void main() async {
///   // Ensure Flutter bindings are initialized for async operations before runApp.
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize Flutter Core services (e.g., network, storage).
///   await FlutterCore.initialize(baseUrl: 'https://api.example.com');
///
///   // Optionally, initialize UI-specific services like themes and fonts.
///   await FlutterCore.initializeUI();
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
library flutter_core;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

import 'src/core/network/dio_client.dart';
import 'src/core/network/dio_cache_config.dart';
import 'src/core/services/connectivity_service.dart';
import 'src/core/storage/secure_storage_service.dart';
import 'src/theme/theme_provider.dart';

/// Main class for initializing and accessing core functionalities of the Flutter Core package.
///
/// This class provides static methods to initialize services like networking ([dioClient]),
/// secure storage ([storageService]), and UI theming ([themeProvider]).
///
/// The [initialize] method **must** be called before accessing any services.
/// The [initializeUI] method can be called to set up themes and fonts.
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

  /// Provides access to the [SecureStorageService] instance for secure data persistence.
  ///
  /// Available after [initialize] has been successfully called.
  /// Throws a [LateInitializationError] if accessed before initialization.
  static late final SecureStorageService storageService;

  /// Provides access to the singleton [ThemeProvider] instance for managing app themes.
  ///
  /// This getter retrieves the instance from [ThemeProvider.instance].
  /// The [ThemeProvider] itself is configured via [initializeUI].
  static ThemeProvider get themeProvider => ThemeProvider.instance;

  /// Initializes core non-UI services of the Flutter Core package.
  ///
  /// This method sets up:
  /// - [SecureStorageService]: For secure local data storage.
  /// - [DioClient]: For network communication, configured with base URL, timeouts, logging, and caching.
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
  /// - [cacheMaxAge]: Default maximum age for cached network responses (default: 1 hour).
  ///
  /// If called more than once, subsequent calls will be ignored and a debug message will be printed.
  static Future<void> initialize({
    required String baseUrl,
    int connectTimeout = 30000, // 30 seconds
    int receiveTimeout = 30000, // 30 seconds
    bool enableLogging = true,
    Duration cacheMaxAge = const Duration(hours: 1),
  }) async {
    if (_isInitialized) {
      debugPrint(
          "FlutterCore.initialize() called multiple times. Ignoring subsequent calls.");
      return;
    }

    // 1. Initialize Secure Storage Service
    // This service is used for securely storing sensitive data.
    storageService = SecureStorageService();
    await storageService.initialize();

    // 2. Initialize Network Client (Dio)
    // Configures Dio with caching, logging, and timeout settings.
    final cacheConfig = DioCacheConfig(maxAge: cacheMaxAge);
    dioClient = DioClient(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      enableLogging: enableLogging,
      cacheConfig: cacheConfig,
      logger: Logger(
        printer: PrettyPrinter(
          methodCount: 0, // Hides method stack trace in logs
          colors: true, // Enables colored logs
          printEmojis: true, // Enables emojis in logs
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Log time format
        ),
      ),
    );

    // 3. Initialize Connectivity Service
    // This service monitors the device's network connection status.
    // It's a singleton and can be initialized here to check initial connection state.
    await ConnectivityService.instance.hasConnection();

    _isInitialized = true;
    debugPrint("FlutterCore initialized successfully.");
  }

  /// Initializes UI-related services and configurations.
  ///
  /// This method typically handles:
  /// - Google Fonts initialization (e.g., pre-loading specific fonts).
  /// - ThemeProvider configuration with custom or default light/dark themes, text themes, and color schemes.
  ///
  /// This should generally be called after [initialize] and before `runApp()`.
  ///
  /// Parameters:
  /// - [lightTheme]: Optional custom [ThemeData] for the light mode.
  /// - [darkTheme]: Optional custom [ThemeData] for the dark mode.
  /// - [textTheme]: Optional custom global [TextTheme].
  /// - [colorScheme]: Optional custom global [ColorScheme].
  static Future<void> initializeUI({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    TextTheme? textTheme,
    ColorScheme? colorScheme,
  }) async {
    // Initialize Google Fonts.
    // Example: Pre-load 'Inter' font. This can be expanded to accept a list of fonts.
    await GoogleFonts.pendingFonts([
      GoogleFonts.inter(), // Commonly used sans-serif font
    ]);

    // Configure the ThemeProvider with custom or default themes.
    // If parameters are null, ThemeProvider will use its internal defaults.
    ThemeProvider.configure(
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      textTheme: textTheme,
      colorScheme: colorScheme,
    );
    debugPrint("FlutterCore UI initialized successfully.");
  }

  /// Cleans up resources and resets the initialization state of FlutterCore.
  ///
  /// This method is primarily intended for use in testing environments where
  /// re-initialization of services might be necessary between tests.
  /// It clears data from [storageService] and resets the `_isInitialized` flag.
  ///
  /// **Note:** In a typical application lifecycle, this method should not be needed.
  /// Resetting static fields for services like `dioClient` is not straightforward
  /// in Dart without more complex dependency injection patterns. This cleanup
  /// mainly focuses on storage and the initialization flag.
  static Future<void> cleanup() async {
    if (!_isInitialized) {
      debugPrint("FlutterCore.cleanup() called but core is not initialized.");
      return;
    }

    await storageService.clear();
    // Note: dioClient and other late final static fields cannot be easily "reset"
    // to an uninitialized state without restarting the app or using more
    // sophisticated DI. This cleanup is partial.
    _isInitialized = false;
    debugPrint("FlutterCore cleaned up. Ready for re-initialization if needed.");
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
      builder: (_, widgetChild) => widgetChild!, // widgetChild is the 'child' passed to ScreenUtilInit
      child: child, // This is the 'child' property of ScreenUtilWrapper
    );
  }
}
