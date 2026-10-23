import 'package:flutter/material.dart';
import 'package:fmt/app/modules/signup/controllers/signup_controller.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/auth_usable.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: R.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthLogo(),
              
              Text(
                'auth.create_account_title'.trns(),
                style: TextStyle(
                  fontSize: R.sp(32),
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: R.h(30)),

              // Email / Username
              SizedBox(
                height: R.h(60),
                child: InputField(
                  controller: controller.emailController,
                  hintText: 'auth.username_email_hint'.trns(),
                  borderRadius: 12,
                  prefixIcon: Icon(Icons.person, color: AppColors.grey, size: R.sp(22)),
                ),
              ),
              SizedBox(height: R.h(16)),

              // Password
              Obx(() => SizedBox(
                height: R.h(60),
                child: InputField(
                  controller: controller.passwordController,
                  hintText: 'auth.password_hint'.trns(),
                  obscureText: controller.isPasswordHidden.value,
                  borderRadius: 12,
                  prefixIcon: Icon(Icons.lock, color: AppColors.grey, size: R.sp(22)),
                  suffixIcon: GestureDetector(
                    onTap: controller.togglePasswordVisibility,
                    child: Icon(
                      controller.isPasswordHidden.value 
                          ? Icons.visibility 
                          : Icons.visibility_off,
                      color: AppColors.grey,
                      size: R.sp(22),
                    ),
                  ),
                ),
              )),
              SizedBox(height: R.h(16)),

              // Confirm Password
              Obx(() => SizedBox(
                height: R.h(60),
                child: InputField(
                  controller: controller.confirmPasswordController,
                  hintText: 'auth.confirm_password_hint'.trns(),
                  obscureText: controller.isConfirmPasswordHidden.value,
                  borderRadius: 12,
                  prefixIcon: Icon(Icons.lock, color: AppColors.grey, size: R.sp(22)),
                  suffixIcon: GestureDetector(
                    onTap: controller.toggleConfirmPasswordVisibility,
                    child: Icon(
                      controller.isConfirmPasswordHidden.value 
                          ? Icons.visibility 
                          : Icons.visibility_off,
                      color: AppColors.grey,
                      size: R.sp(22),
                    ),
                  ),
                ),
              )),
              
              SizedBox(height: R.h(20)),

              // Terms and Conditions RichText
              RichText(
                text: TextSpan(
                  text: 'auth.tos_prefix'.trns(),
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                    fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                  ),
                  children: [
                    TextSpan(
                      text: 'auth.tos_link'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(12),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: 'auth.tos_suffix'.trns(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.h(30)),

              // Register Button
              Obx(() => SizedBox(
                height: R.h(60),
                child: MainBtn(
                  text: 'auth.create_account_btn'.trns(),
                  color: AppColors.primary, 
                  borderRadius: 12,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.performSignUp,
                ),
              )),

              SizedBox(height: R.h(40)),

              // OR Continue With
              Center(
                child: Text(
                  'auth.or_continue_with'.trns(),
                  style: TextStyle(
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                ),
              ),
              
              SizedBox(height: R.h(20)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialLoginBtn(iconPath: AuthAssets.googleIcon, onTap: () {}),
                  SocialLoginBtn(iconPath: AuthAssets.appleIcon, onTap: () {}),
                  SocialLoginBtn(iconPath: AuthAssets.facebookIcon, onTap: () {}),
                ],
              ),

              SizedBox(height: R.h(40)),

              // Login Link
              Center(
                child: AuthBottomRichText(
                  normalText: 'auth.have_account'.trns(),
                  linkText: 'auth.login_link'.trns(),
                  onLinkTap: () => Get.back(), // Go back to login
                ),
              ),
              SizedBox(height: R.h(20)),
            ],
          ),
        ),
      ),
    );
  }
}