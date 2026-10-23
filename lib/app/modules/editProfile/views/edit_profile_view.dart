import 'package:flutter/material.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/main_btn.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EditProfileController());

    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              showmenu: false,
              title: 'profile_edit.title'.trns(),
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
                      'profile_edit.personal_info'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(18),
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: R.h(20)),
                    
                    _buildLabel('profile_edit.full_name'.trns()),
                    InputField(
                      controller: controller.nameController,
                      hintText: 'profile_edit.full_name_hint'.trns(),
                      borderRadius: 12,
                    ),
                    SizedBox(height: R.h(16)),
                    
                    _buildLabel('profile_edit.email'.trns()),
                    InputField(
                      controller: controller.emailController,
                      hintText: 'profile_edit.email_hint'.trns(),
                      keyboardType: TextInputType.emailAddress,
                      borderRadius: 12,
                    ),
                    SizedBox(height: R.h(16)),
                    
                    _buildLabel('profile_edit.phone'.trns()),
                    InputField(
                      controller: controller.phoneController,
                      hintText: 'profile_edit.phone_hint'.trns(),
                      keyboardType: TextInputType.phone,
                      borderRadius: 12,
                    ),
                    SizedBox(height: R.h(16)),
                    
                    _buildLabel('profile_edit.dob'.trns()),
                    InputField(
                      controller: controller.dobController,
                      hintText: 'profile_edit.dob_hint'.trns(),
                      borderRadius: 12,
                    ),
                    SizedBox(height: R.h(16)),
                    
                    _buildLabel('profile_edit.gender'.trns()),
                    InputField(
                      controller: controller.genderController,
                      hintText: 'profile_edit.gender_hint'.trns(),
                      borderRadius: 12,
                    ),
                    
                    SizedBox(height: R.h(40)),
                    
                    SizedBox(
                      height: R.h(55),
                      child: MainBtn(
                        text: 'profile_edit.save'.trns(),
                        color: AppColors.primary,
                        borderRadius: 12,
                        onPressed: controller.saveProfile,
                      ),
                    ),
                    
                    SizedBox(height: R.h(40)),
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