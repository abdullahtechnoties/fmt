import 'package:flutter/material.dart';
import 'package:fmt/app/modules/cart/controllers/cart_controller.dart';
import 'package:fmt/utilities/auth_guard.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

class BottomnavController extends GetxController {
    var tabIndex = 0.obs;

  static const int cartTabIndex = 2;
  static const int profileTabIndex = 3;

  /// Profile needs a login — guests get the auth prompt and stay put.
  /// Opening the cart tab silently refreshes it so the user sees fresh data.
  Future<void> changeTabIndex(int index) async {
    if (index == profileTabIndex) {
      final allowed = await AuthGuard.requireLogin(
        title: 'auth.required_title'.trns(),
        message: 'auth.required_profile'.trns(),
      );
      if (!allowed) return;
    }
    tabIndex.value = index;
    if (index == cartTabIndex) {
      try {
        await Get.find<CartController>().refreshSilently();
      } catch (_) {}
    }
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  
  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

}