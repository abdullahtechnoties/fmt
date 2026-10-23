import 'package:flutter/material.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/main_btn.dart';
import '../controllers/support_controller.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SupportController());

    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              title: 'support.title'.trns(),
              onMenu: () {},
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: R.h(20)),
                    
                    // Form Fields
                    _buildLabel('support.full_name'.trns()),
                    InputField(
                      controller: controller.nameController,
                      hintText: 'support.full_name_hint'.trns(),
                      borderRadius: 12,
                    ),
                    SizedBox(height: R.h(20)),
                    
                    _buildLabel('support.email'.trns()),
                    InputField(
                      controller: controller.emailController,
                      hintText: 'support.email_hint'.trns(),
                      keyboardType: TextInputType.emailAddress,
                      borderRadius: 12,
                    ),
                    SizedBox(height: R.h(20)),
                    
                    _buildLabel('support.ticket_category'.trns()),
                    Obx(() => DropdownInputField(
                      value: controller.selectedCategory.value,
                      hintText: 'support.ticket_category_hint'.trns(),
                      items: controller.categories,
                      borderRadius: 12,
                      onChanged: (val) => controller.selectedCategory.value = val,
                    )),
                    SizedBox(height: R.h(20)),
                    
                    _buildLabel('support.subject'.trns()),
                    InputField(
                      controller: controller.subjectController,
                      hintText: 'support.subject_hint'.trns(),
                      borderRadius: 12,
                    ),
                    SizedBox(height: R.h(20)),
                    
                    _buildLabel('support.describe_issue'.trns()),
                    InputField(
                      controller: controller.issueController,
                      hintText: 'support.describe_issue_hint'.trns(),
                      maxLines: 5, // Creates the text area
                      borderRadius: 12,
                    ),
                    
                    SizedBox(height: R.h(40)),
                    
                    // Submit Button
                    MainBtn(
                      text: 'support.submit'.trns(),
                      color: AppColors.primary, // Using Cyan primary instead of default orange
                      borderRadius: 12,
                      onPressed: controller.submitTicket,
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