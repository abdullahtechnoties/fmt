import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CommonTextInputField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLength;
  final int? maxLines;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool showPrefixIcon;
  final bool showSuffixIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? textFontSize;
  final FontWeight? textFontWeight;
  final Color? hintTextColor;
  final double? borderRadius;
  final double? topLeftBorderRadius;
  final double? topRightBorderRadius;
  final double? bottomLeftBorderRadius;
  final double? bottomRightBorderRadius;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final String? initialValue;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final double hintTextSize;
  final double? height;
  final List<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlignVertical? textAlignVertical;

  const CommonTextInputField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.showPrefixIcon = false,
    this.backgroundColor,
    this.textColor,
    this.hintTextColor,
    this.borderRadius,
    this.onChanged,
    this.onTap,
    this.initialValue,
    this.enabled = true,
    this.contentPadding,
    this.topLeftBorderRadius,
    this.topRightBorderRadius,
    this.bottomLeftBorderRadius,
    this.bottomRightBorderRadius,
    this.showSuffixIcon = false,
    this.hintTextSize = 12,
    this.height = 45,
    this.textFontSize,
    this.textFontWeight,
    this.autofillHints,
    this.inputFormatters,
    this.textAlignVertical,
  });

  @override
  State<CommonTextInputField> createState() => CommonTextInputFieldState();
}

class CommonTextInputFieldState extends State<CommonTextInputField> {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Container(
      height: widget.height,
      decoration: BoxDecoration(borderRadius: _getBorderRadius()),
      child: TextFormField(
        initialValue: widget.initialValue,
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        onTap: widget.onTap,
        autofillHints: widget.autofillHints,
        style: TextStyle(
          color:
              widget.textColor ??
              (themeController.isDarkMode.value
                  ? AppColors.primary
                  : AppColors.primary),
          fontSize: widget.textFontSize ?? 12,
          fontWeight: widget.textFontWeight ?? FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor:
              widget.backgroundColor ??
              (themeController.isDarkMode.value
                  ? AppColors.transparent
                  : AppColors.white),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color:
                widget.hintTextColor ??
                (themeController.isDarkMode.value
                    ? AppColors.primary
                    : AppColors.primary),
            fontWeight: FontWeight.w500,
            fontSize: widget.hintTextSize,
          ),
          contentPadding:
              widget.contentPadding ??
              const EdgeInsets.only(left: 16, right: 16),
          border: OutlineInputBorder(
            borderRadius: _getBorderRadius(),
            borderSide: BorderSide(
              color:
                  themeController.isDarkMode.value
                      ? Color(0xFF5D6765)
                      : AppColors.black.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: _getBorderRadius(),
            borderSide: BorderSide(
              color:
                  themeController.isDarkMode.value
                      ? Color(0xFF5D6765)
                      : AppColors.black.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: _getBorderRadius(),
            borderSide: BorderSide(
              color:
                  themeController.isDarkMode.value
                      ? Color(0xFF5D6765)
                      : AppColors.black.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: _getBorderRadius(),
            borderSide: BorderSide(
              color: AppColors.error.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: _getBorderRadius(),
            borderSide: BorderSide(
              color: AppColors.error.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          errorStyle: TextStyle(
            color: AppColors.error,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          suffixIcon:
              widget.showSuffixIcon ? widget.suffixIcon ?? SizedBox() : null,
          prefixIcon:
              widget.showPrefixIcon ? widget.prefixIcon ?? SizedBox() : null,
          counterText: "",
        ),
        validator: widget.validator,
        onChanged: widget.onChanged,
        inputFormatters: widget.inputFormatters,
        textAlignVertical: widget.textAlignVertical,
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(
        widget.topLeftBorderRadius ?? widget.borderRadius ?? 10,
      ),
      topRight: Radius.circular(
        widget.topRightBorderRadius ?? widget.borderRadius ?? 10,
      ),
      bottomLeft: Radius.circular(
        widget.bottomLeftBorderRadius ?? widget.borderRadius ?? 10,
      ),
      bottomRight: Radius.circular(
        widget.bottomRightBorderRadius ?? widget.borderRadius ?? 10,
      ),
    );
  }
}