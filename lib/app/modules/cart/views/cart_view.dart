import 'package:flutter/material.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/modules/cart/controllers/cart_controller.dart';
import 'package:fmt/models/cart_model.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              
              title: 'cart.title'.trns(),
              onMenu: () {
                Get.find<BottomnavController>().openDrawer();
              },
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const _CartShimmer();
                }
                if (controller.loadError.value != null &&
                    controller.isEmpty) {
                  return _ErrorState(
                    message: controller.loadError.value!,
                    onRetry: controller.loadCart,
                  );
                }
                if (controller.isEmpty) {
                  return _EmptyState(onBrowse: controller.browseProducts);
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.refreshList,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                        R.w(20), R.h(4), R.w(20), R.h(110)),
                    children: [
                      Obx(() => ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: controller.lines.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: R.h(16)),
                            itemBuilder: (context, index) =>
                                _CartItemCard(
                                    line: controller.lines[index]),
                          )),
                      SizedBox(height: R.h(24)),
                      _BottomSummary(),
                    ],
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

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    final busy = controller.updatingKeys.contains(line.cartKey);
    return Container(
      padding: EdgeInsets.all(R.w(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.w(16)),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppCachedImage(
            imageUrl: line.imageUrl,
            width: R.w(70),
            height: R.w(70),
            fit: BoxFit.contain,
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        line.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: busy ? null : () => controller.removeLine(line),
                      child: Icon(Icons.close,
                          color: AppColors.darkGrey, size: R.sp(16)),
                    )
                  ],
                ),
                // Variant label (variable products hold one line per variant)
                if ((line.variantLabel ?? '').isNotEmpty) ...[
                  SizedBox(height: R.h(4)),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: R.w(8), vertical: R.h(3)),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(R.w(6)),
                    ),
                    child: Text(
                      line.variantLabel!,
                      style: TextStyle(
                        fontSize: R.sp(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: R.h(4)),
                if (line.bulkPrice != null &&
                    line.bulkPrice! > 0 &&
                    (line.minBulkQty ?? 0) > 0)
                  Text(
                    line.bulkActive
                        ? 'cart.bulk_applied'.trnsFormat({
                            'price': currencyFormat.format(line.bulkPrice),
                          })
                        : 'cart.buy_bulk'.trnsFormat({
                            'qty': line.minBulkQty.toString(),
                            'price':
                                currencyFormat.format(line.bulkPrice),
                          }),
                    style: TextStyle(
                      fontSize: R.sp(12),
                      fontWeight: FontWeight.w600,
                      color: line.bulkActive
                          ? AppColors.primary
                          : AppColors.mediumGrey,
                    ),
                  ),
                SizedBox(height: R.h(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (line.displayUnitPrice < line.unitPrice &&
                            line.unitPrice > 0)
                          Text(
                            '${'home.currency_symbol'.trns()}${currencyFormat.format(line.unitPrice)}',
                            style: TextStyle(
                              fontSize: R.sp(12),
                              color: AppColors.lightGrey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '${'home.currency_symbol'.trns()}${currencyFormat.format(line.lineTotal)}',
                          style: TextStyle(
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                    if (busy)
                      SizedBox(
                        width: R.w(24),
                        height: R.w(24),
                        child: const CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      QuantitySelector(
                        quantity: line.quantity,
                        onDecrease: () => controller.decreaseQty(line),
                        onIncrease: () => controller.increaseQty(line),
                      )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget _BottomSummary() {
  final controller = Get.find<CartController>();
  return Column(
    children: [
      // ── Promo codes are not offered by the v1 API, so the promo row is
      // ── hidden from the UI until the backend supports vouchers.
      // Container(
      //   height: R.h(50),
      //   decoration: BoxDecoration(
      //     color: AppColors.white,
      //     borderRadius: BorderRadius.circular(R.w(8)),
      //     border: Border.all(color: AppColors.inputBorder),
      //   ),
      //   child: Row(... promo field + apply button ...),
      // ),
      // SizedBox(height: R.h(24)),

      // Total Box
      Container(
        padding: EdgeInsets.all(R.w(24)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.w(24)),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Obx(() => Column(
              children: [
                _SummaryRow(
                  'cart.subtotal'.trns(),
                  controller.totals.value.subtotal,
                  isTotal: false,
                ),
                SizedBox(height: R.h(16)),
                Divider(color: AppColors.inputBorder, height: 1),
                SizedBox(height: R.h(16)),
                _SummaryRow(
                  'cart.bag_total'.trns(),
                  controller.totals.value.total,
                  isTotal: true,
                  itemsCount:
                      controller.totals.value.itemsCount,
                ),
                SizedBox(height: R.h(8)),
                Text(
                  'cart.taxes_note'.trns(),
                  style: TextStyle(
                    fontSize: R.sp(12),
                    color: AppColors.mediumGrey,
                  ),
                ),
                SizedBox(height: R.h(20)),
                SizedBox(
                  height: R.h(50),
                  child: MainBtn(
                    text: 'cart.checkout_btn'.trns(),
                    onPressed: controller.isEmpty
                        ? null
                        : controller.goToCheckout,
                    color: AppColors.primary,
                    borderRadius: 12,
                  ),
                )
              ],
            )),
      )
    ],
  );
}

Widget _SummaryRow(String title, double value,
    {required bool isTotal, int? itemsCount}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: R.sp(16),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          if (isTotal && itemsCount != null)
            Padding(
              padding: EdgeInsets.only(left: R.w(8)),
              child: Text(
                'cart.items_count'
                    .trnsFormat({'count': itemsCount.toString()}),
                style: TextStyle(
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
              ),
            ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${'home.currency_symbol'.trns()}${currencyFormat.format(value)}',
            style: TextStyle(
              fontSize: R.sp(16),
              fontWeight: FontWeight.w700,
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(width: R.w(4)),
          Padding(
            padding: EdgeInsets.only(bottom: R.h(2)),
            child: Text(
              'cart.currency_pkr'.trns(),
              style: TextStyle(
                fontSize: R.sp(10),
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      )
    ],
  );
}

class _CartShimmer extends StatelessWidget {
  const _CartShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(R.w(20)),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(height: R.h(16)),
      itemBuilder: (context, _) => Row(
        children: [
          ShimmerBox(width: R.w(70), height: R.w(70), borderRadius: 12),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    width: double.infinity, height: R.h(16), borderRadius: 6),
                SizedBox(height: R.h(8)),
                ShimmerBox(width: R.w(100), height: R.h(12), borderRadius: 6),
                SizedBox(height: R.h(12)),
                ShimmerBox(width: R.w(80), height: R.h(16), borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: SizedBox(
        height: R.h(480),
        child: Center(
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
                  Icons.shopping_bag_outlined,
                  size: R.sp(38),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: R.h(16)),
              Text(
                'cart.empty_title'.trns(),
                style: TextStyle(
                  fontSize: R.sp(18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: R.h(8)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(48)),
                child: Text(
                  'cart.empty_message'.trns(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.sp(14),
                    color: AppColors.mediumGrey,
                  ),
                ),
              ),
              SizedBox(height: R.h(20)),
              ElevatedButton(
                onPressed: onBrowse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.w(10)),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(28), vertical: R.h(13)),
                ),
                child: Text(
                  'cart.browse_btn'.trns(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
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
