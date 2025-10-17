/// Text theme configurations for consistent typography across the app.
library text_theme;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

// Add a way to override the font function for testing
typedef FontBuilder = TextStyle Function(
    {double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing});

// Default uses Google Fonts
FontBuilder _defaultFont = (
        {double? fontSize,
        FontWeight? fontWeight,
        Color? color,
        double? letterSpacing}) =>
    GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing);

// Allow test to replace it
void setFontBuilderForTesting(FontBuilder builder) {
  _defaultFont = builder;
}

/// Text theme configurations
class TextThemes {
  TextThemes._();

  // Font weights
  static const FontWeight lightW = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  /// Creates a base text theme
  static TextTheme get base => TextTheme(
        displayLarge: _defaultFont(fontSize: 57.sp, fontWeight: bold),
        displayMedium: _defaultFont(fontSize: 45.sp, fontWeight: bold),
        displaySmall: _defaultFont(fontSize: 36.sp, fontWeight: bold),
        headlineLarge: _defaultFont(fontSize: 32.sp, fontWeight: semiBold),
        headlineMedium: _defaultFont(fontSize: 28.sp, fontWeight: semiBold),
        headlineSmall: _defaultFont(fontSize: 22.sp, fontWeight: semiBold),
        titleLarge: _defaultFont(
            fontSize: 18.sp,
            letterSpacing: 0,
            color: FcColors.primaryText,
            fontWeight: bold),
        titleMedium: _defaultFont(
            fontSize: 16.sp,
            letterSpacing: 0,
            fontWeight: bold,
            color: FcColors.primaryText),
        titleSmall: _defaultFont(
          fontSize: 14.sp,
          letterSpacing: 0,
          fontWeight: bold,
          color: FcColors.primaryText,
        ),
        bodyLarge: _defaultFont(
            fontSize: 14.sp,
            letterSpacing: 0,
            fontWeight: regular,
            color: FcColors.primaryText),
        bodyMedium: _defaultFont(
            fontSize: 12.sp,
            letterSpacing: 0,
            fontWeight: regular,
            color: FcColors.primaryText),
        bodySmall: _defaultFont(
            fontSize: 10.sp,
            letterSpacing: 0,
            fontWeight: medium,
            color: FcColors.secondaryText),
        labelLarge: _defaultFont(
            fontSize: 16.sp,
            letterSpacing: 0,
            fontWeight: bold,
            color: FcColors.primaryText),
        labelMedium: _defaultFont(
            fontSize: 14.sp,
            letterSpacing: 0,
            fontWeight: regular,
            color: FcColors.primaryText),
        labelSmall: _defaultFont(
            fontSize: 12.sp,
            letterSpacing: 0,
            fontWeight: medium,
            color: FcColors.primaryText),
      );

  /// Creates a light text theme
  static TextTheme get light => base.apply(
        bodyColor: FcColors.primaryText,
        displayColor: FcColors.primaryText,
      );

  /// Creates a dark text theme
  static TextTheme get dark => base.apply(
        bodyColor: FcColors.darkText,
        displayColor: FcColors.darkText,
      );
}
