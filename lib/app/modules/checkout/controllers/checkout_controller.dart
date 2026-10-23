import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:get/get.dart';
// import 'package:fmt/widgets/snackbar_service.dart';

class CheckoutController extends GetxController {
  // Current Step: 0 = Shipping, 1 = Payment, 2 = Review
  final currentStep = 0.obs;

  // --- Shipping Form Controllers ---
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final postalController = TextEditingController();

  final selectedProvince = RxnString();
  final selectedCity = RxnString();

  final provinces = ['Sindh', 'Punjab', 'KPK', 'Balochistan'];
  final cities = ['Karachi', 'Lahore', 'Islamabad', 'Quetta'];

  // --- Payment Form Controllers ---
  final selectedCardType = 'paypal'.obs; // 'paypal' or 'gpay'
  final cardHolderController = TextEditingController();
  final expirationController = TextEditingController();
  final cvvController = TextEditingController();

  // --- Dummy Review Data ---
  final subtotal = 10300.0.obs;
  final shippingCost = 200.0.obs;
  double get total => subtotal.value + shippingCost.value;

  @override
  void onInit() {
    super.onInit();
    // Setting dummy data for the review screen to match design
    fullNameController.text = 'Umair Khan';
    phoneController.text = '000-0000000';
    streetController.text = 'XYZ Address';
    postalController.text = '75400';
    selectedProvince.value = 'Sindh';
    selectedCity.value = 'Karachi';
  }

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    } else {
      placeOrder();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    } else {
      Get.back(); // Go back to cart if on first step
    }
  }

  void selectPaymentMethod(String method) {
    selectedCardType.value = method;
  }

  void placeOrder() {
    // Utilize your SnackbarService
    // SnackbarService.showSuccess(
    //   title: 'Order Placed',
    //   message: 'Your order has been placed successfully!',
    // );
    
    Get.toNamed(Routes.ORDER_SUCCESS); // Example route navigation
  }
}