import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fmt/utilities/colors.dart';

/// Auth-specific pill-shaped input field matching Figma designs.
/// Uses light grey fill, grey border, teal focus border.
class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  static const double _radius = 30.0;
  static const double _borderWidth = 1.2;

  static final _fieldStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static final _hintStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  OutlineInputBorder _border(Color color,
      [double width = _borderWidth]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      enabled: enabled,
      inputFormatters: inputFormatters,
      style: _fieldStyle,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: _hintStyle,
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 10),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minHeight: 52,
          minWidth: 52,
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 14),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minHeight: 52,
          minWidth: 52,
        ),
        border: _border(Colors.grey, 0.8),
        enabledBorder: _border(Colors.transparent),
        focusedBorder: _border(AppColors.primary, 1.5),
        disabledBorder: _border(Colors.transparent),
        errorBorder: _border(AppColors.red, 1.5),
        focusedErrorBorder: _border(AppColors.red, 1.5),
        errorStyle: TextStyle(
          fontSize: 11,
          color: AppColors.red,
        ),
      ),
    );
  }
}