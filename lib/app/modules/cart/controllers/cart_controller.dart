import 'package:fmt/app/modules/products/controllers/products_controller.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/cart_model.dart';
import 'package:fmt/repositories/cart_repository.dart';
import 'package:fmt/services/store_service.dart';
import 'package:fmt/utilities/auth_guard.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Server-driven shopping bag. Every cart response carries the full cart,
/// so steppers/removes re-parse the response instead of re-fetching.
/// Refreshes silently whenever the tab is opened and on branch switches.
class CartController extends GetxController {
  CartController({CartRepository? repository})
      : _repository = repository ?? CartRepository();

  final CartRepository _repository;

  final RxList<CartLine> lines = <CartLine>[].obs;
  final Rx<CartTotals> totals = const CartTotals().obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxnString loadError = RxnString();

  /// cart_keys with a quantity PATCH currently in flight.
  final RxSet<String> updatingKeys = <String>{}.obs;

  int? _boundStoreId;

  StoreService get _storeService => Get.find<StoreService>();

  bool get isEmpty => lines.isEmpty;

  @override
  void onInit() {
    super.onInit();
    _boundStoreId = _storeService.selectedStoreId;
    ever(_storeService.selectedStore, (_) => _onStoreChanged());
    loadCart();
  }

  void _onStoreChanged() {
    final id = _storeService.selectedStoreId;
    if (id == _boundStoreId) return;
    _boundStoreId = id;
    loadCart();
  }

  /// First paint / error retry — shows the shimmer.
  Future<void> loadCart() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final res = await _repository.fetchCart();
      if (res.isError || res.data == null) {
        if (lines.isEmpty) {
          loadError.value = (res.message?.isNotEmpty ?? false)
              ? res.message
              : 'cart.load_failed'.trns();
        }
        return;
      }
      _applyBody(res.data);
      loadError.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Silent refresh: no shimmer, keeps the current list on failure.
  /// Called every time the cart tab is opened (see BottomnavController).
  Future<void> refreshSilently() async {
    if (isLoading.value || isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      final res = await _repository.fetchCart();
      if (!res.isError && res.data != null) {
        _applyBody(res.data);
        loadError.value = null;
      }
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Pull-to-refresh entry — same silent path, indicator covers feedback.
  Future<void> refreshList() => refreshSilently();

  void _applyBody(Map<String, dynamic>? body) {
    final cart = CartData.fromBody(body);
    if (cart == null) return;
    lines.assignAll(cart.items);
    totals.value = cart.totals;
  }

  /// Stepper: PATCH the absolute quantity. Server caps at branch stock
  /// (422) — the message is display copy, then resync from the server.
  Future<void> setQuantity(CartLine line, int nextQty) async {
    if (updatingKeys.contains(line.cartKey)) return;
    if (nextQty < 1) return;
    if (nextQty == line.quantity) return;
    updatingKeys.add(line.cartKey);
    try {
      final res = await _repository.updateQty(
        cartKey: line.cartKey,
        quantity: nextQty,
      );
      if (res.isError || res.data == null) {
        SnackbarService.showError(
          title: 'cart.update_failed_title'.trns(),
          message: (res.message?.isNotEmpty ?? false)
              ? res.message!
              : 'cart.update_failed'.trns(),
        );
        await refreshSilently();
        return;
      }
      _applyBody(res.data);
    } finally {
      updatingKeys.remove(line.cartKey);
    }
  }

  Future<void> increaseQty(CartLine line) =>
      setQuantity(line, line.quantity + 1);

  Future<void> decreaseQty(CartLine line) =>
      setQuantity(line, line.quantity - 1);

  /// Remove one line by its `cart_key`.
  Future<void> removeLine(CartLine line) async {
    if (updatingKeys.contains(line.cartKey)) return;
    updatingKeys.add(line.cartKey);
    try {
      final res = await _repository.removeItem(line.cartKey);
      if (res.isError || res.data == null) {
        SnackbarService.showError(
          title: 'cart.remove_failed_title'.trns(),
          message: (res.message?.isNotEmpty ?? false)
              ? res.message!
              : 'cart.remove_failed'.trns(),
        );
        return;
      }
      _applyBody(res.data);
    } finally {
      updatingKeys.remove(line.cartKey);
    }
  }

  void browseProducts() {
    ProductsController.open(title: 'products.all_products'.trns());
  }

  /// Checkout needs a login — guests get the auth prompt instead.
  Future<void> goToCheckout() async {
    if (isEmpty) return;
    final allowed = await AuthGuard.requireLogin(
      title: 'auth.required_title'.trns(),
      message: 'auth.required_checkout'.trns(),
    );
    if (!allowed) return;
    // Re-sync right before checkout so the summary starts from fresh data.
    await refreshSilently();
    if (isEmpty) return;
    Get.toNamed(Routes.CHECKOUT);
  }
}
