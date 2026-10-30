import 'package:flutter/material.dart';
import 'package:fmt/app/modules/orderSuccess/controllers/order_success_controller.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:intl/intl.dart';

class OrderSuccessView extends GetView<OrderSuccessController> {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final money = NumberFormat('#,##0', 'en_US');

    // The server cart was emptied — never pop back into checkout/cart.
    return PopScope(
      canPop: false,
      child: GradientScaffold(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(20)),
            child: Column(
              children: [
                const Spacer(flex: 1),

                Image.asset(
                  "assets/images/order-placed.png",
                  height: R.h(220),
                  width: R.w(220),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: R.h(220),
                    width: R.w(220),
                    decoration: const BoxDecoration(
                      color: AppColors.shimmerBase,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.check_circle_outline,
                        size: R.sp(72), color: AppColors.primary),
                  ),
                ),

                SizedBox(height: R.h(28)),

                Text(
                  'order_success.title'.trns(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.sp(22),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: R.h(12)),

                // Order meta: id + pending status + total
                Obx(() {
                  final chips = <Widget>[];
                  if (controller.orderId.value != null) {
                    chips.add(_Chip(
                        '${'order_success.order_no'.trns()} #${controller.orderId.value}'));
                  }
                  chips.add(_StatusChip(status: controller.status.value));
                  if (controller.total.value > 0) {
                    chips.add(_Chip(
                        '${'home.currency_symbol'.trns()}${money.format(controller.total.value)}'));
                  }
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: R.w(8),
                    runSpacing: R.h(8),
                    children: chips,
                  );
                }),

                SizedBox(height: R.h(14)),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.w(10)),
                  child: Text(
                    'order_success.description'.trns(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: R.h(16)),

                // WhatsApp confirmation step (order is pending until sent)
                Obx(() => controller.hasWhatsapp
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(R.w(16)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F8EF),
                          borderRadius: BorderRadius.circular(R.w(12)),
                          border: Border.all(
                              color: const Color(0xFF25D366)
                                  .withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: R.w(44),
                              height: R.w(44),
                              decoration: const BoxDecoration(
                                color: Color(0xFF25D366),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.chat,
                                  color: AppColors.white,
                                  size: R.sp(22)),
                            ),
                            SizedBox(width: R.w(12)),
                            Expanded(
                              child: Text(
                                'order_success.whatsapp_note'.trns(),
                                style: TextStyle(
                                  fontSize: R.sp(13),
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),

                const Spacer(flex: 2),

                // Primary: confirm on WhatsApp
                Obx(() => controller.hasWhatsapp
                    ? SizedBox(
                        height: R.h(50),
                        child: MainBtn(
                          text: 'order_success.whatsapp_btn'.trns(),
                          color: const Color(0xFF25D366),
                          borderRadius: 12,
                          onPressed: controller.openWhatsapp,
                        ),
                      )
                    : const SizedBox.shrink()),
                SizedBox(height: R.h(12)),

                // Secondary: back to shopping (clears the stack)
                SizedBox(
                  height: R.h(50),
                  child: MainBtn(
                    text: 'order_success.continue_btn'.trns(),
                    color: AppColors.primary,
                    borderRadius: 12,
                    onPressed: controller.onContinueShopping,
                  ),
                ),

                SizedBox(height: R.h(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.w(20)),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: R.sp(13),
          fontWeight: FontWeight.w700,
          color: AppColors.darkGrey,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final pending = status.toLowerCase() == 'pending';
    final color =
        pending ? const Color(0xFFB7791F) : AppColors.primary;
    final bg =
        pending ? const Color(0xFFFFF3D6) : AppColors.white;
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(R.w(20)),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: R.w(7),
            height: R.w(7),
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: R.w(6)),
          Text(
            status.isEmpty
                ? 'order_success.status_pending'.trns()
                : '${'order_success.status'.trns()}: $status',
            style: TextStyle(
              fontSize: R.sp(13),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
