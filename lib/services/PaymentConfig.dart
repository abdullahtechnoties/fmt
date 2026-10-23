class PaymentConfig {
  PaymentConfig._();

  /// Fallback publishable key (the pay API also returns one per order).
  static String get stripePublishableKey =>
      'pk_test_51Rmhzh8zdCrsdJ0ThPGERsfrIRci60ujwB3AXAeByBp2diMk8iJClDs36iNIp5aZoTQNykJaUyBVhA36Lo9Q7R4d00vAwgUtol';

  static String get merchantDisplayName => 'fmt';

  static String get preferredPaymentMethodKey => 'preferredPaymentMethod';

  /// URL markers the PayPal webview watches to detect approve / cancel.
  /// Align these with the backend's return/cancel URLs if they differ.
  static String get paypalSuccessMarker => '/orders/paypal/return';
  static String get paypalCancelMarker => '/orders/paypal/cancelled';
}
