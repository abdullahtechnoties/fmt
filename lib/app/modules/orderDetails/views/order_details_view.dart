import 'package:flutter/material.dart';
import 'package:fmt/app/modules/orderDetails/controllers/order_details_controller.dart';
import 'package:fmt/models/order_model.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:intl/intl.dart';

class OrderDetailsView extends GetView<OrderDetailsController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              showmenu: false,
              title: 'order_details.title'.trns(),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const _DetailsShimmer();
                }
                final detail = controller.detail.value;
                if (controller.loadError.value != null ||
                    detail == null) {
                  return _ErrorState(
                    message: controller.loadError.value ??
                        'order_details.load_failed'.trns(),
                    onRetry: controller.loadDetail,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.loadDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                        R.w(20), R.h(4), R.w(20), R.h(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderCard(detail: detail),
                        SizedBox(height: R.h(16)),
                        _ItemsCard(items: detail.items),
                        SizedBox(height: R.h(16)),
                        _SummaryCard(detail: detail),
                        if ((detail.billingName ?? '').isNotEmpty ||
                            (detail.billingAddress ?? '')
                                .isNotEmpty) ...[
                          SizedBox(height: R.h(16)),
                          _BillingCard(detail: detail),
                        ],
                        SizedBox(height: R.h(20)),
                        if (detail.hasWhatsapp)
                          SizedBox(
                            height: R.h(50),
                            child: MainBtn(
                              text: 'order_success.whatsapp_btn'.trns(),
                              color: const Color(0xFF25D366),
                              borderRadius: 12,
                              onPressed: controller.openWhatsapp,
                            ),
                          ),
                        if (detail.hasWhatsapp)
                          SizedBox(height: R.h(12)),
                        Obx(() => SizedBox(
                              height: R.h(50),
                              child: MainBtn(
                                text: 'order_details.invoice_btn'.trns(),
                                color: AppColors.darkGrey,
                                borderRadius: 12,
                                isLoading:
                                    controller.isOpeningInvoice.value,
                                onPressed: controller
                                        .isOpeningInvoice.value
                                    ? null
                                    : controller.openInvoice,
                              ),
                            )),
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
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.detail});

  final OrderDetail detail;

  @override
  Widget build(BuildContext context) {
    final pending = detail.summary.isPending;
    final color = pending ? const Color(0xFFB7791F) : AppColors.primary;
    final bg = pending ? const Color(0xFFFFF3D6) : AppColors.white;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.w(16)),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${'order_success.order_no'.trns()} #${detail.summary.id ?? '–'}',
                style: TextStyle(
                  fontSize: R.sp(18),
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGrey,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(12), vertical: R.h(6)),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(R.w(20)),
                  border:
                      Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  detail.summary.statusLabel,
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if ((detail.summary.createdAt ?? '').isNotEmpty ||
              (detail.storeName ?? '').isNotEmpty) ...[
            SizedBox(height: R.h(8)),
            Text(
              [
                if ((detail.summary.createdAt ?? '').isNotEmpty)
                  detail.summary.createdAt!,
                if ((detail.storeName ?? '').isNotEmpty)
                  detail.storeName!,
              ].join('  •  '),
              style:
                  TextStyle(fontSize: R.sp(12), color: AppColors.grey),
            ),
          ],
          if ((detail.summary.paymentMethod ?? '').isNotEmpty) ...[
            SizedBox(height: R.h(4)),
            Text(
              '${'checkout.payment'.trns()}: ${detail.summary.paymentMethod}',
              style:
                  TextStyle(fontSize: R.sp(12), color: AppColors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0', 'en_US');
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.w(16)),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'order_details.items'.trnsFormat({'count': '${items.length}'}),
            style: TextStyle(
              fontSize: R.sp(16),
              fontWeight: FontWeight.w800,
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: R.h(12)),
          for (var i = 0; i < items.length; i++) ...[
            Row(
              children: [
                AppCachedImage(
                  imageUrl: items[i].imageUrl ?? '',
                  width: R.w(52),
                  height: R.w(52),
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(R.w(8)),
                ),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].title ?? '–',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: R.sp(13),
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      if ((items[i].variantLabel ?? '').isNotEmpty)
                        Text(
                          items[i].variantLabel!,
                          style: TextStyle(
                            fontSize: R.sp(12),
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      SizedBox(height: R.h(2)),
                      Text(
                        '×${items[i].quantity}  •  ${'home.currency_symbol'.trns()}${money.format(items[i].price)}',
                        style: TextStyle(
                          fontSize: R.sp(12),
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: R.w(8)),
                Text(
                  '${'home.currency_symbol'.trns()}${money.format(items[i].subtotal)}',
                  style: TextStyle(
                    fontSize: R.sp(13),
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            if (i < items.length - 1) ...[
              SizedBox(height: R.h(12)),
              Divider(color: AppColors.inputBorder, height: 1),
              SizedBox(height: R.h(12)),
            ],
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.detail});

  final OrderDetail detail;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0', 'en_US');
    final total = detail.summary.total > 0
        ? detail.summary.total
        : detail.subtotal;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.w(16)),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _row('order_details.subtotal'.trns(), detail.subtotal, money,
              bold: false),
          SizedBox(height: R.h(10)),
          Divider(color: AppColors.inputBorder, height: 1),
          SizedBox(height: R.h(10)),
          _row('checkout.total'.trns(), total, money, bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, double value, NumberFormat money,
      {required bool bold}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? R.sp(16) : R.sp(14),
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        Text(
          '${'home.currency_symbol'.trns()}${money.format(value)}',
          style: TextStyle(
            fontSize: bold ? R.sp(16) : R.sp(14),
            fontWeight: FontWeight.w800,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }
}

class _BillingCard extends StatelessWidget {
  const _BillingCard({required this.detail});

  final OrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.w(16)),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'checkout.shipping_address'.trns(),
            style: TextStyle(
              fontSize: R.sp(16),
              fontWeight: FontWeight.w800,
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: R.h(10)),
          if ((detail.billingName ?? '').isNotEmpty)
            _line(detail.billingName!),
          if ((detail.billingPhone ?? '').isNotEmpty)
            _line(detail.billingPhone!),
          if ((detail.billingAddress ?? '').isNotEmpty)
            _line(detail.billingAddress!),
          if ((detail.notes ?? '').isNotEmpty)
            _line('${'checkout.order_notes'.trns()}: ${detail.notes}'),
        ],
      ),
    );
  }

  Widget _line(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(4)),
      child: Text(
        text,
        style: TextStyle(fontSize: R.sp(13), color: AppColors.grey),
      ),
    );
  }
}

class _DetailsShimmer extends StatelessWidget {
  const _DetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(R.w(20)),
      child: Column(
        children: [
          ShimmerBox(
              width: double.infinity, height: R.h(96), borderRadius: 16),
          SizedBox(height: R.h(16)),
          ShimmerBox(
              width: double.infinity, height: R.h(180), borderRadius: 16),
          SizedBox(height: R.h(16)),
          ShimmerBox(
              width: double.infinity, height: R.h(110), borderRadius: 16),
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
