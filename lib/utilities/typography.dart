import 'package:flutter/material.dart';
import 'package:fmt/utilities/colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1({Color color = AppColors.black}) =>
      TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle heading2({Color color = AppColors.black}) =>
      TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle heading3({Color color = AppColors.black}) =>
      TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle sectionTitle({Color color = AppColors.black}) =>
      TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle bodyLarge({Color color = AppColors.black}) =>
      TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle body({Color color = AppColors.grey}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodyMedium({Color color = AppColors.black}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle small({Color color = AppColors.grey}) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle smallMedium({Color color = AppColors.grey}) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle tiny({Color color = AppColors.grey}) =>
      TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle tinyMedium({Color color = AppColors.grey}) =>
      TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle price({Color color = AppColors.black}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle priceStrike({Color color = AppColors.lightGrey}) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        decoration: TextDecoration.lineThrough,
        decorationColor: color,
      );

  static TextStyle buttonText({Color color = AppColors.white}) =>
      TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.5,
      );

  static TextStyle seeAll({Color color = AppColors.primary}) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle categoryLabel({Color color = AppColors.black}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: color
      );

  static TextStyle countBadge({Color color = AppColors.grey}) =>
      TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle bannerTitle({Color color = AppColors.white}) =>
      TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.1,
      );

  static TextStyle bannerSubtitle({Color color = AppColors.white}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle countdown({Color color = AppColors.white}) =>
      TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: color,
      );
}