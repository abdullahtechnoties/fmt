import 'package:flutter/material.dart';
import 'package:fmt/models/order_model.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:intl/intl.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Bound by OrderHistoryBinding; GetView already finds the controller.
    R.init(context);
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              showmenu: false,
              title: 'order_history.title'.trns(),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const _HistoryShimmer();
                }
                if (controller.loadError.value != null &&
                    controller.orders.isEmpty) {
                  return _ErrorState(
                    message: controller.loadError.value!,
                    onRetry: controller.loadOrders,
                  );
                }
                if (controller.orders.isEmpty) {
                  return _EmptyState(onRetry: controller.loadOrders);
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.loadOrders,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                        R.w(20), R.h(4), R.w(20), R.h(24)),
                    itemCount: controller.orders.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.orders.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: R.h(12)),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      final order = controller.orders[index];
                      // Prefetch the next page before the end.
                      if (index ==
                          controller.orders.length - 3) {
                        controller.loadMore();
                      }
                      return Padding(
                        padding: EdgeInsets.only(bottom: R.h(14)),
                        child: _OrderRow(
                          order: order,
                          onTap: () => controller.openOrder(order),
                        ),
                      );
                    },
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

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.onTap});

  final OrderSummary order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0', 'en_US');
    final pending = order.isPending;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(R.w(14)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.w(16)),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            AppCachedImage(
              imageUrl: order.previewImage ?? '',
              width: R.w(64),
              height: R.w(64),
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(R.w(10)),
            ),
            SizedBox(width: R.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${'order_success.order_no'.trns()} #${order.id ?? '–'}',
                        style: TextStyle(
                          fontSize: R.sp(15),
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const Spacer(),
                      _StatusPill(
                          status: order.statusLabel, pending: pending),
                    ],
                  ),
                  if ((order.previewTitle ?? '').isNotEmpty) ...[
                    SizedBox(height: R.h(4)),
                    Text(
                      order.previewTitle! +
                          (order.itemsCount > 1
                              ? ' +${order.itemsCount - 1}'
                              : ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.sp(13),
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                  SizedBox(height: R.h(6)),
                  Row(
                    children: [
                      if ((order.createdAt ?? '').isNotEmpty)
                        Expanded(
                          child: Text(
                            order.createdAt!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: R.sp(12),
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      Text(
                        '${'home.currency_symbol'.trns()}${money.format(order.total)}',
                        style: TextStyle(
                          fontSize: R.sp(15),
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: R.w(4)),
            Icon(Icons.chevron_right,
                size: R.sp(22), color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.pending});

  final String status;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final color = pending ? const Color(0xFFB7791F) : AppColors.primary;
    final bg = pending ? const Color(0xFFFFF3D6) : AppColors.white;
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(4)),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(R.w(20)),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: R.sp(11),
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _HistoryShimmer extends StatelessWidget {
  const _HistoryShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(R.w(20)),
      itemCount: 5,
      separatorBuilder: (_, __) => SizedBox(height: R.h(14)),
      itemBuilder: (context, _) => Row(
        children: [
          ShimmerBox(width: R.w(64), height: R.w(64), borderRadius: 10),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    width: R.w(120), height: R.h(16), borderRadius: 6),
                SizedBox(height: R.h(8)),
                ShimmerBox(
                    width: double.infinity,
                    height: R.h(12),
                    borderRadius: 6),
                SizedBox(height: R.h(8)),
                ShimmerBox(
                    width: R.w(90), height: R.h(14), borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRetry,
      child: SingleChildScrollView(
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
                    Icons.receipt_long_outlined,
                    size: R.sp(38),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: R.h(16)),
                Text(
                  'order_history.empty_title'.trns(),
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
                    'order_history.empty_message'.trns(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: R.sp(14),
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ),
              ],
            ),
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
