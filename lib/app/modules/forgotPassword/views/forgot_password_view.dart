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

/// Forgot password: emails a reset link. No in-app reset — after the user
/// taps the emailed link they either deep-link back or use the web page.
class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

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
                  'auth.forgot_password_title'.trns(),
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
                      SizedBox(
                        height: R.h(60),
                        child: InputField(
                          controller: controller.emailController,
                          hintText: 'auth.email_hint'.trns(),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          borderRadius: 12,
                          prefixIcon: Icon(Icons.email,
                              color: AppColors.grey, size: R.sp(22)),
                          validator: controller.validateEmail,
                          onFieldSubmitted: (_) =>
                              controller.performForgotPassword(),
                        ),
                      ),
                      if (controller.emailError.value != null)
                        Padding(
                          padding: EdgeInsets.only(top: R.h(6), left: R.w(4)),
                          child: Text(
                            controller.emailError.value!,
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

                Obx(
                  () => controller.emailSent.value
                      ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(R.w(14)),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(R.w(12)),
                            border: Border.all(
                              color:
                                  AppColors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'auth.forgot.checkInbox'.trns(),
                            style: TextStyle(
                              fontSize: R.sp(13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                              height: 1.5,
                            ),
                          ),
                        )
                      : Text(
                          'auth.reset_password_desc'.trns(),
                          style: TextStyle(
                            fontSize: R.sp(13),
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey,
                            height: 1.4,
                          ),
                        ),
                ),

                SizedBox(height: R.h(30)),

                Obx(
                  () => SizedBox(
                    height: R.h(60),
                    child: MainBtn(
                      text: 'auth.submit_btn'.trns(),
                      color: AppColors.primary,
                      borderRadius: 12,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.performForgotPassword,
                    ),
                  ),
                ),
                SizedBox(height: R.h(24)),

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
