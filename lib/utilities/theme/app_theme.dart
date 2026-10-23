import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.white,
      error: AppColors.red,
    ),
    fontFamily: GoogleFonts.beVietnamPro().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.black),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
    ),
    dividerColor: AppColors.navOutline,
    extensions: const [AppColorsExtension.light],
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkScaffold,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkCard,
      error: AppColors.red,
    ),
    fontFamily: GoogleFonts.beVietnamPro().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkCard,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerColor: AppColors.darkSurface,
    extensions: const [AppColorsExtension.dark],
  );
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color scaffoldBg;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const AppColorsExtension({
    required this.scaffoldBg,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  static const light = AppColorsExtension(
    scaffoldBg: AppColors.scaffoldBg,
    cardBg: AppColors.cardBg,
    textPrimary: AppColors.black,
    textSecondary: AppColors.grey,
  );

  static const dark = AppColorsExtension(
    scaffoldBg: AppColors.darkScaffold,
    cardBg: AppColors.darkCard,
    textPrimary: AppColors.white,
    textSecondary: AppColors.lightGrey,
  );

  @override
  AppColorsExtension copyWith({
    Color? scaffoldBg,
    Color? cardBg,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AppColorsExtension(
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      cardBg: cardBg ?? this.cardBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}
