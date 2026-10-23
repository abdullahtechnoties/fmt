import 'package:flutter/material.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
// import 'package:fmt/utilities/r.dart';
// import 'package:fmt/utilities/translation_extention.dart';

class CheckoutStepper extends StatelessWidget {
  final int currentStep;

  const CheckoutStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(30), vertical: R.h(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep(
            index: 0,
            title: 'checkout.shipping'.trns(),
            activeIcon: 'assets/images/check.png',
            inactiveIcon: 'assets/images/checku.png',
          ),
          _buildDivider(0),
          _buildStep(
            index: 1,
            title: 'checkout.payment'.trns(),
            activeIcon: 'assets/images/card-tick.png',
            inactiveIcon: 'assets/images/card-ticku.png',
          ),
          _buildDivider(1),
          _buildStep(
            index: 2,
            title: 'checkout.review'.trns(),
            activeIcon: 'assets/images/clipboard-tick.png',
            inactiveIcon: 'assets/images/clipboard-ticku.png',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int index,
    required String title,
    required String activeIcon,
    required String inactiveIcon,
  }) {
    final isActiveOrCompleted = currentStep >= index;

    return Column(
      children: [
        // Stepper Icon (Manual Asset Replacement Here)
        SizedBox(
          height: R.h(32),
          width: R.w(32),
          child: Image.asset(
            isActiveOrCompleted ? activeIcon : inactiveIcon,
            fit: BoxFit.contain,
            // Fallback for missing assets during development
            errorBuilder: (context, error, stackTrace) => Icon(
              index == 0 ? Icons.local_shipping : (index == 1 ? Icons.credit_card : Icons.assignment),
              color: isActiveOrCompleted ? AppColors.primary : AppColors.lightGrey,
              size: R.sp(28),
            ),
          ),
        ),
        SizedBox(height: R.h(8)),
        Text(
          title,
          style: TextStyle(
            fontSize: R.sp(12),
            fontWeight: FontWeight.w600,
            color: isActiveOrCompleted ? AppColors.primary : AppColors.lightGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(int stepIndex) {
    final isCompleted = currentStep > stepIndex;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: R.h(16), left: R.w(8), right: R.w(8)),
        child: Container(
          height: 1.5,
          color: isCompleted ? AppColors.primary : AppColors.lightGrey.withOpacity(0.5),
        ),
      ),
    );
  }
}