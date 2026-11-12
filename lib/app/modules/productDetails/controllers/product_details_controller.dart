import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/catalog_model.dart';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:fmt/repositories/cart_repository.dart';
import 'package:fmt/repositories/store_repository.dart';
import 'package:fmt/services/store_service.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Product details: `GET /products/{slug}` (ids resolve via
/// `GET /products/resolve/{id}` first). Holds gallery position, attribute
/// selection, quantity and the add-to-cart call with `variant_id` /
/// `variant_label`. Reloads when the branch changes (stock is per branch).
class ProductDetailsController extends GetxController {
  ProductDetailsController({
    StoreRepository? storeRepo,
    CartRepository? cartRepo,
    NetworkService? network,
  })  : _storeRepo = storeRepo ?? StoreRepository(),
        _cartRepo = cartRepo ?? CartRepository(),
        _network = network ?? Get.find();

  /// Open from listings: card taps pass `slug ?? id`.
  static void open(Object idOrSlug) {
    Get.toNamed(
      Routes.PRODUCT_DETAILS,
      arguments: idOrSlug,
      preventDuplicates: false,
    );
  }

  final StoreRepository _storeRepo;
  final CartRepository _cartRepo;
  final NetworkService _network;

  final Rxn<ProductDetail> detail = Rxn<ProductDetail>();
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();

  final RxInt galleryIndex = 0.obs;
  final RxMap<int, int> selectedOptions = <int, int>{}.obs;
  final RxInt quantity = 1.obs;
  final RxBool isAdding = false.obs;
  final RxBool showCartFab = false.obs;

  int? _boundStoreId;
  String? _slug;
  bool _loaded = false;

  StoreService get _storeService => Get.find<StoreService>();

  ProductDetail? get product => detail.value;

  /// Exact variant for the current option selection (variable products).
  ProductVariant? get matchedVariant {
    final p = product;
    if (p == null || !p.isVariable) return null;
    return p.matchVariant(selectedOptions);
  }

  /// All attributes chosen — required before a variable product can be added.
  bool get hasCompleteSelection {
    final p = product;
    if (p == null || !p.isVariable) return true;
    if (p.attributes.isEmpty) return matchedVariant != null;
    return p.attributes.every((a) => selectedOptions.containsKey(a.id));
  }

  /// What the customer pays per unit right now (variant-aware, bulk-aware).
  double get unitPrice {
    final p = product;
    if (p == null) return 0;
    final base = matchedVariant?.effectivePrice ?? p.effectivePrice;
    if (_bulkApplies) return _bulkPrice!;
    return base;
  }

  double? get _bulkPrice => matchedVariant?.bulkPrice ?? product?.bulkPrice;

  int? get _bulkMinQty => matchedVariant?.minBulkQty ?? product?.minBulkQty;

  bool get _bulkApplies {
    final price = _bulkPrice;
    final min = _bulkMinQty;
    return price != null && price > 0 && min != null && quantity.value >= min;
  }

  /// Max buyable right now (variant stock when selected, else product sum).
  int? get maxQuantity {
    final p = product;
    if (p == null) return null;
    if (p.isVariable) return matchedVariant?.stockQty;
    return p.stockQty > 0 ? p.stockQty : null;
  }

  bool get canAdd {
    final p = product;
    if (p == null || isAdding.value) return false;
    if (p.isVariable) {
      final v = matchedVariant;
      return hasCompleteSelection && v != null && v.inStock;
    }
    return p.inStock;
  }

  String get addButtonLabel {
    final p = product;
    if (p == null) return 'details.add_to_cart'.trns();
    if (p.isVariable && !hasCompleteSelection) {
      return 'details.select_options'.trns();
    }
    if (!canAdd) return 'details.out_of_stock'.trns();
    return 'details.add_to_cart'.trns();
  }

  @override
  void onInit() {
    super.onInit();
    _boundStoreId = _storeService.selectedStoreId;
    ever(_storeService.selectedStore, (_) => _onStoreChanged());
    final args = Get.arguments;
    if (args is String && args.isNotEmpty) {
      _slug = args;
    } else if (args is int) {
      _resolveAndLoad(args);
      return;
    } else if (args is CatalogProduct) {
      _slug = args.slug;
      if (_slug == null || _slug!.isEmpty) {
        _resolveAndLoad(args.id);
        return;
      }
    }
    if (_slug == null || _slug!.isEmpty) {
      isLoading.value = false;
      loadError.value = 'details.load_failed'.trns();
      return;
    }
    loadDetail();
  }

  void _onStoreChanged() {
    final id = _storeService.selectedStoreId;
    if (id == _boundStoreId) return;
    _boundStoreId = id;
    if (_loaded) loadDetail();
  }

  Future<void> _resolveAndLoad(int id) async {
    try {
      final res =
          await _network.get(endpoint: ApiPath.productResolve(id));
      final body = res.data?['data'];
      final slug = body is Map ? body['slug']?.toString() : null;
      if (!res.isError && slug != null && slug.isNotEmpty) {
        _slug = slug;
        await loadDetail();
        return;
      }
      loadError.value = 'details.load_failed'.trns();
    } catch (_) {
      loadError.value = 'details.load_failed'.trns();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDetail() async {
    final slug = _slug;
    if (slug == null || slug.isEmpty) return;
    isLoading.value = true;
    loadError.value = null;
    try {
      final res = await _storeRepo.productDetail(slug);
      if (res.isError || res.data == null) {
        loadError.value = (res.message?.isNotEmpty ?? false)
            ? res.message
            : 'details.load_failed'.trns();
        return;
      }
      detail.value = res.data;
      _loaded = true;
      galleryIndex.value = 0;
      selectedOptions.clear();
      quantity.value = 1;
      _preselectSingleOptions(res.data!);
    } finally {
      isLoading.value = false;
    }
  }

  /// When an attribute has exactly one in-stock value, pick it up front.
  void _preselectSingleOptions(ProductDetail p) {
    if (!p.isVariable) return;
    for (final attr in p.attributes) {
      final available =
          attr.values.where((v) => v.inStock).toList(growable: false);
      if (available.length == 1) {
        selectedOptions[attr.id] = available.first.id;
      }
    }
  }

  void onGalleryChanged(int index) => galleryIndex.value = index;

  void selectOption(int attributeId, int valueId) {
    if (selectedOptions[attributeId] == valueId) return;
    selectedOptions[attributeId] = valueId;
    // Clamp quantity to the newly matched variant's stock.
    final max = maxQuantity;
    if (max != null && quantity.value > max) quantity.value = max;
  }

  void incrementQty() {
    final max = maxQuantity;
    if (max != null && quantity.value >= max) return;
    quantity.value++;
  }

  void decrementQty() {
    if (quantity.value > 1) quantity.value--;
  }

  /// Footer price line, bulk-aware.
  String get footerPriceHint {
    final min = _bulkMinQty;
    final price = _bulkPrice;
    if (min == null || price == null || price <= 0) return '';
    return 'details.bulk_hint'.trnsFormat({
      'qty': min,
      'price': price.toStringAsFixed(price % 1 == 0 ? 0 : 2),
    });
  }

  /// Related card tap on its add button: simple items add straight away,
  /// variable ones open their own details page to pick options.
  Future<void> addRelated(CatalogProduct item) async {
    if (item.isVariable || (item.slug ?? '').isEmpty) {
      open(item.slug ?? item.id);
      return;
    }
    if (!item.inStock) {
      SnackbarService.showError(
        title: 'cart.out_of_stock_title'.trns(),
        message: 'cart.out_of_stock'.trns(),
      );
      return;
    }
    final wasAdding = isAdding.value;
    isAdding.value = true;
    try {
      final res = await _cartRepo.addItem(productId: item.id, quantity: 1);
      if (res.isError) return;
      SnackbarService.showSuccess(
        title: 'cart.added_title'.trns(),
        message: 'cart.added'.trnsFormat({'title': item.title}),
      );
      showCartFab.value = true;
    } finally {
      isAdding.value = wasAdding;
    }
  }

  Future<void> onAddToCart() async {
    final p = product;
    if (p == null || isAdding.value) return;
    if (p.isVariable) {
      if (!hasCompleteSelection) {
        SnackbarService.showError(
          title: 'details.select_options_title'.trns(),
          message: 'details.select_options'.trns(),
        );
        return;
      }
      final v = matchedVariant;
      if (v == null || !v.inStock) {
        SnackbarService.showError(
          title: 'cart.out_of_stock_title'.trns(),
          message: 'cart.out_of_stock'.trns(),
        );
        return;
      }
    } else if (!p.inStock) {
      SnackbarService.showError(
        title: 'cart.out_of_stock_title'.trns(),
        message: 'cart.out_of_stock'.trns(),
      );
      return;
    }
    final variant = matchedVariant;
    isAdding.value = true;
    try {
      final res = await _cartRepo.addItem(
        productId: p.id,
        quantity: quantity.value,
        variantId: variant?.id,
        variantLabel: variant != null && variant.optionLabels.isNotEmpty
            ? variant.optionLabels.join(', ')
            : null,
      );
      if (res.isError) return;
      SnackbarService.showSuccess(
        title: 'cart.added_title'.trns(),
        message: 'cart.added'.trnsFormat({'title': p.title}),
      );
      showCartFab.value = true;
    } finally {
      isAdding.value = false;
    }
  }
}
