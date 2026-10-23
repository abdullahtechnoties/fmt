import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fmt/models/user_model.dart';
import 'package:fmt/network/service/local_storage.dart';
import 'package:fmt/utilities/app_strings.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static const String accessTokenKey = 'access_token';

  final Rx<String?> accessToken = Rx<String?>(null);
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  late final Future<void> ready;
  static final RxBool _logoutInProgress = false.obs;

  // Role helpers
  bool get isVendor =>
      currentUser.value?.roles?.any(
        (role) => role.name?.toLowerCase() == 'vendor',
      ) ??
      false;
  bool get isCompany =>
      currentUser.value?.roles?.any(
        (role) => role.name?.toLowerCase() == 'company',
      ) ??
      false;
  bool get isCustomer =>
      currentUser.value?.roles?.any(
        (role) => role.name?.toLowerCase() == 'customer',
      ) ??
      false;

  // Check if user has allowed role for this app (single app, both roles)
  bool get hasAllowedRole => isCustomer || isVendor;

  @override
  void onInit() async {
    super.onInit();
    ready = _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([_loadAccessToken(), _loadCurrentUser()]);
    log('AuthService init ${accessToken.value}, ${currentUser.value}');
  }

  Future<void> _loadAccessToken() async {
    final token = await getAuthBearerToken();
    log('Loaded access token: $token');
    accessToken.value = token.isEmpty ? null : token;
  }

  Future<void> _loadCurrentUser() async {
    final raw = LocalStorageService.prefs?.getString(AppStrings.userKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      log('Loaded current user: $decoded');
      if (decoded is Map) {
        log('Decoded user data: $decoded');
        final user = UserModel.fromJson(Map<String, dynamic>.from(decoded));
        currentUser.value = user;
        log(
          'Restored user roles: ${user.roles?.map((role) => role.name).toList()}',
        );
      }
    } catch (_) {
      log('Failed to decode user data: $raw');
      currentUser.value = null;
    }
  }

  Future<void> setAccessToken(String token) async {
    await setAuthBearerToken(token);
    accessToken.value = token.isEmpty ? null : token;
  }

  Future<void> setCurrentUser(UserModel? user) async {
    if (user == null) {
      await LocalStorageService.prefs?.remove(AppStrings.userKey);
      currentUser.value = null;
      return;
    }

    final userJson = user.toJson();
    final cachedRoles = currentUser.value?.roles;
    if ((user.roles == null || user.roles!.isEmpty) && cachedRoles != null) {
      userJson['roles'] = cachedRoles.map((role) => role.toJson()).toList();
    }

    await LocalStorageService.prefs?.setString(
      AppStrings.userKey,
      jsonEncode(userJson),
    );
    currentUser.value =
        (user.roles == null || user.roles!.isEmpty) && cachedRoles != null
        ? UserModel.fromJson(userJson)
        : user;
    log(
      'Saved user roles: ${(userJson['roles'] as List?)?.map((role) => role['name']).toList()}',
    );
  }

  static bool firstTimeOnApp() {
    return LocalStorageService.prefs?.getBool(AppStrings.firstTimeOnApp) ??
        true;
  }

  static Future<void> firstTimeCompleted() async {
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
  }

  static bool authenticated() {
    return LocalStorageService.prefs?.getBool(AppStrings.authenticated) ??
        false;
  }

  static Future<bool> isAuthenticated() async {
    await LocalStorageService.prefs?.setBool(AppStrings.authenticated, true);
    return LocalStorageService.prefs!.getBool(AppStrings.authenticated) ??
        false;
  }

  static Future<void> setAuthenticated(bool value) async {
    await LocalStorageService.prefs?.setBool(AppStrings.authenticated, value);
  }

  static Future<String> getAuthBearerToken() async {
    return LocalStorageService.prefs?.getString(AppStrings.userAuthToken) ?? "";
  }

  static Future<bool> setAuthBearerToken(String token) async {
    return LocalStorageService.prefs!.setString(
      AppStrings.userAuthToken,
      token,
    );
  }

  static Future<void> saveLocale(String locale) async {
    await LocalStorageService.prefs?.setString(AppStrings.appLocale, locale);
  }

  static Future<String?> getSavedLocale() async {
    return LocalStorageService.prefs?.getString(AppStrings.appLocale);
  }

  static Future<void> logout() async {
    // Clear FCM token first
    // await NotificationService.instance.clearTokenOnLogout();
    // await FirebaseMessaging.instance.deleteToken();
    await LocalStorageService.prefs?.clear();
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
  }

  static Future<void> confirmLogout() async {
    if (_logoutInProgress.value || Get.isDialogOpen == true) return;

    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('profile.logout_title'.trns()),
        content: Text('profile.logout_message'.trns()),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.trns()),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'common.yes'.trns(),
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true || _logoutInProgress.value) return;

    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      await forceLogout(showLogin: false);
      // if (Get.isDialogOpen == true) Get.back<void>();
      Get.offAllNamed('/login');
    } catch (_) {
      if (Get.isDialogOpen == true) Get.back<void>();
      SnackbarService.showError(
        message: 'errors.errorTitle'.trns(),
        title: 'errors.unexpectedShort'.trns(),
      );
    }
  }

  bool get requiresProfileCompletion =>
      currentUser.value == null || !currentUser.value!.hasBasicDetails;

  static Future<void> forceLogout({bool showLogin = true}) async {
    if (_logoutInProgress.value) return;
    _logoutInProgress.value = true;

    try {
      await logout();
      if (Get.isRegistered<AuthService>()) {
        final service = Get.find<AuthService>();
        service.accessToken.value = null;
        service.currentUser.value = null;
      }
      // currentUser = null;
      if (showLogin && Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } finally {
      _logoutInProgress.value = false;
    }
  }

  static bool get isLogoutInProgress => _logoutInProgress.value;
  static RxBool get logoutInProgressObs => _logoutInProgress;
}
