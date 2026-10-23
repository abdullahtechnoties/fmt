import 'package:flutter/material.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
// import 'package:fmt/utilities/r.dart';
// import 'package:fmt/widgets/app_cached_image.dart';
// import 'package:fmt/utilities/translation_extention.dart';
import 'package:intl/intl.dart';

final currencyFormat = NumberFormat('#,##0', 'en_US');

/// Reusable Background Gradient Scaffold
class GradientScaffold extends StatelessWidget {
  final Widget child;

  const GradientScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Reusable Sub-Page Header
class CustomHeaderBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final bool showmenu;

  const CustomHeaderBar({
    super.key,
    required this.title,
    this.onBack,
    this.onMenu,
    this.showmenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack ?? () => Get.back(),
            child: Icon(Icons.chevron_left_sharp, color: AppColors.black, size: R.sp(34)),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: R.sp(22),
              fontWeight: FontWeight.w700,
              color: AppColors.darkGrey,
            ),
          ),
          if (showmenu)
          GestureDetector(
            onTap: onMenu,
            child: Icon(Icons.menu, color: AppColors.black, size: R.sp(26)),
          ),
        ],
      ),
    );
  }
}

/// Cart Item Quantity Selector
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onDecrease,
          child: Container(
            padding: EdgeInsets.all(R.w(4)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Icon(Icons.remove, color: AppColors.primary, size: R.sp(14)),
          ),
        ),
        SizedBox(width: R.w(12)),
        Text(
          quantity.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: R.sp(14),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        SizedBox(width: R.w(12)),
        GestureDetector(
          onTap: onIncrease,
          child: Container(
            padding: EdgeInsets.all(R.w(4)),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Icon(Icons.add, color: AppColors.white, size: R.sp(14)),
          ),
        ),
      ],
    );
  }
}