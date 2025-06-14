/// Extension methods for TextStyle to simplify text styling and scaling.
library text_style_extension;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension TextStyleExtension on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle fontSize(double value) => copyWith(fontSize: value.sp);
  TextStyle heightSpace(double value) => copyWith(height: value);
  TextStyle letterSpace(double value) => copyWith(letterSpacing: value);
  TextStyle withColor(Color color) => copyWith(color: color);
}
