import 'package:flutter/material.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/repositories/account_repository.dart';
import 'package:fmt/utilities/navigation_helper.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Change password via `PUT /account/profile` with the password trio —
/// profile fields are left untouched when only these keys are sent.
class ChangePasswordController extends GetxController {
  ChangePasswordController({AccountRepository? accountRepo})
      : _accountRepo = accountRepo ?? AccountRepository();

  final AccountRepository _accountRepo;

  final formKey = GlobalKey<FormState>();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  final isSaving = false.obs;

  final obscureOld = true.obs;
  final obscureNew = true.obs;
  final obscureRepeat = true.obs;

  String? requiredValidator(String? v) {
    if ((v ?? '').isEmpty) {
      return 'auth.validation.required'.trns();
    }
    return null;
  }

  String? newPasswordValidator(String? v) {
    if ((v ?? '').isEmpty) {
      return 'auth.validation.passwordRequired'.trns();
    }
    if (v!.length < 6) {
      return 'auth.validation.passwordMinLength'.trns();
    }
    return null;
  }

  String? repeatValidator(String? v) {
    if ((v ?? '').isEmpty) {
      return 'auth.validation.confirmPasswordRequired'.trns();
    }
    if (v != newPasswordController.text) {
      return 'auth.validation.passwordMismatch'.trns();
    }
    return null;
  }

  Future<void> savePassword() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      // PUT /account/profile requires the full profile (name/email/contact)
      // even for a password-only change — resend the current values with
      // the trio. Cached session first, fresh fetch as fallback.
      var user = Get.find<AuthService>().currentUser.value;
      user ??= (await _accountRepo.profile()).data;
      final email = (user?.email ?? '').trim();
      if (user == null || email.isEmpty) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: 'password.save_failed'.trns(),
        );
        return;
      }
      final res = await _accountRepo.changePassword(
        name: (user.name ?? '').trim(),
        email: email,
        contact: (user.contact ?? '').trim(),
        alternateNumber: user.alternateNumber,
        currentPassword: oldPasswordController.text,
        password: newPasswordController.text,
        passwordConfirmation: repeatPasswordController.text,
      );
      if (res.isError) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: (res.message?.isNotEmpty ?? false)
              ? res.message!
              : 'password.save_failed'.trns(),
        );
        return;
      }
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: (res.message?.isNotEmpty ?? false)
            ? res.message!
            : 'password.saved'.trns(),
      );
      // Get.back();
      NavigationHelper.safePop(Get.context!);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    repeatPasswordController.dispose();
    super.onClose();
  }
}
