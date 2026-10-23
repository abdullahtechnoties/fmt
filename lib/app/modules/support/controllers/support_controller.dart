import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:get/get.dart';

class SupportController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final issueController = TextEditingController();
  
  final selectedCategory = Rxn<String>();
  final categories = ['General Inquiry', 'Order Issue', 'Payment Problem', 'Other'];

  void submitTicket() {
    // Dummy validation
    // if (nameController.text.isEmpty || issueController.text.isEmpty) {
    //   SnackbarService.showError(title: 'Error', message: 'Please fill all fields');
    //   return;
    // }
    
    SnackbarService.showSuccess(title: 'Success', message: 'Ticket submitted successfully');

    Get.toNamed(Routes.CHAT); // Navigate to a success page or show a dialog
    
    // Clear form
    nameController.clear();
    emailController.clear();
    subjectController.clear();
    issueController.clear();
    selectedCategory.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    issueController.dispose();
    super.onClose();
  }
}