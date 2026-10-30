import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/response/api_response.dart';
import 'package:fmt/network/service/local_storage.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:fmt/utilities/app_strings.dart';
import 'package:get/get.dart';

/// Server-side cart API (works for guests via `X-Cart-Token` and for
/// logged-in users via Bearer). Every response returns the full cart, so no
/// follow-up fetch is needed. `cart_token` is persisted on every response.
class CartRepository {
  CartRepository({NetworkService? network}) : _network = network ?? Get.find();

  final NetworkService _network;

  void _persistToken(Map<String, dynamic>? body) {
    try {
      final data = body?['data'];
      final token = data is Map ? data['cart_token']?.toString() : null;
      if (token != null && token.isNotEmpty) {
        LocalStorageService.prefs?.setString(AppStrings.cartToken, token);
      }
    } catch (_) {}
  }

  Future<ApiResponse<Map<String, dynamic>>> fetchCart() async {
    final res = await _network.get(endpoint: ApiPath.cart);
    _persistToken(res.data);
    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> addItem({
    required int productId,
    required int quantity,
    int? variantId,
    String? variantLabel,
  }) async {
    final res = await _network.post(
      endpoint: ApiPath.cartItems,
      body: {
        'product_id': productId,
        'quantity': quantity,
        if (variantId != null) 'variant_id': variantId,
        if (variantLabel != null && variantLabel.isNotEmpty)
          'variant_label': variantLabel,
      },
    );
    _persistToken(res.data);
    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> clear() async {
    final res = await _network.delete(endpoint: ApiPath.cart);
    _persistToken(res.data);
    return res;
  }

  /// Sets an absolute quantity (`PATCH /cart/items/{cart_key}`).
  /// Stock is enforced server-side — a 422 means the branch ran out and
  /// the message is display copy.
  Future<ApiResponse<Map<String, dynamic>>> updateQty({
    required String cartKey,
    required int quantity,
  }) async {
    final res = await _network.patch(
      endpoint: ApiPath.cartItem(cartKey),
      body: {'quantity': quantity},
    );
    _persistToken(res.data);
    return res;
  }

  /// Removes one line (`DELETE /cart/items/{cart_key}`).
  Future<ApiResponse<Map<String, dynamic>>> removeItem(
      String cartKey) async {
    final res = await _network.delete(endpoint: ApiPath.cartItem(cartKey));
    _persistToken(res.data);
    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> mergeGuestCart(
    String cartToken,
  ) async {
    return _network.post(
      endpoint: ApiPath.cartMerge,
      body: {'cart_token': cartToken},
    );
  }

  /// Number of lines in the server cart (for the branch-switch guard).
  int itemCount(Map<String, dynamic>? cartBody) {
    try {
      final data = cartBody?['data'];
      if (data is! Map) return 0;
      final totals = data['totals'];
      if (totals is Map) {
        final c = totals['items_count'] ?? totals['quantity'];
        if (c is num) return c.toInt();
      }
      final items = data['items'];
      if (items is List) return items.length;
    } catch (_) {}
    return 0;
  }
}
