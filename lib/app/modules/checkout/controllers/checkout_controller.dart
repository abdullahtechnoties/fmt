import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/cart_model.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/repositories/cart_repository.dart';
import 'package:fmt/repositories/checkout_repository.dart';
import 'package:fmt/services/store_service.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// 3-step checkout (shipping → COD payment → review) wired to
/// `GET /checkout/summary` and `POST /orders`.
///
/// Step 1 fields map 1:1 to the API's billing_* payload and prefill from
/// the saved address + logged-in user. Step 2 is Cash on Delivery only —
/// the API has no gateway; card methods stay commented out in the view
/// until the backend supports them. Success routes to ORDER_SUCCESS with
/// the order + prefilled WhatsApp deep link.
class CheckoutController extends GetxController {
  CheckoutController({
    CheckoutRepository? checkoutRepo,
    CartRepository? cartRepo,
  })  : _checkoutRepo = checkoutRepo ?? CheckoutRepository(),
        _cartRepo = cartRepo ?? CartRepository();

  final CheckoutRepository _checkoutRepo;
  final CartRepository _cartRepo;

  // Current Step: 0 = Shipping, 1 = Payment, 2 = Review
  final currentStep = 0.obs;

  final isLoadingSummary = true.obs;
  final isPlacingOrder = false.obs;
  final RxnString summaryError = RxnString();

  final Rx<CheckoutSummary> summary = const CheckoutSummary().obs;
  final RxList<CartLine> lines = <CartLine>[].obs;
  final Rx<CartTotals> totals = const CartTotals().obs;

  // --- Step 1: Shipping / billing form ---
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final countryController = TextEditingController();
  final postalController = TextEditingController();
  final notesController = TextEditingController();

  // --- Step 2: Payment (COD only for v1) ---
  final selectedPaymentMethod = 'COD'.obs;

  // --- Step 3: Review acknowledgement (required to place the order) ---
  final agreedToConfirm = false.obs;

  AuthService get _auth => Get.find<AuthService>();
  StoreService get _storeService => Get.find<StoreService>();

  // Kept while the legacy design still binds dropdowns elsewhere.
  final provinces = ['Sindh', 'Punjab', 'KPK', 'Balochistan'];
  final cities = ['Karachi', 'Lahore', 'Islamabad', 'Quetta'];

  @override
  void onInit() {
    super.onInit();
    countryController.text = 'Pakistan';
    _prefillFromUser();
    loadSummary();
  }

  void _prefillFromUser() {
    final user = _auth.currentUser.value;
    if (user == null) return;
    if (fullNameController.text.isEmpty) {
      fullNameController.text = user.displayName;
    }
    if (emailController.text.isEmpty && (user.email ?? '').isNotEmpty) {
      emailController.text = user.email!;
    }
    if (phoneController.text.isEmpty && (user.contact ?? '').isNotEmpty) {
      phoneController.text = user.contact!;
    }
    if (cityController.text.isEmpty && (user.city ?? '').isNotEmpty) {
      cityController.text = user.city!;
    }
  }

  Future<void> loadSummary() async {
    isLoadingSummary.value = true;
    summaryError.value = null;
    try {
      final res = await _checkoutRepo.summary();
      if (res.isError || res.data == null) {
        summaryError.value = (res.message?.isNotEmpty ?? false)
            ? res.message
            : 'checkout.summary_failed'.trns();
        return;
      }
      final parsed = CheckoutSummary.fromBody(res.data);
      summary.value = parsed;
      if (parsed.cart != null) {
        lines.assignAll(parsed.cart!.items);
        totals.value = parsed.cart!.totals;
      } else {
        // Summary carries no cart → fall back to the live server cart.
        final cart = await _cartRepo.fetchCart();
        final data = CartData.fromBody(cart.data);
        if (data != null) {
          lines.assignAll(data.items);
          totals.value = data.totals;
        }
      }
      _prefillFromSavedAddress(parsed.savedAddress);
      summaryError.value = null;
    } finally {
      isLoadingSummary.value = false;
    }
  }

  void _prefillFromSavedAddress(Map<String, dynamic> a) {
    if (a.isEmpty) return;
    void fill(TextEditingController c, List<String> keys) {
      if (c.text.isNotEmpty) return;
      for (final k in keys) {
        final v = a[k]?.toString().trim() ?? '';
        if (v.isNotEmpty) {
          c.text = v;
          return;
        }
      }
    }

    fill(fullNameController, ['name', 'full_name', 'billing_name']);
    fill(emailController, ['email', 'billing_email']);
    fill(phoneController,
        ['phone', 'billing_phone', 'contact', 'whatsapp', 'mobile']);
    // Street prefers the delivery line the customer typed in the delivery
    // sheet, then the billing block. City also accepts `district` (the
    // register form stores district where the address record stores city).
    fill(streetController, [
      'delivery_address',
      'shipping_address',
      'address',
      'street',
      'billing_address'
    ]);
    fill(cityController, ['city', 'billing_city', 'district']);
    fill(provinceController, ['province', 'billing_province', 'state']);
    fill(countryController, ['country', 'billing_country']);
    fill(postalController, ['zip', 'postal_code', 'billing_zip']);
  }

  // ─── Step navigation ─────────────────────────────────────────────────────

  void nextStep() {
    if (currentStep.value == 0) {
      if (!(formKey.currentState?.validate() ?? false)) return;
      currentStep.value = 1;
    } else if (currentStep.value == 1) {
      currentStep.value = 2;
    } else {
      placeOrder();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  String? requiredValidator(String? v) {
    if ((v ?? '').trim().isEmpty) {
      return 'auth.validation.required'.trns();
    }
    return null;
  }

  String? emailValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'auth.validation.required'.trns();
    if (!GetUtils.isEmail(value)) {
      return 'auth.validation.emailInvalid'.trns();
    }
    return null;
  }

  String? phoneValidator(String? v) {
    if (((v ?? '').trim()).length < 7) {
      return 'auth.validation.phoneInvalid'.trns();
    }
    return null;
  }

  // ─── Place order ─────────────────────────────────────────────────────────

  Future<void> placeOrder() async {
    if (isPlacingOrder.value || lines.isEmpty) return;
    if (!agreedToConfirm.value) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'checkout.confirm_ack_required'.trns(),
      );
      return;
    }
    isPlacingOrder.value = true;
    try {
      final res = await _checkoutRepo.placeOrder(
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: streetController.text.trim(),
        city: cityController.text.trim(),
        province: provinceController.text.trim(),
        country: countryController.text.trim().isEmpty
            ? 'Pakistan'
            : countryController.text.trim(),
        paymentMethod: selectedPaymentMethod.value,
        zip: postalController.text.trim(),
        notes: notesController.text.trim(),
        storeId: _storeService.selectedStoreId,
      );
      if (res.isError || res.data == null) {
        SnackbarService.showError(
          title: 'checkout.order_failed_title'.trns(),
          message: (res.message?.isNotEmpty ?? false)
              ? res.message!
              : 'checkout.order_failed'.trns(),
        );
        return;
      }
      final order = PlacedOrder.fromBody(res.data);
      Get.offNamed(
        Routes.ORDER_SUCCESS,
        arguments: {
          'orderId': order.id,
          'status': order.status ?? 'pending',
          'total': order.total,
          'paymentMethod': order.paymentMethod ?? 'COD',
          'whatsappUrl': order.whatsappUrl,
        },
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    countryController.dispose();
    postalController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
