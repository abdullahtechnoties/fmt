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
    R.init(context);

    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: R.w(20)),
          child: Form(
            key: controller.formKey,
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
                SizedBox(height: R.h(8)),
                Text(
                  'auth.login.subtitle'.trns(),
                  style: TextStyle(
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: R.h(24)),

                // Email / WhatsApp toggle
                Obx(
                  () => Row(
                    children: [
                      _ModeChip(
                        label: 'auth.login.emailMode'.trns(),
                        selected: !controller.isWhatsappMode.value,
                        onTap: () => controller.setWhatsappMode(false),
                      ),
                      SizedBox(width: R.w(10)),
                      _ModeChip(
                        label: 'auth.login.whatsappMode'.trns(),
                        selected: controller.isWhatsappMode.value,
                        onTap: () => controller.setWhatsappMode(true),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.h(16)),

                // Email / WhatsApp
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: R.h(60),
                        child: InputField(
                          controller: controller.loginController,
                          hintText: controller.isWhatsappMode.value
                              ? 'auth.login.whatsappHint'.trns()
                              : 'auth.username_email_hint'.trns(),
                          keyboardType: controller.isWhatsappMode.value
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          borderRadius: 12,
                          prefixIcon: Icon(
                            controller.isWhatsappMode.value
                                ? Icons.phone
                                : Icons.person,
                            color: AppColors.grey,
                            size: R.sp(22),
                          ),
                          validator: controller.validateLogin,
                        ),
                      ),
                      if (controller.loginError.value != null)
                        Padding(
                          padding: EdgeInsets.only(top: R.h(6), left: R.w(4)),
                          child: Text(
                            controller.loginError.value!,
                            style: TextStyle(
                              fontSize: R.sp(12),
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: R.h(16)),

                // Password
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: R.h(60),
                        child: InputField(
                          controller: controller.passwordController,
                          hintText: 'auth.password_hint'.trns(),
                          obscureText: controller.isPasswordHidden.value,
                          textInputAction: TextInputAction.done,
                          borderRadius: 12,
                          prefixIcon: Icon(Icons.lock,
                              color: AppColors.grey, size: R.sp(22)),
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
                          validator: controller.validatePassword,
                          onFieldSubmitted: (_) => controller.performLogin(),
                        ),
                      ),
                      if (controller.passwordError.value != null)
                        Padding(
                          padding: EdgeInsets.only(top: R.h(6), left: R.w(4)),
                          child: Text(
                            controller.passwordError.value!,
                            style: TextStyle(
                              fontSize: R.sp(12),
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: R.h(12)),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.toNamed(Routes.FORGOT_PASSWORD),
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

                Obx(
                  () => SizedBox(
                    height: R.h(60),
                    child: MainBtn(
                      text: 'auth.login_btn'.trns(),
                      color: AppColors.primary,
                      borderRadius: 12,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.performLogin,
                    ),
                  ),
                ),

                SizedBox(height: R.h(50)),

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
                    SocialLoginBtn(
                        iconPath: AuthAssets.facebookIcon, onTap: () {}),
                  ],
                ),

                SizedBox(height: R.h(40)),

                Center(
                  child: AuthBottomRichText(
                    normalText: 'auth.no_account'.trns(),
                    linkText: 'auth.sign_up_link'.trns(),
                    onLinkTap: () => Get.toNamed(Routes.SIGNUP),
                  ),
                ),
                SizedBox(height: R.h(16)),

                // Guest mode: browse the store without an account.
                // Profile + checkout prompt for login when needed.
                Center(
                  child: GestureDetector(
                    onTap: controller.continueAsGuest,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(28), vertical: R.h(14)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(R.w(12)),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Text(
                        'auth.skip'.trns(),
                        style: TextStyle(
                          fontSize: R.sp(15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: R.h(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(10)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(R.w(20)),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: R.sp(13),
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.grey,
          ),
        ),
      ),
    );
  }
}
