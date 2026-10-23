import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final forgotPasswordEmailController = TextEditingController();

  // State
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // Dummy Methods
  Future<void> performLogin() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    SnackbarService.showSuccess(
      title: 'Success', 
      message: 'Logged in gracefully!'
    );
    // Get.offAllNamed(Routes.HOME);
  }

  Future<void> performSignUp() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    SnackbarService.showSuccess(
      title: 'Success', 
      message: 'Account created successfully!'
    );
    Get.toNamed(Routes.BOTTOMNAV);
  }

  Future<void> performForgotPassword() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    SnackbarService.showSuccess(
      title: 'Email Sent', 
      message: 'Check your email to reset password.'
    );
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    forgotPasswordEmailController.dispose();
    super.onClose();
  }
}
