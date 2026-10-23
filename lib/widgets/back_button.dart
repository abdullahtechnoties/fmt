import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
/// Shared back button used across all screens
class BackButton extends StatelessWidget {
  const BackButton({super.key, this.dark = true});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: dark ? Colors.transparent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.chevron_left_rounded,
          size: 28,
          color: dark ? AppColors.black : AppColors.black,
        ),
      ),
    );
  }
}