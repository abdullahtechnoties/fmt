import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/modules/products/controllers/products_controller.dart';
import 'package:fmt/models/catalog_model.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/repositories/cart_repository.dart';
import 'package:fmt/repositories/store_repository.dart';
import 'package:fmt/services/store_service.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Home screen: `GET /home` blocks, reactive to branch switches.
/// Featured falls back to latest when empty (per API docs) so the screen is
/// never blank. RefreshIndicator + shimmer handled by the view.
class HomeController extends GetxController {
  HomeController({
    StoreRepository? storeRepo,
    CartRepository? cartRepo,
  })  : _storeRepo = storeRepo ?? StoreRepository(),
        _cartRepo = cartRepo ?? CartRepository();

  final StoreRepository _storeRepo;
  final CartRepository _cartRepo;

  final isLoading = true.obs;
  final isRefreshing = false.obs;

  final RxList<CatalogCategory> categories = <CatalogCategory>[].obs;
  final RxList<CatalogProduct> featuredProducts = <CatalogProduct>[].obs;
  final RxList<CatalogProduct> specialProducts = <CatalogProduct>[].obs;
  final RxList<CatalogProduct> latestProducts = <CatalogProduct>[].obs;

  StoreService get _storeService => Get.find<StoreService>();
  AuthService get _auth => Get.find<AuthService>();

  String? get userAvatar => _auth.currentUser.value?.avatar;
  String get userName =>
      _auth.currentUser.value?.displayName ?? 'profile.guest'.trns();

  int? _boundStoreId;

  @override
  void onInit() {
    super.onInit();
    _boundStoreId = _storeService.selectedStoreId;
    // Reload stock whenever the branch changes.
    ever(_storeService.selectedStore, (_) => _onStoreChanged());
    loadHome();
  }

  void _onStoreChanged() {
    final id = _storeService.selectedStoreId;
    if (id == _boundStoreId) return;
    _boundStoreId = id;
    loadHome();
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    try {
      // Branch list may have changed (first run) — keep selector in sync.
      await _syncBranches();
      final res = await _storeRepo.home();
      if (res.isError || res.data == null) {
        if (featuredProducts.isEmpty) {
          SnackbarService.showError(
            title: 'home.load_failed_title'.trns(),
            message: (res.message?.isNotEmpty ?? false)
                ? res.message!
                : 'home.load_failed'.trns(),
          );
        }
        return;
      }
      final data = res.data!;
      categories.assignAll(data.categories);
      latestProducts.assignAll(data.latestProducts);
      featuredProducts.assignAll(
        data.featuredProducts.isNotEmpty
            ? data.featuredProducts
            : data.latestProducts,
      );
      specialProducts.assignAll(
        data.specialProducts.isNotEmpty
            ? data.specialProducts
            : data.latestProducts,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHome() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      await _syncBranches();
      final res = await _storeRepo.home();
      if (!res.isError && res.data != null) {
        final data = res.data!;
        categories.assignAll(data.categories);
        latestProducts.assignAll(data.latestProducts);
        featuredProducts.assignAll(
          data.featuredProducts.isNotEmpty
              ? data.featuredProducts
              : data.latestProducts,
        );
        specialProducts.assignAll(
          data.specialProducts.isNotEmpty
              ? data.specialProducts
              : data.latestProducts,
        );
      }
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> _syncBranches() async {
    try {
      final res = await _storeRepo.bootstrap();
      if (!res.isError && res.data != null && res.data!.stores.isNotEmpty) {
        _storeService.syncStores(
          res.data!.stores,
          preferredId: res.data!.preselectedStoreId,
        );
        _boundStoreId = _storeService.selectedStoreId;
      }
    } catch (_) {
      // Branch sync is best-effort; home payload still renders.
    }
  }

  /// Open the shared products page for one home category (children ids
  /// included so sub-category items appear too).
  void openCategory(CatalogCategory category) {
    final ids = <int>[category.id];
    for (final child in category.children) {
      if (!ids.contains(child.id)) ids.add(child.id);
    }
    ProductsController.open(title: category.name, categoryIds: ids);
  }

  /// All three "view all" entry points land on the shared products page.
  void openAllCategories() =>
     Get.find<BottomnavController>().changeTabIndex(1);

  void openAllProducts() =>
      ProductsController.open(title: 'products.all_products'.trns());

  void openFeatured() =>
      ProductsController.open(title: 'home.featured_products'.trns());

  void openSpecial() =>
      ProductsController.open(title: 'home.special_products'.trns());

  Future<void> onAddToCart(CatalogProduct product) async {
    if (!product.inStock) {
      SnackbarService.showError(
        title: 'cart.out_of_stock_title'.trns(),
        message: 'cart.out_of_stock'.trns(),
      );
      return;
    }
    final res = await _cartRepo.addItem(productId: product.id, quantity: 1);
    if (res.isError) {
      // NetworkService already toasted the stock message.
      return;
    }
    SnackbarService.showSuccess(
      title: 'cart.added_title'.trns(),
      message: 'cart.added'.trnsFormat({'title': product.title}),
    );
  }
}
