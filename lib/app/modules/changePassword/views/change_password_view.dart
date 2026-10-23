import 'package:flutter/material.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/main_btn.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChangePasswordController());

    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              showmenu: false,
              title: 'password.title'.trns(),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: R.h(16)),
                    Text(
                      'password.title'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(18),
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: R.h(20)),
                    
                    _buildLabel('password.old'.trns()),
                    InputField(
                      controller: controller.oldPasswordController,
                      hintText: 'password.old_hint'.trns(),
                      obscureText: true,
                      borderRadius: 12,
                    ),
                    SizedBox(height: R.h(16)),
                    
                    _buildLabel('password.new_pass'.trns()),
                    InputField(
                      controller: controller.newPasswordController,
                      hintText: 'password.new_hint'.trns(),
                      obscureText: true,
                      borderRadius: 12,
                    ),
                    SizedBox(height: R.h(16)),
                    
                    _buildLabel('password.repeat'.trns()),
                    InputField(
                      controller: controller.repeatPasswordController,
                      hintText: 'password.repeat_hint'.trns(),
                      obscureText: true,
                      borderRadius: 12,
                    ),
                    
                    SizedBox(height: R.h(40)),
                    
                    SizedBox(
                      height: R.h(55),
                      child: MainBtn(
                        text: 'password.save'.trns(),
                        color: AppColors.primary,
                        borderRadius: 12,
                        onPressed: controller.savePassword,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(8), left: R.w(4)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: R.sp(14),
          fontWeight: FontWeight.w700,
          color: AppColors.darkGrey,
        ),
      ),
    );
  }
}