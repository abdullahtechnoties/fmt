import 'package:flutter/material.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  void savePassword() {
    if (newPasswordController.text != repeatPasswordController.text) {
      SnackbarService.showError(title: 'Error', message: 'Passwords do not match');
      return;
    }
    SnackbarService.showSuccess(title: 'Success', message: 'Password changed successfully');
    Get.back();
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    repeatPasswordController.dispose();
    super.onClose();
  }
}