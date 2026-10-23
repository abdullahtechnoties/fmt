import 'package:flutter/material.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Dummy Data Pre-fill
    nameController.text = ""; // Placeholder handles "Enter Full Name"
    phoneController.text = "";
    dobController.text = "12/08/1998";
    genderController.text = "Male";
  }

  void saveProfile() {
    SnackbarService.showSuccess(title: 'Success', message: 'Profile updated successfully');
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    genderController.dispose();
    super.onClose();
  }
}