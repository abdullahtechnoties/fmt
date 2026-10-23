import 'package:flutter/material.dart';
import 'package:fmt/app/modules/forgotPassword/controllers/forgot_password_controller.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/auth_usable.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context); // Ensure responsive initialized

    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: R.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthLogo(),
              
              Text(
                'auth.forgot_password_title'.trns(),
                style: TextStyle(
                  fontSize: R.sp(32),
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: R.h(30)),

              // Email
              SizedBox(
                height: R.h(60),
                child: InputField(
                  controller: controller.forgotPasswordEmailController,
                  hintText: 'auth.email_hint'.trns(),
                  borderRadius: 12,
                  prefixIcon: Icon(Icons.email, color: AppColors.grey, size: R.sp(22)),
                ),
              ),
              
              SizedBox(height: R.h(16)),

              // Reset Info Text
              Text(
                'auth.reset_password_desc'.trns(),
                style: TextStyle(
                  fontSize: R.sp(13),
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                  height: 1.4,
                ),
              ),

              SizedBox(height: R.h(30)),

              // Submit Button
              Obx(() => SizedBox(
                height: R.h(60),
                child: MainBtn(
                  text: 'auth.submit_btn'.trns(),
                  color: AppColors.primary, 
                  borderRadius: 12,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.performForgotPassword,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}