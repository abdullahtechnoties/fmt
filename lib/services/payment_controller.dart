import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:fmt/network/service/local_storage.dart';
import 'package:fmt/services/PaymentConfig.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';

/// Stripe (payment-sheet) + preference persistence used by checkout.
class PaymentController extends GetxController {
  final RxBool isProcessing = false.obs;

  final RxString preferredMethod = 'stripe'.obs;

  static PaymentController get to {
    if (Get.isRegistered<PaymentController>()) {
      return Get.find<PaymentController>();
    }
    return Get.put(PaymentController(), permanent: true);
  }

  @override
  void onInit() {
    super.onInit();
    final saved = LocalStorageService.prefs?.getString(
      PaymentConfig.preferredPaymentMethodKey,
    );
    if (saved == 'stripe' || saved == 'paypal') {
      preferredMethod.value = saved!;
    }
  }

  Future<void> setPreferredMethod(String method) async {
    if (method != 'stripe' && method != 'paypal') return;
    preferredMethod.value = method;
    await LocalStorageService.prefs?.setString(
      PaymentConfig.preferredPaymentMethodKey,
      method,
    );
  }

  /// Presents Stripe's own bottom sheet for [clientSecret].
  /// Returns true when the sheet completes (backend confirms via webhook /
  /// the already-created order flips to paid — the order screen polls or the
  /// success page is shown optimistically by the caller).
  Future<bool> payWithStripe({
    required String clientSecret,
    String? publishableKey,
  }) async {
    if (isProcessing.value) return false;
    isProcessing.value = true;

    try {
      final key = (publishableKey ?? '').trim().isNotEmpty
          ? publishableKey!.trim()
          : PaymentConfig.stripePublishableKey;
      Stripe.publishableKey = key;
      await Stripe.instance.applySettings();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: PaymentConfig.merchantDisplayName,
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await setPreferredMethod('stripe');
      return true;
    } on StripeException catch (e) {
      final msg = e.error.localizedMessage ??
          'checkout.stripe_cancelled'.trns();
      // User-cancelled sheets are not errors worth alarming about.
      if (e.error.code != FailureCode.Canceled) {
        SnackbarService.showError(
          title: 'checkout.stripe_title'.trns(),
          message: msg,
        );
      }
      return false;
    } catch (e) {
      SnackbarService.showError(
        title: 'checkout.stripe_title'.trns(),
        message: e.toString(),
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
}
