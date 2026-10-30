import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/repositories/auth_repository.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Signup mirrors the website fields exactly: name, email, whatsapp,
/// alternate_number, city, district, password + confirmation.
class SignupController extends GetxController {
  SignupController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final whatsappController = TextEditingController();
  final alternateNumberController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  /// Server-side field errors, keyed by API field name.
  final fieldErrors = <String, String?>{}.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  String? errorFor(String field) => fieldErrors[field];

  String? required(String? v) =>
      ((v ?? '').trim().isEmpty) ? 'auth.validation.required'.trns() : null;

  String? validateEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'auth.validation.emailRequired'.trns();
    if (!GetUtils.isEmail(t)) return 'auth.validation.emailInvalid'.trns();
    return null;
  }

  String? validatePhone(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'auth.validation.phoneRequired'.trns();
    if (t.length < 7) return 'auth.validation.phoneInvalid'.trns();
    return null;
  }

  String? validatePassword(String? v) {
    if ((v ?? '').isEmpty) return 'auth.validation.passwordRequired'.trns();
    if (v!.length < 6) return 'auth.validation.passwordMinLength'.trns();
    return null;
  }

  String? validateConfirm(String? v) {
    if ((v ?? '').isEmpty) {
      return 'auth.validation.confirmPasswordRequired'.trns();
    }
    if (v != passwordController.text) {
      return 'auth.validation.passwordMismatch'.trns();
    }
    return null;
  }

  Future<void> performSignUp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    fieldErrors.clear();
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final res = await _repository.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        whatsapp: whatsappController.text.trim(),
        alternateNumber: alternateNumberController.text.trim(),
        city: cityController.text.trim(),
        district: districtController.text.trim(),
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
        deviceName: 'android-app',
      );
      if (res.isError || res.data == null) {
        _mapErrors(res.errors);
        final fallback = (res.message ?? '').isNotEmpty
            ? res.message!
            : 'auth.signup.errorTitle'.trns();
        SnackbarService.showError(
          title: 'auth.signup.errorTitle'.trns(),
          message: fieldErrors.values.firstWhere(
            (e) => e != null && e.isNotEmpty,
            orElse: () => fallback,
          )!,
        );
        return;
      }
      await _repository.persistSession(res.data!);
      SnackbarService.showSuccess(
        title: 'auth.signup.successTitle'.trns(),
        message: 'auth.signup.successMessage'.trns(),
      );
      Get.offAllNamed(Routes.BOTTOMNAV);
    } finally {
      isLoading.value = false;
    }
  }

  void _mapErrors(Map<String, List<String>>? errors) {
    if (errors == null || errors.isEmpty) return;
    final mapped = <String, String?>{};
    errors.forEach((key, list) {
      if (list.isNotEmpty) mapped[key] = list.first;
    });
    fieldErrors.assignAll(mapped);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    whatsappController.dispose();
    alternateNumberController.dispose();
    cityController.dispose();
    districtController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
