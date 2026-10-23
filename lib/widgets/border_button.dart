import 'package:flutter/material.dart';

import '../utilities/colors.dart';

/// White pill with orange border and orange text. Pass any label; it is shown in uppercase.
class BorderButton extends StatelessWidget {
  const BorderButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final double? width;

  static final TextStyle _labelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    letterSpacing: 0.6,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 66,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.secondary, width: 2),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Center(child: Text(text.toUpperCase(), style: _labelStyle)),
          ),
        ),
      ),
    );
  }
}
