import 'package:flutter/material.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/widgets/delivery_address_sheet.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/profile_menu_item.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Bound by ProfileBinding; GetView already finds the controller.
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
              child: Obx(() {
                if (Get.find<AuthService>().currentUser.value == null) {
                  return _GuestPrompt();
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.loadAddress,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: R.w(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: R.h(16)),

                        // User Info Header (live user, initial placeholder)
                        Row(
                          children: [
                            _Avatar(
                              imageUrl: controller.userAvatar,
                              initial: controller.userInitial,
                            ),
                            SizedBox(width: R.w(16)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.userName,
                                    style: TextStyle(
                                      fontSize: R.sp(18),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkGrey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: R.h(4)),
                                  if (controller.userEmail.isNotEmpty)
                                    Text(
                                      controller.userEmail,
                                      style: TextStyle(
                                        fontSize: R.sp(14),
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.mediumGrey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),

                        SizedBox(height: R.h(32)),

                        // Section 1: Personal Information
                        _buildSectionTitle(
                            'profile.personal_info'.trns()),
                        ProfileMenuItem(
                            icon: Icons.person_outline,
                            title: 'profile.my_profile'.trns(),
                            onTap: controller.goToEditProfile),
                        _AddressMenuItem(
                          subtitle: controller.deliveryLine.isEmpty
                              ? controller.billingLine
                              : controller.deliveryLine,
                          onTap: () =>
                              showDeliveryAddressSheet(
                            initial: controller.deliveryLine,
                            onSave: controller.saveDeliveryAddress,
                          ),
                        ),
                        // COD only for v1 — the API stores no payment
                        // methods, so this row stays informational.
                        // ProfileMenuItem(
                        //     icon: Icons.credit_card_outlined,
                        //     title: 'profile.payment_method'.trns(),
                        //     onTap: () {}),
                        ProfileMenuItem(
                            icon: Icons.receipt_long_outlined,
                            title: 'profile.order_history'.trns(),
                            onTap: controller.goToOrderHistory),

                        SizedBox(height: R.h(24)),

                        // Section 2: Support & Information
                        _buildSectionTitle(
                            'profile.support_info'.trns()),
                        ProfileMenuItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'profile.privacy_policy'.trns(),
                            onTap: () {
                              Get.toNamed(Routes.PRIVACY_POLICY);
                            }),
                        ProfileMenuItem(
                            icon: Icons.description_outlined,
                            title: 'profile.terms_conditions'.trns(),
                            onTap: () {
                              Get.toNamed(Routes.PRIVACY_POLICY);
                            }),
                        ProfileMenuItem(
                            icon: Icons.help_outline,
                            title: 'profile.faqs'.trns(),
                            onTap: () {
                              Get.toNamed(Routes.FAQS);
                            }),

                        SizedBox(height: R.h(24)),

                        // Section 3: Account Management
                        _buildSectionTitle(
                            'profile.account_management'.trns()),
                        ProfileMenuItem(
                            icon: Icons.lock_outline,
                            title: 'profile.change_password'.trns(),
                            onTap: controller.goToChangePassword),
                        Obx(() => _LogoutItem(
                              isBusy: controller.isLoggingOut.value,
                              onTap: controller.logout,
                            )),

                        SizedBox(height: R.h(90)),
                      ],
                    ),
                  ),
                );
              }),
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

/// Initial-circle placeholder until the backend serves avatars (the
/// account API has no photo upload, so this stays for now).
class _Avatar extends StatelessWidget {
  const _Avatar({this.imageUrl, required this.initial});

  final String? imageUrl;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return CircleAvatar(
        radius: R.h(32),
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: Text(
          initial,
          style: TextStyle(
            fontSize: R.sp(24),
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: R.h(32),
      backgroundColor: AppColors.shimmerBase,
      child: ClipOval(
        child: AppCachedImage(
          imageUrl: url,
          width: R.h(64),
          height: R.h(64),
          showShimmer: false,
        ),
      ),
    );
  }
}

/// Shipping/delivery row: opens the single-address bottom sheet and shows
/// the current line underneath.
class _AddressMenuItem extends StatelessWidget {
  const _AddressMenuItem({required this.subtitle, required this.onTap});

  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: R.h(14)),
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: R.sp(22), color: AppColors.darkGrey),
            SizedBox(width: R.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'profile.shipping_address'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(15),
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty) ...[
                    SizedBox(height: R.h(2)),
                    Text(
                      subtitle.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.sp(12),
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: R.sp(22), color: AppColors.darkGrey),
          ],
        ),
      ),
    );
  }
}

/// Logout lives beneath Change Password: warning dialog first, then the
/// token is revoked, local data cleared and the user lands on login.
class _LogoutItem extends StatelessWidget {
  const _LogoutItem({required this.isBusy, required this.onTap});

  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isBusy ? null : onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: R.h(14)),
        child: Row(
          children: [
            if (isBusy)
              SizedBox(
                width: R.sp(22),
                height: R.sp(22),
                child: const CircularProgressIndicator(
                  color: AppColors.red,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(Icons.logout,
                  size: R.sp(22), color: AppColors.red),
            SizedBox(width: R.w(16)),
            Expanded(
              child: Text(
                'profile.logout_btn'.trns(),
                style: TextStyle(
                  fontSize: R.sp(15),
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown on the profile tab while browsing as a guest: prompt login.
class _GuestPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.w(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: R.w(84),
              height: R.w(84),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: R.sp(38),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: R.h(16)),
            Text(
              'auth.required_title'.trns(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: R.sp(18),
                fontWeight: FontWeight.w700,
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: R.h(8)),
            Text(
              'auth.required_profile'.trns(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: R.sp(14),
                color: AppColors.mediumGrey,
              ),
            ),
            SizedBox(height: R.h(20)),
            SizedBox(
              height: R.h(50),
              child: MainBtn(
                text: 'auth.login_btn'.trns(),
                color: AppColors.primary,
                borderRadius: 12,
                onPressed: () => Get.toNamed(Routes.LOGIN),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
