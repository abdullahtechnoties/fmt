import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fmt/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:fmt/app/modules/checkout/views/widgets/stepper.dart';
import 'package:fmt/models/payment_proof_model.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
              showmenu: false,
            ),

            // Stepper Widget
            Obx(
              () => CheckoutStepper(currentStep: controller.currentStep.value),
            ),

            // Dynamic Body
            Expanded(
              child: Obx(() {
                if (controller.isLoadingSummary.value) {
                  return const _SummaryShimmer();
                }
                if (controller.summaryError.value != null &&
                    controller.lines.isEmpty) {
                  return _ErrorState(
                    message: controller.summaryError.value!,
                    onRetry: controller.loadSummary,
                  );
                }
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
            Obx(() {
              if (controller.isLoadingSummary.value) {
                return const SizedBox.shrink();
              }
              String btnText = '';
              if (controller.currentStep.value == 0) {
                btnText = 'checkout.save_btn'.trns();
              } else if (controller.currentStep.value == 1) {
                btnText = 'checkout.continue_btn'.trns();
              } else {
                btnText = 'checkout.place_order_btn'.trns();
              }

              final mustAgree =
                  controller.currentStep.value == 2 &&
                  !controller.agreedToConfirm.value;
              return Padding(
                padding: EdgeInsets.all(R.w(20)),
                child: MainBtn(
                  text: btnText,
                  onPressed: controller.isPlacingOrder.value || mustAgree
                      ? null
                      : controller.nextStep,
                  isLoading: controller.isPlacingOrder.value,
                  color: AppColors.primary,
                  borderRadius: 12,
                ),
              );
            }),
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
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequiredLabel('checkout.full_name'.trns()),
            InputField(
              controller: controller.fullNameController,
              hintText: 'checkout.enter_full_name'.trns(),
              borderRadius: 12,
              textInputAction: TextInputAction.next,
              validator: controller.requiredValidator,
            ),
            SizedBox(height: R.h(16)),

            _buildRequiredLabel('checkout.email'.trns()),
            InputField(
              controller: controller.emailController,
              hintText: 'checkout.enter_email'.trns(),
              keyboardType: TextInputType.emailAddress,
              borderRadius: 12,
              textInputAction: TextInputAction.next,
              validator: controller.emailValidator,
            ),
            SizedBox(height: R.h(16)),

            _buildRequiredLabel('checkout.phone_number'.trns()),
            InputField(
              controller: controller.phoneController,
              hintText: '000-0000000',
              keyboardType: TextInputType.phone,
              borderRadius: 12,
              textInputAction: TextInputAction.next,
              validator: controller.phoneValidator,
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: R.w(16), right: R.w(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+92',
                      style: TextStyle(
                        fontSize: R.sp(14),
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: R.h(16)),

            _buildRequiredLabel('checkout.street_address'.trns()),
            InputField(
              controller: controller.streetController,
              hintText: 'checkout.enter_street'.trns(),
              borderRadius: 12,
              textInputAction: TextInputAction.next,
              validator: controller.requiredValidator,
            ),
            SizedBox(height: R.h(16)),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('checkout.city'.trns()),
                      InputField(
                        controller: controller.cityController,
                        hintText: 'checkout.enter_city'.trns(),
                        borderRadius: 12,
                        textInputAction: TextInputAction.next,
                        validator: controller.requiredValidator,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: R.w(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('checkout.province'.trns()),
                      InputField(
                        controller: controller.provinceController,
                        hintText: 'checkout.enter_province'.trns(),
                        borderRadius: 12,
                        textInputAction: TextInputAction.next,
                        validator: controller.requiredValidator,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(16)),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('checkout.country'.trns()),
                      InputField(
                        controller: controller.countryController,
                        hintText: 'checkout.enter_country'.trns(),
                        borderRadius: 12,
                        textInputAction: TextInputAction.next,
                        validator: controller.requiredValidator,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: R.w(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('checkout.postal_code'.trns()),
                      InputField(
                        controller: controller.postalController,
                        hintText: 'checkout.enter_postal'.trns(),
                        keyboardType: TextInputType.number,
                        borderRadius: 12,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(16)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 2: PAYMENT PROOF — optional upload.
  // The API no longer offers a payment selector. Customers who already
  // paid can attach a receipt; everyone else can add it later from the
  // order screen, so this step never blocks the order.
  // ==========================================
  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: R.w(20)),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentProofSection(),
          SizedBox(height: R.h(24)),
          Text(
            'checkout.order_notes'.trns(),
            style: TextStyle(
              fontSize: R.sp(14),
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: R.h(8)),
          InputField(
            controller: controller.notesController,
            hintText: 'checkout.enter_notes'.trns(),
            borderRadius: 12,
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProofSection() {
    return Obx(() {
      final rules = controller.paymentProofRules;
      final picked = controller.paymentProof.value;
      final title = rules.label.trim().isEmpty
          ? 'payment_proof.title'.trns()
          : rules.label;
      final hint = rules.hint.trim().isEmpty
          ? 'payment_proof.hint'.trns()
          : rules.hint;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(R.w(16)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.w(12)),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.w(10),
                    vertical: R.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(R.w(20)),
                  ),
                  child: Text(
                    'payment_proof.optional'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(11),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(8)),
            Text(
              hint,
              style: TextStyle(
                fontSize: R.sp(13),
                height: 1.4,
                color: AppColors.mediumGrey,
              ),
            ),
            SizedBox(height: R.h(16)),
            if (picked == null)
              _buildProofPicker(rules)
            else
              _buildPickedProof(picked),
            SizedBox(height: R.h(12)),
            Text(
              'payment_proof.note'.trns(),
              style: TextStyle(
                fontSize: R.sp(12),
                height: 1.4,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProofPicker(PaymentProofRules rules) {
    return GestureDetector(
      onTap: controller.pickPaymentProof,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(22)),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(R.w(12)),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: R.sp(34),
              color: AppColors.primary,
            ),
            SizedBox(height: R.h(8)),
            Text(
              'payment_proof.add'.trns(),
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: R.h(4)),
            Text(
              'payment_proof.rules'.trnsFormat({
                'types': rules.accepts.map((e) => e.toUpperCase()).join(', '),
                'size': rules.maxMbLabel,
              }),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: R.sp(12), color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickedProof(PlatformFile file) {
    final path = file.path ?? '';
    final isPdf = file.name.toLowerCase().endsWith('.pdf');
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(10)),
      decoration: BoxDecoration(
        color: AppColors.shimmerBase.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(R.w(12)),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(R.w(8)),
                child: isPdf
                    ? Container(
                        width: R.w(52),
                        height: R.w(52),
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.picture_as_pdf_outlined,
                          color: AppColors.primary,
                          size: R.sp(26),
                        ),
                      )
                    : Image.file(
                        File(path),
                        width: R.w(52),
                        height: R.w(52),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: R.w(52),
                          height: R.w(52),
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.insert_drive_file_outlined,
                            color: AppColors.primary,
                            size: R.sp(26),
                          ),
                        ),
                      ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.sp(13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      '${'payment_proof.attached'.trns()}'
                      '${file.size > 0 ? ' · ${PaymentProof.formatSize(file.size)}' : ''}',
                      style: TextStyle(
                        fontSize: R.sp(12),
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: controller.removePaymentProof,
                icon: Icon(
                  Icons.close_rounded,
                  size: R.sp(20),
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.pickPaymentProof,
              child: Text(
                'payment_proof.replace'.trns(),
                style: TextStyle(
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 3: REVIEW FORM
  // ==========================================
  Widget _buildReviewForm() {
    final currencyFormat = NumberFormat('#,##0', 'en_US');

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: R.h(20)),
      physics: const BouncingScrollPhysics(),
      child: Obx(() {
        final lines = controller.lines;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Confirmation notice — the store confirms every order over
            // WhatsApp/Chat after it is placed.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(20)),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(R.w(14)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(R.w(12)),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'checkout.before_place_title'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      'checkout.before_place_subtitle'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(13),
                        height: 1.4,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: R.h(16)),
            // Items
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'checkout.items_count'.trnsFormat({
                      'count': '${controller.totals.value.itemsCount}',
                    }),
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  Text(
                    '${'home.currency_symbol'.trns()}${currencyFormat.format(controller.totals.value.subtotal)}',
                    style: TextStyle(
                      fontSize: R.sp(15),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(12)),
            SizedBox(
              height: R.h(96),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                itemCount: lines.length,
                separatorBuilder: (_, __) => SizedBox(width: R.w(12)),
                itemBuilder: (context, i) {
                  final line = lines[i];
                  return Container(
                    width: R.w(76),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(R.w(12)),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    padding: EdgeInsets.all(R.w(6)),
                    child: Column(
                      children: [
                        Expanded(
                          child: AppCachedImage(
                            imageUrl: line.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            borderRadius: BorderRadius.circular(R.w(8)),
                          ),
                        ),
                        SizedBox(height: R.h(4)),
                        Text(
                          '×${line.quantity}',
                          style: TextStyle(
                            fontSize: R.sp(12),
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  SizedBox(height: R.h(16)),
                  _buildReviewRow(
                    'checkout.full_name'.trns(),
                    controller.fullNameController.text,
                  ),
                  _buildReviewRow(
                    'checkout.email'.trns(),
                    controller.emailController.text,
                  ),
                  _buildReviewRow(
                    'checkout.mobile_number'.trns(),
                    controller.phoneController.text,
                  ),
                  _buildReviewRow(
                    'checkout.street_address'.trns(),
                    controller.streetController.text,
                  ),
                  _buildReviewRow(
                    'checkout.city'.trns(),
                    controller.cityController.text,
                  ),
                  _buildReviewRow(
                    'checkout.province'.trns(),
                    controller.provinceController.text,
                  ),
                  _buildReviewRow(
                    'checkout.country'.trns(),
                    controller.countryController.text,
                  ),
                  if (controller.postalController.text.trim().isNotEmpty)
                    _buildReviewRow(
                      'checkout.postal_code'.trns(),
                      controller.postalController.text,
                    ),
                  if (controller.notesController.text.trim().isNotEmpty)
                    _buildReviewRow(
                      'checkout.order_notes'.trns(),
                      controller.notesController.text,
                    ),
                  _buildReviewRow(
                    'payment_proof.title'.trns(),
                    controller.paymentProof.value == null
                        ? 'payment_proof.not_attached'.trns()
                        : '${controller.paymentProof.value!.name}'
                              '${controller.paymentProof.value!.size > 0 ? ' (${PaymentProof.formatSize(controller.paymentProof.value!.size)})' : ''}',
                  ),

                  SizedBox(height: R.h(8)),
                  Divider(color: AppColors.inputBorder, height: 1),
                  SizedBox(height: R.h(16)),

                  // Order Info
                  Text(
                    'checkout.order_info'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  SizedBox(height: R.h(16)),
                  for (final line in lines)
                    Padding(
                      padding: EdgeInsets.only(bottom: R.h(8)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${line.title}${(line.variantLabel ?? '').isNotEmpty ? ' (${line.variantLabel})' : ''} ×${line.quantity}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: R.sp(13),
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          SizedBox(width: R.w(8)),
                          Text(
                            'Rs:${currencyFormat.format(line.lineTotal)}',
                            style: TextStyle(
                              fontSize: R.sp(13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: R.h(8)),
                  _buildReviewRow(
                    'checkout.subtotal'.trns(),
                    'Rs:${currencyFormat.format(controller.totals.value.subtotal)}',
                  ),

                  // Store notices from the summary (website parity)
                  if (controller.summary.value.notices.isNotEmpty) ...[
                    SizedBox(height: R.h(16)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(R.w(14)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E7),
                        borderRadius: BorderRadius.circular(R.w(10)),
                        border: Border.all(color: const Color(0xFFF0D489)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final n in controller.summary.value.notices)
                            Padding(
                              padding: EdgeInsets.only(bottom: R.h(6)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: TextStyle(
                                      fontSize: R.sp(13),
                                      color: AppColors.darkGrey,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      n,
                                      style: TextStyle(
                                        fontSize: R.sp(13),
                                        height: 1.4,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: R.h(16)),
                  Divider(color: AppColors.inputBorder, height: 1),
                  SizedBox(height: R.h(24)),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'checkout.total'.trns(),
                        style: TextStyle(
                          fontSize: R.sp(20),
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'Rs:${currencyFormat.format(controller.totals.value.total)}',
                        style: TextStyle(
                          fontSize: R.sp(20),
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(16)),
                  // Required acknowledgement before placing the order
                  GestureDetector(
                    onTap: controller.agreedToConfirm.toggle,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(R.w(14)),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(R.w(12)),
                        border: Border.all(
                          color: controller.agreedToConfirm.value
                              ? AppColors.primary
                              : AppColors.inputBorder,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: R.w(22),
                            height: R.w(22),
                            margin: EdgeInsets.only(top: R.h(1)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: controller.agreedToConfirm.value
                                    ? AppColors.primary
                                    : AppColors.lightGrey,
                                width: 2,
                              ),
                            ),
                            child: controller.agreedToConfirm.value
                                ? Center(
                                    child: Container(
                                      width: R.w(12),
                                      height: R.w(12),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(width: R.w(12)),
                          Expanded(
                            child: Text(
                              'checkout.confirm_ack'.trns(),
                              style: TextStyle(
                                fontSize: R.sp(13),
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: R.sp(13),
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
            ),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: R.sp(13),
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
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
              style: TextStyle(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryShimmer extends StatelessWidget {
  const _SummaryShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: R.w(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: R.w(140), height: R.h(16), borderRadius: 6),
          SizedBox(height: R.h(12)),
          ShimmerBox(width: double.infinity, height: R.h(52), borderRadius: 12),
          SizedBox(height: R.h(16)),
          ShimmerBox(width: double.infinity, height: R.h(52), borderRadius: 12),
          SizedBox(height: R.h(16)),
          ShimmerBox(width: double.infinity, height: R.h(52), borderRadius: 12),
          SizedBox(height: R.h(24)),
          ShimmerBox(
            width: double.infinity,
            height: R.h(120),
            borderRadius: 12,
          ),
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
          Icon(
            Icons.cloud_off_outlined,
            size: R.sp(48),
            color: AppColors.lightGrey,
          ),
          SizedBox(height: R.h(12)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(48)),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: R.sp(14), color: AppColors.mediumGrey),
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
                horizontal: R.w(24),
                vertical: R.h(12),
              ),
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
