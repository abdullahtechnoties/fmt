import 'package:flutter/material.dart';
import 'package:fmt/repositories/auth_repository.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Forgot password: emails a reset link to `email` — no in-app reset.
/// Unknown addresses return 422, mapped onto the field.
class ForgotPasswordController extends GetxController {
  ForgotPasswordController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final emailError = Rx<String?>(null);
  final emailSent = false.obs;

  String? validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'auth.validation.emailRequired'.trns();
    if (!GetUtils.isEmail(v)) return 'auth.validation.emailInvalid'.trns();
    return null;
  }

  Future<void> performForgotPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    emailError.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final res = await _repository.forgotPassword(
        email: emailController.text.trim(),
      );
      if (res.isError) {
        final errors = res.errors;
        if (errors != null && errors['email']?.isNotEmpty == true) {
          emailError.value = errors['email']!.first;
        }
        SnackbarService.showError(
          title: 'auth.forgot.errorTitle'.trns(),
          message: emailError.value ?? (res.message ?? ''),
        );
        return;
      }
      emailSent.value = true;
      SnackbarService.showSuccess(
        title: 'auth.forgot.successTitle'.trns(),
        message: (res.message?.isNotEmpty ?? false)
            ? res.message!
            : 'auth.forgot.successMessage'.trns(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
