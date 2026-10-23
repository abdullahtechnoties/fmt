// Updated ProfileFormField — add textCapitalization parameter

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';

class ProfileFormField extends StatelessWidget {
  const ProfileFormField({
    super.key,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
    this.enabled = true,
    this.inputFormatters,
    this.maxLines = 1,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  static final _hintStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static final _inputStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  OutlineInputBorder _border(Color color, [double width = 1.0]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(R.w(4)),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(R.w(4)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onTap: onTap,
        validator: validator,
        readOnly: readOnly,
        enabled: enabled,
        inputFormatters: inputFormatters,
        maxLines: obscureText ? 1 : maxLines,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        style: _inputStyle,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: _hintStyle,
          isDense: true,
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: R.w(20),
            vertical: R.h(22),
          ),
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 52,
            minHeight: 52,
          ),
          border: _border(AppColors.inputBorder),
          enabledBorder: _border(AppColors.inputBorder),
          focusedBorder: _border(AppColors.primary, 1.5),
          disabledBorder: _border(
              AppColors.inputBorder.withValues(alpha: 0.5)),
          errorBorder: _border(AppColors.red, 1.5),
          focusedErrorBorder: _border(AppColors.red, 1.5),
          errorStyle: TextStyle(
            fontSize: R.sp(11),
            color: AppColors.red,
          ),
        ),
      ),
    );
  }
}