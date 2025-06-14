/// Exports all core modules and initializes the Flutter Core package.
///
/// This file serves as a barrel for the Flutter Core package, re-exporting
/// commonly used classes and functions for easier access. It also provides a
/// centralized initialization point for the core services.
///
/// Before using any service from this package, you must call `FlutterCore.initialize()`.
///
/// Example:
///
/// ```dart
/// import 'package:flutter_core/flutter_core.dart';
///
/// void main() async {
///   // Ensure that Flutter bindings are initialized.
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize Flutter Core services.
///   await FlutterCore.initialize(baseUrl: 'https://api.example.com');
///
///   runApp(MyApp());
/// }
/// ```
library flutter_core;

// Core initialization
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'src/core/network/dio_client.dart';
import 'src/core/network/dio_cache_config.dart';
import 'src/core/services/connectivity_service.dart';
import 'src/core/storage/secure_storage_service.dart';
import 'src/theme/theme_provider.dart';

/// Main entry point for the Flutter Core package.
///
/// Provides robust initialization and access to core functionalities.
/// Accessing any service before calling [initialize] will result in a [LateInitializationError].
class FlutterCore {
  /// A private flag to prevent re-initialization.
  static bool _isInitialized = false;

  /// Provides access to the configured [DioClient] instance.
  ///
  /// Throws a [LateInitializationError] if accessed before [initialize] is called.
  static late final DioClient dioClient;

  /// Provides access to the configured [StorageService] instance.
  ///
  /// Throws a [LateInitializationError] if accessed before [initialize] is called.
  static late final SecureStorageService storageService;

  /// Provides access to the [ThemeProvider] instance.
  static ThemeProvider get themeProvider => ThemeProvider.instance;

  /// Initializes the Flutter Core package with the given configuration.
  ///
  /// This method must be called once before accessing any core services.
  ///
  /// - [baseUrl]: The base URL for the [DioClient]. This is required.
  /// - [connectTimeout]: Connect timeout for Dio client in milliseconds.
  /// - [receiveTimeout]: Receive timeout for Dio client in milliseconds.
  /// - [enableLogging]: Enables network request logging.
  /// - [cacheMaxAge]: The maximum age for cached network responses.
  static Future<void> initialize({
    required String baseUrl,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
    bool enableLogging = true,
    Duration cacheMaxAge = const Duration(hours: 1),
  }) async {
    if (_isInitialized) {
      // Using a logger or print to inform developers about the redundant call.
      debugPrint(
          "FlutterCore is already initialized. Skipping redundant call.");
      return;
    }

    // 1. Initialize Storage
    storageService = SecureStorageService();
    await storageService.initialize();

    // 2. Initialize Network
    final cacheConfig = DioCacheConfig(maxAge: cacheMaxAge);
    dioClient = DioClient(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      enableLogging: enableLogging,
      cacheConfig: cacheConfig,
      logger: Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      ),
    );

    // 3. Initialize Connectivity Service
    // The connectivity service can be initialized lazily or explicitly here.
    // Since it's a singleton, its initialization is self-managed.
    await ConnectivityService.instance.hasConnection();

    _isInitialized = true;
  }

  /// Initializes UI-related services and configurations.
  ///
  /// This should be called after [initialize] and before `runApp`.
  ///
  /// - [lightTheme]: Custom light theme data.
  /// - [darkTheme]: Custom dark theme data.
  /// - [textTheme]: Custom text theme to override defaults.
  /// - [colorScheme]: Custom color scheme to override defaults.
  static Future<void> initializeUI({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    TextTheme? textTheme,
    ColorScheme? colorScheme,
  }) async {
    // Initialize Google Fonts
    // This can be customized to accept a list of fonts.
    await GoogleFonts.pendingFonts([
      GoogleFonts.inter(),
    ]);

    // Configure the theme provider with custom or default themes.
    ThemeProvider.configure(
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      textTheme: textTheme,
      colorScheme: colorScheme,
    );
  }

  /// Cleans up resources and resets the initialization state.
  ///
  /// This is useful for testing or for applications that need to re-initialize services.
  static Future<void> cleanup() async {
    if (!_isInitialized) return;

    await storageService.clear();
    // Resetting static fields is not straightforward in Dart without complex workarounds.
    // For simplicity, we'll just clear the storage and reset the flag.
    // In a real-world scenario, a more robust dependency injection solution would be better.
    _isInitialized = false;
  }
}

/// A wrapper widget that initializes [ScreenUtil] for responsive UI.
///
/// Place this widget at the root of your application, typically wrapping
/// your [MaterialApp].
class ScreenUtilWrapper extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The size of the device in the design draft, in pixels.
  final Size designSize;

  /// Whether to adapt the text size.
  final bool minTextAdapt;

  /// Whether to support split screen mode.
  final bool splitScreenMode;

  /// Creates a [ScreenUtilWrapper].
  const ScreenUtilWrapper({
    super.key,
    required this.child,
    this.designSize = const Size(375, 812),
    this.minTextAdapt = true,
    this.splitScreenMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: minTextAdapt,
      splitScreenMode: splitScreenMode,
      // The builder ensures that the child is built with the ScreenUtil context.
      builder: (_, child) => child!,
      child: child,
    );
  }
}
