import 'package:fmt/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkTheme {
  ThemeData darkTheme(BuildContext context) => ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkScaffold,
    fontFamily: GoogleFonts.beVietnamPro().fontFamily,
  );
}
