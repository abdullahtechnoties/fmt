import 'package:flutter/material.dart';
import 'package:fmt/app/modules/orderSuccess/controllers/order_success_controller.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';

class OrderSuccessView extends GetView<OrderSuccessController> {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context); // Ensure responsive initialized

    return GradientScaffold(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(20)),
          child: Column(
            children: [
              const Spacer(flex: 1), // Pushes content slightly down for balance

              // Central Illustration / Vector
              Image.asset(
                "assets/images/order-placed.png",
                height: R.h(280),
                width: R.w(280),
                fit: BoxFit.contain,
                // Fallback grey box during development if asset is missing
                errorBuilder: (context, error, stackTrace) => Container(
                  height: R.h(280),
                  width: R.w(280),
                  decoration: const BoxDecoration(
                    color: AppColors.shimmerBase,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Vector\nHere",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grey, fontSize: R.sp(16)),
                  ),
                ),
              ),

              SizedBox(height: R.h(40)),

              // Title text
              Text(
                'order_success.title'.trns(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.sp(22),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1.3,
                ),
              ),

              SizedBox(height: R.h(16)),

              // Description text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(10)),
                child: Text(
                  'order_success.description'.trns(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(flex: 2), // Pushes button to the bottom gracefully

              // Bottom Button
              SizedBox(
                height: R.h(50),
                child: MainBtn(
                  text: 'order_success.continue_btn'.trns(),
                  color: AppColors.primary, // Teal color as per design
                  borderRadius: 12,
                  onPressed: controller.onContinueShopping,
                ),
              ),

              SizedBox(height: R.h(20)), // Bottom padding before safe area ends
            ],
          ),
        ),
      ),
    );
  }
}