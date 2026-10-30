class ApiPath {
  // ─── FMT Store App API (v1) ────────────────────────────────────────────────
  // Base URL: https://www.fmtonlinestore.com/api/v1
  // Auth: Laravel Sanctum (Bearer). Currency: PKR.
  static const String baseUrl = 'https://www.fmtonlinestore.com/api/v1';

  /// Fallback host used to resolve relative image paths.
  static const String imageUrl = 'https://www.fmtonlinestore.com/storage';

  // Bootstrap / app config
  static const String bootstrap = '/bootstrap';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String deleteAccount = '/auth/account';

  // Stores (branches)
  static const String stores = '/stores';
  static String storeDetail(String slug) => '/stores/$slug';
  static String storeProducts(String slug) => '/stores/$slug/products';

  // Catalog
  static const String home = '/home';
  static const String categories = '/categories';
  static const String products = '/products';
  static String productDetail(String slug) => '/products/$slug';
  static const String productSearch = '/search/products';
  static String productResolve(Object id) => '/products/resolve/$id';

  // Cart (guest + authed; server-side, identified by X-Cart-Token / Bearer)
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(String cartKey) => '/cart/items/$cartKey';
  static const String cartMerge = '/cart/merge';

  // Checkout & orders
  static const String checkoutSummary = '/checkout/summary';
  static const String orders = '/orders';
  static String orderDetail(Object id) => '/orders/$id';
  static String orderInvoice(Object id) => '/orders/$id/invoice';

  // Account
  static const String accountProfile = '/account/profile';
  static const String accountAddresses = '/account/addresses';
  static const String accountBillingAddress = '/account/addresses/billing';
  static const String accountDeliveryAddress = '/account/addresses/delivery';

  // Content
  static String page(String slug) => '/pages/$slug';
  static const String blogs = '/blogs';
  static String blogDetail(String slug) => '/blogs/$slug';
  static const String testimonials = '/testimonials';
  static const String contact = '/contact';

  // ─── Legacy (pre-FMT) endpoint constants ───────────────────────────────────
  // Kept so untouched modules still compile; they are migrated module-wise.

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
  static String userProfile(int userId) => '/users/$userId';
  static const String legacyDeleteAccount = '/users';

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
  static const String legacyProducts = '/products-legacy';
  static String productUpdate(Object id) => '/products/$id';
  static String productDelete(Object id) => '/products/$id';
  static String productToggleActive(Object id) => '/products/$id/toggle-active';

  // Cart Endpoints
  static const String legacyCart = '/cart-legacy';
  static const String legacyCartItems = '/cart-items';
  static String legacyCartItem(Object id) => '/cart-items/$id';

  // Voucher Endpoints
  static const String voucherApply = '/vouchers/apply';

  // Checkout / Order Endpoints
  static const String shippingMethodsActive = '/shipping-methods-active';
  static const String settings = '/settings';
  static String userDetail(Object id) => '/users/$id';
  static String orderPay(Object id) => '/orders/$id/pay';
  static String orderStripeConfirm(Object id) =>
      '/orders/$id/pay/stripe/confirm';
  static String orderReorder(Object id) => '/orders/$id/reorder';

  // Rating Endpoints
  static const String ratings = '/ratings';

  // Categories & Brands Endpoints
  static String categoryDetail(Object id) => '/categories/$id';
  static const String brands = '/brands';

  // Home Endpoints
  static const String banners = '/data/banners';
  static const String flashSalesRunning = '/flash-sales-running';

  // Wishlist Endpoints
  static const String wishlistToggle = '/wishlists';
  static const String wishlists = '/wishlists';
  static String wishlistDelete(int productId) =>
      '/wishlists/product/$productId';

  // Legacy auth Endpoints
  static const String legacyRegister = '/register';
  static const String verifyEmail = '/verify-email';
  static const String resendCode = '/resend-code';
  static const String legacyLogin = '/login';
  static const String legacyLogout = '/logout';
  static const String legacyForgotPassword = '/forgot-password';
  static const String legacyResetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String profileUpdate = '/profile/update';
  static const String profileComplete = '/profile';
  static const String sendResetCode = '/resend-code';
  static const String profileImage = '/profile/image';

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
