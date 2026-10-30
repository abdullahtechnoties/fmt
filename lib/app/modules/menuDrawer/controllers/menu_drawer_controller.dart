import 'package:fmt/app/modules/products/controllers/products_controller.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/catalog_model.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/repositories/auth_repository.dart';
import 'package:fmt/repositories/store_repository.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Drawer: real user, live categories, branch entry, logout.
class MenuDrawerController extends GetxController {
  MenuDrawerController({
    StoreRepository? storeRepo,
  }) : _storeRepo = storeRepo ?? StoreRepository();

  final StoreRepository _storeRepo;

  AuthService get _auth => Get.find<AuthService>();

  String get userName =>
      _auth.currentUser.value?.displayName ?? 'profile.guest'.trns();
  String? get userEmail => _auth.currentUser.value?.email;
  String? get userImage => _auth.currentUser.value?.avatar;

  bool get isLoggedIn => _auth.currentUser.value != null;

  void goToLogin() {
    Get.back();
    Get.toNamed(Routes.LOGIN);
  }

  final RxList<CatalogCategory> categories = <CatalogCategory>[].obs;
  final isLoadingCategories = false.obs;
  final isLoggingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    if (isLoadingCategories.value) return;
    isLoadingCategories.value = true;
    try {
      final res = await _storeRepo.categories();
      if (!res.isError && res.data != null) {
        categories.assignAll(res.data!);
      }
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Branch switch needs the live cart emptied first — callers pass a clear
  /// callback that runs only after the user confirms.

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      await AuthRepository().logout();
    } catch (_) {
      // Server logout is best-effort — local session always clears.
    } finally {
      await AuthService.forceLogout(showLogin: false);
      isLoggingOut.value = false;
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void goToCategories(CatalogCategory category) {
    Get.back();
    // Drawer shortcuts deep-link straight into that category's listing:
    // open the shared products page for the category, with the bottom-nav
    // categories tab left intact underneath.
    final ids = <int>[category.id];
    for (final child in category.children) {
      if (!ids.contains(child.id)) ids.add(child.id);
    }
    ProductsController.open(title: category.name, categoryIds: ids);
  }
}
