import 'package:flutter/material.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {

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
    forgotPasswordEmailController.dispose();
    super.onClose();
  }
}
