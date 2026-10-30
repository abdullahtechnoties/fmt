import 'package:flutter/material.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/main_btn.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Bound by EditProfileBinding; GetView already finds the controller.
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              showmenu: false,
              title: 'profile_edit.title'.trns(),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const _EditShimmer();
                }
                if (controller.loadError.value != null &&
                    controller.nameController.text.isEmpty) {
                  return _ErrorState(
                    message: controller.loadError.value!,
                    onRetry: controller.loadAccount,
                  );
                }
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      EdgeInsets.symmetric(horizontal: R.w(20)),
                  child: Form(
                    key: controller.formKey,
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
                          textInputAction: TextInputAction.next,
                          validator: controller.requiredValidator,
                        ),
                        SizedBox(height: R.h(16)),

                        // Login identifier — read-only.
                        _buildLabel('profile_edit.email'.trns()),
                        InputField(
                          controller: controller.emailController,
                          hintText: 'profile_edit.email_hint'.trns(),
                          keyboardType: TextInputType.emailAddress,
                          borderRadius: 12,
                          enabled: false,
                        ),
                        SizedBox(height: R.h(16)),

                        _buildLabel('profile_edit.phone'.trns()),
                        InputField(
                          controller: controller.phoneController,
                          hintText: 'profile_edit.phone_hint'.trns(),
                          keyboardType: TextInputType.phone,
                          borderRadius: 12,
                          textInputAction: TextInputAction.next,
                          validator: controller.phoneValidator,
                        ),
                        SizedBox(height: R.h(16)),

                        _buildLabel('profile_edit.alternate'.trns()),
                        InputField(
                          controller: controller.alternateController,
                          hintText:
                              'profile_edit.alternate_hint'.trns(),
                          keyboardType: TextInputType.phone,
                          borderRadius: 12,
                          textInputAction: TextInputAction.done,
                        ),

                        SizedBox(height: R.h(24)),

                        Obx(() => SizedBox(
                              height: R.h(52),
                              child: MainBtn(
                                text: 'profile_edit.save'.trns(),
                                color: AppColors.primary,
                                borderRadius: 12,
                                isLoading:
                                    controller.isSavingProfile.value,
                                onPressed:
                                    controller.isSavingProfile.value
                                        ? null
                                        : controller.saveProfile,
                              ),
                            )),

                        // ── Billing address ───────────────────────────
                        SizedBox(height: R.h(32)),
                        Text(
                          'profile_edit.billing_title'.trns(),
                          style: TextStyle(
                            fontSize: R.sp(18),
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        SizedBox(height: R.h(4)),
                        Text(
                          'profile_edit.billing_hint'.trns(),
                          style: TextStyle(
                            fontSize: R.sp(12),
                            color: AppColors.grey,
                          ),
                        ),
                        SizedBox(height: R.h(20)),

                        _buildLabel(
                            'profile_edit.billing_name'.trns()),
                        InputField(
                          controller:
                              controller.billingNameController,
                          hintText:
                              'profile_edit.full_name_hint'.trns(),
                          borderRadius: 12,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: R.h(16)),

                        _buildLabel(
                            'profile_edit.billing_phone'.trns()),
                        InputField(
                          controller:
                              controller.billingPhoneController,
                          hintText: 'profile_edit.phone_hint'.trns(),
                          keyboardType: TextInputType.phone,
                          borderRadius: 12,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: R.h(16)),

                        _buildLabel(
                            'profile_edit.billing_address'.trns()),
                        InputField(
                          controller:
                              controller.billingAddressController,
                          hintText:
                              'profile_edit.billing_address_hint'
                                  .trns(),
                          borderRadius: 12,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: R.h(16)),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('checkout.city'.trns()),
                                  InputField(
                                    controller: controller
                                        .billingCityController,
                                    hintText:
                                        'checkout.enter_city'.trns(),
                                    borderRadius: 12,
                                    textInputAction:
                                        TextInputAction.next,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: R.w(16)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(
                                      'checkout.postal_code'.trns()),
                                  InputField(
                                    controller: controller
                                        .billingZipController,
                                    hintText:
                                        'checkout.enter_postal'.trns(),
                                    keyboardType:
                                        TextInputType.number,
                                    borderRadius: 12,
                                    textInputAction:
                                        TextInputAction.next,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: R.h(16)),

                        _buildLabel('checkout.country'.trns()),
                        InputField(
                          controller:
                              controller.billingCountryController,
                          hintText: 'checkout.enter_country'.trns(),
                          borderRadius: 12,
                          textInputAction: TextInputAction.done,
                        ),

                        SizedBox(height: R.h(24)),

                        Obx(() => SizedBox(
                              height: R.h(52),
                              child: MainBtn(
                                text: 'profile_edit.billing_save'
                                    .trns(),
                                color: AppColors.primary,
                                borderRadius: 12,
                                isLoading:
                                    controller.isSavingBilling.value,
                                onPressed:
                                    controller.isSavingBilling.value
                                        ? null
                                        : controller.saveBilling,
                              ),
                            )),

                        SizedBox(height: R.h(40)),
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

class _EditShimmer extends StatelessWidget {
  const _EditShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: R.w(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: R.h(16)),
          ShimmerBox(width: R.w(160), height: R.h(20), borderRadius: 6),
          SizedBox(height: R.h(20)),
          for (var i = 0; i < 4; i++) ...[
            ShimmerBox(width: R.w(120), height: R.h(14), borderRadius: 6),
            SizedBox(height: R.h(8)),
            ShimmerBox(
                width: double.infinity, height: R.h(52), borderRadius: 12),
            SizedBox(height: R.h(16)),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined,
              size: R.sp(48), color: AppColors.lightGrey),
          SizedBox(height: R.h(12)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(48)),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: R.sp(14), color: AppColors.mediumGrey),
            ),
          ),
          SizedBox(height: R.h(16)),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.w(10)),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: R.w(24), vertical: R.h(12)),
            ),
            child: Text(
              'common.retry'.trns(),
              style: TextStyle(
                color: AppColors.white,
                fontSize: R.sp(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
