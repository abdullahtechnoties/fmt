import 'package:flutter/material.dart';
import 'package:fmt/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:fmt/app/modules/checkout/views/widgets/stepper.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:fmt/utilities/colors.dart';
// import 'package:fmt/utilities/r.dart';
// import 'package:fmt/utilities/translation_extention.dart';
// import 'package:fmt/widgets/input_field.dart';
// import 'package:fmt/widgets/main_btn.dart';
// import 'package:fmt/widgets/shared_ui_components.dart'; // GradientScaffold & CustomHeaderBar from previous
// import '../controllers/checkout_controller.dart';
// import '../widgets/checkout_stepper.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              title: 'checkout.title'.trns(),
              onBack: controller.previousStep,
              onMenu: () {},
            ),
            
            // Stepper Widget
            Obx(() => CheckoutStepper(currentStep: controller.currentStep.value)),

            // Dynamic Body
            Expanded(
              child: Obx(() {
                switch (controller.currentStep.value) {
                  case 0:
                    return _buildShippingForm();
                  case 1:
                    return _buildPaymentForm();
                  case 2:
                    return _buildReviewForm();
                  default:
                    return const SizedBox();
                }
              }),
            ),

            // Dynamic Bottom Button
            Padding(
              padding: EdgeInsets.all(R.w(20)),
              child: Obx(() {
                String btnText = '';
                if (controller.currentStep.value == 0) btnText = 'checkout.save_btn'.trns();
                else if (controller.currentStep.value == 1) btnText = 'checkout.continue_btn'.trns();
                else btnText = 'checkout.place_order_btn'.trns();

                return MainBtn(
                  text: btnText,
                  onPressed: controller.nextStep,
                  color: AppColors.primary,
                  borderRadius: 12,
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 1: SHIPPING FORM
  // ==========================================
  Widget _buildShippingForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: R.w(20)),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequiredLabel('checkout.full_name'.trns()),
          InputField(
            controller: controller.fullNameController,
            hintText: 'checkout.enter_full_name'.trns(),
            borderRadius: 12,
          ),
          SizedBox(height: R.h(16)),

          _buildRequiredLabel('checkout.phone_number'.trns()),
          InputField(
            controller: controller.phoneController,
            hintText: '000-0000000',
            keyboardType: TextInputType.phone,
            borderRadius: 12,
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: R.w(16), right: R.w(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    'https://flagcdn.com/w40/pk.png', // PK Flag (Placeholder network image)
                    width: R.w(24),
                    height: R.h(16),
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => const Icon(Icons.flag),
                  ),
                  SizedBox(width: R.w(4)),
                  Icon(Icons.keyboard_arrow_down, size: R.sp(16), color: AppColors.darkGrey),
                  SizedBox(width: R.w(8)),
                  Text(
                    '+92',
                    style: TextStyle(fontSize: R.sp(14), color: AppColors.lightGrey),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: R.h(16)),

          DropdownInputField(
            hintText: 'checkout.select_province'.trns(),
            value: controller.selectedProvince.value,
            items: controller.provinces,
            onChanged: (val) => controller.selectedProvince.value = val,
            borderRadius: 12,
          ),
          SizedBox(height: R.h(16)),

          DropdownInputField(
            
            hintText: 'checkout.select_city'.trns(),
            value: controller.selectedCity.value,
            items: controller.cities,
            onChanged: (val) => controller.selectedCity.value = val,
            borderRadius: 12,
          ),
          SizedBox(height: R.h(16)),

          _buildRequiredLabel('checkout.street_address'.trns()),
          InputField(
            controller: controller.streetController,
            hintText: 'checkout.enter_street'.trns(),
            borderRadius: 12,
          ),
          SizedBox(height: R.h(16)),

          _buildRequiredLabel('checkout.postal_code'.trns()),
          InputField(
            controller: controller.postalController,
            hintText: 'checkout.enter_postal'.trns(),
            keyboardType: TextInputType.number,
            borderRadius: 12,
          ),
          SizedBox(height: R.h(20)),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 2: PAYMENT FORM
  // ==========================================
  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: R.w(20)),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildPaymentMethodCard('paypal', 'assets/images/paypal.png')),
              SizedBox(width: R.w(16)),
              Expanded(child: _buildPaymentMethodCard('gpay', 'assets/images/pay.png')),
            ],
          ),
          SizedBox(height: R.h(24)),

          _buildRequiredLabel('checkout.card_holder_name'.trns()),
          InputField(
            controller: controller.cardHolderController,
            hintText: 'checkout.enter_card_name'.trns(),
            borderRadius: 12,
          ),
          SizedBox(height: R.h(16)),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequiredLabel('checkout.expiration'.trns()),
                    InputField(
                      controller: controller.expirationController,
                      hintText: 'checkout.mm_yy'.trns(),
                      borderRadius: 12,
                    ),
                  ],
                ),
              ),
              SizedBox(width: R.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequiredLabel('checkout.cvv'.trns()),
                    InputField(
                      controller: controller.cvvController,
                      hintText: '123',
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      borderRadius: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(String id, String dummyAsset) {
    return Obx(() {
      final isSelected = controller.selectedCardType.value == id;
      return GestureDetector(
        onTap: () => controller.selectPaymentMethod(id),
        child: Container(
          height: R.h(60),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(R.w(12)),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.inputBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            // Replace with actual static assets
            child: Image.asset(
              dummyAsset,
              width: R.w(50),
              height: R.h(50),
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    });
  }

  // ==========================================
  // STEP 3: REVIEW FORM
  // ==========================================
  Widget _buildReviewForm() {
    final currencyFormat = NumberFormat('#,##0', 'en_US');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'checkout.items_count'.trnsFormat({'count': '2'}),
                  style: TextStyle(fontSize: R.sp(16), fontWeight: FontWeight.w600, color: AppColors.darkGrey),
                ),
                Icon(Icons.chevron_right, color: AppColors.darkGrey, size: R.sp(24)),
              ],
            ),
          ),
          SizedBox(height: R.h(16)),
          Divider(color: AppColors.inputBorder, height: 1),
          SizedBox(height: R.h(16)),

          // Shipping Address Info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'checkout.shipping_address'.trns(),
                  style: TextStyle(fontSize: R.sp(16), fontWeight: FontWeight.w700, color: AppColors.darkGrey),
                ),
                SizedBox(height: R.h(16)),
                _buildReviewRow('checkout.full_name'.trns(), controller.fullNameController.text),
                _buildReviewRow('checkout.mobile_number'.trns(), '+92 ${controller.phoneController.text}'),
                _buildReviewRow('checkout.province'.trns(), controller.selectedProvince.value ?? ''),
                _buildReviewRow('checkout.city'.trns(), controller.selectedCity.value ?? ''),
                _buildReviewRow('checkout.street_address'.trns(), controller.streetController.text),
                _buildReviewRow('checkout.postal_code'.trns(), controller.postalController.text),
                
                SizedBox(height: R.h(8)),
                Divider(color: AppColors.inputBorder, height: 1),
                SizedBox(height: R.h(16)),

                // Order Info
                Text(
                  'checkout.order_info'.trns(),
                  style: TextStyle(fontSize: R.sp(16), fontWeight: FontWeight.w700, color: AppColors.darkGrey),
                ),
                SizedBox(height: R.h(16)),
                _buildReviewRow('checkout.subtotal'.trns(), 'Rs:${currencyFormat.format(controller.subtotal.value)}'),
                _buildReviewRow('checkout.shipping_cost'.trns(), 'Rs:${currencyFormat.format(controller.shippingCost.value)}'),
                
                SizedBox(height: R.h(16)),
                Divider(color: AppColors.inputBorder, height: 1),
                SizedBox(height: R.h(24)),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'checkout.total'.trns(),
                      style: TextStyle(fontSize: R.sp(20), fontWeight: FontWeight.w700, color: AppColors.black),
                    ),
                    Text(
                      'Rs:${currencyFormat.format(controller.total)}',
                      style: TextStyle(fontSize: R.sp(20), fontWeight: FontWeight.w800, color: AppColors.black),
                    ),
                  ],
                ),
                SizedBox(height: R.h(20)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: R.sp(13), fontWeight: FontWeight.w400, color: AppColors.grey),
          ),
          Text(
            value,
            style: TextStyle(fontSize: R.sp(13), fontWeight: FontWeight.w500, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================
  Widget _buildRequiredLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(8), left: R.w(4)),
      child: RichText(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: R.sp(14),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error), // Red asterisk
            )
          ],
        ),
      ),
    );
  }
}