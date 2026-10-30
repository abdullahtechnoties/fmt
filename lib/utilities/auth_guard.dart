import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Central login gate for guest-visible surfaces (profile tab, checkout).
/// Returns true when the user is authenticated; otherwise shows a prompt
/// that routes to the login screen and returns false.
class AuthGuard {
  AuthGuard._();

  static bool get isLoggedIn {
    try {
      final auth = Get.find<AuthService>();
      if (auth.currentUser.value != null) return true;
    } catch (_) {}
    return AuthService.authenticated();
  }

  static Future<bool> requireLogin({
    String? title,
    String? message,
  }) async {
    if (isLoggedIn) return true;
    final go = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title ?? 'auth.required_title'.trns(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.darkGrey,
          ),
        ),
        content: Text(
          message ?? 'auth.required_message'.trns(),
          style: const TextStyle(color: AppColors.mediumGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.trns()),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'auth.login_btn'.trns(),
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
    if (go == true) {
      Get.toNamed(Routes.LOGIN);
    }
    return false;
  }
}
