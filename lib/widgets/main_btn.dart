import 'package:flutter/material.dart';
import '../utilities/colors.dart';

/// Full orange stadium button (`#FE7F14` secondary). Pass any label; it is shown in uppercase.
class MainBtn extends StatelessWidget {
  const MainBtn({
    super.key,
    required this.text,
    required this.onPressed,
    // color
    this.color,
    // radius
    this.borderRadius = 10,
    this.width,
    this.labelStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
      letterSpacing: 0.6,
    ),

    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final bool isLoading;
  final Color? color;
  final double? borderRadius;
  final TextStyle? labelStyle;


  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;
    return SizedBox(
      width: width ?? double.infinity,
      height: 66,
      child: Material(
        color: isEnabled
            ? color ?? AppColors.secondary
            : (color ?? AppColors.secondary).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : Text(text, style: labelStyle),
          ),
        ),
      ),
    );
  }
}
