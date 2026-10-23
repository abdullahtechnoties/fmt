import 'package:flutter/material.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/modules/cart/controllers/cart_controller.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
// import 'package:fmt/utilities/colors.dart';
// import 'package:fmt/utilities/r.dart';
// import 'package:fmt/utilities/translation_extention.dart';
// import 'package:fmt/widgets/app_cached_image.dart';
// import 'package:fmt/widgets/main_btn.dart';
// import 'package:fmt/widgets/shared_ui_components.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomHeaderBar(
                title: 'cart.title'.trns(),
                onMenu: () {
                      Get.find<BottomnavController>().openDrawer();
                },
              ),
              
              Obx(() => ListView.separated(
                padding: EdgeInsets.all(R.w(20)),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.cartItems.length,
                separatorBuilder: (context, index) => SizedBox(height: R.h(16)),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildCartItemCard(item, index);
                },
              )),
          
              // Promo code & Bottom Checkout Summary
              _buildBottomSummary(),
              SizedBox(height: R.h(20)), // Extra spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemCard(item, int index) {
    return Container(
      padding: EdgeInsets.all(R.w(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.w(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          AppCachedImage(
            imageUrl: item.imageUrl,
            width: R.w(70),
            height: R.w(70),
            fit: BoxFit.contain,
          ),
          SizedBox(width: R.w(12)),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.removeItem(index),
                      child: Icon(Icons.close, color: AppColors.darkGrey, size: R.sp(16)),
                    )
                  ],
                ),
                SizedBox(height: R.h(4)),
                Text(
                  'cart.buy_bulk'.trnsFormat({
                    'qty': item.bulkQty.toString(),
                    'price': currencyFormat.format(item.bulkPrice),
                  }),
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.mediumGrey,
                  ),
                ),
                SizedBox(height: R.h(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${'home.currency_symbol'.trns()}${currencyFormat.format(item.price)}',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    QuantitySelector(
                      quantity: item.quantity,
                      onDecrease: () => controller.decreaseQty(index),
                      onIncrease: () => controller.increaseQty(index),
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

  Widget _buildBottomSummary() {
    return Container(
      padding: EdgeInsets.fromLTRB(R.w(20), R.h(0), R.w(20), R.h(20)),
      child: Column(
        children: [
          // Promo Code Row
          Container(
            height: R.h(50),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(R.w(8)),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.promoController,
                    decoration: InputDecoration(

                      hintText: 'cart.promo_hint'.trns(),
                      hintStyle: TextStyle(
                        fontSize: R.sp(14),
                        color: AppColors.lightGrey,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(18)),
                    ),
                  ),
                ),
                    
                  Spacer(),
                    Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: R.w(2)),
            height: R.h(50),
            // width: R.w(50),

            child: ElevatedButton(
              onPressed: controller.applyPromo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.w(10)),
                ),
              ),
              child: Text(
                'cart.apply'.trns(),
                style: TextStyle(
                  fontSize: R.sp(14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
                    ),
                    SizedBox(width: R.w(12)),
              ],
            ),
          ),
          SizedBox(height: R.h(24)),
          
          // Total Box
          Container(
            padding: EdgeInsets.all(R.w(24)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(R.w(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ]
            ),
            child: Obx(() => Column(
              children: [
                _buildSummaryRow(
                  'cart.subtotal'.trns(),
                  controller.subtotal,
                  isTotal: false,
                ),
                SizedBox(height: R.h(16)),
                _buildSummaryRow(
                  'cart.shipping'.trns(),
                  controller.shippingCost.value,
                  isTotal: false,
                ),
                SizedBox(height: R.h(16)),
                Divider(color: AppColors.inputBorder, height: 1),
                SizedBox(height: R.h(16)),
                _buildSummaryRow(
                  'cart.bag_total'.trns(),
                  controller.total,
                  isTotal: true,
                  itemsCount: controller.totalItems,
                ),
                SizedBox(height: R.h(24)),
                
                // Used existing MainBtn with Primary Color Override
                SizedBox(
                  height: R.h(50),
                  child: MainBtn(
                    text: 'cart.checkout_btn'.trns(),
                    onPressed: () {
                      Get.toNamed(Routes.CHECKOUT);
                    },
                    color: AppColors.primary, 
                    borderRadius: 12, // Adjusted radius to match image slightly tighter
                  ),
                )
              ],
            )),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, double value, {required bool isTotal, int? itemsCount}) {
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
                  'cart.items_count'.trnsFormat({'count': itemsCount.toString()}),
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
}