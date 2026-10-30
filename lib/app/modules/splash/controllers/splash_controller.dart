import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/bootstrap_model.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/network/service/local_storage.dart';
import 'package:fmt/repositories/auth_repository.dart';
import 'package:fmt/repositories/store_repository.dart';
import 'package:fmt/services/store_service.dart';
import 'package:fmt/utilities/app_strings.dart';
import 'package:get/get.dart';

/// Launch gate: bootstrap the app config, then route.
///
/// Order:
/// 1. `GET /bootstrap` → cache branch list, preselect branch, cache
///    WhatsApp numbers. Offline → fall back to the cached payload.
/// 2. First run → onboarding.
/// 3. Valid token (`GET /auth/me`) → bottom nav; otherwise login.
class SplashController extends GetxController {
  final count = 0.obs;
  final logoOpacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    logoOpacity.value = 1.0;
    _navigateInitial();
  }

  Future<void> _navigateInitial() async {
    await Future.delayed(const Duration(seconds: 2));

    await _bootstrap();

    if (AuthService.firstTimeOnApp()) {
      Get.offAllNamed(Routes.ONBOARDING);
      return;
    }

    try {
      await Get.find<AuthService>().ready;
    } catch (_) {
      // Bootstrap failure → fall through to the checks below.
    }

    final token = await AuthService.getAuthBearerToken();
    if (token.isEmpty) {
      // Guest mode: Skip on login drops straight into the shop; the
      // profile tab and checkout prompt for login when needed.
      final guest =
          LocalStorageService.prefs?.getBool(AppStrings.guestMode) ?? false;
      Get.offAllNamed(guest ? Routes.BOTTOMNAV : Routes.LOGIN);
      return;
    }

    // Confirm the stored token is still valid before entering the app.
    final me = await AuthRepository().me();
    if (me.isError || me.data == null) {
      // NetworkService already surfaced the 401 session-expiry dialog;
      // for anything else just drop to login so the user can retry.
      if (Get.isDialogOpen != true) {
        Get.offAllNamed(Routes.LOGIN);
      }
      return;
    }
    await Get.find<AuthService>().setCurrentUser(me.data);
    Get.offAllNamed(Routes.BOTTOMNAV);
  }

  Future<void> _bootstrap() async {
    try {
      final repo = StoreRepository();
      var bootstrap = await repo.bootstrap();
      BootstrapData? data = bootstrap.data;
      data ??= repo.cachedBootstrap();
      if (data == null) return;

      final storeService = Get.find<StoreService>();
      storeService.syncStores(
        data.stores,
        preferredId: data.preselectedStoreId,
      );
      if (data.whatsappGeneral != null) {
        await LocalStorageService.prefs?.setString(
          AppStrings.whatsappGeneral,
          data.whatsappGeneral!,
        );
      }
      if (data.whatsappOrder != null) {
        await LocalStorageService.prefs?.setString(
          AppStrings.whatsappOrder,
          data.whatsappOrder!,
        );
      }
    } catch (_) {
      // Launch must never die on bootstrap — Home retries it.
    }
  }
}
