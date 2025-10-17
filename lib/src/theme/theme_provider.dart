import 'package:flutter/material.dart';
import 'package:flutter_core/src/core/storage/local_storage.dart'
    show LocalStorage;
import 'theme.dart';

/// The main provider for managing and notifying listeners of theme changes.
class ThemeProvider extends ChangeNotifier {
  static ThemeProvider? _instance;
  static const String themeBoxName = 'theme_box';
  static const String themeKey = 'theme_mode';
  static const String _colorSchemeKey = 'color_scheme';
  static LocalStorage localStorage = LocalStorage();

  // These are the themes that can be customized during configuration
  ThemeData? _customLightTheme;
  ThemeData? _customDarkTheme;

  // The currently active theme, selected from custom or default themes
  ThemeData _currentTheme = AppTheme.defaultLightTheme;
  bool _isDarkMode = false;
  String _currentColorScheme = 'default';

  ThemeProvider._();

  static ThemeProvider get instance => _instance ??= ThemeProvider._();

  /// Configure the theme provider with custom light and dark themes.
  /// This method should be called once, before the app starts.
  static void configure({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    _instance ??= ThemeProvider._();
    _instance!._customLightTheme = lightTheme;
    _instance!._customDarkTheme = darkTheme;
    _instance!._updateTheme();
  }

  /// Get the current theme, which will be either a custom theme or a default.
  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  String get currentColorScheme => _currentColorScheme;

  /// Load saved theme settings from LocalStorage.
  Future<void> loadThemeMode() async {
    final isDark = await localStorage.get<bool>(themeBoxName, themeKey);
    final scheme =
        await localStorage.get<String>(themeBoxName, _colorSchemeKey);
    _isDarkMode = isDark ?? false;
    _currentColorScheme = scheme ?? 'default';
    _updateTheme();
    notifyListeners();
  }

  /// Update the current theme based on the selected mode and custom themes.
  void _updateTheme() {
    _currentTheme = _isDarkMode
        ? (_customDarkTheme ?? AppTheme.defaultDarkTheme)
        : (_customLightTheme ?? AppTheme.defaultLightTheme);
  }

  /// Save current theme settings to LocalStorage.
  Future<void> _saveThemeSettings() async {
    await localStorage.set<bool>(themeBoxName, themeKey, _isDarkMode);
    await localStorage.set<String>(
        themeBoxName, _colorSchemeKey, _currentColorScheme);
  }

  /// Toggle between light and dark theme.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _updateTheme();
    await _saveThemeSettings();
    notifyListeners();
  }

  /// Sets the theme mode explicitly.
  Future<void> setThemeMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _updateTheme();
      await _saveThemeSettings();
      notifyListeners();
    }
  }

  /// Sets the color scheme. This functionality is more illustrative
  /// as the current `_updateTheme` only uses the theme object itself.
  /// For more dynamic color schemes, the `_updateTheme` logic would
  /// need to be adjusted to merge a new color scheme into the base theme.
  Future<void> setColorScheme(String scheme) async {
    if (_currentColorScheme != scheme) {
      _currentColorScheme = scheme;
      // In a real-world scenario, you would have logic here to
      // merge the new color scheme into the current theme.
      await _saveThemeSettings();
      notifyListeners();
    }
  }

  /// Resets the singleton instance (for testing only).
  @visibleForTesting
  static void reset() {
    _instance = null;
  }
}
