import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';

/// Manages and persists light/dark theme selection and notifies listeners.
///
/// Theme mode is a non-sensitive UI preference, so it is stored in
/// `shared_preferences` (fast) rather than secure storage.
class ThemeProvider extends ChangeNotifier {
  static ThemeProvider? _instance;

  /// `shared_preferences` key used to persist the dark-mode flag.
  static const String themeKey = 'flutter_corekit.theme_mode';

  // Optional custom themes supplied via [configure].
  ThemeData? _customLightTheme;
  ThemeData? _customDarkTheme;

  ThemeData _currentTheme = AppTheme.defaultLightTheme;
  bool _isDarkMode = false;

  ThemeProvider._();

  static ThemeProvider get instance => _instance ??= ThemeProvider._();

  /// Configure the provider with custom light/dark themes.
  /// Call once before the app starts (e.g. in `main`).
  static void configure({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    _instance ??= ThemeProvider._();
    _instance!._customLightTheme = lightTheme;
    _instance!._customDarkTheme = darkTheme;
    _instance!._updateTheme();
  }

  /// The currently active theme (custom if provided, otherwise the default).
  ThemeData get currentTheme => _currentTheme;

  /// Whether dark mode is currently active.
  bool get isDarkMode => _isDarkMode;

  /// Loads the saved theme mode from `shared_preferences`.
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(themeKey) ?? false;
    _updateTheme();
    notifyListeners();
  }

  void _updateTheme() {
    _currentTheme = _isDarkMode
        ? (_customDarkTheme ?? AppTheme.defaultDarkTheme)
        : (_customLightTheme ?? AppTheme.defaultLightTheme);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, _isDarkMode);
  }

  /// Toggles between light and dark, persisting the choice.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _updateTheme();
    await _save();
    notifyListeners();
  }

  /// Sets the theme mode explicitly, persisting the choice.
  Future<void> setThemeMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _updateTheme();
      await _save();
      notifyListeners();
    }
  }

  /// Resets the singleton instance (for testing only).
  @visibleForTesting
  static void reset() {
    _instance = null;
  }
}
