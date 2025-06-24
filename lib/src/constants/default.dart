/// Provides default constant values used throughout the Flutter Core package.
///
/// This library defines common values for padding, radius, durations,
/// standard UI element heights, and other reusable constants.
library fc_defaults;

import 'dart:typed_data';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Default logical padding value used as a base for spacing and insets.
///
/// This value is typically multiplied by factors in UI helper methods
/// (e.g., `UiHelper.spacing(width: 1)` would use `1 * kPadding`).
/// It represents logical pixels and might be further scaled by `ScreenUtil`
/// depending on the specific helper method.
const double kPadding = 16.0;

/// Default logical radius value for rounded corners on elements like cards or buttons.
///
/// This value represents logical pixels. UI helpers or widgets might use this
/// directly or scale it (e.g., using `.cornerRadius` extension).
const double kRadius = 10.0;

/// Default animation duration for standard transitions and animations.
///
/// Set to 300 milliseconds, a common duration for smooth UI animations.
const Duration kDuration = Duration(milliseconds: 300);

/// Standard height for the bottom navigation bar, adjusted by `ScreenUtil`.
///
/// Returns `56.h`, which means 56 logical pixels scaled vertically by `ScreenUtil`.
double get kBottomNavigationBarHeight => 56.h;

/// Standard height for the AppBar, adjusted by `ScreenUtil`.
///
/// Returns `56.h`, which means 56 logical pixels scaled vertically by `ScreenUtil`.
double get kAppBarHeight => 56.h;

/// A pre-created `Future` that completes after `kDuration`.
///
/// This can be used for simple delays in UI logic or animations.
/// However, for more complex scenarios or multiple delays, creating `Future.delayed`
/// instances on demand might be more appropriate to avoid potential reuse issues
/// if the future is expected to run multiple times.
///
/// Example:
/// ```dart
/// await kDelayed; // Waits for kDuration (300ms)
/// // Perform action after delay
/// ```
final Future<void> kDelayed = Future.delayed(kDuration);

/// A 1x1 transparent PNG image represented as a `Uint8List`.
///
/// Useful as a placeholder in `Image.memory` or other scenarios
/// where a transparent image is needed.
///
/// Bytes for a 1x1 transparent PNG:
/// `0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature`
/// `0x00, 0x00, 0x00, 0x0D, // IHDR chunk length`
/// `0x49, 0x48, 0x44, 0x52, // IHDR chunk type`
/// `0x00, 0x00, 0x00, 0x01, // Width: 1`
/// `0x00, 0x00, 0x00, 0x01, // Height: 1`
/// `0x08, // Bit depth: 8`
/// `0x06, // Color type: 6 (RGBA)`
/// `0x00, // Compression method: 0 (deflate)`
/// `0x00, // Filter method: 0`
/// `0x00, // Interlace method: 0 (no interlace)`
/// `0x1F, 0x15, 0xC4, 0x89, // CRC`
/// `0x00, 0x00, 0x00, 0x0A, // IDAT chunk length`
/// `0x49, 0x44, 0x41, 0x54, // IDAT chunk type`
/// `0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, // Image data (1x1 transparent pixel)`
/// `0x0D, 0x0A, 0x2D, 0xB4, // CRC`
/// `0x00, 0x00, 0x00, 0x00, // IEND chunk length`
/// `0x49, 0x45, 0x4E, 0x44, // IEND chunk type`
/// `0xAE, 0x42, 0x60, 0x82; // CRC`
final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
  0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
  0x49, 0x48, 0x44, 0x52, // IHDR chunk type
  0x00, 0x00, 0x00, 0x01, // Width: 1
  0x00, 0x00, 0x00, 0x01, // Height: 1
  0x08, // Bit depth: 8
  0x06, // Color type: 6 (RGBA)
  0x00, // Compression method: 0 (deflate)
  0x00, // Filter method: 0
  0x00, // Interlace method: 0 (no interlace)
  0x1F, 0x15, 0xC4, 0x89, // IHDR CRC
  0x00, 0x00, 0x00, 0x0A, // IDAT chunk length
  0x49, 0x44, 0x41, 0x54, // IDAT chunk type
  0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, // Pixel data (1x1 transparent pixel)
  0x0D, 0x0A, 0x2D, 0xB4, // IDAT CRC
  0x00, 0x00, 0x00, 0x00, // IEND chunk length
  0x49, 0x45, 0x4E, 0x44, // IEND chunk type
  0xAE, 0x42, 0x60, 0x82, // IEND CRC
]);
