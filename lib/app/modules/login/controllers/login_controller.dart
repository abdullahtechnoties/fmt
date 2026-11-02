import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/network/service/local_storage.dart';
import 'package:fmt/services/notification_service.dart';
import 'package:fmt/repositories/auth_repository.dart';
import 'package:fmt/utilities/app_strings.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Email **or** WhatsApp login — the API defaults to email; sending
/// `login_type: "whatsapp"` with a `whatsapp` field switches modes.
/// Wrong credentials return 422 keyed on `email`/`whatsapp` (not 401), so
/// field errors are mapped onto the form.
class LoginController extends GetxController {
  LoginController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  final formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final isWhatsappMode = false.obs;

  final loginError = Rx<String?>(null);
  final passwordError = Rx<String?>(null);

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void setWhatsappMode(bool value) {
    if (isWhatsappMode.value == value) return;
    isWhatsappMode.value = value;
    loginError.value = null;
  }

  bool get _isEmailInput {
    final v = loginController.text.trim();
    return v.contains('@');
  }

  String? validateLogin(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'auth.validation.loginRequired'.trns();
    if (isWhatsappMode.value) {
      if (v.contains('@')) return 'auth.validation.phoneInvalid'.trns();
      if (v.length < 7) return 'auth.validation.phoneInvalid'.trns();
      return null;
    }
    if (_isEmailInput) {
      if (!GetUtils.isEmail(v)) return 'auth.validation.emailInvalid'.trns();
      return null;
    }
    if (v.length < 7) return 'auth.validation.loginInvalid'.trns();
    return null;
  }

  String? validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'auth.validation.passwordRequired'.trns();
    if (value!.length < 6) return 'auth.validation.passwordMinLength'.trns();
    return null;
  }

  Future<void> performLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();
    loginError.value = null;
    passwordError.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final login = loginController.text.trim();
      final password = passwordController.text;
      final res = (isWhatsappMode.value || !_isEmailInput)
          ? await _repository.loginWithWhatsapp(
              whatsapp: login,
              password: password,
            )
          : await _repository.loginWithEmail(
              email: login,
              password: password,
            );
      if (res.isError || res.data == null) {
        _mapErrors(res.errors);
        final fallback = (res.message ?? '').isNotEmpty
            ? res.message!
            : 'auth.login.errorTitle'.trns();
        SnackbarService.showError(
          title: 'auth.login.errorTitle'.trns(),
          message: loginError.value ?? passwordError.value ?? fallback,
        );
        return;
      }
      await _repository.persistSession(res.data!);
      // Register this handset for order + chat pushes (token is the
      // server-side unique key, so re-registering updates in place).
      try {
        await FmtNotificationService.instance.refreshToken();
      } catch (_) {}
      // A successful login ends guest mode.
      await LocalStorageService.prefs?.setBool(AppStrings.guestMode, false);
      SnackbarService.showSuccess(
        title: 'auth.login.successTitle'.trns(),
        message: 'auth.login.successMessage'.trns(),
      );
      Get.offAllNamed(Routes.BOTTOMNAV);
    } finally {
      isLoading.value = false;
    }
  }

  void _mapErrors(Map<String, List<String>>? errors) {
    if (errors == null || errors.isEmpty) return;
    String? first(List<String>? list) =>
        (list != null && list.isNotEmpty) ? list.first : null;
    loginError.value = first(errors['email']) ??
        first(errors['whatsapp']) ??
        first(errors['login']);
    passwordError.value = first(errors['password']);
  }

  void continueAsGuest() {
    LocalStorageService.prefs?.setBool(AppStrings.guestMode, true);
    Get.offAllNamed(Routes.BOTTOMNAV);
  }

  @override
  void onClose() {
    loginController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
