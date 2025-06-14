/// Text theme configurations for consistent typography across the app.
library text_theme;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

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
        headlineLarge: GoogleFonts.inter(
          fontWeight: bold,
          fontSize: 24.sp,
        ),
        headlineSmall: GoogleFonts.inter(
            fontSize: 20.sp, fontWeight: semiBold, color: FcColors.primaryText),
        titleLarge: GoogleFonts.inter(
            fontSize: 18.sp,
            letterSpacing: 0,
            color: FcColors.primaryText,
            fontWeight: bold),
        titleMedium: GoogleFonts.inter(
            fontSize: 16.sp,
            letterSpacing: 0,
            fontWeight: bold,
            color: FcColors.primaryText),
        titleSmall: GoogleFonts.inter(
          fontSize: 14.sp,
          letterSpacing: 0,
          fontWeight: bold,
          color: FcColors.primaryText,
        ),
        bodyLarge: GoogleFonts.inter(
            fontSize: 14.sp,
            letterSpacing: 0,
            fontWeight: regular,
            color: FcColors.primaryText),
        bodyMedium: GoogleFonts.inter(
            fontSize: 12.sp,
            letterSpacing: 0,
            fontWeight: regular,
            color: FcColors.primaryText),
        bodySmall: GoogleFonts.inter(
            fontSize: 10.sp,
            letterSpacing: 0,
            fontWeight: medium,
            color: FcColors.secondaryText),
        labelLarge: GoogleFonts.inter(
            fontSize: 16.sp,
            letterSpacing: 0,
            fontWeight: bold,
            color: FcColors.primaryText),
        labelMedium: GoogleFonts.inter(
            fontSize: 14.sp,
            letterSpacing: 0,
            fontWeight: regular,
            color: FcColors.primaryText),
        labelSmall: GoogleFonts.inter(
            fontSize: 12.sp,
            letterSpacing: 0,
            fontWeight: medium,
            color: FcColors.primaryText),
      );

  /// Creates a light text theme
  static TextTheme get light => base.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black,
      );

  /// Creates a dark text theme
  static TextTheme get dark => base.apply(
        bodyColor: Colors.white70,
        displayColor: Colors.white,
      );
}
