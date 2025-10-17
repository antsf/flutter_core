// test/test_helpers.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void initScreenUtilForTests() {
  // Simulasikan MediaQueryData
  const mockMediaQuery = MediaQueryData(
    size: Size(390, 844), // ukuran perangkat
    devicePixelRatio: 3.0,
    textScaler: TextScaler.linear(1.0),
    padding: EdgeInsets.zero,
    viewInsets: EdgeInsets.zero,
    // orientation: Orientation.portrait,
  );

  // Inisialisasi ScreenUtil secara manual
  ScreenUtil.configure(
    data: mockMediaQuery,
    designSize: const Size(375, 812), // ukuran desain UI
    minTextAdapt: true,
    splitScreenMode: false,
  );
}

TextStyle setFontForTesting(
    {double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing}) {
  return TextStyle(
    fontFamily: 'Inter', // just the name, no actual loading
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}
