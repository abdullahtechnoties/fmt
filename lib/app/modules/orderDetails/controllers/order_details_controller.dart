import 'package:fmt/models/order_model.dart';
import 'package:fmt/repositories/order_repository.dart';
import 'package:fmt/utilities/chat_navigator.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// One order fully broken down: `GET /orders/{id}` plus a fresh
/// `whatsapp_url` so the pending-confirmation step can be retried later.
/// The printable invoice comes from `GET /orders/{id}/invoice`.
class OrderDetailsController extends GetxController {
  OrderDetailsController({OrderRepository? orderRepo})
      : _orderRepo = orderRepo ?? OrderRepository();

  final OrderRepository _orderRepo;

  final Rxn<OrderDetail> detail = Rxn<OrderDetail>();
  final isLoading = true.obs;
  final RxnString loadError = RxnString();
  final isOpeningInvoice = false.obs;

  dynamic get orderId => Get.arguments;

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    final id = orderId;
    if (id == null) {
      loadError.value = 'order_details.load_failed'.trns();
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    loadError.value = null;
    try {
      final res = await _orderRepo.orderDetail(id);
      if (res.isError || res.data == null) {
        loadError.value = (res.message?.isNotEmpty ?? false)
            ? res.message
            : 'order_details.load_failed'.trns();
        return;
      }
      detail.value = res.data;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openWhatsapp() async {
    final url = (detail.value?.whatsappUrl ?? '').trim();    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Opens the in-app store chat with this order's confirmation message
  /// prefilled — mirrors the WhatsApp button for later follow-ups.
  Future<void> confirmOnChat() {
    final d = detail.value;
    if (d == null) return Future.value();
    final total =
        d.summary.total > 0 ? d.summary.total : d.subtotal;
    return ChatNavigator.confirmOrderOnChat(
      orderId: d.summary.id,
      total: total,
    );
  }

  Future<void> openInvoice() async {
    final id = orderId;
    if (id == null || isOpeningInvoice.value) return;
    isOpeningInvoice.value = true;
    try {
      final res = await _orderRepo.invoiceUrl(id);
      if (res.isError || res.data == null) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: (res.message?.isNotEmpty ?? false)
              ? res.message!
              : 'order_details.invoice_failed'.trns(),
        );
        return;
      }
      final uri = Uri.tryParse(res.data!);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } finally {
      isOpeningInvoice.value = false;
    }
  }
}
