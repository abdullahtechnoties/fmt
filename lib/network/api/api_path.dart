class ApiPath {
  // // Common Endpoints
  static const String baseUrl = 'https://orgina.screenlinktechnologies.com/api';
  static const String imageUrl = 'https://orgina.screenlinktechnologies.com/storage';
  
  // Local Endpoints
  // static const String baseUrl =
  //     'https://subregular-lauretta-nonprovocatively.ngrok-free.dev/api';
  // static const String imageUrl =
  //     'https://subregular-lauretta-nonprovocatively.ngrok-free.dev/storage';

  // Currency Converter Key
  static const String currencyConverterKey = '14e9eb5ef84310db91a22a8d';
  //Example Request: https://v6.exchangerate-api.com/v6/14e9eb5ef84310db91a22a8d/latest/USD

  /// Store totals are in this currency; bank-transfer conversion starts here.
  static const String storeBaseCurrency = 'CAD';

  /// Full external converter URL (NOT the app backend — call with raw Dio).
  static String currencyConverterLatest(String baseCode) =>
      'https://v6.exchangerate-api.com/v6/$currencyConverterKey/latest/$baseCode';

  // Bank Transfer Endpoints
  static const String bankTransferCurrencies = '/bank-transfer/currencies';
  static String orderBankTransferSubmit(Object id) =>
      '/orders/$id/pay/bank-transfer/submit';

  // Common Endpoints
  static const String getSetupFcm = '/users/fcm-token';
  static String userProfile(int userId) => '/users/$userId'  ;
  static const String deleteAccount = '/users';
  
  // Product Request Endpoints
  static const String productRequests = '/product-requests';
  static String productRequestDetails(int id) => '/product-requests/$id';
  static String productRequestUpdate(int id) => '/product-requests/$id';
  static String productRequestDelete(int id) => '/product-requests/$id';

  // Vendor Product Request Endpoints (assigned requests accept/reject flow)
  static const String vendorProductRequests = '/vendor/product-requests';
  static String vendorProductRequestDetail(Object id) =>
      '/vendor/product-requests/$id';
  static String vendorProductRequestComplete(Object id) =>
      '/vendor/product-requests/$id/complete';
  static String vendorProductRequestCancel(Object id) =>
      '/vendor/product-requests/$id/cancel';

  // Lookup Endpoints
  static const String brandLookup = '/data/brands';
  static const String productFilters = '/data/filters';

  // Vendor product form lookups (dynamic dropdowns)
  static const String dataCategories = '/data/categories';
  static const String dataUnits = '/data/units';
  static const String dataTags = '/data/tags';
  static const String dataAttributes = '/data/attributes';

  // Product Endpoints
  static const String products = '/products';
  static String productDetail(Object id) => '/products/$id';
  static String productUpdate(Object id) => '/products/$id';
  static String productDelete(Object id) => '/products/$id';
  static String productToggleActive(Object id) => '/products/$id/toggle-active';

  // Cart Endpoints
  static const String cart = '/cart';
  static const String cartItems = '/cart-items';
  static String cartItem(Object id) => '/cart-items/$id';

  // Voucher Endpoints
  static const String voucherApply = '/vouchers/apply';

  // Checkout / Order Endpoints
  static const String shippingMethodsActive = '/shipping-methods-active';
  static const String settings = '/settings';
  static String userDetail(Object id) => '/users/$id';
  static const String orders = '/orders';
  static String orderPay(Object id) => '/orders/$id/pay';
    static String orderStripeConfirm(Object id) => '/orders/$id/pay/stripe/confirm';
  static String orderDetail(Object id) => '/orders/$id';
  static String orderReorder(Object id) => '/orders/$id/reorder';

  // Rating Endpoints
  static const String ratings = '/ratings';

  // Categories & Brands Endpoints
  static const String categories = '/categories';
  static String categoryDetail(Object id) => '/categories/$id';
  static const String brands = '/brands';

  // Home Endpoints
  static const String banners = '/data/banners';
  static const String flashSalesRunning = '/flash-sales-running';

  // Wishlist Endpoints
  static const String wishlistToggle = '/wishlists';
  static const String wishlists = '/wishlists';
  static String wishlistDelete(int productId) => '/wishlists/product/$productId';

  // Auth Endpoints
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String resendCode = '/resend-code';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String profileUpdate = '/profile/update';
  static const String profileComplete = '/profile';
  static const String sendResetCode = '/resend-code';
  static const String profileImage = '/profile/image';


  // Geo (Unauthenticated)
  // static const String countries = '/countries';
  // static String countryStates(int countryId) => '/states?country_id=$countryId';
  // static String stateCities(int stateId) => '/cities?state_id=$stateId';
  // static String cityAreas(int cityId) => '/areas?city_id=$cityId';

  // Shipping Address Endpoints
  static const String shippingAddresses = '/shipping-addresses';
  static String shippingAddress(Object id) => '/shipping-addresses/$id';
  static String shippingAddressSetDefault(Object id) =>
      '/shipping-addresses/$id/set-default';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(int id) => '/notifications/read/$id';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Vendor onboarding (authenticated — token is available right after login,
  // even before the vendor is approved/paid).
  static const String vendorOnboardingStatus = '/vendor-onboarding-status';
  static const String plansActive = '/plans-active';
  static const String googleVerifyPayment = '/google/verify-payment';
  static const String vendorProfiles = '/vendor-profiles-me';
  static const String vendorProfile = '/vendor-profiles';
  static String vendorProfileUpdate(Object id) => '/vendor-profiles/$id';

  // Vendor orders (tab: processing (default), delivered, cancelled)
  static const String vendorOrders = '/vendor/orders';
  static String vendorOrderDetail(Object id) => '/vendor/orders/$id';
  static String vendorOrderStatus(Object id) => '/vendor/orders/$id/status';

  // Vendor dashboard (?range=today|yesterday|this_week|this_month|this_year)
  static const String vendorDashboard = '/dashboard';

}

