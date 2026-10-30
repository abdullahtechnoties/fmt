import 'package:fmt/app/modules/products/controllers/products_controller.dart';
import 'package:fmt/models/catalog_model.dart';
import 'package:fmt/repositories/store_repository.dart';
import 'package:fmt/services/store_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Categories tab: live `GET /categories` with pull-to-refresh, local search
/// filter (500ms debounce over cached list), branch-change reload, and taps
/// that open the shared products page for that category.
class CategoriesController extends GetxController {
  CategoriesController({StoreRepository? storeRepo})
      : _storeRepo = storeRepo ?? StoreRepository();

  final StoreRepository _storeRepo;

  final RxList<CatalogCategory> allCategories = <CatalogCategory>[].obs;
  final RxList<CatalogCategory> visibleCategories = <CatalogCategory>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxnString loadError = RxnString();
  final RxString searchQuery = ''.obs;

  int? _boundStoreId;

  StoreService get _storeService => Get.find<StoreService>();

  @override
  void onInit() {
    super.onInit();
    _boundStoreId = _storeService.selectedStoreId;
    ever(_storeService.selectedStore, (_) => _onStoreChanged());
    debounce<String>(
      searchQuery,
      (_) => _applySearch(),
      time: const Duration(milliseconds: 500),
    );
    loadCategories();
  }

  void _onStoreChanged() {
    final id = _storeService.selectedStoreId;
    if (id == _boundStoreId) return;
    _boundStoreId = id;
    loadCategories();
  }

  void onSearchChanged(String value) => searchQuery.value = value;

  void _applySearch() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      visibleCategories.assignAll(allCategories);
      return;
    }
    visibleCategories.assignAll(
      allCategories.where((c) => c.name.toLowerCase().contains(q)),
    );
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final res = await _storeRepo.categories();
      if (res.isError || res.data == null) {
        if (allCategories.isEmpty) {
          loadError.value = (res.message?.isNotEmpty ?? false)
              ? res.message
              : 'categories.load_failed'.trns();
        }
        return;
      }
      allCategories.assignAll(res.data!);
      _applySearch();
      loadError.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCategories() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      final res = await _storeRepo.categories();
      if (!res.isError && res.data != null) {
        allCategories.assignAll(res.data!);
        _applySearch();
        loadError.value = null;
      }
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Flatten parents + children so sub-categories are tappable too.
  List<CatalogCategory> flattened(List<CatalogCategory> cats) {
    final out = <CatalogCategory>[];
    for (final c in cats) {
      out.add(c);
      out.addAll(c.children);
    }
    return out;
  }

  void openCategory(CatalogCategory category) {
    final ids = <int>[category.id];
    for (final child in category.children) {
      if (!ids.contains(child.id)) ids.add(child.id);
    }
    ProductsController.open(title: category.name, categoryIds: ids);
  }

  void browseAll() {
    ProductsController.open(title: 'categories.all_products'.trns());
  }
}
