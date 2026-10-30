import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/account_model.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/repositories/account_repository.dart';
import 'package:fmt/repositories/auth_repository.dart';
import 'package:fmt/utilities/navigation_helper.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/app_confirm_dialog.dart';
import 'package:get/get.dart';

/// Profile tab: live user header, single delivery address (bottom-sheet
/// editor), order-history / change-password entries, logout with warning.
/// Address edits overwrite the customer's single address record per API.
class ProfileController extends GetxController {
  ProfileController({
    AccountRepository? accountRepo,
    AuthRepository? authRepo,
  })  : _accountRepo = accountRepo ?? AccountRepository(),
        _authRepo = authRepo ?? AuthRepository();

  final AccountRepository _accountRepo;
  final AuthRepository _authRepo;

  AuthService get _auth => Get.find<AuthService>();

  String get userName =>
      _auth.currentUser.value?.displayName ?? 'profile.guest'.trns();
  String get userEmail => _auth.currentUser.value?.email ?? '';
  String? get userAvatar => _auth.currentUser.value?.avatar;
  String get userInitial =>
      userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : '?';

  final Rxn<CustomerAddress> address = Rxn<CustomerAddress>();
  final isLoadingAddress = false.obs;
  final isLoggingOut = false.obs;

  String get deliveryLine =>
      (address.value?.deliveryAddress ?? '').trim();
  String get billingLine => address.value?.summaryLine ?? '';

  @override
  void onInit() {
    super.onInit();
    loadAddress();
    // Re-pull the address when the account changes (login/logout).
    ever(_auth.currentUser, (_) {
      address.value = null;
      loadAddress();
    });
  }

  Future<void> loadAddress() async {
    if (_auth.currentUser.value == null) return;
    if (isLoadingAddress.value) return;
    isLoadingAddress.value = true;
    try {
      final res = await _accountRepo.addresses();
      if (!res.isError) address.value = res.data;
    } finally {
      isLoadingAddress.value = false;
    }
  }

  /// Overwrites the single delivery line (`PUT /account/addresses/delivery`).
  Future<bool> saveDeliveryAddress(String value) async {
    final text = value.trim();
    if (text.isEmpty) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'auth.validation.required'.trns(),
      );
      return false;
    }
    final res = await _accountRepo.updateDelivery(deliveryAddress: text);
    if (res.isError) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: (res.message?.isNotEmpty ?? false)
            ? res.message!
            : 'profile.address_save_failed'.trns(),
      );
      return false;
    }
    final current = address.value;
    address.value = CustomerAddress(
      name: current?.name,
      address: current?.address,
      city: current?.city,
      zip: current?.zip,
      country: current?.country,
      phone: current?.phone,
      deliveryAddress: text,
    );
    NavigationHelper.safePop(Get.context!);
    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message: (res.message?.isNotEmpty ?? false)
          ? res.message!
          : 'profile.address_saved'.trns(),
    );
    return true;
  }

  void goToEditProfile() => Get.toNamed(Routes.EDIT_PROFILE);
  void goToOrderHistory() => Get.toNamed(Routes.ORDER_HISTORY);
  void goToChangePassword() => Get.toNamed(Routes.CHANGE_PASSWORD);

  /// Warn first — logout revokes the token, wipes local data and returns
  /// to login. Past orders stay on the server as financial records.
  Future<void> logout() async {
    if (isLoggingOut.value) return;
    final confirmed = await AppConfirmDialog.show(
      title: 'profile.logout_title'.trns(),
      message: 'profile.logout_message'.trns(),
      confirmText: 'common.yes'.trns(),
      isDangerous: true,
    );
    if (confirmed != true) return;
    isLoggingOut.value = true;
    try {
      await _authRepo.logout();
    } catch (_) {
      // Server logout is best-effort — local session always clears.
    } finally {
      await AuthService.forceLogout(showLogin: false);
      isLoggingOut.value = false;
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
