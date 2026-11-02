import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fmt/app/modules/cart/controllers/cart_controller.dart';
import 'package:fmt/repositories/chat_repository.dart';
import 'package:fmt/services/notification_resolver_service.dart';
import 'package:fmt/utilities/auth_guard.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

class BottomnavController extends GetxController
    with WidgetsBindingObserver {
    var tabIndex = 0.obs;

  /// Unread store-chat count shown on the message FAB. Login-only.

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
    unawaited(refreshChatBadge());
    if (index == cartTabIndex) {
      try {
        await Get.find<CartController>().refreshSilently();
      } catch (_) {}
    }
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final chatUnread = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    refreshChatBadge();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pushes are best-effort — resume always refreshes from the server.
    if (state == AppLifecycleState.resumed) {
      refreshChatBadge();
      try {
        NotificationResolverService.instance.refreshAll();
      } catch (_) {}
    }
  }

  Future<void> refreshChatBadge() async {
    if (!AuthGuard.isLoggedIn) {
      chatUnread.value = 0;
      return;
    }
    try {
      chatUnread.value = await ChatRepository().unreadCount();
    } catch (_) {}
  }


  
  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

}