import 'package:flutter/material.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/order-history.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OrderHistoryController());

    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // Custom Layout Header (Back on left, Title on right)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_ios_new, color: AppColors.darkGrey, size: R.sp(22)),
                  ),
                  Text(
                    'order_history.title'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(24),
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Obx(() => ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(R.w(20)),
                itemCount: controller.orders.length,
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  return OrderHistoryCard(
                    title: order['title'] as String,
                    imageUrl: order['image'] as String,
                    bulkQty: order['bulkQty'] as int,
                    bulkPrice: order['bulkPrice'] as double,
                    currentPrice: order['currentPrice'] as double,
                    onRemove: () => controller.removeOrder(index),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}