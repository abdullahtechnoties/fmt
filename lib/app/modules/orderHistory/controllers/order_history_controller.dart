import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/order_model.dart';
import 'package:fmt/repositories/order_repository.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Customer orders newest-first (`GET /orders`, paginated). Tapping a row
/// opens the order-details page with the full breakdown.
class OrderHistoryController extends GetxController {
  OrderHistoryController({OrderRepository? orderRepo})
      : _orderRepo = orderRepo ?? OrderRepository();

  final OrderRepository _orderRepo;

  final RxList<OrderSummary> orders = <OrderSummary>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final RxnString loadError = RxnString();

  int _page = 1;
  bool _hasMore = true;
  static const int _perPage = 10;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    loadError.value = null;
    _page = 1;
    _hasMore = true;
    try {
      final res = await _orderRepo.orders(page: 1, perPage: _perPage);
      if (res.isError || res.data == null) {
        loadError.value = (res.message?.isNotEmpty ?? false)
            ? res.message
            : 'order_history.load_failed'.trns();
        return;
      }
      orders.assignAll(res.data!.items);
      _hasMore = res.data!.meta.hasNextPage;
      _page = 2;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore || isLoading.value) return;
    isLoadingMore.value = true;
    try {
      final res = await _orderRepo.orders(page: _page, perPage: _perPage);
      if (!res.isError && res.data != null) {
        orders.addAll(res.data!.items);
        _hasMore = res.data!.meta.hasNextPage;
        _page++;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  void openOrder(OrderSummary order) {
    if (order.id == null) return;
    Get.toNamed(Routes.ORDER_DETAILS, arguments: order.id);
  }
}
