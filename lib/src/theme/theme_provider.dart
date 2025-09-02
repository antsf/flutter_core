// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'theme.dart';

// /// Theme provider for managing app themes
// class ThemeProvider extends ChangeNotifier {
//   static ThemeProvider? _instance;
//   static const String themeBoxName = 'theme_box';
//   static const String _themeKey = 'theme_mode';
//   static const String _colorSchemeKey = 'color_scheme';

//   ThemeData _currentTheme = AppTheme.defaultLightTheme;
//   bool _isDarkMode = false;
//   String _currentColorScheme = 'default';
//   Duration _themeTransitionDuration = const Duration(milliseconds: 300);
//   Curve _themeTransitionCurve = Curves.easeInOut;

//   ThemeProvider._();

//   /// Get the singleton instance
//   static ThemeProvider get instance => _instance ??= ThemeProvider._();

//   /// Configure the theme provider with custom settings
//   static void configure({
//     ThemeData? lightTheme,
//     ThemeData? darkTheme,
//     TextTheme? textTheme,
//     ColorScheme? colorScheme,
//   }) {
//     _instance ??= ThemeProvider._();
//     if (lightTheme != null) {
//       _instance!._currentTheme = lightTheme;
//     }
//   }

//   /// Get the current theme
//   ThemeData get currentTheme => _currentTheme;

//   bool get isDarkMode => _isDarkMode;
//   String get currentColorScheme => _currentColorScheme;
//   Duration get themeTransitionDuration => _themeTransitionDuration;
//   Curve get themeTransitionCurve => _themeTransitionCurve;

//   /// Load saved theme mode and color scheme
//   Future<void> loadThemeMode() async {
//     final box = Hive.box(themeBoxName);
//     _isDarkMode = box.get(_themeKey, defaultValue: false) as bool;
//     _currentColorScheme =
//         box.get(_colorSchemeKey, defaultValue: 'default') as String;
//     _updateTheme();
//     notifyListeners();
//   }

//   /// Save theme mode and color scheme
//   Future<void> _saveThemeSettings() async {
//     final box = Hive.box(themeBoxName);
//     await box.put(_themeKey, _isDarkMode);
//     await box.put(_colorSchemeKey, _currentColorScheme);
//   }

//   /// Update current theme based on mode and color scheme
//   void _updateTheme() {
//     final baseTheme =
//         _isDarkMode ? AppTheme.defaultDarkTheme : AppTheme.defaultLightTheme;
//     _currentTheme = baseTheme;
//   }

//   /// Toggle between light and dark theme
//   void toggleTheme() {
//     _isDarkMode = !_isDarkMode;
//     _updateTheme();
//     notifyListeners();
//   }

//   /// Set theme mode with animation
//   Future<void> setThemeMode(bool isDark) async {
//     if (_isDarkMode != isDark) {
//       _isDarkMode = isDark;
//       _updateTheme();
//       await _saveThemeSettings();
//       notifyListeners();
//     }
//   }

//   /// Set color scheme
//   Future<void> setColorScheme(String scheme) async {
//     if (_currentColorScheme != scheme) {
//       _currentColorScheme = scheme;
//       _updateTheme();
//       await _saveThemeSettings();
//       notifyListeners();
//     }
//   }

//   /// Update theme transition settings
//   void updateThemeTransition({
//     Duration? duration,
//     Curve? curve,
//   }) {
//     _themeTransitionDuration = duration ?? _themeTransitionDuration;
//     _themeTransitionCurve = curve ?? _themeTransitionCurve;
//     notifyListeners();
//   }

//   /// Preview a theme without saving
//   void previewTheme(ThemeData theme) {
//     _currentTheme = theme;
//     notifyListeners();
//   }

//   /// Reset to saved theme
//   void resetToSavedTheme() {
//     _updateTheme();
//     notifyListeners();
//   }
// }
