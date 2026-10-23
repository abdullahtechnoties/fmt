import 'package:get/get.dart';

import '../controllers/menu_drawer_controller.dart';

class MenuDrawerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MenuDrawerController>(
      () => MenuDrawerController(),
    );
  }
}
