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
          child: Form(
            key: controller.formKey,
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
                SizedBox(height: R.h(24)),

                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Field(
                        controller: controller.nameController,
                        hint: 'auth.signup.fullNameLabel'.trns(),
                        icon: Icons.person,
                        keyboardType: TextInputType.name,
                        action: TextInputAction.next,
                        validator: controller.required,
                        apiError: controller.errorFor('name'),
                      ),
                      SizedBox(height: R.h(16)),
                      _Field(
                        controller: controller.emailController,
                        hint: 'auth.signup.emailLabel'.trns(),
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        action: TextInputAction.next,
                        validator: controller.validateEmail,
                        apiError: controller.errorFor('email'),
                      ),
                      SizedBox(height: R.h(16)),
                      _Field(
                        controller: controller.whatsappController,
                        hint: 'auth.signup.whatsappLabel'.trns(),
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        action: TextInputAction.next,
                        validator: controller.validatePhone,
                        apiError: controller.errorFor('whatsapp'),
                      ),
                      SizedBox(height: R.h(16)),
                      _Field(
                        controller: controller.alternateNumberController,
                        hint: 'auth.signup.alternateLabel'.trns(),
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        action: TextInputAction.next,
                        validator: controller.validatePhone,
                        apiError: controller.errorFor('alternate_number'),
                      ),
                      SizedBox(height: R.h(16)),
                      Row(
                        children: [
                          Expanded(
                            child: _Field(
                              controller: controller.cityController,
                              hint: 'auth.signup.cityLabel'.trns(),
                              icon: Icons.location_city,
                              action: TextInputAction.next,
                              validator: controller.required,
                              apiError: controller.errorFor('city'),
                            ),
                          ),
                          SizedBox(width: R.w(12)),
                          Expanded(
                            child: _Field(
                              controller: controller.districtController,
                              hint: 'auth.signup.districtLabel'.trns(),
                              icon: Icons.map,
                              action: TextInputAction.next,
                              validator: controller.required,
                              apiError: controller.errorFor('district'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.h(16)),
                Obx(
                  () => _Field(
                    controller: controller.passwordController,
                    hint: 'auth.signup.passwordLabel'.trns(),
                    icon: Icons.lock,
                    obscure: controller.isPasswordHidden.value,
                    action: TextInputAction.next,
                    validator: controller.validatePassword,
                    apiError: controller.errorFor('password'),
                    suffix: GestureDetector(
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
                ),
                SizedBox(height: R.h(16)),
                Obx(
                  () => _Field(
                    controller: controller.confirmPasswordController,
                    hint: 'auth.signup.confirmPasswordLabel'.trns(),
                    icon: Icons.lock_outline,
                    obscure: controller.isConfirmPasswordHidden.value,
                    action: TextInputAction.done,
                    validator: controller.validateConfirm,
                    apiError: controller.errorFor('password_confirmation'),
                    suffix: GestureDetector(
                      onTap: controller.toggleConfirmPasswordVisibility,
                      child: Icon(
                        controller.isConfirmPasswordHidden.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.grey,
                        size: R.sp(22),
                      ),
                    ),
                    onSubmit: (_) => controller.performSignUp(),
                  ),
                ),

                SizedBox(height: R.h(20)),

                RichText(
                  text: TextSpan(
                    text: 'auth.tos_prefix'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                      fontFamily:
                          Theme.of(context).textTheme.bodyMedium?.fontFamily,
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
                      TextSpan(text: 'auth.tos_suffix'.trns()),
                    ],
                  ),
                ),

                SizedBox(height: R.h(30)),

                Obx(
                  () => SizedBox(
                    height: R.h(60),
                    child: MainBtn(
                      text: 'auth.create_account_btn'.trns(),
                      color: AppColors.primary,
                      borderRadius: 12,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.performSignUp,
                    ),
                  ),
                ),

                SizedBox(height: R.h(40)),

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
                    normalText: 'auth.have_account'.trns(),
                    linkText: 'auth.login_link'.trns(),
                    onLinkTap: () => Get.back(),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.action,
    this.validator,
    this.apiError,
    this.suffix,
    this.onSubmit,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? action;
  final FormFieldValidator<String>? validator;
  final String? apiError;
  final Widget? suffix;
  final void Function(String)? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: R.h(60),
          child: InputField(
            controller: controller,
            hintText: hint,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: action,
            borderRadius: 12,
            prefixIcon: Icon(icon, color: AppColors.grey, size: R.sp(22)),
            suffixIcon: suffix,
            validator: validator,
            onFieldSubmitted: onSubmit,
          ),
        ),
        if (apiError != null && apiError!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: R.h(6), left: R.w(4)),
            child: Text(
              apiError.toString(),
              style: TextStyle(fontSize: R.sp(12), color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
