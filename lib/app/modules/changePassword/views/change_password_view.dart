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
    // Bound by ChangePasswordBinding; GetView already finds the controller.
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
                child: Form(
                  key: controller.formKey,
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
                      SizedBox(height: R.h(4)),
                      Text(
                        'password.subtitle'.trns(),
                        style: TextStyle(
                          fontSize: R.sp(13),
                          color: AppColors.grey,
                        ),
                      ),
                      SizedBox(height: R.h(20)),

                      _buildLabel('password.old'.trns()),
                      Obx(() => InputField(
                            controller: controller.oldPasswordController,
                            hintText: 'password.old_hint'.trns(),
                            obscureText: controller.obscureOld.value,
                            borderRadius: 12,
                            textInputAction: TextInputAction.next,
                            validator: controller.requiredValidator,
                            suffixIcon: _VisibilityToggle(
                              visible: !controller.obscureOld.value,
                              onTap: () => controller.obscureOld.toggle(),
                            ),
                          )),
                      SizedBox(height: R.h(16)),

                      _buildLabel('password.new_pass'.trns()),
                      Obx(() => InputField(
                            controller: controller.newPasswordController,
                            hintText: 'password.new_hint'.trns(),
                            obscureText: controller.obscureNew.value,
                            borderRadius: 12,
                            textInputAction: TextInputAction.next,
                            validator: controller.newPasswordValidator,
                            suffixIcon: _VisibilityToggle(
                              visible: !controller.obscureNew.value,
                              onTap: () => controller.obscureNew.toggle(),
                            ),
                          )),
                      SizedBox(height: R.h(16)),

                      _buildLabel('password.repeat'.trns()),
                      Obx(() => InputField(
                            controller:
                                controller.repeatPasswordController,
                            hintText: 'password.repeat_hint'.trns(),
                            obscureText:
                                controller.obscureRepeat.value,
                            borderRadius: 12,
                            textInputAction: TextInputAction.done,
                            validator: controller.repeatValidator,
                            suffixIcon: _VisibilityToggle(
                              visible:
                                  !controller.obscureRepeat.value,
                              onTap: () =>
                                  controller.obscureRepeat.toggle(),
                            ),
                          )),

                      SizedBox(height: R.h(40)),

                      Obx(() => SizedBox(
                            height: R.h(55),
                            child: MainBtn(
                              text: 'password.save'.trns(),
                              color: AppColors.primary,
                              borderRadius: 12,
                              isLoading: controller.isSaving.value,
                              onPressed: controller.isSaving.value
                                  ? null
                                  : controller.savePassword,
                            ),
                          )),
                    ],
                  ),
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

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.visible, required this.onTap});

  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: R.w(12)),
        child: Icon(
          visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: R.sp(20),
          color: AppColors.grey,
        ),
      ),
    );
  }
}
