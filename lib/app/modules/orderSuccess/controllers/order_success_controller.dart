import 'package:fmt/app/routes/app_pages.dart';
import 'package:get/get.dart';


class OrderSuccessController extends GetxController {
  
  void onContinueShopping() {
    // Navigate back to home or bottom navigation wrapper gracefully
    // Get.offAllNamed(Routes.HOME); 
    Get.offAllNamed(Routes.BOTTOMNAV); // Dummy action for now
  }
}