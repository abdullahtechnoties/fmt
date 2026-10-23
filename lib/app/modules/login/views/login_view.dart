import 'package:flutter/material.dart';
import 'package:fmt/app/modules/login/controllers/login_controller.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/auth_usable.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';


class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
                'auth.welcome_back'.trns(),
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
              
              SizedBox(height: R.h(12)),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.toNamed(Routes.FORGOT_PASSWORD), // Replace with AppPages route
                  child: Text(
                    'auth.forgot_password_link'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: R.h(30)),

              // Login Button
              Obx(() => SizedBox(
                height: R.h(60),
                child: MainBtn(
                  text: 'auth.login_btn'.trns(),
                  color: AppColors.primary, // Using primary teal from AppColors
                  borderRadius: 12,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.performLogin,
                ),
              )),

              SizedBox(height: R.h(50)),

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

              // Social Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialLoginBtn(iconPath: AuthAssets.googleIcon, onTap: () {}),
                  SocialLoginBtn(iconPath: AuthAssets.appleIcon, onTap: () {}),
                  SocialLoginBtn(iconPath: AuthAssets.facebookIcon, onTap: () {}),
                ],
              ),

              SizedBox(height: R.h(40)),

              // Sign Up Link
              Center(
                child: AuthBottomRichText(
                  normalText: 'auth.no_account'.trns(),
                  linkText: 'auth.sign_up_link'.trns(),
                  onLinkTap: () => Get.toNamed('/signup'), // Replace with AppPages route
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