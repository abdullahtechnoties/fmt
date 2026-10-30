import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/catalog_model.dart';
import 'package:fmt/repositories/cart_repository.dart';
import 'package:fmt/repositories/store_repository.dart';
import 'package:fmt/services/store_service.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Arguments for the shared products listing page. Callers resolve [title]
/// before navigating (via `trns()`), because the page itself is reused for
/// all-products, category, featured/special and search entry points.
class ProductsArgs {
  const ProductsArgs({
    required this.title,
    this.categoryIds = const [],
    this.initialSearch = '',
    this.autofocusSearch = false,
  });

  final String title;
  final List<int> categoryIds;
  final String initialSearch;
  final bool autofocusSearch;
}

/// Shared products listing: `GET /products` with search (500ms debounce),
/// sort, stock and category-chip filters, pull-to-refresh and `has_more`
/// pagination. Reloads from page 1 whenever the branch changes.
class ProductsController extends GetxController {
  ProductsController({
    StoreRepository? storeRepo,
    CartRepository? cartRepo,
  })  : _storeRepo = storeRepo ?? StoreRepository(),
        _cartRepo = cartRepo ?? CartRepository();

  static const String sortLatest = 'latest';
  static const String sortPriceLow = 'price_low';
  static const String sortPriceHigh = 'price_high';
  static const String sortNameAsc = 'name_asc';
  static const String sortNameDesc = 'name_desc';

  static const List<String> sortOptions = [
    sortLatest,
    sortPriceLow,
    sortPriceHigh,
    sortNameAsc,
    sortNameDesc,
  ];

  /// `''` = all, otherwise `in_stock` / `out_of_stock`.
  static const String stockAll = '';
  static const String stockIn = 'in_stock';
  static const String stockOut = 'out_of_stock';

  static void open({
    required String title,
    List<int>? categoryIds,
    String? initialSearch,
    bool autofocusSearch = false,
  }) {
    Get.toNamed(
      Routes.PRODUCTS,
      arguments: ProductsArgs(
        title: title,
        categoryIds: categoryIds ?? const [],
        initialSearch: initialSearch ?? '',
        autofocusSearch: autofocusSearch,
      ),
    );
  }

  final StoreRepository _storeRepo;
  final CartRepository _cartRepo;

  final RxString title = ''.obs;
  final RxList<CatalogProduct> products = <CatalogProduct>[].obs;
  final RxList<CatalogCategory> categories = <CatalogCategory>[].obs;

  final RxSet<int> selectedCategoryIds = <int>{}.obs;
  final RxString sort = sortLatest.obs;
  final RxString stock = stockAll.obs;
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt total = 0.obs;
  final RxnString loadError = RxnString();

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  Timer? _debounce;
  int _page = 1;
  static const int _perPage = 12;
  int? _boundStoreId;
  bool _focusedOnce = false;

  StoreService get _storeService => Get.find<StoreService>();

  String get sortLabel => 'products.sort_$sort'.trns();
  bool get hasActiveFilters =>
      selectedCategoryIds.isNotEmpty ||
      sort.value != sortLatest ||
      stock.value != stockAll ||
      searchQuery.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ProductsArgs) {
      title.value = args.title;
      selectedCategoryIds.addAll(args.categoryIds);
      if (args.initialSearch.isNotEmpty) {
        searchController.text = args.initialSearch;
        searchQuery.value = args.initialSearch;
      }
      if (args.autofocusSearch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_focusedOnce && searchFocusNode.canRequestFocus) {
            _focusedOnce = true;
            searchFocusNode.requestFocus();
          }
        });
      }
    }
    if (title.value.isEmpty) title.value = 'products.all_products'.trns();

    _boundStoreId = _storeService.selectedStoreId;
    ever(_storeService.selectedStore, (_) => _onStoreChanged());
    scrollController.addListener(_onScroll);

    _loadCategories();
    loadFirst();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onStoreChanged() {
    final id = _storeService.selectedStoreId;
    if (id == _boundStoreId) return;
    _boundStoreId = id;
    loadFirst();
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoadingMore.value) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 320) loadMore();
  }

  // ─── Search ────────────────────────────────────────────────────────────────

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), loadFirst);
  }

  void clearSearch() {
    if (searchController.text.isEmpty && searchQuery.value.isEmpty) return;
    searchController.clear();
    searchQuery.value = '';
    _debounce?.cancel();
    loadFirst();
  }

  // ─── Filters ───────────────────────────────────────────────────────────────

  void toggleCategory(int id) {
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id);
    }
    loadFirst();
  }

  void clearCategoryFilter() {
    if (selectedCategoryIds.isEmpty) return;
    selectedCategoryIds.clear();
    loadFirst();
  }

  void applyFilters({required String nextSort, required String nextStock}) {
    sort.value = nextSort;
    stock.value = nextStock;
    loadFirst();
  }

  void clearAllFilters() {
    selectedCategoryIds.clear();
    sort.value = sortLatest;
    stock.value = stockAll;
    searchController.clear();
    searchQuery.value = '';
    _debounce?.cancel();
    loadFirst();
  }

  // ─── Paging ────────────────────────────────────────────────────────────────

  Future<void> loadFirst() => _fetch(reset: true);

  Future<void> refreshList() => _fetch(reset: true, silent: true);

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      final res = await _storeRepo.products(
        categoryIds: selectedCategoryIds.toList(),
        search: searchQuery.value,
        sort: sort.value,
        stock: stock.value.isEmpty ? null : stock.value,
        perPage: _perPage,
        page: _page + 1,
      );
      if (!res.isError && res.data != null) {
        _page = res.data!.meta.currentPage;
        hasMore.value = res.data!.meta.hasNextPage;
        total.value = res.data!.meta.total;
        products.addAll(res.data!.items);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _fetch({required bool reset, bool silent = false}) async {
    if (reset) {
      _page = 1;
      hasMore.value = true;
      loadError.value = null;
      if (!silent) isLoading.value = true;
    }
    try {
      final res = await _storeRepo.products(
        categoryIds: selectedCategoryIds.toList(),
        search: searchQuery.value,
        sort: sort.value,
        stock: stock.value.isEmpty ? null : stock.value,
        perPage: _perPage,
        page: 1,
      );
      if (res.isError || res.data == null) {
        if (products.isEmpty && reset) {
          loadError.value = (res.message?.isNotEmpty ?? false)
              ? res.message
              : 'products.load_failed'.trns();
        } else if (reset) {
          SnackbarService.showError(
            title: 'products.load_failed_title'.trns(),
            message: (res.message?.isNotEmpty ?? false)
                ? res.message!
                : 'products.load_failed'.trns(),
          );
        }
        return;
      }
      _page = res.data!.meta.currentPage;
      hasMore.value = res.data!.meta.hasNextPage;
      total.value = res.data!.meta.total;
      products.assignAll(res.data!.items);
      loadError.value = null;
    } finally {
      if (reset && !silent) isLoading.value = false;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final res = await _storeRepo.categories();
      if (!res.isError && res.data != null) {
        categories.assignAll(res.data!);
      }
    } catch (_) {
      // Chips are optional — the grid still works without them.
    }
  }

  // ─── Cart ──────────────────────────────────────────────────────────────────

  Future<void> onAddToCart(CatalogProduct product) async {
    if (product.isVariable) return;
    if (!product.inStock) {
      SnackbarService.showError(
        title: 'cart.out_of_stock_title'.trns(),
        message: 'cart.out_of_stock'.trns(),
      );
      return;
    }
    final res = await _cartRepo.addItem(productId: product.id, quantity: 1);
    if (res.isError) return;
    SnackbarService.showSuccess(
      title: 'cart.added_title'.trns(),
      message: 'cart.added'.trnsFormat({'title': product.title}),
    );
  }
}
