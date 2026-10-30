import 'dart:convert';

import 'package:fmt/models/store_model.dart';
import 'package:fmt/network/service/local_storage.dart';
import 'package:fmt/utilities/app_strings.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/app_confirm_dialog.dart';
import 'package:get/get.dart';

/// Owns the selected branch (store) and the branch list.
///
/// The id is persisted to prefs so [NetworkService] can attach it as
/// `X-Store-Id` on every catalog/cart call without depending on this service.
///
/// Branch switching empties the server cart (prices/stock are per branch),
/// so [selectStore] confirms with the user when [cartNotEmpty] is true.
class StoreService extends GetxService {
  final RxList<StoreModel> stores = <StoreModel>[].obs;
  final Rx<StoreModel?> selectedStore = Rx<StoreModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString lastInventoryClearedAt = ''.obs;

  int? get selectedStoreId => selectedStore.value?.id;

  @override
  void onInit() {
    super.onInit();
    _restoreFromCache();
  }

  void _restoreFromCache() {
    try {
      final raw = LocalStorageService.prefs?.getString(AppStrings.storeListCache);
      final savedId = LocalStorageService.prefs?.getInt(AppStrings.selectedStoreId);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final list = decoded
          .whereType<Map>()
          .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (list.isEmpty) return;
      stores.assignAll(list);
      if (savedId != null) {
        for (final s in list) {
          if (s.id == savedId) {
            selectedStore.value = s;
            break;
          }
        }
      }
      selectedStore.value ??= list.first;
    } catch (_) {
      // Corrupt cache → fall back to bootstrap defaults.
    }
  }

  /// Cache the branch list (from `/stores` or `/bootstrap`) and ensure a
  /// valid selection. The user's saved selection always wins — [preferredId]
  /// (bootstrap's default) applies only on first run when nothing is saved.
  /// This keeps a manual branch switch sticky across home/categories/cart
  /// reloads, which all re-sync the branch list from bootstrap.
  void syncStores(List<StoreModel> list, {int? preferredId}) {
    if (list.isEmpty) return;
    stores.assignAll(list);
    // 1. Keep whatever the user already picked (sticky across reloads).
    StoreModel? next = _matchCurrent(list);
    // 2. First run only: fall back to bootstrap's preselected branch.
    if (next == null && preferredId != null) {
      for (final s in list) {
        if (s.id == preferredId) {
          next = s;
          break;
        }
      }
    }
    next ??= list.first;
    // Skip the write when nothing changed so Obx listeners (home pill,
    // drawer tile, sheet highlight) don't rebuild with a stale flash.
    if (selectedStore.value?.id == next.id) return;
    _persistSelection(next);
    _cacheList(list);
  }

  StoreModel? _matchCurrent(List<StoreModel> list) {
    final id = selectedStore.value?.id ??
        LocalStorageService.prefs?.getInt(AppStrings.selectedStoreId);
    if (id == null) return null;
    for (final s in list) {
      if (s.id == id) return s;
    }
    return null;
  }

  void _persistSelection(StoreModel store) {
    selectedStore.value = store;
    LocalStorageService.prefs?.setInt(AppStrings.selectedStoreId, store.id);
  }

  void _cacheList(List<StoreModel> list) {
    try {
      LocalStorageService.prefs?.setString(
        AppStrings.storeListCache,
        jsonEncode(list.map((s) => s.toJson()).toList()),
      );
    } catch (_) {}
  }

  /// Switch branch. When the cart holds items, confirm first because the
  /// server empties the cart on branch change. Returns true when switched.
  Future<bool> selectStore(
    StoreModel store, {
    required bool cartNotEmpty,
    Future<void> Function()? onClearCart,
  }) async {
    if (selectedStore.value?.id == store.id) return true;
    if (cartNotEmpty) {
      final confirmed = await AppConfirmDialog.show(
        title: 'branch.switch_title'.trns(),
        message: 'branch.switch_message'.trns(),
        confirmText: 'branch.switch_confirm'.trns(),
      );
      if (confirmed != true) return false;
      try {
        await onClearCart?.call();
      } catch (_) {
        SnackbarService.showError(
          title: 'branch.switch_failed_title'.trns(),
          message: 'branch.switch_failed'.trns(),
        );
        return false;
      }
      lastInventoryClearedAt.value = DateTime.now().toIso8601String();
    }
    _persistSelection(store);
    return true;
  }
}
