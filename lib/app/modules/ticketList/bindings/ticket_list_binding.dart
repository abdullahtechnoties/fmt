import 'package:get/get.dart';

import '../controllers/ticket_list_controller.dart';

class TicketListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketListController>(
      () => TicketListController(),
    );
  }
}
