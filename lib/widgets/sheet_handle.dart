import 'package:flutter/material.dart';
import 'package:fmt/utilities/colors.dart';

/// Shared drag handle for bottom sheets
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.inputBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}