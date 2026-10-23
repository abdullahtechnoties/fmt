import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utilities/colors.dart';

/// Pill-shaped text field: grey border when idle, **primary** border when
/// focused by default; **[loginStyle]** uses orange borders + muted hints;
/// **[signupStyle]** uses grey idle and orange focus (signup form).
/// Typed text is black; hint/placeholder is grey (or muted for [loginStyle]).
///
/// Use for email, username, password (`obscureText: true`), etc.
class InputField extends StatelessWidget {
  const InputField({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.loginStyle = false,
    this.signupStyle = false,
    this.borderRadius,
  }) : assert(
         controller == null || initialValue == null,
         'Use either controller or initialValue, not both.',
       ),
       assert(
         !loginStyle || !signupStyle,
         'Use only one of loginStyle or signupStyle.',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// Orange borders + muted hints (login screen design).
  final bool loginStyle;

  /// Grey border when idle, orange when focused (signup screen design).
  final bool signupStyle;

  /// Custom border radius for the input field
  final double? borderRadius;

  static const double _radius = 999;
  static const double _borderWidth = 1.5;

  static final TextStyle _fieldStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static final TextStyle _hintStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.placeholderBackground,
  );

  static final TextStyle _loginHintStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.placeholderBackground,
  );

  OutlineInputBorder _border(Color color, [double width = _borderWidth]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? _radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      autofillHints: autofillHints,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      style: _fieldStyle,
      cursorColor: (loginStyle || signupStyle)
          ? AppColors.secondary
          : AppColors.primary,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: loginStyle ? _loginHintStyle : _hintStyle,
        floatingLabelStyle: (loginStyle ? _loginHintStyle : _hintStyle)
            .copyWith(
              color: loginStyle ? AppColors.secondary : AppColors.primary,
            ),
        hintText: hintText,
        hintStyle: loginStyle ? _loginHintStyle : _hintStyle,
        isDense: true,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 22,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(
          minHeight: 48,
          minWidth: 48,
        ),
        border: _border(AppColors.inputBorder),
        enabledBorder: _border(
          loginStyle ? AppColors.secondary : AppColors.inputBorder,
        ),
        focusedBorder: _border(
          loginStyle
              ? AppColors.secondary
              : (signupStyle ? AppColors.secondary : AppColors.primary),
          (loginStyle || signupStyle) ? 2 : _borderWidth,
        ),
        disabledBorder: _border(AppColors.inputBorder.withValues(alpha: 0.45)),
        errorBorder: _border(AppColors.secondary),
        focusedErrorBorder: _border(AppColors.secondary),
      ),
    );
  }
}

/// Dropdown input field with pill-shaped design similar to InputField
class DropdownInputField extends StatelessWidget {
  const DropdownInputField({
    super.key,
    this.hintText,
    this.value,
    this.items,
    this.onChanged,
    this.signupStyle = false,
    this.borderRadius,
  });

  final String? hintText;
  final String? value;
  final List<String>? items;
  final void Function(String?)? onChanged;
  final bool signupStyle;
  final double? borderRadius;

  static const double _radius = 999;
  static const double _borderWidth = 1.5;

  static final TextStyle _fieldStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static final TextStyle _hintStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.placeholderBackground,
  );

  OutlineInputBorder _border(Color color, [double width = _borderWidth]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? _radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items?.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: _fieldStyle.copyWith(color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      style: _fieldStyle.copyWith(color: Colors.black),
      hint: Text(
        hintText ?? '',
        style: _hintStyle,
      ),
      isDense: true,
      isExpanded: true,
      dropdownColor: AppColors.white,
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: _hintStyle,
        isDense: true,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 22,
        ),
        suffixIcon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondary),
        suffixIconConstraints: const BoxConstraints(
          minHeight: 48,
          minWidth: 48,
        ),
        border: _border(AppColors.inputBorder),
        enabledBorder: _border(AppColors.inputBorder),
        focusedBorder: _border(AppColors.primary, 2),
        disabledBorder: _border(AppColors.inputBorder.withValues(alpha: 0.45)),
        errorBorder: _border(AppColors.primary),
        focusedErrorBorder: _border(AppColors.secondary),
      ),
    );
  }
}
