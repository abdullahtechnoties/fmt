import 'package:flutter/material.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/profile_menu_item.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());

    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              title: 'profile.title'.trns(),
              onMenu: () {
                Get.find<BottomnavController>().openDrawer();
              },
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: R.h(16)),
                    
                    // User Info Header
                    Obx(() => Row(
                      children: [
                        CircleAvatar(
                          radius: R.h(32),
                          backgroundColor: AppColors.shimmerBase,
                          backgroundImage: NetworkImage(controller.userImage.value),
                        ),
                        SizedBox(width: R.w(16)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.userName.value,
                              style: TextStyle(
                                fontSize: R.sp(18),
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            SizedBox(height: R.h(4)),
                            Text(
                              controller.userEmail.value,
                              style: TextStyle(
                                fontSize: R.sp(14),
                                fontWeight: FontWeight.w400,
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
                    
                    SizedBox(height: R.h(32)),

                    // Section 1: Personal Information
                    _buildSectionTitle('profile.personal_info'.trns()),
                    ProfileMenuItem(
                      icon: Icons.person_outline, 
                      title: 'profile.my_profile'.trns(), 
                      onTap: () {
                        Get.toNamed(Routes.EDIT_PROFILE);
                      }
                    ),
                    ProfileMenuItem(
                      icon: Icons.inventory_2_outlined, 
                      title: 'profile.shipping_address'.trns(), 
                      onTap: () {}
                    ),
                    ProfileMenuItem(
                      icon: Icons.credit_card_outlined, 
                      title: 'profile.payment_method'.trns(), 
                      onTap: () {}
                    ),
                    ProfileMenuItem(
                      icon: Icons.receipt_long_outlined, 
                      title: 'profile.order_history'.trns(), 
                      onTap: () {
                        Get.toNamed(Routes.ORDER_HISTORY);
                      }
                    ),
                    
                    SizedBox(height: R.h(24)),

                    // Section 2: Support & Information
                    _buildSectionTitle('profile.support_info'.trns()),
                    ProfileMenuItem(
                      icon: Icons.privacy_tip_outlined, 
                      title: 'profile.privacy_policy'.trns(), 
                      onTap: () {
                        Get.toNamed(Routes.PRIVACY_POLICY);
                      }
                    ),
                    ProfileMenuItem(
                      icon: Icons.description_outlined, 
                      title: 'profile.terms_conditions'.trns(), 
                      onTap: () {
                        Get.toNamed(Routes.PRIVACY_POLICY);
                      }
                    ),
                    ProfileMenuItem(
                      icon: Icons.help_outline, 
                      title: 'profile.faqs'.trns(), 
                      onTap: () {}
                    ),

                    SizedBox(height: R.h(24)),

                    // Section 3: Account Management
                    _buildSectionTitle('profile.account_management'.trns()),
                    ProfileMenuItem(
                      icon: Icons.lock_outline, 
                      title: 'profile.change_password'.trns(), 
                      onTap: () {
                        Get.toNamed(Routes.CHANGE_PASSWORD);
                      }
                    ),
                    
                    SizedBox(height: R.h(90)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(12)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: R.sp(18),
          fontWeight: FontWeight.w800,
          color: AppColors.darkGrey,
        ),
      ),
    );
  }
}