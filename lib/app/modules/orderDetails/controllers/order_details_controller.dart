import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fmt/models/order_model.dart';
import 'package:fmt/models/payment_proof_model.dart';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/repositories/order_repository.dart';
import 'package:fmt/utilities/chat_navigator.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/payment_proof_viewer.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// One order fully broken down: `GET /orders/{id}` plus a fresh
/// `whatsapp_url` so the pending-confirmation step can be retried later.
/// The printable invoice comes from `GET /orders/{id}/invoice`.
///
/// Payment proof is optional. When the order has none, the customer can
/// attach one later with `POST /orders/{id}/payment-proof`; the returned
/// proof replaces any previous receipt.
class OrderDetailsController extends GetxController {
  OrderDetailsController({OrderRepository? orderRepo})
    : _orderRepo = orderRepo ?? OrderRepository();

  final OrderRepository _orderRepo;

  final Rxn<OrderDetail> detail = Rxn<OrderDetail>();
  final isLoading = true.obs;
  final RxnString loadError = RxnString();
  final isOpeningInvoice = false.obs;
  final isUploadingProof = false.obs;

  dynamic get orderId => Get.arguments;

  PaymentProof? get paymentProof => detail.value?.paymentProof;

  Map<String, String> get paymentProofHeaders =>
      Get.find<AuthService>().authHeaders;

  String? get paymentProofApiUrl {
    final proof = paymentProof;
    if (proof == null) return null;
    final api = (proof.apiUrl ?? '').trim();
    if (api.isNotEmpty) return api;
    final id = orderId;
    if (id == null) return null;
    return '${ApiPath.baseUrl}${ApiPath.orderPaymentProof(id)}';
  }

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
    final url = (detail.value?.whatsappUrl ?? '').trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Opens the in-app store chat with this order's confirmation message
  /// prefilled — mirrors the WhatsApp button for later follow-ups.
  Future<void> confirmOnChat() {
    final d = detail.value;
    if (d == null) return Future.value();
    final total = d.summary.total > 0 ? d.summary.total : d.subtotal;
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

  // ─── Payment proof ───────────────────────────────────────────────────────

  Future<void> pickPaymentProof() async {
    if (isUploadingProof.value) return;
    const rules = PaymentProofRules();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: rules.accepts,
        allowMultiple: false,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final error = rules.validateFile(name: file.name, size: file.size);
      if (error != null) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: _proofErrorMessage(error, rules),
        );
        return;
      }
      if ((file.path ?? '').isEmpty) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: 'payment_proof.pick_failed'.trns(),
        );
        return;
      }
      await _uploadPaymentProof(File(file.path!));
    } catch (_) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'payment_proof.pick_failed'.trns(),
      );
    }
  }

  Future<void> _uploadPaymentProof(File file) async {
    final id = orderId;
    if (id == null || isUploadingProof.value) return;
    isUploadingProof.value = true;
    try {
      final res = await _orderRepo.uploadPaymentProof(id, file);
      if (res.isError || res.data == null) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: (res.message?.isNotEmpty ?? false)
              ? res.message!
              : 'payment_proof.upload_failed'.trns(),
        );
        return;
      }
      detail.value = detail.value?.copyWith(paymentProof: res.data!);
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: (res.message?.isNotEmpty ?? false)
            ? res.message!
            : 'payment_proof.uploaded'.trns(),
      );
    } finally {
      isUploadingProof.value = false;
    }
  }

  void openPaymentProof() {
    final proof = paymentProof;
    final url = paymentProofApiUrl;
    if (proof == null || url == null || url.isEmpty) return;
    Get.to(
      () => PaymentProofViewerPage(
        url: url,
        headers: paymentProofHeaders,
        title: proof.name,
      ),
    );
  }

  String _proofErrorMessage(
    PaymentProofFileError error,
    PaymentProofRules rules,
  ) {
    switch (error) {
      case PaymentProofFileError.tooLarge:
        return 'payment_proof.too_large'.trnsFormat({'size': rules.maxMbLabel});
      case PaymentProofFileError.unsupportedType:
        return 'payment_proof.invalid_type'.trnsFormat({
          'types': rules.accepts.map((e) => e.toUpperCase()).join(', '),
        });
    }
  }
}
