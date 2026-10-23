import 'package:get/get.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/network/service/auth_service.dart';

class SplashController extends GetxController {


  final count = 0.obs;
  // logo opacity
  var logoOpacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    logoOpacity.value = 1.0;
    Future.delayed(const Duration(seconds: 3), () async {
      // await _navigateInitial();
      Get.toNamed(Routes.ONBOARDING);
    });
  }

  // bool _hasRole(String role) {
  //   final roles = Get.find<AuthService>().currentUser.value?.roles;
  //   if (roles == null || roles.isEmpty) return false;
  //   return roles.any(
  //     (r) => (r.name ?? '').trim().toLowerCase() == role,
  //   );
  // }

  /// Graceful launch redirection. Customer flow is untouched; vendor flow
  /// re-checks the backend onboarding stage (token stays valid before
  /// approval/payment, so the token alone can't decide the landing page).
  // Future<void> _navigateInitial() async {
  //   final isFirstTime = AuthService.firstTimeOnApp();

  //   if (isFirstTime) {
  //     Get.offAllNamed(Routes.ONBOARDING);
  //     return;
  //   }

  //   try {
  //     await Get.find<AuthService>().ready;
  //   } catch (_) {
  //     // Bootstrap failure -> fall through to the checks below.
  //   }

  //   final token = await AuthService.getAuthBearerToken();
  //   final isAuthed = AuthService.authenticated();

  //   if (!isAuthed || token.isEmpty) {
  //     Get.offAllNamed(Routes.LOGIN);
  //     return;
  //   }

  //   // Vendor-only stage check; customers go straight home.
  //   if (_hasRole('vendor')) {
  //     final statusResponse =
  //         await _vendorOnboarding.fetchOnboardingStatus();
  //     if (statusResponse.isError || statusResponse.data == null) {
  //       // NetworkService already surfaced the error (and handles 401
  //       // session-expiry itself). Fall back to login so the user can retry.
  //       Get.offAllNamed(Routes.LOGIN);
  //       return;
  //     }
  //     VendorOnboardingRedirector.redirect(statusResponse.data!);
  //     return;
  //   }

  //   if (_hasRole('customer')) {
  //     Get.offAllNamed(Routes.BOTTOMNAV);
  //     return;
  //   }

  //   // Authenticated but role is missing/unknown (e.g. stale user cache):
  //   // send back to login instead of guessing a landing page.
  //   Get.offAllNamed(Routes.LOGIN);
  // }
}
