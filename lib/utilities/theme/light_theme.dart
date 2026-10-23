import 'package:fmt/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightTheme {
  ThemeData lightTheme(BuildContext context) => ThemeData(
    brightness: Brightness.light,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldBg,
    fontFamily: GoogleFonts.beVietnamPro().fontFamily,
  );
}
