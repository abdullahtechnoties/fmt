import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/utilities/chat_navigator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Order confirmation. Arguments from checkout:
/// `{orderId, status, total, paymentMethod, whatsappUrl}`.
///
/// No back navigation (PopScope): the cart was emptied server-side, so
/// returning could show a stale state. The WhatsApp button opens the
/// prefilled confirmation chat — the order stays pending until the
/// customer messages the store and pays the advance.
class OrderSuccessController extends GetxController {
  final orderId = Rxn<dynamic>();
  final status = 'pending'.obs;
  final total = 0.0.obs;
  final paymentMethod = 'COD'.obs;
  final whatsappUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      orderId.value = args['orderId'];
      final s = args['status']?.toString().trim();
      if (s != null && s.isNotEmpty) status.value = s;
      final t = args['total'];
      if (t is num) {
        total.value = t.toDouble();
      } else if (t != null) {
        total.value = double.tryParse('$t') ?? 0;
      }
      final pm = args['paymentMethod']?.toString().trim();
      if (pm != null && pm.isNotEmpty) paymentMethod.value = pm;
      final wa = args['whatsappUrl']?.toString().trim();
      if (wa != null && wa.isNotEmpty) whatsappUrl.value = wa;
    }
  }

  bool get hasWhatsapp =>
      (whatsappUrl.value ?? '').trim().isNotEmpty;

  Future<void> openWhatsapp() async {    final url = (whatsappUrl.value ?? '').trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Opens the in-app store chat with the order-confirmation message
  /// prefilled — the WhatsApp button stays as the parallel option.
  Future<void> confirmOnChat() {
    return ChatNavigator.confirmOrderOnChat(
      orderId: orderId.value,
      total: total.value,
    );
  }

  void onContinueShopping() {
    Get.offAllNamed(Routes.BOTTOMNAV);
  }
}
